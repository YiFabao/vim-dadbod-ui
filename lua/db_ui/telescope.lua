local M = {}

function M.run_search(save_path)
  local has_telescope, builtin = pcall(require, 'telescope.builtin')
  if not has_telescope then
    vim.notify('Telescope is not installed.', vim.log.levels.ERROR)
    return
  end

  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  builtin.live_grep({
    search_dirs = { save_path },
    attach_mappings = function(prompt_bufnr, map)
      local function select_entry()
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          local filepath = selection.filename or selection.path
          if filepath then
            vim.fn['Db_ui_open_file_in_query'](filepath)
          end
        end
      end

      map('i', '<CR>', select_entry)
      map('n', '<CR>', select_entry)
      return true
    end,
  })
end

return M
