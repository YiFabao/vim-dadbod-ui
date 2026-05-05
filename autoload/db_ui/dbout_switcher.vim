let s:query_dbout_map = {}

function! db_ui#dbout#register_query_buffer(query_bufnr, dbout_bufnr) abort
  let s:query_dbout_map[a:query_bufnr] = a:dbout_bufnr
endfunction

function! db_ui#dbout#get_dbout_for_query(query_bufnr) abort
  return get(s:query_dbout_map, a:query_bufnr, -1)
endfunction

function! db_ui#dbout#switch_to_result(query_bufnr) abort
  let dbout_bufnr = db_ui#dbout#get_dbout_for_query(a:query_bufnr)
  if dbout_bufnr <= 0
    return
  endif

  " Find the dbout window
  let dbout_win = bufwinnr(dbout_bufnr)
  if dbout_win > 0
    " dbout window already showing this buffer, nothing to do
    return
  endif

  " Look for any dbout window and switch it
  for win in range(1, winnr('$'))
    let wbuf = winbufnr(win)
    if getbufvar(wbuf, '&filetype') ==? 'dbout'
      " This is a dbout window, switch it to our dbout
      let current_win = winnr()
      exe win.'wincmd w'
      exe 'silent! buffer '.dbout_bufnr
      exe current_win.'wincmd w'
      return
    endif
  endfor
endfunction
