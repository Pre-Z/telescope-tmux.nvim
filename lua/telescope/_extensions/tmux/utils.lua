local utils = {}

utils.init_notifier = function (opts)
  local notifier
	if opts.use_nvim_notify == nil or opts.use_nvim_notify then
		local notify_plugin_available, notify = pcall(require, "notify")
		if opts.use_nvim_notify and not notify_plugin_available then
			vim.notify(
				"Nvim-notify plugin is not available, but was set to be used, fallbacking to vim.notify. Please install nvim-notify to be able to use it.",
				vim.log.levels.ERROR
			)
		end
    local nvim_notify_wrapper = function(message, level)
      notify(message, level, opts.nvim_notify_options)
    end
		notifier = notify_plugin_available and nvim_notify_wrapper or vim.notify
	else
		notifier = vim.notify
	end

  return notifier
end

return utils
