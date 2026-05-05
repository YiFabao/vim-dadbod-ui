local M = {}

local function get_current_db()
  local drawer = vim.g.db_ui_drawer_instance
  if not drawer then
    return nil
  end
  local current_item = drawer.get_current_item()
  if not current_item or not current_item.dbui_db_key_name then
    return nil
  end
  return drawer.dbui.dbs[current_item.dbui_db_key_name]
end

local function open_file_in_query_buf(filepath)
  local drawer = vim.g.db_ui_drawer_instance
  if not drawer then
    return
  end
  local db = get_current_db()
  if not db then
    return
  end

  local query = drawer.get_query()
  local item = {
    type = 'buffer',
    file_path = filepath,
    saved = true,
    dbui_db_key_name = db.key_name,
  }
  query.open(item, 'edit')
end

function M.search_content()
  local has_telescope, builtin = pcall(require, 'telescope.builtin')
  if not has_telescope then
    vim.notify('Telescope is not installed.', vim.log.levels.ERROR)
    return
  end

  local db = get_current_db()
  if not db or not db.save_path then
    vim.notify('No save location configured.', vim.log.levels.ERROR)
    return
  end

  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  builtin.live_grep({
    search_dirs = { db.save_path },
    attach_mappings = function(prompt_bufnr, map)
      local function select_entry()
        local selection = action_state.get_selected_entry()
        if selection then
          local filepath = selection.filename or selection.path
          actions.close(prompt_bufnr)
          if filepath then
            open_file_in_query_buf(filepath)
          end
        end
      end

      actions.set_keymap('i', '<CR>', select_entry)
      actions.set_keymap('n', '<CR>', select_entry)
      return true
    end,
  })
end

return M
