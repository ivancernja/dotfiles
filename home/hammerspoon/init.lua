-- Window and Space helpers.
-- Page Up / Page Down move a Space, ctrl+alt+cmd+R rescues stranded windows,
-- ctrl+alt+cmd+M almost-maximizes, and new windows size themselves.

-- Page Up and Page Down move one macOS Space left or right.
-- hs.spaces switches directly; synthesized ctrl+arrow is the fallback, because
-- macOS does not always act on a synthetic key for Spaces.
local pageLog = os.getenv("HOME") .. "/.hammerspoon/pagekeys.log"
local function note(msg)
  local f = io.open(pageLog, "a")
  if f then
    f:write(os.date("%H:%M:%S ") .. msg .. "\n")
    f:close()
  end
end

local function moveSpace(dir)
  local ok, err = pcall(function()
    local uuid = hs.screen.mainScreen():getUUID()
    local all = hs.spaces.spacesForScreen(uuid) or {}
    local cur = hs.spaces.activeSpaceOnScreen(uuid)
    local idx
    for i, s in ipairs(all) do
      if s == cur then idx = i end
    end
    if idx then
      local target = all[idx + (dir == "right" and 1 or -1)]
      if target then
        local gok, gerr = hs.spaces.gotoSpace(target)
        if not gok then
          note("gotoSpace failed: " .. tostring(gerr))
        end
        return
      end
      return
    end
    note("current space not found, using the key instead")
    hs.eventtap.keyStroke({ "ctrl" }, dir == "right" and "right" or "left", 20000)
  end)
  if not ok then
    note("hs.spaces failed: " .. tostring(err) .. ", using the key instead")
    hs.eventtap.keyStroke({ "ctrl" }, dir == "right" and "right" or "left", 20000)
  end
end

local pageUpHotkey = hs.hotkey.bind({}, "pageup", function() moveSpace("left") end)
local pageDownHotkey = hs.hotkey.bind({}, "pagedown", function() moveSpace("right") end)

-- Re-enable defensively in case another app temporarily shadows either key.
local hotkeyGuard = hs.timer.doEvery(30, function()
  pageUpHotkey:enable()
  pageDownHotkey:enable()
end)

-- Start Hammerspoon at login.
hs.autoLaunch(true)

-- Bring stranded windows back.
-- The tiling-manager experiments left windows parked a pixel from the right edge, or with
-- their title bar above the screen, so they could not be clicked or dragged back. macOS has
-- no way to move those without Accessibility, which Hammerspoon already holds.
--
-- Two things make this harder than it looks. hs.window.allWindows() only sees the Space that
-- is showing, so the sweep walks every Space and returns to where it started. And a minimized
-- window cannot be repositioned at all, so each Space is un-minimized first, then moved.
local function isStranded(f, screen)
  -- Nothing left to grab: the window sits past an edge, or its title bar is above the top.
  return f.x >= screen.x + screen.w - 60
      or f.y >= screen.y + screen.h - 60
      or f.x + f.w <= screen.x + 60
      or f.y < screen.y - 5
end

local function candidates(screen)
  local found = {}
  local lists = { hs.window.allWindows(), hs.window.minimizedWindows() or {} }
  local seen = {}
  for _, list in ipairs(lists) do
    for _, win in ipairs(list) do
      local ok = pcall(function()
        local id = win:id()
        if not id or seen[id] then return end
        -- Some apps (Granola) use a window type Hammerspoon does not call standard. A
        -- titled window is still a real one, so only untitled non-standard panels and
        -- HUDs are skipped.
        if win:isFullScreen() then return end
        if not win:isStandard() and (win:title() or "") == "" then return end
        local f = win:frame()
        if f.w < 120 or f.h < 80 then return end
        if not isStranded(f, screen) then return end
        seen[id] = true
        table.insert(found, win)
      end)
      if not ok then note("could not inspect a window") end
    end
  end
  return found
end

local function rescueHere(step, done)
  local screen = hs.screen.mainScreen():frame()
  local found = candidates(screen)
  if #found == 0 then return done(0) end

  for _, win in ipairs(found) do
    pcall(function()
      if win:isMinimized() then win:unminimize() end
    end)
  end

  -- Un-minimizing is animated; the window is not addressable until it finishes.
  hs.timer.doAfter(0.5, function()
    local rescued = 0
    for _, win in ipairs(found) do
      pcall(function()
        local f = win:frame()
        win:setFrame({
          x = screen.x + 40 + ((step + rescued) % 5) * 24,
          y = screen.y + 30 + ((step + rescued) % 5) * 24,
          w = math.min(f.w, screen.w - 80),
          h = math.min(f.h, screen.h - 80),
        })
        rescued = rescued + 1
      end)
    end
    done(rescued)
  end)
end

local function rescueWindows()
  local uuid = hs.screen.mainScreen():getUUID()
  local spaces = hs.spaces.spacesForScreen(uuid) or {}
  local startSpace = hs.spaces.activeSpaceOnScreen(uuid)
  local total, index = 0, 1

  local function nextSpace()
    if index > #spaces then
      hs.spaces.gotoSpace(startSpace)
      hs.alert.show(total > 0 and (total .. " windows brought back")
                               or "no stranded windows")
      return
    end
    local target = spaces[index]
    index = index + 1
    hs.spaces.gotoSpace(target)
    -- The Space transition is animated too.
    hs.timer.doAfter(0.8, function()
      rescueHere(total, function(count)
        total = total + count
        nextSpace()
      end)
    end)
  end

  nextSpace()
end

-- Ctrl+Alt+Cmd+R, deliberately outside the Raycast cmd+shift family.
local rescueHotkey = hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "r", rescueWindows)

-- Launch almost-maximized.
-- Raycast cannot resize a window as macOS creates it, which is the one part of the plan
-- that was given up on. A window watcher can: it fires on creation, and setFrame works
-- normally even though moving a window between Spaces no longer does on this macOS.
local ALMOST_W, ALMOST_H = 0.92, 0.94
local SETTLE = 4   -- pixels; closer than this counts as correct

-- Apps whose windows are panels, launchers or dialogs, where resizing would be wrong.
local noResize = {
  ["Raycast"] = true, ["Hammerspoon"] = true, ["Finicky"] = true,
  ["Granola"] = true, ["System Settings"] = true,
  ["loginwindow"] = true, ["Control Center"] = true, ["Spotlight"] = true,
}

local function wantedFrame(win)
  local screen = win:screen():frame()
  return {
    w = screen.w * ALMOST_W,
    h = screen.h * ALMOST_H,
    x = screen.x + screen.w * (1 - ALMOST_W) / 2,
    y = screen.y + screen.h * (1 - ALMOST_H) / 2,
  }
end

local function closeEnough(a, b)
  return math.abs(a.x - b.x) <= SETTLE and math.abs(a.y - b.y) <= SETTLE
     and math.abs(a.w - b.w) <= SETTLE and math.abs(a.h - b.h) <= SETTLE
end

-- Many apps restore their own remembered size a moment after the window appears, which
-- lands it near the target rather than on it. So set the frame, check, and set again.
local function applyAlmost(win, attempt)
  attempt = attempt or 1
  local ok = pcall(function()
    local target = wantedFrame(win)
    win:setFrame(target)
    if attempt >= 4 then return end
    hs.timer.doAfter(0.45, function()
      pcall(function()
        if not win:isStandard() or win:isFullScreen() then return end
        if not closeEnough(win:frame(), wantedFrame(win)) then
          applyAlmost(win, attempt + 1)
        end
      end)
    end)
  end)
  return ok
end

local function almostMaximize(win)
  if not win then return false end
  local allowed = pcall(function()
    if not win:isStandard() or win:isFullScreen() then error("skip", 0) end
    local app = win:application()
    if app and noResize[app:name()] then error("skip", 0) end
    local f = win:frame()
    -- A small window is a dialog or a palette, not a document window.
    if f.w < 400 or f.h < 300 then error("skip", 0) end
  end)
  if not allowed then return false end
  return applyAlmost(win, 1)
end

-- New windows land almost-maximized. The filter is unfiltered on purpose; the decision
-- about what to skip lives in almostMaximize, where the window itself can be inspected.
local newWindowFilter = hs.window.filter.new(nil)
newWindowFilter:subscribe(hs.window.filter.windowCreated, function(win)
  -- Apps draw a window before they finish sizing it, so let them settle first.
  hs.timer.doAfter(0.35, function() almostMaximize(win) end)
end)

-- Ctrl+Alt+Cmd+M almost-maximizes whatever is focused, for windows that predate this.
local almostHotkey = hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "m", function()
  if not almostMaximize(hs.window.focusedWindow()) then
    hs.alert.show("not a window this resizes")
  end
end)
