local settings = require("tip_of_my_buffer.settings")
local core = require("tip_of_my_buffer.core")
local events = require("tip_of_my_buffer.events")

local M = {}

function M.setup(opts)
	settings.setup(opts)
	if settings.enabled then
		events.setup()
		core.log("TipOfMyBuffer setup complete")
	else
		core.log("TipOfMyBuffer is disabled")
	end
end

return M
