local picker = require'telescope._extensions.line_notes.picker'
return require'telescope'.register_extension {
  exports = {
    line_notes_project = function()
      local results = require "line-notes".get_list()
      return picker(results)
    end,
  },
}
