local Storage = {}

function Storage:new(opts)
  local obj = {}
  obj.opts = opts or {}
  obj.opts.path = obj.opts.path or vim.fn.stdpath('data')..'/line-notes.json'
  obj.data = {}

  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Storage:add(entry)
  if not self.data[entry.path] then
    self.data[entry.path] = {}
  end
  if not self.data[entry.path][tostring(entry.line)] then
    self.data[entry.path][tostring(entry.line)] = {
      line_content = entry.line_content,
      notes = {},
    }
  end
  table.insert(self.data[entry.path][tostring(entry.line)].notes, {
    col = entry.col,
    note = entry.note,
    created_at = entry.created_at,
  })
  self:write()
  return self
end

function Storage:update_line_notes(line_notes)
  local path = vim.fn.expand('%:p')
  self.data[path][tostring(vim.fn.line('.'))].notes = line_notes
  if not line_notes then
    self.data[path] = nil
  end
  self:write()
  return self
end

function Storage:get(key, default)
  if not key then return self.data end
  local def = default or {}
  if type(key) == 'string' then return self.data[tostring(key)] or def end

  local result = self.data
  for _, path in ipairs(key) do
    result = result[tostring(path)] or {}
  end
  if vim.tbl_isempty(result) then return def end
  return result
end

function Storage:get_current_line_notes()
  local current_path = vim.fn.expand('%:p')
  local line = vim.fn.line('.')
  return self:get({current_path, line, 'notes'})
end

function Storage:update_note_line(path, old_line, new_line)
  local notes = self:get({path, old_line}, {})
  if vim.tbl_isempty(notes) then return end
  self.data[path][tostring(new_line)] = notes
  self.data[path][tostring(old_line)] = nil
end

function Storage:read()
  local has_file, fd = pcall(vim.loop.fs_open, vim.fn.expand(self.opts.path, true), "r", 438)
  if has_file and fd then
    local stat = assert(vim.loop.fs_fstat(fd))
    self.data = assert(vim.loop.fs_read(fd, stat.size, 0))
    self.data = vim.fn.json_decode(self.data)
    assert(vim.loop.fs_close(fd))
  end
  return self
end

function Storage:write()
  -- TODO: Use fs_write
  return vim.fn.writefile({vim.fn.json_encode(self.data)}, self.opts.path)
end

return Storage
