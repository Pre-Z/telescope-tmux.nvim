local TmuxPicker = require("telescope-tmux.core.base-picker")
local tutils = require("telescope.utils")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local transform_mod = require("telescope.actions.mt").transform_mod
local utils = require("telescope._extensions.tmux.utils")
local tmux_commands = require("telescope._extensions.tmux.tmux_commands")

{
			prompt_title = "Other Tmux Sessions",
			sorter = sorters.get_generic_fuzzy_sorter(),
			previewer = previewers.new_termopen_previewer({
				get_command = function(entry, status)
					local session_name = formatted_to_real_session_map[entry.value]
					return { "tmux", "attach-session", "-t", session_name, "-r" }
				end,
			}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					-- if not in_tmux_session then
					-- 	tmux_opts.notifier("You are not in a tmux session, switch is not possible", vim.log.levels.WARN)
					-- else
					local selection = action_state.get_selected_entry()
					vim.cmd(string.format('silent !tmux switchc -t "%s" -c "%s"', selection.value, current_client))
					-- end
					actions.close(prompt_bufnr)
				end)

				actions.close:enhance({
					post = function()
						if tmux_opts.quit_on_select then
							vim.cmd("q!")
						end
					end,
				})
				map("i", "<c-a>", custom_actions.create_new_session)
				map("n", "<c-a>", custom_actions.create_new_session)
				map("i", "<c-d>", custom_actions.delete_session)
				map("n", "<c-d>", custom_actions.delete_session)
				map("i", "<c-r>", custom_actions.rename_session)
				map("n", "<c-r>", custom_actions.rename_session)

				return true
			end,
		}

local switch_session = TmuxPicker:new({
  finder = finders.new_table({
    results = user_formatted_session_names,
    entry_maker = function(result)
      return {
        value = result,
        display = result,
        ordinal = result,
        valid = formatted_to_real_session_map[result] ~= current_session,
      }
    end,
  }),
})

return switch_session
