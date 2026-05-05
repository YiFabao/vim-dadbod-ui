" Manage per-query-buffer dbout buffers
" When switching between query buffers, automatically show the corresponding dbout

let s:query_dbout_map = {}
let s:last_query_bufnr = -1

function! db_ui#dbout#register_query_buffer(query_bufnr, dbout_bufnr) abort
  let s:query_dbout_map[a:query_bufnr] = a:dbout_bufnr
endfunction

function! db_ui#dbout#get_dbout_for_query(query_bufnr) abort
  return get(s:query_dbout_map, a:query_bufnr, -1)
endfunction

function! db_ui#dbout#on_query_enter() abort
  let bufnr = bufnr()
  if bufnr == s:last_query_bufnr
    return
  endif
  let s:last_query_bufnr = bufnr

  " Find and switch to the dbout window for this query
  let dbout_bufnr = db_ui#dbout#get_dbout_for_query(bufnr)
  if dbout_bufnr <= 0
    return
  endif

  " Find dbout windows (usually at the bottom)
  for win in range(1, winnr('$'))
    let wbuf = winbufnr(win)
    if getbufvar(wbuf, '&filetype') ==? 'dbout'
      " Found a dbout window, switch it to show our dbout
      exe win.'wincmd w'
      exe 'buffer '.dbout_bufnr
      " Go back to query window
      wincmd p
      return
    endif
  endfor
endfunction

augroup dbui_dbout_switcher
  autocmd!
  autocmd BufEnter *.sql,*.mysql,*.plsql call db_ui#dbout#on_query_enter()
augroup END
