local Notes = require'line_notes/notes'
local instance = nil

local function setup(opts)
  if instance ~= nil then return instance end
  instance = Notes:new(opts)
  return instance
end

local render = vim.schedule_wrap(function()
  return setup():render()
end)

local preview = vim.schedule_wrap(function()
  return setup():preview()
end)

local function add()
  return setup():add()
end

local function edit()
  return setup():edit()
end

local function delete()
  return setup():delete()
end


return {
  setup = setup,
  render = render,
  add = add,
  edit = edit,
  delete = delete,
  preview = preview,
}
