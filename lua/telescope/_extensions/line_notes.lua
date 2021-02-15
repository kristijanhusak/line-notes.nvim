local picker = require'telescope._extensions.line_notes.picker'
return require'telescope'.register_extension {
  exports = {
    line_notes = function()
      local results = require "line-notes".get_list({ all = true })
      return picker(results)
    end,
  },
}
