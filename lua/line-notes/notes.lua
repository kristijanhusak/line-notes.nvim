local Storage = require'line-notes/storage'
local Popup = require'line-notes/popup'
local Notes = {}
local borders = {
  top_left = '╭', top_mid = '─', top_right = '╮', mid = '│', bottom_left = '╰', bottom_right= '╯',
}
local default_mappings = {
  add = '<leader>lna',
  edit = '<leader>lne',
  preview = '<leader>lnp',
  delete = '<leader>lnd',
}

function Notes:new(opts)
  local obj = {}
  obj.opts = opts or {}
  obj.opts.icon = obj.opts.icon or ''
  obj.opts.border_chars = obj.opts.border_chars or borders
  obj.opts.preview_max_width = obj.opts.preview_max_width or 80
  obj.opts.auto_preview = obj.opts.auto_preview or false
  obj.opts.mappings = obj.opts.mappings ~= nil and obj.opts.mappings or default_mappings
  setmetatable(obj, self)
  self.__index = self
  self.storage = Storage:new(opts):read()
  obj:setup_autocmds()
  obj:setup_mappings()
  return obj
end

function Notes:setup_autocmds()
  vim.cmd[[augroup line_notes]]
  vim.cmd[[autocmd!]]
  vim.cmd[[autocmd BufEnter * lua require'line-notes'.render()]]
  if self.opts.auto_preview then
    vim.cmd[[autocmd CursorHold * lua require'line-notes'.preview()]]
  end
  vim.cmd[[augroup END]]

  vim.cmd[[command! LineNotesAdd lua require'line-notes'.add()]]
  vim.cmd[[command! LineNotesEdit lua require'line-notes'.edit()]]
  vim.cmd[[command! LineNotesPreview lua require'line-notes'.preview()]]
  vim.cmd[[command! LineNotesDelete lua require'line-notes'.delete()]]
  vim.cmd[[command! LineNotesRedraw lua require'line-notes'.render()]]
end

function Notes:setup_mappings()
  if self.opts.mappings == false then return end
  local mappings = vim.deepcopy(default_mappings)

  if type(self.opts.mappings) == 'table' then
    for action, map in pairs(self.opts.mappings) do
      if mappings[action] then
        mappings[action] = map
      end
    end
  end

  for name, mapping in pairs(mappings) do
    if default_mappings[name] ~= nil and mapping ~= nil then
      vim.api.nvim_set_keymap('n', mapping, ':LineNotes'..(name:sub(1,1):upper()..name:sub(2))..'<CR>', {
        nowait = true,
        silent = true,
        noremap = true,
      })
    end
  end
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
  if Popup.is_opened() then
    Popup.close()
    self:preview()
  end
  return self
end

function Notes:preview()
  local line_notes = self.storage:get_current_line_notes()
  if vim.tbl_isempty(line_notes) then return end

  local float_content = {}
  for idx, item in ipairs(line_notes) do
    table.insert(float_content, string.format('%d. %s', idx, item.note))
  end
  Popup.create(float_content, self.opts)
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
