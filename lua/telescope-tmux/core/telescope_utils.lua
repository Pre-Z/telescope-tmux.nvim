local action_state = require "telescope.actions.state"
local telescope_actions = require "telescope.actions"
local util = require "telescope-tmux.core.utils"
local previewers = require "telescope.previewers"

local telescope_utils = {}

function telescope_utils.get_attach_mappings_fn(keys)
  return function(prompt_bufnr, map)
    for key, f in pairs(keys or {}) do
      if key == "<CR>" then
        telescope_actions.select_default:replace(function()
          f(prompt_bufnr)
        end)
      else
        local modes = { "n" }
        if key:sub(1, 1) == "<" then
          table.insert(modes, "i")
        end
        for _, mode in ipairs(modes) do
          map(mode, key, function()
            f(prompt_bufnr)
          end)
        end
      end
    end
    return true
  end
end

return telescope_utils
