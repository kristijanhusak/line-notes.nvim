# [WIP] line-notes.nvim

Leave personal comments and notes in your files that are visible only to you. Neovim 0.5+ only.

Still in very alpha stage. Breaking changes to be expected.

![line-notes-floating](https://user-images.githubusercontent.com/1782860/107988352-16b87480-6fd0-11eb-9d85-b09bb2c8c942.gif)

## Installation
```vim
" vim-packager
call packager#add('kristijanhusak/line-notes.nvim')
```

or

```lua
-- packer.nvim
use {'kristijanhusak/line-notes.nvim'}
```

Or

```vim
" vim-plug
Plug 'kristijanhusak/line-notes.nvim'
```

```vim
" These are the default options
lua require'line-notes'.setup({
	path = vim.fn.stdpath('data')..'/line-notes.json', -- path where to save the file
	border_chars = { top_left = '╭', top_mid = '─', top_right = '╮', mid = '│', bottom_left = '╰', bottom_right= '╯' },
	preview_max_width = 80, -- maximum width of preview notes float window
	auto_preview = false -- automatically open preview notes float window
	icon = '',
	mappings = {  -- pass in false to disable all. Pass in table to override. Partial overrides are possible
		add = '<leader>lna', -- pass null to disable the mapping
		edit = '<leader>lne',
		preview = '<leader>lnp',
		delete = '<leader>lnd',
	}
})
```

Use commands:
* `LineNotesAdd`
* `LineNotesEdit`
* `LineNotesPreview`
* `LineNotesDelete`

Or if you use [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim):
* `Telescope line_notes` - All line notes
* `Telescope line_notes_project` - Notes in files that are part of current working directory

## Limitations
Notes are currently tied to the line number and content in the file. If line content is changed notes stay on the same place, even if moved around.
This can cause confusion if notes are left in places that are changed a lot.
Currently there is no easy way to keep track of these changes in a simple way, but if anyone has any idea how to solve that issue,
please let me know.

If line content is just moved to another line number, line-notes syncs that change and follows the line for the notes. If that's unexpected
behaviour, open an issue.

TODO:
* [ ] Add option to leave comment per line and column
* [ ] Add option to show bubble icon in floating window and sign (currently available only as virtual text)
* [x] Improve preview window (borders, positioning)
* [x] Add finder for notes (Telescope)
* [x] Add ability to set up mappings
