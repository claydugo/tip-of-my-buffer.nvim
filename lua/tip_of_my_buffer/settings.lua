local M = {}

local defaults = {
	enabled = true,
	events = { "FocusLost" },
	execution_message = "",
	conditions = {
		exclude_filename = {},
		exclude_filetype = {},
		exclude_mode = { "i", "c" },
	},
	debounce_delay_ms = 150,
	debug = false,
}

local schema = {
	enabled = "boolean",
	events = { type = "table", list = true },
	execution_message = "string",
	conditions = {
		exclude_filename = { type = "table", list = true },
		exclude_filetype = { type = "table", list = true },
		exclude_mode = { type = "table", list = true },
	},
	debounce_delay_ms = "number",
	debug = "boolean",
}

local config = vim.deepcopy(defaults)

local function validate_options(defaults_table, opts_table, path, invalid_keys)
	invalid_keys = invalid_keys or {}
	for key, value in pairs(opts_table) do
		local current_path = path and (path .. "." .. key) or key
		if defaults_table[key] == nil then
			table.insert(invalid_keys, current_path)
		else
			if type(value) == "table" and type(defaults_table[key]) == "table" and not vim.islist(value) then
				validate_options(defaults_table[key], value, current_path, invalid_keys)
			end
		end
	end
	return invalid_keys
end

local function validate_types(schema, config_table, path)
	for key, spec in pairs(schema) do
		local current_path = path and (path .. "." .. key) or key
		local value = config_table[key]

		if value == nil then
			error(string.format("Missing configuration option: '%s'.", current_path))
		end

		if type(spec) == "table" and not spec.type then
			if type(value) ~= "table" then
				error(string.format("Invalid type for '%s'. Expected table.", current_path))
			end
			validate_types(spec, value, current_path)
		else
			local expected_type = type(spec) == "table" and spec.type or spec
			local is_list = type(spec) == "table" and spec.list

			if type(value) ~= expected_type then
				error(
					string.format(
						"Invalid type for '%s'. Expected %s, got %s.",
						current_path,
						expected_type,
						type(value)
					)
				)
			end

			if is_list and not vim.islist(value) then
				error(string.format("Invalid format for '%s'. Expected a list (array).", current_path))
			end
		end
	end
end

local setup_called = false

function M.setup(opts)
	if setup_called then
		error("Setup has already been called and cannot be called again.")
	end
	setup_called = true

	opts = opts or {}

	local invalid_keys = validate_options(defaults, opts)
	if #invalid_keys > 0 then
		error(
			string.format(
				"Invalid configuration option%s:\n    %s,\n\nPlease refer to the documentation for valid configuration keys.",
				(#invalid_keys == 1 and "" or "s"),
				table.concat(
					vim.tbl_map(function(k)
						return '"' .. k .. '"'
					end, invalid_keys),
					",\n    "
				)
			)
		)
	end

	config = vim.tbl_deep_extend("force", {}, defaults, opts)

	validate_types(schema, config)

	setmetatable(M, {
		__index = function(t, key)
			local value = config[key]
			if value ~= nil then
				return value
			else
				error(string.format("Attempt to access undefined setting: '%s'", key))
			end
		end,
		__newindex = function(t, key, value)
			error(string.format("Attempt to modify setting '%s' is not allowed", key))
		end,
		__metatable = false,
	})
end

return M
