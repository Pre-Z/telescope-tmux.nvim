local utils = require('telescope.utils')

local tmux_commands = {}

-- Include the session name since the window may be linked to multiple sessions
-- This format makes the window location unambiguous
tmux_commands.window_id_fmt = "#{session_name}:#{window_id}"
tmux_commands.session_id_fmt = "#{session_id}"
tmux_commands.session_name_fmt = "#S"

tmux_commands.list_windows = function(opts)
  local cmd = {'tmux', 'list-windows', '-a'}
  if opts.format ~= nil then
    table.insert(cmd, "-F")
    table.insert(cmd, opts.format)
  end
  return utils.get_os_command_output(cmd)
end

tmux_commands.list_sessions = function(opts)
 local cmd = {'tmux', 'list-sessions'}
 if opts.format ~= nil then
   table.insert(cmd, "-F")
   table.insert(cmd, opts.format)
 end
 return utils.get_os_command_output(cmd)
end

tmux_commands.get_base_index_option = function()
  return utils.get_os_command_output{'tmux', 'show-options', '-gv', 'base-index'}[1]
end

tmux_commands.link_window = function(src_window, target_window)
  local src = src_window  or error("src_window is required")
  local target = target_window  or error("target_window is required")
  return utils.get_os_command_output{'tmux', 'link-window', "-kd", '-s', src, "-t", target}
end

tmux_commands.kill_window = function(target)
  return utils.get_os_command_output{"tmux", "kill-window", "-t", target}
end

tmux_commands.being_in_tmux_session = function()
  local tmux_variable_content = utils.get_os_command_output({"printenv", "TMUX"})[1]

  return tmux_variable_content ~= nil
end

return tmux_commands