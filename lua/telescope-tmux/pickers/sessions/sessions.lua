local tutils = require("telescope.utils")
local helper = require("telescope-tmux.lib.helper")

---@class TmuxSession
---@field list_sessions function
---@field create_session function
---@field delete_session function
---@field rename_session function
---@field switch_session function
local TmuxSession = {}

---@type nil | string
local __tmux_client_tty = tutils.get_os_command_output({ "tmux", "display-message", "-p", "#{client_tty}" })[1]

---@type boolean
local __in_tmux_session = tutils.get_os_command_output({"printenv", "TMUX"})[1] ~= nil

function TmuxSession:new()
	local obj = {}
	setmetatable(obj, self)
	self.__index = self
  self:__refresh_session_list_mappings()
	return obj
end

-- -- TODO: remove this hardcoding later
-- local window_id_fmt = "#{session_name}:#{window_id}"
-- local session_id_fmt = "#{session_id}"
-- local session_name_fmt = "#S"

---@class TmuxSessionTable
---@field id string
---@field name string
---@field last_used number

---@type TmuxSessionTable[]
local __session_list = {}

-- ---@class SessionDetails
-- ---@field name string
-- ---@field last_used number

---@type {id: TmuxSessionTable}
local __sessions_by_id = {}

---@class SessionListOptions
---@field format string?
-------@field exclude_current_session boolean?

---@param session_id string
---@param session_name string
function TmuxSession:__add_session_to_session_cache(session_id, session_name)
	if __sessions_by_id[session_id] then
		__sessions_by_id[session_id].name = session_name -- force update the session_name
		-- __sessions_by_id[session_id].last_used = 0 -- reset the last_used_time?
	else
		__sessions_by_id[session_id] = { name = session_name, last_used = 0, id = session_id }
	end
	table.insert(__session_list, __sessions_by_id[session_id])
end

function TmuxSession:__refresh_session_list_mappings()
	-- if opts.exclude_current_session == nil then
	-- 	opts.exclude_current_session = false
	-- end

	-- since tmux does not allow to have `:` in the name of a session it is safe to separate the id with `:`
	-- if opts.format ~= nil then
	-- 	table.insert(cmd, "-f")
	-- 	table.insert(cmd, opts.format)
	-- end

	-- local sessions = {
	-- 	session_names_by_id = {},
	-- 	session_id_by_names = {},
	-- }
	--
	--  print("iterating through the result of tmux lists...")
	-- for id, name in string.gmatch(tmux_session_list, "(.+):(.+)") do
	-- 	print(id, name)
	--    sessions.session_names_by_id[id] = name
	--    sessions.session_id_by_names[name] = id
	-- end
	local cmd = { "tmux", "list-sessions", "-f", "#{session_id}:#{session_name}" }
	local tmux_session_list = tutils.get_os_command_output(cmd)
	__session_list = {} -- empty current list

	print("iterating through the result of tmux lists...")
	for id, name in string.gmatch(tmux_session_list, "^\\$(%d+):(.+)$") do
		self:__add_session_to_session_cache(id, name)
	end
end

---@param session_name string
---@return string, string:? Error
function TmuxSession:create_session(session_name)
	local new_session_id, _, err = tutils.get_os_command_output({
		"tmux",
		"new-session",
		"-dP",
		"-s",
		session_name,
		"-F",
		"#{session_id}",
	})

  if not err then
    self:__add_session_to_session_cache(new_session_id, session_name)
  end

	return new_session_id, err
end

---@param session_id string
---@return any
---@return string?: Error
function TmuxSession:switch_session(session_id)
	if not __sessions_by_id[session_id] then
		return error("No session found")
	end
end
-- local __sort_table_by_name_field = function(tbl)
-- 	local keys = {}
-- 	for k in pairs(tbl) do
-- 		table.insert(keys, k)
-- 	end
-- 	table.sort(keys)
-- 	return keys
-- end
--
-- local __reverse_sort_table = function(tbl)
-- 	local keys = {}
-- 	for k in pairs(tbl) do
-- 		table.insert(keys, k)
-- 	end
-- 	table.sort(keys, function(a, b)
-- 		return a > b
-- 	end)
-- end
--
-- ---@param order_property string
-- ---@param second_order_property string?
-- local __get__session_list_ordered_by_last_used = function(order_property, second_order_property)
-- 	-- local order_property = opts.order_sessions_by
-- 	-- local second_order_property = opts.second_session_order_property
-- 	-- no need to prepare for multiple sessions under the same name, since tmux does not let it to happen,
-- 	-- in any other cases the primary and secondary ordering properties will be different
-- 	second_order_property = second_order_property and second_order_property or "name"
-- 	local ordered_session_list = {}
-- 	local sessions_by_order_property = {}
-- 	for id, session_data in __sessions_by_id do
-- 		if not sessions_by_order_property[session_data[order_property]] then
-- 			sessions_by_order_property[session_data[order_property]] = { { id = id, name = session_data.name } }
-- 		else
-- 			table.insert(
-- 				sessions_by_order_property[session_data[order_property]],
-- 				{ id = id, name = session_data.name }
-- 			)
-- 		end
-- 	end
--
-- 	for _, v in helper.key_ordered_pairs(sessions_by_order_property, __reverse_sort_table) do
-- 		-- only matters if last usage time is zero
-- 		table.sort(v, function(a, b)
-- 			return a[second_order_property] < b[second_order_property]
-- 		end)
--
-- 		for _, subvalue in pairs(v) do
-- 			table.insert(ordered_session_list, subvalue)
-- 		end
-- 	end
--
-- 	return ordered_session_list
-- end
--
-- this is gonna be more efficient
---@param order_property string
---@param second_order_property string?
local __get_ordered_session_list = function(order_property, second_order_property)
	-- local order_property = opts.order_sessions_by
	-- local second_order_property = opts.second_session_order_property
	-- no need to prepare for multiple sessions under the same name, since tmux does not let it to happen,
	-- in any other cases the primary and secondary ordering properties will be different
	second_order_property = second_order_property and second_order_property or "name"
	local ordered_session_list = helper.shallow_copy_table(__session_list)
	local sessions_by_order_property = {}

	table.sort(ordered_session_list, function(a, b)
		if a[order_property] == b[order_property] then
			return a[second_order_property] < b[second_order_property]
		else
			-- the last used should be the first in the list
			if order_property == "last_used_time" then
				return a[order_property] > b[order_property]
			else
				return a[order_property] < b[order_property]
			end
		end
	end)

	for _, v in helper.key_ordered_pairs(sessions_by_order_property, __reverse_sort_table) do
		-- only matters if last usage time is zero
		table.sort(v, function(a, b)
			return a[second_order_property] < b[second_order_property]
		end)

		for _, subvalue in pairs(v) do
			table.insert(ordered_session_list, subvalue)
		end
	end

	return ordered_session_list
end

local instance = TmuxSession:new()

return instance
