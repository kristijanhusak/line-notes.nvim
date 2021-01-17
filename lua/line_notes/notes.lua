local Storage = require'line_notes/storage'
local Notes = {}

function Notes:new(opts)
  local obj = opts or {}
  setmetatable(obj, self)
  self.__index = self
  self.storage = Storage:new(opts):read()
  return obj
end

function Notes:add()
  local note = vim.fn.input('Enter note: ')
  if not note or note == '' then return end
  self.storage:add({
    path = vim.fn.expand('%:p'),
    line = vim.fn.line('.'),
    col = vim.fn.col('.'),
    note = note,
  })
  self:render()
end

function Notes:render()
  local current_path = vim.fn.expand('%:p')
  local buf = vim.api.nvim_get_current_buf()
  local file_notes = self.storage:get(current_path)
  if vim.tbl_isempty(file_notes) then return end
  if not vim.b.line_notes_ns then
    vim.b.line_notes_ns = vim.api.nvim_create_namespace(string.format('line_notes_%s', current_path));
  end
  for line, notes_by_line in pairs(file_notes) do
    local c = #notes_by_line > 1 and #notes_by_line or ''
    vim.api.nvim_buf_set_virtual_text(buf, vim.b.line_notes_ns, tonumber(line) - 1, {{'    '..c, 'Comment'}}, {})
  end
end

function Notes:preview()
  local line = vim.fn.line('.')
  local current_path = vim.fn.expand('%:p')
  local file_notes = self.storage:get(current_path)
  local line_notes = file_notes[tostring(line)] or {}

  if not vim.tbl_isempty(line_notes) then
    local counter = 1
    local float_content = vim.tbl_map(function(item)
      local result = counter..') '..item.note
      counter = counter + 1
      return result
    end, line_notes)
    local line_len = #vim.fn.getline('.')
    vim.lsp.util.open_floating_preview(float_content, 'markdown', {
        offset_x = math.max(line_len + 7, 80) - vim.fn.col('.'),
        offset_y = -1
      })
  end
end

return Notes
