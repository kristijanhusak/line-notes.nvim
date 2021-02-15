local actions = require'telescope.actions'
local finders = require'telescope.finders'
local pickers = require'telescope.pickers'
local sorters = require'telescope.sorters'
local previewers = require'telescope.previewers'

local run = function(results)
  local cwd = vim.fn.getcwd()

  pickers.new({}, {
    prompt_title = "Line notes",
    finder = finders.new_table {
      results = results,
      entry_maker = function(entry)
        local file = entry.filename
        if file:sub(1, #cwd) == cwd then
          file = vim.fn.fnamemodify(entry.filename, ':.')
        end
        local name = string.format('%s:%s', file, entry.line)
        return {
          value = entry,
          ordinal = name,
          display = name,
          preview_command = function(en, bufnr)
            local content = {}
            for i, note in ipairs(en.value.notes) do
              table.insert(content, string.format('%d) %s', i, note.note))
            end
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
          end,
        }
      end,
    },
    sorter = sorters.get_generic_fuzzy_sorter(),
    attach_mappings = function(prompt_bufnr)
      actions._goto_file_selection:enhance({
          post = function()
            local selection = actions.get_selected_entry(prompt_bufnr)
            vim.api.nvim_win_set_cursor(0, { selection.value.line, 0 })
          end
      })
      return true
    end,
    previewer = previewers.display_content.new({}),
  }):find()
end

return run
