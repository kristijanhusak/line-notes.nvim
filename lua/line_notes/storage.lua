local Storage = {}

function Storage:new(opts)
  local obj = opts or {}
  obj.path = obj.path or vim.fn.fnamemodify('~/line-notes.json', ':p')
  obj.data = obj.data or {}

  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Storage:add(entry)
  if not self.data[entry.path] then
    self.data[entry.path] = {}
  end
  if not self.data[entry.path][tostring(entry.line)] then
    self.data[entry.path][tostring(entry.line)] = {}
  end
  table.insert(self.data[entry.path][tostring(entry.line)], {
    col = entry.col,
    note = entry.note,
  })
  self:write()
  return self
end

function Storage:get(key, default)
  local def = default or {}
  if not key then return self.data or def end
  return self.data[key] or def
end

function Storage:read()
  local has_file, fd = pcall(vim.loop.fs_open, vim.fn.expand(self.path, true), "r", 438)
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
  return vim.fn.writefile({vim.fn.json_encode(self.data)}, self.path)
end

return Storage
