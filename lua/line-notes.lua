local Notes = require'line-notes/notes'
local instance = nil

local function setup(opts)
  if instance ~= nil then return instance end
  instance = Notes:new(opts)
  local has_telescope, telescope = pcall(require, 'telescope')
  if has_telescope then
    telescope.load_extension('line_notes')
    telescope.load_extension('line_notes_project')
  end
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

local function get_list(opts)
  return setup():get_all(opts)
end


return {
  setup = setup,
  render = render,
  add = add,
  edit = edit,
  delete = delete,
  preview = preview,
  get_list = get_list,
}
