# [WIP] line-notes.nvim

Leave personal comments and notes in your files that are visible only to you. Neovim 0.5+ only.

Still in very alpha stage. Breaking changes to be expected.

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
" These are the default values
lua require'line-notes'.setup({
	path = vim.fn.fnamemodify('~/.local/share/line-notes.json'),
	icon = ''
})
```

Use commands:
* `AddLineNote`
* `EditLineNote`
* `PreviewLineNotes`
* `DeleteLineNotes`

TODO:
* [ ] Add option to leave comment per line and column
* [ ] Add option to show bubble icon in floating window and sign (currently available only as virtual text)
* [ ] Improve preview window (borders, positioning)
* [ ] Add finder for notes (Telescope, fzf)
* [ ] Add ability to set up mappings
