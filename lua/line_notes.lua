local comments = {}
local path = vim.fn.fnamemodify('~/line-comments.json', ':p')
local has_file, fd = pcall(vim.loop.fs_open, vim.fn.expand(path, true), "r", 438)
if has_file and fd then
  local stat = assert(vim.loop.fs_fstat(fd))
  comments = assert(vim.loop.fs_read(fd, stat.size, 0))
  comments = vim.fn.json_decode(comments)
  assert(vim.loop.fs_close(fd))
end
local M = {}

M.add = function()
  local current_path = vim.fn.expand('%:p')
  local line = vim.fn.line('.')
  if not comments[current_path] then
    comments[current_path] = {}
  end
  local comment = vim.fn.input('Enter comment: ')
  if not comment or comment == '' then return end
  if not comments[current_path][tostring(line)] then
    comments[current_path][tostring(line)] = {}
  end
  table.insert(comments[current_path][tostring(line)], {
      col = vim.fn.col('.'),
      comment = comment,
  })
  vim.fn.writefile({vim.fn.json_encode(comments)}, path)
  M.render()
end

M.render = function()
  local current_path = vim.fn.expand('%:p')
  local buf = vim.api.nvim_get_current_buf()
  local file_comments = comments[current_path] or {}
  if vim.tbl_isempty(file_comments) then return end
  if not vim.b.line_commenter_ns then
    vim.b.line_commenter_ns = vim.api.nvim_create_namespace(string.format('line_commenter_%s', current_path));
  end
  for line, comments_by_line in pairs(file_comments) do
    local c = #comments_by_line > 1 and #comments_by_line or ''
    vim.api.nvim_buf_set_virtual_text(buf, vim.b.line_commenter_ns, tonumber(line) - 1, {{'    '..c, 'Comment'}}, {})
  end
end

M.preview = vim.schedule_wrap(function()
  local line = vim.fn.line('.')
  local current_path = vim.fn.expand('%:p')
  local line_comments = comments[current_path] or {}
  line_comments = line_comments[tostring(line)] or {}

  if not vim.tbl_isempty(line_comments) then
    local float_content = vim.tbl_map(function(item) return item.comment end, line_comments)
    local line_len = #vim.fn.getline('.')
    vim.lsp.util.open_floating_preview(float_content, 'markdown', {
        offset_x = math.max(line_len + 7, 80) - vim.fn.col('.'),
        offset_y = -1
      })
  end
end)

vim.cmd[[augroup line_commenter]]
  vim.cmd[[autocmd!]]
  vim.cmd[[autocmd BufEnter * lua require'partials/line_commenter'.render()]]
vim.cmd[[augroup END]]

vim.cmd[[command! AddLineComment lua require'partials/line_commenter'.add()]]
vim.cmd[[command! PreviewLineComment lua require'partials/line_commenter'.preview()]]

return M
