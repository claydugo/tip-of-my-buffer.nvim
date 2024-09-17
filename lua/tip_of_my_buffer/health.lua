local health = vim.health or require("health")
local start = health.start or health.report_start
local ok = health.ok or health.report_ok
local warn = health.warn or health.report_warn

local settings = require("tip_of_my_buffer.settings")

local M = {}

function M.check()
	local execution_message = settings.execution_message or ""

	local cmdheight = vim.o.cmdheight

	start("Configuration")
	if execution_message ~= "" and cmdheight == 0 then
		warn(
			"cmdheight is set to 0. This is not supported with execution_message\n"
				.. "Consider setting cmdheight to a higher value or setting the execution_message to an empty string."
		)
	else
		ok("No settings that may interfere with plugin behavior were found.")
	end
end

return M
