local settings = require("tip_of_my_buffer.settings")
local core = require("tip_of_my_buffer.core")

local M = {}

function M.setup()
	local group = vim.api.nvim_create_augroup("TipOfMyBufferGroup", { clear = true })

	vim.api.nvim_create_autocmd(settings.events, {
		group = group,
		callback = function()
			core.debounce(core.auto_save, settings.debounce_delay_ms)
		end,
	})

	core.log("Event handlers registered")
end

return M
