-- local utils = require("telescope-tmux.core.utils")
local config = {}
local _TmuxDefaultConfig = {
	nvim_notify_options = {
		icon = "﬿",
		title = "Telescope Tmux",
		timeout = 3000,
	},
	layout_strategy = "horizontal",
	layout_config = { preview_width = 0.8 },
}

config.setup = function(extension_config, telescope_config)
	config.opts = _TmuxDefaultConfig
	config.opts = vim.tbl_deep_extend("force", config.opts, telescope_config)
	config.opts = vim.tbl_deep_extend("force", config.opts, extension_config)
end

config.reinit_config = function(opts)
	if opts ~= nil then
		config.opts = vim.tbl_deep_extend("force", config.opts, opts)
	end
	return config
end

return config
