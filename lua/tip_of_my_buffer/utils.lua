local M = {}

local timer = nil

function M.debounce(func, delay_ms)
	if timer then
		timer:stop()
		timer:close()
	end
	timer = vim.loop.new_timer()
	timer:start(
		delay_ms,
		0,
		vim.schedule_wrap(function()
			timer:stop()
			timer:close()
			timer = nil
			func()
		end)
	)
end

return M
