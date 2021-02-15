local api = vim.api
local util = vim.lsp.util

local floating_winnr = nil
local border_winnr = nil

local function close()
  if border_winnr ~= nil then
    pcall(vim.api.nvim_win_close, border_winnr, true)
    border_winnr = nil
  end
  if floating_winnr ~= nil then
    pcall(vim.api.nvim_win_close, floating_winnr, true)
    floating_winnr = nil
  end
end

local function is_opened()
  return floating_winnr ~= nil
end

local function create(contents, options)
  vim.validate {
    contents = { contents, 't' };
    options = { options, 't', true }
  }

  local opts = { max_width = options.preview_max_width }
  local borders = options.border_chars

  contents = util._trim_and_pad(contents, opts)

  opts.wrap_at = api.nvim_win_get_width(0)
  local width, height = util._make_floating_popup_size(contents, opts)

  local floating_bufnr = api.nvim_create_buf(false, true)
  local float_option = util.make_floating_popup_options(width, height, opts)
  float_option.relative = 'editor'
  float_option.anchor = 'NW'
  float_option.row = math.max(1, vim.fn.line('.') - vim.fn.line('w0') + 1)
  float_option.col = vim.o.columns - options.preview_max_width - 2
  api.nvim_buf_set_option(floating_bufnr, 'filetype', 'markdown')
  if not floating_winnr then
    floating_winnr = api.nvim_open_win(floating_bufnr, false, float_option)
  else
    api.nvim_win_set_buf(floating_winnr, floating_bufnr)
    api.nvim_win_set_config(floating_winnr, float_option)
  end
  api.nvim_win_set_option(floating_winnr, 'wrap', true)
  api.nvim_win_set_option(floating_winnr, 'winhl', 'Normal:Normal')
  api.nvim_buf_set_lines(floating_bufnr, 0, -1, true, contents)
  api.nvim_buf_set_option(floating_bufnr, 'modifiable', false)
  api.nvim_buf_set_option(floating_bufnr, 'bufhidden', 'wipe')

  local border_bufnr = api.nvim_create_buf(false, true)
  local border_option = vim.fn.copy(float_option)
  border_option.width = border_option.width + 2
  border_option.height = border_option.height + 2
  border_option.row = border_option.row - 1
  border_option.col = border_option.col - 1
  local border_middle = borders.mid..string.rep(' ', border_option.width - 2)..borders.mid
  local border_content = {borders.top_left..string.rep(borders.top_mid, border_option.width - 2)..borders.top_right}
  local counter = border_option.height - 2
  while (counter > 0) do
    table.insert(border_content, border_middle)
    counter = counter - 1
  end
  table.insert(border_content, borders.bottom_left..string.rep(borders.top_mid, border_option.width - 2)..borders.bottom_right)

  api.nvim_buf_set_lines(border_bufnr, 0, -1, true, border_content)
  api.nvim_buf_set_option(border_bufnr, 'modifiable', false)
  api.nvim_buf_set_option(border_bufnr, 'bufhidden', 'wipe')
  if not border_winnr then
    border_winnr = api.nvim_open_win(border_bufnr, false, border_option)
  else
    api.nvim_win_set_buf(border_winnr, border_bufnr)
    api.nvim_win_set_config(border_winnr, border_option)
  end
  api.nvim_win_set_option(border_winnr, 'winhl', 'Normal:Normal')
  api.nvim_win_set_option(border_winnr, 'winblend', 10)
  api.nvim_command("autocmd CursorMoved,CursorMovedI,BufHidden,BufLeave <buffer> ++once lua require'line-notes/popup'.close()")

  return floating_bufnr, floating_winnr, border_bufnr, border_winnr
end

return {
  create = create,
  close = close,
  is_opened = is_opened,
}
