let s:suite = themis#suite('Safe query')
let s:expect = themis#helper('expect')

function! s:suite.before() abort
  call SetupTestDbs()
  sleep 1
endfunction

function! s:suite.after() abort
  call Cleanup()
endfunction

function! s:suite.should_block_delete_without_where() abort
  :DBUI
  norm ojo
  call s:expect(&filetype).to_equal('sql')
  " 写入无 WHERE 的 DELETE
  norm!Idelete from contacts
  write
  " 应该被拦截，最后一条通知是 warning
  let last_msg = db_ui#notifications#get_last_msg()
  call s:expect(last_msg).to_match('Blocked')
endfunction

function! s:suite.should_block_update_without_where() abort
  :DBUI
  norm ojo
  norm!Iupdate contacts set first_name = 'test'
  write
  let last_msg = db_ui#notifications#get_last_msg()
  call s:expect(last_msg).to_match('Blocked')
endfunction

function! s:suite.should_allow_delete_with_where() abort
  :DBUI
  norm ojo
  norm!Idelete from contacts where contact_id = 999
  write
  " 不应被拦截，最后一条通知不应包含 Blocked
  let last_msg = db_ui#notifications#get_last_msg()
  call s:expect(last_msg).not.to_match('Blocked')
endfunction

function! s:suite.should_allow_update_with_where() abort
  :DBUI
  norm ojo
  norm!Iupdate contacts set first_name = 'test' where contact_id = 999
  write
  let last_msg = db_ui#notifications#get_last_msg()
  call s:expect(last_msg).not.to_match('Blocked')
endfunction

function! s:suite.should_allow_select_without_where() abort
  :DBUI
  norm ojo
  norm!Iselect * from contacts
  write
  let last_msg = db_ui#notifications#get_last_msg()
  call s:expect(last_msg).not.to_match('Blocked')
endfunction

function! s:suite.should_allow_bypass_when_disabled() abort
  let g:db_ui_safe_query = 0
  :DBUI
  norm ojo
  norm!Idelete from contacts
  write
  " 关闭保护后，无 WHERE 的 DELETE 不应被拦截
  let last_msg = db_ui#notifications#get_last_msg()
  call s:expect(last_msg).not.to_match('Blocked')
  let g:db_ui_safe_query = 1
endfunction
