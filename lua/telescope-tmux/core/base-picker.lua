local telescope_utils = require("telescope-tmux.core.telescope_utils")
local utils = require("telescope-tmux.core.utils")
local tmux_commands = require("telescope-tmux.core.tmux_commands")
local pickers = require("telescope.pickers")

---@class TmuxPickerOptions
---@field title string
---@field finder function
---@field sorter function
---@field previewer function
---@field mappings table

---@class TmuxPicker
---@field title string
---@field finder function
---@field sorter function
---@field previewer function
---@field mappings table
---@field _in_tmux_session boolean
local TmuxPicker = {}
TmuxPicker.__index = TmuxPicker

---@param opts TmuxPickerOptions
function TmuxPicker:new(opts)
  self._in_tmux_session = tmux_commands.being_in_tmux_session()
  return setmetatable(opts, self)
end

function TmuxPicker:get_picker_for_telescope(opts)
  local picker_options = {
    prompt_title = self.title,
    finder = self.finder(),
    sorter = self.sorter(),
    previewer = self.previewer(),
    attach_mappings = telescope_utils.get_attach_mappings_fn(self.mappings),
  }
  local notifier = utils.get_notifier(opts)

  picker_options = vim.tbl_deep_extend("force", opts, picker_options)
  return function ()
    if not self._in_tmux_session then
      notifier("You are not in a Tmux Session, no session switch is possible", vim.log.levels.ERROR)
    end
    local picker = pickers.new(picker_options)
    picker:find()
  end
end

return TmuxPicker
