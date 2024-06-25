local tutils = require("telescope.utils")

local __tmux_client_tty

__in_tmux_session = tutils.get_os_command_output({ "printenv", "TMUX" })[1] ~= nil

---@class TmuxState
---@field in_tmux_session function
---@field get_tmux_client_tty function
---@field update_tmux_client_tty function
local TmuxState = {}
TmuxState.__index = TmuxState -- with this we will have a singleton

function TmuxState:new()
  local obj = {}

  setmetatable(obj, self)
  self.update_tmux_client_tty()
  return obj
end

function TmuxState:get_tmux_client_tty()
  return __tmux_client_tty
end

function TmuxState:update_tmux_client_tty()
  __tmux_client_tty = tutils.get_os_command_output({ "tmux", "display-message", "-p", "#{client_tty}" })[1]
end

---@return boolean
function TmuxState:in_tmux_session()
 return __in_tmux_session
end

return TmuxState

