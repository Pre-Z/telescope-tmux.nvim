local actions = require("telescope-tmux.pickers.sessions.switch_session.actions")

return {
	["<cr>"] = actions.on_select,
	-- ["<c-a>"] = custom_actions.create_new_session,
	-- ["<c-d>"] = custom_actions.delete_session,
	-- ["<c-r>"] = custom_actions.rename_session,
}

