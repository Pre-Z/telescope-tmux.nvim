local tutils = require("telescope.utils")

local M = {}

---@param session_name string
M.create_session = function(session_name)
	return true
end

---@param session_id string
M.rename_session = function(session_id)
	return true
end

---@param session_id string
M.delete_session = function(session_id)
	return true
end

return M
