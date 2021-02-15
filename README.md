# [WIP] line-notes.nvim

Leave personal comments and notes in your files that are visible only to you. Neovim 0.5+ only.

Still in very alpha stage. Breaking changes to be expected.

![line-notes](https://user-images.githubusercontent.com/1782860/107889483-3178e380-6f13-11eb-9095-f115756f7b38.gif)

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
	path = vim.fn.fnamemodify('~/.local/share/line-notes.json', ':p'), -- path where to save the file
	border_chars = { top_left = '╭', top_mid = '─', top_right = '╮', mid = '│', bottom_left = '╰', bottom_right= '╯' },
	preview_max_width = 80, -- maximum width of preview notes float window
	auto_preview = false -- automatically open preview notes float window
	icon = ''
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

TODO:
* [ ] Add option to leave comment per line and column
* [ ] Add option to show bubble icon in floating window and sign (currently available only as virtual text)
* [x] Improve preview window (borders, positioning)
* [x] Add finder for notes (Telescope)
* [ ] Add ability to set up mappings
