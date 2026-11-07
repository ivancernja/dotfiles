vim.cmd.highlight("clear")
vim.g.colors_name = "whitby-bay"
vim.o.termguicolors = true

local colors = {
  bg = "#272a38",
  surface = "#2c2f3c",
  raised = "#393c4a",
  selection = "#434861",
  border = "#474a56",
  fg = "#f7f7ee",
  bright = "#fdfdfa",
  muted = "#a4a6a7",
  dim = "#84868b",
  accent = "#b696f7",
  red = "#ff5d57",
  green = "#4df08a",
  yellow = "#f5f28a",
  pink = "#ff7ed1",
  cyan = "#90ecf6",
}

local groups = {
  Normal = { fg = colors.fg, bg = colors.bg },
  NormalFloat = { fg = colors.fg, bg = colors.surface },
  FloatBorder = { fg = colors.border, bg = colors.surface },
  FloatTitle = { fg = colors.accent, bg = colors.surface, bold = true },
  Cursor = { fg = colors.bg, bg = colors.fg },
  CursorLine = { bg = colors.surface },
  CursorLineNr = { fg = colors.accent, bold = true },
  LineNr = { fg = colors.dim },
  Visual = { bg = colors.selection },
  Search = { fg = colors.bg, bg = colors.yellow },
  IncSearch = { fg = colors.bg, bg = colors.pink },
  MatchParen = { fg = colors.cyan, bold = true },
  Pmenu = { fg = colors.fg, bg = colors.surface },
  PmenuSel = { fg = colors.bg, bg = colors.accent, bold = true },
  PmenuSbar = { bg = colors.raised },
  PmenuThumb = { bg = colors.accent },
  StatusLine = { fg = colors.fg, bg = colors.raised },
  StatusLineNC = { fg = colors.dim, bg = colors.surface },
  WinSeparator = { fg = colors.border },
  TabLine = { fg = colors.muted, bg = colors.surface },
  TabLineSel = { fg = colors.bright, bg = colors.raised, bold = true },
  Folded = { fg = colors.muted, bg = colors.surface },
  SignColumn = { bg = colors.bg },
  Directory = { fg = colors.cyan },
  Title = { fg = colors.accent, bold = true },
  Comment = { fg = colors.dim, italic = true },
  Constant = { fg = colors.pink },
  String = { fg = colors.green },
  Character = { fg = colors.green },
  Number = { fg = colors.yellow },
  Boolean = { fg = colors.yellow },
  Identifier = { fg = colors.fg },
  Function = { fg = colors.cyan },
  Statement = { fg = colors.accent },
  Conditional = { fg = colors.accent },
  Repeat = { fg = colors.accent },
  Operator = { fg = colors.pink },
  Keyword = { fg = colors.accent, italic = true },
  Exception = { fg = colors.red },
  PreProc = { fg = colors.pink },
  Type = { fg = colors.cyan },
  Special = { fg = colors.pink },
  Underlined = { fg = colors.cyan, underline = true },
  Error = { fg = colors.red },
  Todo = { fg = colors.bg, bg = colors.yellow, bold = true },
  DiagnosticError = { fg = colors.red },
  DiagnosticWarn = { fg = colors.yellow },
  DiagnosticInfo = { fg = colors.cyan },
  DiagnosticHint = { fg = colors.green },
  DiffAdd = { fg = colors.green, bg = colors.surface },
  DiffChange = { fg = colors.yellow, bg = colors.surface },
  DiffDelete = { fg = colors.red, bg = colors.surface },
  GitSignsAdd = { fg = colors.green },
  GitSignsChange = { fg = colors.yellow },
  GitSignsDelete = { fg = colors.red },
  WhichKey = { fg = colors.accent },
  WhichKeyGroup = { fg = colors.cyan },
  WhichKeyDesc = { fg = colors.fg },
  SnacksPickerBorder = { fg = colors.border, bg = colors.surface },
  SnacksPickerMatch = { fg = colors.pink, bold = true },
  SnacksPickerCursorLine = { bg = colors.raised },
  BlinkCmpMenu = { fg = colors.fg, bg = colors.surface },
  BlinkCmpMenuSelection = { fg = colors.bg, bg = colors.accent, bold = true },
}

for group, opts in pairs(groups) do
  vim.api.nvim_set_hl(0, group, opts)
end

vim.g.terminal_color_0 = "#20222e"
vim.g.terminal_color_1 = colors.red
vim.g.terminal_color_2 = colors.green
vim.g.terminal_color_3 = colors.yellow
vim.g.terminal_color_4 = colors.accent
vim.g.terminal_color_5 = colors.pink
vim.g.terminal_color_6 = colors.cyan
vim.g.terminal_color_7 = "#f2f2ea"
vim.g.terminal_color_8 = "#66759f"
vim.g.terminal_color_9 = "#ff7a72"
vim.g.terminal_color_10 = "#72fa9e"
vim.g.terminal_color_11 = "#fbfcae"
vim.g.terminal_color_12 = "#d0b0fb"
vim.g.terminal_color_13 = "#fc97d8"
vim.g.terminal_color_14 = "#aefbf8"
vim.g.terminal_color_15 = colors.bright
