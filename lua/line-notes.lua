local Notes = require'line-notes/notes'
local instance = nil
local M = {}

M.setup = function(opts)
  if instance ~= nil then return instance end
  instance = Notes:new(opts)
  local has_telescope, telescope = pcall(require, 'telescope')
  if has_telescope then
    telescope.load_extension('line_notes')
    telescope.load_extension('line_notes_project')
  end
  return instance
end

M.render = vim.schedule_wrap(function(skip_reopen)
  return M.setup():render(skip_reopen)
end)

M.preview = vim.schedule_wrap(function()
  return M.setup():preview()
end)

M.add = function()
  return M.setup():add()
end

M.edit = function()
  return M.setup():edit()
end

M.delete = function()
  return M.setup():delete()
end

M.get_list = function(opts)
  return M.setup():get_all(opts)
end

M.do_mapping = function(name, from_mapping)
  M[name]()
  if from_mapping then
    vim.cmd(string.format('silent! call repeat#set("\\<Plug>(LineNotes%s)")', name:sub(1, 1):upper()..name:sub(2)))
  end
end

M.check_for_changes = function()
  return M.setup():check_for_changes()
end

return M
