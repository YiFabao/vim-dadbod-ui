" Save and restore view state
let s:view_file = ''

function! db_ui#views#get_save_path() abort
  if empty(s:view_file)
    let base = get(g:, 'db_ui_save_location', expand('~/.local/share/db_ui'))
    let s:view_file = base . '/.view_state.json'
  endif
  return s:view_file
endfunction

function! db_ui#views#save() abort
  let dbui = db_ui#get_instance()
  if empty(dbui)
    return db_ui#notifications#error('DBUI is not initialized')
  endif

  let drawer = dbui.drawer
  if empty(drawer) || empty(drawer.dbui)
    return db_ui#notifications#error('No drawer available')
  endif

  let state = {}

  " --- Drawer state ---
  let state.drawer_open = drawer.is_opened()
  let state.drawer_cursor_line = -1
  if state.drawer_open
    let drawer_winnr = drawer.get_winnr()
    if drawer_winnr > 0
      " Save cursor position in drawer window
      let current_win = winnr()
      execute drawer_winnr . 'wincmd w'
      let state.drawer_cursor_line = line('.')
      execute current_win . 'wincmd w'
    endif
  endif
  let state.show_details = drawer.show_details
  let state.show_dbout_list = drawer.show_dbout_list

  " --- Database expansion state ---
  let state.dbs = {}
  for [key_name, db] in items(drawer.dbui.dbs)
    let db_state = {
          \ 'expanded': db.expanded,
          \ 'buffers_expanded': db.buffers.expanded,
          \ 'saved_queries_expanded': db.saved_queries.expanded,
          \ 'dir_expanded': get(db.saved_queries, 'dir_expanded', {}),
          \ }

    " Tables expansion (non-schema DBs)
    if has_key(db, 'tables')
      let db_state.tables_expanded = db.tables.expanded
      let db_state.table_items = {}
      for table in db.tables.list
        if has_key(db.tables.items, table)
          let db_state.table_items[table] = db.tables.items[table].expanded
        endif
      endfor
    endif

    " Schemas expansion (schema-supporting DBs)
    if has_key(db, 'schemas') && db.schema_support
      let db_state.schemas_expanded = db.schemas.expanded
      let db_state.schema_items = {}
      for schema in db.schemas.list
        if has_key(db.schemas.items, schema)
          let schema_item = db.schemas.items[schema]
          let db_state.schema_items[schema] = {
                \ 'expanded': schema_item.expanded,
                \ 'tables': {},
                \ }
          if has_key(schema_item, 'tables')
            for table in schema_item.tables.list
              if has_key(schema_item.tables.items, table)
                let db_state.schema_items[schema].tables[table] = schema_item.tables.items[table].expanded
              endif
            endfor
          endif
        endif
      endfor
    endif

    let state.dbs[key_name] = db_state
  endfor

  " --- Open query buffers ---
  let state.query_buffers = []
  let active_bufnr = bufnr()
  let cache = db_ui#dbout#get_cache()
  for b in range(1, bufnr('$'))
    if bufexists(b) && !empty(getbufvar(b, 'dbui_db_key_name', ''))
      let qbuf = {
            \ 'file': bufname(b),
            \ 'dbui_db_key_name': getbufvar(b, 'dbui_db_key_name'),
            \ 'bind_params': getbufvar(b, 'dbui_bind_params', []),
            \ 'is_active': (b == active_bufnr),
            \ '_dbout_content': get(cache, b, []),
            \ }
      call add(state.query_buffers, qbuf)
    endif
  endfor

  " --- Dbout content cache ---
  " Save content mapping by query file path instead of bufnr
  let state.dbout_cache = {}
  for qbuf in state.query_buffers
    if !empty(qbuf.file)
      let state.dbout_cache[qbuf.file] = qbuf._dbout_content
    endif
  endfor

  " --- Save to file ---
  let save_path = db_ui#views#get_save_path()
  let dir = fnamemodify(save_path, ':h')
  if !isdirectory(dir)
    call mkdir(dir, 'p')
  endif

  let json_str = json_encode(state)
  call writefile([json_str], save_path)

  call db_ui#notifications#info('View saved to ' . save_path)
endfunction

function! db_ui#views#restore() abort
  let save_path = db_ui#views#get_save_path()
  if !filereadable(save_path)
    return db_ui#notifications#error('No saved view found at ' . save_path)
  endif

  let lines = readfile(save_path)
  if empty(lines)
    return db_ui#notifications#error('Saved view file is empty')
  endif

  let state = json_decode(lines[0])

  " --- Open query buffers first ---
  let restored_active = -1
  let restored_count = 0
  for qbuf in state.query_buffers
    if !empty(qbuf.file) && filereadable(qbuf.file)
      let edit_action = restored_count == 0 ? 'edit' : 'split'
      " Open the buffer via query interface
      let drawer = db_ui#get_drawer()
      if !empty(drawer)
        let query = drawer.get_query()
        let open_item = {
              \ 'type': 'buffer',
              \ 'file_path': qbuf.file,
              \ 'saved': 1,
              \ 'dbui_db_key_name': qbuf.dbui_db_key_name,
              \ 'label': fnamemodify(qbuf.file, ':t:r')
              \ }
        call query.open(open_item, edit_action)

        " Restore bind params
        if has_key(qbuf, 'bind_params') && !empty(qbuf.bind_params)
          let b:dbui_bind_params = qbuf.bind_params
        endif

        if get(qbuf, 'is_active', 0)
          let restored_active = bufnr(qbuf.file)
        endif
        let restored_count += 1
      endif
    endif
  endfor

  " Activate the last active buffer
  if restored_active > 0
    exe 'buffer ' . restored_active
  endif

  " --- Restore dbout cache to current query buffers ---
  if has_key(state, 'dbout_cache')
    let cache = db_ui#dbout#get_cache()
    for b in range(1, bufnr('$'))
      if bufexists(b) && !empty(getbufvar(b, 'dbui_db_key_name', ''))
        let f = bufname(b)
        if has_key(state.dbout_cache, f) && !empty(state.dbout_cache[f])
          let cache[b] = state.dbout_cache[f]
          " Trigger switch_to_result to display the content in dbout window
          call db_ui#dbout#switch_to_result(b)
        endif
      endif
    endfor
  endif

  " --- Restore drawer state ---
  let drawer = db_ui#get_drawer()
  if !empty(drawer) && !empty(drawer.dbui)
    " Restore expansion states
    if has_key(state, 'dbs')
      for [key_name, db_state] in items(state.dbs)
        if has_key(drawer.dbui.dbs, key_name)
          let db = drawer.dbui.dbs[key_name]
          let db.expanded = get(db_state, 'expanded', db.expanded)

          if has_key(db, 'buffers')
            let db.buffers.expanded = get(db_state, 'buffers_expanded', db.buffers.expanded)
          endif
          if has_key(db, 'saved_queries')
            let db.saved_queries.expanded = get(db_state, 'saved_queries_expanded', db.saved_queries.expanded)
            if has_key(db_state, 'dir_expanded')
              let db.saved_queries.dir_expanded = db_state.dir_expanded
            endif
          endif

          " Tables
          if has_key(db_state, 'tables_expanded') && has_key(db, 'tables')
            let db.tables.expanded = db_state.tables_expanded
            if has_key(db_state, 'table_items')
              for [table, expanded] in items(db_state.table_items)
                if has_key(db.tables.items, table)
                  let db.tables.items[table].expanded = expanded
                endif
              endfor
            endif
          endif

          " Schemas
          if has_key(db_state, 'schemas_expanded') && has_key(db, 'schemas')
            let db.schemas.expanded = db_state.schemas_expanded
            if has_key(db_state, 'schema_items')
              for [schema, schema_state] in items(db_state.schema_items)
                if has_key(db.schemas.items, schema)
                  let db.schemas.items[schema].expanded = schema_state.expanded
                  if has_key(schema_state, 'tables')
                    for [table, expanded] in items(schema_state.tables)
                      if has_key(db.schemas.items[schema].tables.items, table)
                        let db.schemas.items[schema].tables.items[table].expanded = expanded
                      endif
                    endfor
                  endif
                endif
              endfor
            endif
          endif
        endif
      endfor
    endif

    " Restore drawer UI state
    if has_key(state, 'show_details')
      let drawer.show_details = state.show_details
    endif
    if has_key(state, 'show_dbout_list')
      let drawer.show_dbout_list = state.show_dbout_list
    endif

    " Re-render drawer
    call drawer.render({ 'queries': 1 })

    " Restore cursor position in drawer
    if has_key(state, 'drawer_cursor_line') && state.drawer_cursor_line > 0
      let drawer_winnr = drawer.get_winnr()
      if drawer_winnr > 0
        let current_win = winnr()
        execute drawer_winnr . 'wincmd w'
        call cursor(state.drawer_cursor_line, 1)
        execute current_win . 'wincmd w'
      endif
    endif

    " Re-open drawer if it was open
    if get(state, 'drawer_open', 0) && !drawer.is_opened()
      call db_ui#open('')
    endif
  endif

  call db_ui#notifications#info('View restored')
endfunction
