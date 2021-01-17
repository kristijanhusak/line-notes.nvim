local Notes = require'line_notes/notes'
local instance = nil

local function setup(opts)
  if instance ~= nil then return instance end
  instance = Notes:new(opts)
  vim.cmd[[augroup line_commenter]]
  vim.cmd[[autocmd!]]
  vim.cmd[[autocmd BufEnter * lua require'line_notes'.render()]]
  vim.cmd[[augroup END]]

  vim.cmd[[command! AddLineComment lua require'line_notes'.add()]]
  vim.cmd[[command! PreviewLineComment lua require'line_notes'.preview()]]
end

local render = vim.schedule_wrap(function()
  return setup():render()
end)

local function preview()
  return setup():preview()
end

local function add()
  return setup():add()
end


return {
  setup = setup,
  render = render,
  add = add,
  preview = preview,
}
