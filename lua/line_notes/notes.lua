local Storage = require'line_notes/storage'
local Notes = {}

function Notes:new(opts)
  local obj = opts or {}
  setmetatable(obj, self)
  self.__index = self
  self.storage = Storage:new(opts):read()
  vim.cmd[[augroup line_notes]]
  vim.cmd[[autocmd!]]
  vim.cmd[[autocmd BufEnter * lua require'line_notes'.render()]]
  vim.cmd[[augroup END]]

  vim.cmd[[command! AddLineComment lua require'line_notes'.add()]]
  vim.cmd[[command! EditLineComment lua require'line_notes'.edit()]]
  vim.cmd[[command! PreviewLineComment lua require'line_notes'.preview()]]
  vim.cmd[[command! DeleteLineComment lua require'line_notes'.delete()]]
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
  return self:render()
end

function Notes:edit()
  local line_notes = self.storage:get_current_line_notes()
  if vim.tbl_isempty(line_notes) then
    return print('No notes available for this line.')
  end
  local opts = {}
  for idx, item in ipairs(line_notes) do
    table.insert(opts, string.format('%d) %s', idx, item.note))
  end
  local selected = tonumber(vim.fn.inputlist(opts))
  if selected < 1 or selected > #opts then
    return print('Wrong selection.')
  end
  local new_note = vim.fn.input('Edit note: ', line_notes[selected].note)
  if not new_note or new_note == '' then
    return print('Empty note.')
  end
  line_notes[selected].note = new_note
  self.storage:update_line_notes(line_notes)
  return self:render()
end

function Notes:delete()
  local line_notes = self.storage:get_current_line_notes()
  if vim.tbl_isempty(line_notes) then
    return print('No notes available for this line.')
  end
  local opts = {}
  for idx, item in ipairs(line_notes) do
    table.insert(opts, string.format('%d) %s', idx, item.note))
  end
  table.insert(opts, string.format('%d) %s', #opts + 1, 'All'))
  local selected = tonumber(vim.fn.inputlist(opts))
  if selected < 1 or selected > #opts then
    return print('Wrong selection.')
  end
  if selected == #opts then
    self.storage:update_line_notes(nil)
  else
    line_notes[selected] = nil
    self.storage:update_line_notes(line_notes)
  end
  return self:render()
end

function Notes:render()
  local current_path = vim.fn.expand('%:p')
  local buf = vim.api.nvim_get_current_buf()
  local file_notes = self.storage:get(current_path)
  if vim.b.line_notes_ns then
    vim.api.nvim_buf_clear_namespace(buf, vim.b.line_notes_ns, vim.fn.line('.') - 1, vim.fn.line('.'))
  end
  if vim.tbl_isempty(file_notes) then return end

  if not vim.b.line_notes_ns then
    vim.b.line_notes_ns = vim.api.nvim_create_namespace(string.format('line_notes_%s', current_path));
  end
  for line, notes_by_line in pairs(file_notes) do
    local c = #notes_by_line > 1 and #notes_by_line or ''
    vim.api.nvim_buf_set_virtual_text(buf, vim.b.line_notes_ns, tonumber(line) - 1, {{'    '..c, 'Comment'}}, {})
  end
  return self
end

function Notes:preview()
  local line_notes = self.storage:get_current_line_notes()
  if vim.tbl_isempty(line_notes) then return end

  local float_content = {}
  for idx, item in ipairs(line_notes) do
    table.insert(float_content, string.format('%d) %s', idx, item.note))
  end
  local line_len = #vim.fn.getline('.')
  vim.lsp.util.open_floating_preview(float_content, 'markdown', {
    offset_x = math.max(line_len + 7, 80) - vim.fn.col('.'),
    offset_y = -1
  })
end

return Notes
