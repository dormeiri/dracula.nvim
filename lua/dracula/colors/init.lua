local util = require("dracula.util")

local M = {}

---@type table<string, DraculaPalette|fun(opts:DraculaConfig):DraculaPalette>
M.styles = setmetatable({}, {
  __index = function(_, style)
    return vim.deepcopy(util.mod("dracula.colors." .. style))
  end,
})

---@param opts? DraculaConfig
function M.setup(opts)
  opts = require("dracula.config").extend(opts)

  util.day_brightness = opts.day_brightness

  local palette = M.styles[opts.style]
  ---@type fun(colors: DraculaColorScheme)?
  local post_run = nil
  if type(palette) == "function" then
    ---@type DraculaPalette, fun(colors: DraculaColorScheme)?
    palette, post_run = palette(opts)
  end

  -- Color Palette
  ---@class DraculaColorScheme: DraculaPalette
  local colors = palette

  util.bg = colors.bg
  util.fg = colors.fg

  colors.none = "NONE"
  colors.teal = util.blend(colors.green, 0.6, colors.cyan)

  colors.git = {
    add = util.blend_bg(colors.green, 0.8),
    change = util.blend_bg(colors.cyan, 0.8),
    delete = util.blend_bg(colors.red, 0.8),
    ignore = util.blend_bg(colors.comment, 0.8),
  }
  colors.gitSigns = {
    add = util.blend_bg(colors.green, 0.8),
    change = util.blend_bg(colors.cyan, 0.8),
    delete = util.blend_bg(colors.red, 0.8),
  }
  colors.diff = {
    add = util.blend_bg(colors.green, 0.2),
    change = util.blend_bg(colors.cyan, 0.4),
    delete = util.blend_bg(colors.red, 0.5),
    text = util.blend_bg(colors.fg, 0.5),
  }

  colors.error = colors.bright_red
  colors.warning = colors.yellow
  colors.info = colors.cyan
  colors.hint = colors.teal
  colors.todo = colors.bright_cyan
  colors.inactive = util.blend_bg(colors.white, "4A")
  colors.line = util.blend_bg(colors.selection, "75")
  colors.border_header = colors.pink
  colors.border = util.blend_bg(colors.purple, 0.8)
  colors.visual = util.blend_bg(colors.purple, 0.4)
  colors.search = util.blend(colors.purple, 0.6, "#0000ff")
  colors.search_alt = util.blend(colors.pink, 0.7, "#ff0000")
  colors.statusline = util.blend(colors.bg, 0.5, "#000000")

  colors.dark = {
    fg = util.blend_bg(colors.fg, 0.8),
    bg = util.blend(colors.bg, 0.7, "#000000"),
  }
  colors.gutter = {
    fg = util.blend_bg(colors.white, "32"),
    bg = util.blend_bg(colors.white, "0A"),
  }
  colors.sidebar = {
    fg = util.blend_bg(colors.fg, 0.8),
    bg = opts.styles.sidebars == "transparent" and colors.none
      or opts.styles.sidebars == "dark" and colors.dark.bg
      or colors.bg,
  }
  colors.float = {
    fg = util.blend_bg(colors.fg, 0.8),
    bg = opts.styles.floats == "transparent" and colors.none
      or opts.styles.floats == "dark" and colors.dark.bg
      or colors.bg,
  }
  colors.popup = {
    fg = util.blend_bg(colors.fg, 0.8),
    bg = colors.dark.bg,
  }
  colors.rainbow = { colors.purple, colors.yellow, colors.orange, colors.green, colors.cyan, colors.pink }

  if post_run then
    post_run(colors)
  end

  opts.on_colors(colors)

  return colors, opts
end

return M
