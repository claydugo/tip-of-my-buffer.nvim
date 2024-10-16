local settings = require("tip_of_my_buffer.settings")
local utils = require("tip_of_my_buffer.utils")

local M = {}

function M.log(msg)
	if settings.debug then
		vim.notify("[TipOfMyBuffer] " .. msg, vim.log.levels.INFO)
	end
end

function M.debounce(func, delay)
	utils.debounce(func, delay)
end

function M.should_save(buf)
	if not settings.enabled then
		return false
	end

	local buftype = vim.bo[buf].buftype
	local modifiable = vim.bo[buf].modifiable
	local readonly = vim.bo[buf].readonly
	local modified = vim.bo[buf].modified
	local filetype = vim.bo[buf].filetype
	local filename_full = vim.api.nvim_buf_get_name(buf)
	local filename = vim.fn.fnamemodify(filename_full, ":t")

	if not modified then
		M.log("Buffer is not modified")
		return false
	end

	if buftype ~= "" then
		M.log("Skipping non-file buffer: " .. buftype)
		return false
	end

	if not modifiable or readonly then
		M.log("Buffer is not modifiable or is readonly")
		return false
	end

	if settings.conditions.exists then
		if filename_full == "" or not vim.loop.fs_stat(filename_full) then
			M.log("File does not exist or has no name")
			return false
		end
	end

	if vim.tbl_contains(settings.conditions.exclude_filename, filename) then
		M.log("Filename is excluded: " .. filename)
		return false
	end

	if vim.tbl_contains(settings.conditions.exclude_filetype, filetype) then
		M.log("Filetype is excluded: " .. filetype)
		return false
	end

	local mode = vim.api.nvim_get_mode().mode
	for _, m in ipairs(settings.conditions.exclude_mode) do
		if mode == m then
			M.log("Current mode is excluded: " .. mode)
			return false
		end
	end

	return true
end

function M.auto_save()
	local buf = vim.api.nvim_get_current_buf()

	if not M.should_save(buf) then
		return
	end

	local ok, err = pcall(function()
		vim.cmd("silent! update")
		if settings.execution_message ~= "" and vim.o.cmdheight ~= 0 then
			vim.notify(settings.execution_message, vim.log.levels.INFO)
		end
	end)

	if not ok then
		vim.notify("TipOfMyBuffer: Error saving buffer - " .. err, vim.log.levels.ERROR)
	else
		M.log("Buffer saved successfully")
	end
end

return M
