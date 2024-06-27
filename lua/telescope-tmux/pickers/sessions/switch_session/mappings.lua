local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local utils = require("telescope-tmux.lib.utils")

return {
	["<cr>"] = function(prompt_bufnr, opts)
    local TmuxSessions = require("telescope-tmux.core.sessions"):new(opts)
    -- local tutils = require("telescope.utils")
    -- local current_client = tutils.get_os_command_output({ "tmux", "display-message", "-p", "#{client_tty}" })[1]
    local selection = action_state.get_selected_entry()
    local err = TmuxSessions:switch_session(selection.value.id)
    if err ~= nil then
      local notifier = utils.get_notifier(opts)
      notifier(err, vim.log.levels.ERROR)
      return
    end
		actions.close(prompt_bufnr)
	end,
	-- ["<c-a>"] = custom_actions.create_new_session,
	-- ["<c-d>"] = custom_actions.delete_session,
	-- ["<c-r>"] = custom_actions.rename_session,
}

