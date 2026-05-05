let s:suite = themis#suite('Saved queries tree structure')
let s:expect = themis#helper('expect')

function! s:suite.before() abort
  call SetupTestDbs()
  " Create a complex directory structure
  let save_path = printf('%s/%s', g:db_ui_save_location, 'dadbod_ui_test')
  call mkdir(save_path . '/climb', 'p')
  call mkdir(save_path . '/miner', 'p')
  call mkdir(save_path . '/ops', 'p')
  call mkdir(save_path . '/report', 'p')
  call mkdir(save_path . '/sni', 'p')
  call mkdir(save_path . '/test', 'p')
  call mkdir(save_path . '/traffic', 'p')
  call mkdir(save_path . '/user', 'p')
  
  " Create query files in each directory
  call writefile(['-- climb query'], save_path . '/climb/climb_query.sql')
  call writefile(['-- miner query'], save_path . '/miner/miner_query.sql')
  call writefile(['-- ops query'], save_path . '/ops/ops_query.sql')
  call writefile(['-- report query'], save_path . '/report/report_query.sql')
  call writefile(['-- sni query'], save_path . '/sni/sni_query.sql')
  call writefile(['-- test query'], save_path . '/test/test_query.sql')
  call writefile(['-- traffic query'], save_path . '/traffic/traffic_query.sql')
  call writefile(['-- user query'], save_path . '/user/user_query.sql')
endfunction

function s:suite.after() abort
  call delete(g:db_ui_save_location.'/dadbod_ui_test', 'rf')
  call Cleanup()
endfunction

function! s:suite.should_display_directories_when_expanded() abort
  :DBUI
  normal o  " Expand database connection
  
  /Saved queries
  normal o  " Expand saved queries
  
  " Should show all 8 directories
  call s:expect(search('climb')).to_be_greater_than(0)
  call s:expect(search('miner')).to_be_greater_than(0)
  call s:expect(search('ops')).to_be_greater_than(0)
  call s:expect(search('report')).to_be_greater_than(0)
  call s:expect(search('sni')).to_be_greater_than(0)
  call s:expect(search('test')).to_be_greater_than(0)
  call s:expect(search('traffic')).to_be_greater_than(0)
  call s:expect(search('user')).to_be_greater_than(0)
endfunction

function! s:suite.should_show_files_when_directory_expanded() abort
  :DBUI
  normal o
  /Saved queries
  normal o
  
  " Expand climb directory
  /climb
  normal o
  
  " Should show the query file
  call s:expect(search('climb_query.sql')).to_be_greater_than(0)
endfunction

function! s:suite.should_handle_multiple_files_in_directory() abort
  let save_path = printf('%s/%s', g:db_ui_save_location, 'dadbod_ui_test')
  call writefile(['-- another climb query'], save_path . '/climb/another_query.sql')
  call writefile(['-- yet another climb query'], save_path . '/climb/yet_another.sql')
  
  :DBUI
  normal o
  /Saved queries
  normal o
  /climb
  normal o
  
  call s:expect(search('climb_query.sql')).to_be_greater_than(0)
  call s:expect(search('another_query.sql')).to_be_greater_than(0)
  call s:expect(search('yet_another.sql')).to_be_greater_than(0)
endfunction

function! s:suite.should_toggle_directory_expansion() abort
  :DBUI
  normal o
  /Saved queries
  normal o
  /climb
  normal o  " Expand
  
  call s:expect(search('climb_query.sql', 'w')).to_be_greater_than(0)
  
  normal o  " Collapse
  
  call s:expect(search('climb_query.sql', 'w')).to_equal(0)
endfunction

function! s:suite.should_open_file_from_tree() abort
  :DBUI
  normal o
  /Saved queries
  normal o
  /climb
  normal o
  /climb_query.sql
  normal o
  
  call s:expect(&filetype).to_equal('sql')
  call s:expect(getline(1)).to_equal('-- climb query')
endfunction

function! s:suite.should_handle_empty_directories() abort
  let save_path = printf('%s/%s', g:db_ui_save_location, 'dadbod_ui_test')
  call mkdir(save_path . '/empty-dir', 'p')
  
  :DBUI
  normal o
  /Saved queries
  normal o
  
  /empty-dir
  normal o
  
  " Should not error and directory should be shown but empty
  call s:expect(search('empty-dir')).to_be_greater_than(0)
endfunction

function! s:suite.should_display_correct_file_count() abort
  :DBUI
  normal o
  
  " Should show Saved queries (8) for 8 directories
  call s:expect(search('Saved queries (8)', 'w')).to_be_greater_than(0)
endfunction
