local Storage = require'line-notes/storage'
local Notes = {}

function Notes:new(opts)
  local obj = {}
  obj.opts = opts or {}
  obj.opts.icon = obj.opts.icon or ''
  setmetatable(obj, self)
  self.__index = self
  self.storage = Storage:new(opts):read()
  vim.cmd[[augroup line_notes]]
  vim.cmd[[autocmd!]]
  vim.cmd[[autocmd BufEnter * lua require'line-notes'.render()]]
  vim.cmd[[augroup END]]

  vim.cmd[[command! AddLineNote lua require'line-notes'.add()]]
  vim.cmd[[command! EditLineNote lua require'line-notes'.edit()]]
  vim.cmd[[command! PreviewLineNotes lua require'line-notes'.preview()]]
  vim.cmd[[command! DeleteLineNotes lua require'line-notes'.delete()]]
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
    created_at = os.time(os.date("!*t")),
  })
  return self:render()
end

function Notes:edit()
  local line_notes = self.storage:get_current_line_notes()
  if vim.tbl_isempty(line_notes) then
    return print('No notes available for this line.')
  end

  if #line_notes == 1 then
    local new_note = vim.fn.input('Edit note: ', line_notes[1].note)
    if not new_note or new_note == '' then
      return print('Empty note.')
    end
    line_notes[1].note = new_note
    line_notes[1].updated_at = os.time(os.date("!*t"))
    self.storage:update_line_notes(line_notes)
    return self:render()
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
  line_notes[selected].updated_at = os.time(os.date("!*t"))
  self.storage:update_line_notes(line_notes)
  return self:render()
end

function Notes:delete()
  local line_notes = self.storage:get_current_line_notes()
  if vim.tbl_isempty(line_notes) then
    return print('No notes available for this line.')
  end

  if #line_notes == 1 then
    local choice = vim.fn.confirm(string.format('Delete note %s', line_notes[1].note), '&Yes\n&No\n&Cancel')
    if choice < 1 then return print('Wrong selection.') end
    if choice > 1 then return end
    self.storage:update_line_notes(nil)
    return self:render()
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
    vim.api.nvim_buf_set_virtual_text(buf, vim.b.line_notes_ns, tonumber(line) - 1, {{string.format('  %s  ', self.opts.icon)..c, 'Comment'}}, {})
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

function Notes:get_all(opts)
  opts = opts or {}
  local all = opts.all or false
  local cwd = vim.fn.getcwd()
  local data = self.storage:get()
  local result = {}
  for filename, lines in pairs(data) do
    if all or filename:sub(1, #cwd) == cwd then
      for line, notes in pairs(lines) do
        table.insert(result, {
          filename = filename,
          line = tonumber(line),
          notes = notes
        })
      end
    end
  end
  return result
end

return Notes
