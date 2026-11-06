-- cmd+k clears the terminal, as in Terminal.app, iTerm2 and Ghostty.
rex.bind("cmd+k", "com.superlogical.terminal.clear")
rex.bind("shift+cmd+k", "session.switch")

-- Comms: mail, web, bots, and the feeds tab. Built by ~/rex/bin/comms.
rex.action{
  name  = "comms",
  title = "Open Home Session",
  description = "Mail, web, bots, agenda, Slack and Discord in one session",
  run   = function()
    local out, err = rex.exec{ os.getenv("HOME") .. "/rex/bin/comms" }
    if err ~= nil then error(err, 0) end
    return out
  end,
}

-- Summon Rex over whatever app is in front.
rex.bind("alt+space", "client.visibility.toggle")

-- Save and restore the whole setup. `rex do save` writes every open session to the
-- "default" profile; `rex do restore` reopens it. A launch agent writes "last" every
-- five minutes, so `boot last` is the one for after a crash.
rex.action{
  name  = "save",
  title = "Save Session Layout",
  description = "Write every open session to the default profile",
  run   = function()
    local out, err = rex.exec{ os.getenv("HOME") .. "/rex/bin/snapshot" }
    if err ~= nil then error(err, 0) end
    return out
  end,
}

rex.action{
  name  = "restore",
  title = "Restore Session Layout",
  description = "Reopen every session saved in the default profile",
  run   = function()
    local out, err = rex.exec{ os.getenv("HOME") .. "/rex/bin/boot" }
    if err ~= nil then error(err, 0) end
    return out
  end,
}

-- Work: Linear on one tab, your pull requests on another. Built by ~/rex/bin/work.
rex.action{
  name  = "work",
  title = "Open Work Session",
  description = "Linear issues and your pull requests, with diffs and nvim review",
  run   = function()
    local out, err = rex.exec{ os.getenv("HOME") .. "/rex/bin/work" }
    if err ~= nil then error(err, 0) end
    return out
  end,
}
