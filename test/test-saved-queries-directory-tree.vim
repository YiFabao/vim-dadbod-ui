let s:suite = themis#suite('Saved queries directory tree')
let s:expect = themis#helper('expect')

function! s:suite.before() abort
  call SetupTestDbs()
endfunction

function s:suite.after() abort
  call delete(g:db_ui_save_location.'/dadbod_ui_test', 'rf')
  call Cleanup()
endfunction

function! s:suite.should_show_saved_queries_with_tree_structure() abort
  " Create directory structure for saved queries
  let save_path = printf('%s/%s', g:db_ui_save_location, 'dadbod_ui_test')
  call mkdir(save_path . '/connection', 'p')
  call mkdir(save_path . '/ops/reports', 'p')
  call mkdir(save_path . '/user', 'p')
  
  " Create some query files
  call writefile(['SELECT 1;'], save_path . '/connection/query1.sql')
  call writefile(['SELECT 2;'], save_path . '/connection/query2.sql')
  call writefile(['SELECT 3;'], save_path . '/ops/maintenance.sql')
  call writefile(['SELECT 4;'], save_path . '/ops/reports/daily.sql')
  call writefile(['SELECT 5;'], save_path . '/ops/reports/weekly.sql')
  call writefile(['SELECT 6;'], save_path . '/user/search.sql')
  
  :DBUI
  normal o
  call s:expect(&filetype).to_equal('dbui')
  
  " Check that Saved queries section exists and is collapsed initially
  call s:expect(search('Saved queries (6)', 'w')).to_be_greater_than(0)
endfunction

function! s:suite.should_expand_saved_queries_section() abort
  " Navigate to Saved queries and expand it
  /Saved queries
  normal o
  
  " Should show directories
  call s:expect(search('connection')).to_be_greater_than(0)
  call s:expect(search('ops')).to_be_greater_than(0)
  call s:expect(search('user')).to_be_greater_than(0)
endfunction

function! s:suite.should_show_collapsed_directories() abort
  " Directories should be collapsed by default (showing ▸ icon)
  let current_line = getline('.')
  call s:expect(current_line =~? '▸').to_be_true()
endfunction

function! s:suite.should_expand_directory() abort
  " Navigate to 'connection' directory and expand it
  /connection
  normal o
  
  " Should show files inside connection
  call s:expect(search('query1.sql')).to_be_greater_than(0)
  call s:expect(search('query2.sql')).to_be_greater_than(0)
endfunction

function! s:suite.should_collapse_directory() abort
  " Collapse the 'connection' directory
  normal o
  
  " Files should be hidden now
  call s:expect(search('query1.sql', 'w')).to_equal(0)
  call s:expect(search('query2.sql', 'w')).to_equal(0)
endfunction

function! s:suite.should_open_saved_query_file() abort
  " Expand connection directory
  /connection
  normal o
  
  " Navigate to and open query1.sql
  /query1.sql
  normal o
  
  call s:expect(&filetype).to_equal('sql')
  call s:expect(getline(1)).to_equal('SELECT 1;')
endfunction

function! s:suite.should_handle_nested_directories() abort
  :DBUI
  /Saved queries
  normal o
  
  " Navigate to ops directory
  /ops
  normal o
  
  " Should show files and subdirectories
  call s:expect(search('maintenance.sql')).to_be_greater_than(0)
  call s:expect(search('reports')).to_be_greater_than(0)
  
  " Expand reports subdirectory
  /reports
  normal o
  
  call s:expect(search('daily.sql')).to_be_greater_than(0)
  call s:expect(search('weekly.sql')).to_be_greater_than(0)
endfunction

function! s:suite.should_delete_saved_query_file() abort
  :DBUI
  /Saved queries
  normal o
  /connection
  normal o
  /query1.sql
  normal d
  
  " File should be deleted from view
  call s:expect(search('query1.sql', 'w')).to_equal(0)
  
  " File should be deleted from disk
  let save_path = printf('%s/%s', g:db_ui_save_location, 'dadbod_ui_test')
  call s:expect(filereadable(save_path . '/connection/query1.sql')).to_be_false()
endfunction

function! s:suite.should_add_saved_query_directory() abort
  runtime autoload/db_ui/utils.vim
  function! db_ui#utils#input(name, val)
    if a:name ==? 'Enter directory name: '
      return 'new-directory'
    endif
  endfunction
  
  :DBUI
  call db_ui#drawer#get().add_saved_query_directory(db_ui#connections_list()[0])
  
  " Directory should be created
  let save_path = printf('%s/%s', g:db_ui_save_location, 'dadbod_ui_test')
  call s:expect(isdirectory(save_path . '/new-directory')).to_be_true()
endfunction

function! s:suite.should_add_saved_query_file() abort
  runtime autoload/db_ui/utils.vim
  function! db_ui#utils#input(name, val)
    if a:name ==? 'Enter file name: '
      return 'new-query.sql'
    endif
  endfunction
  
  :DBUI
  call db_ui#drawer#get().add_saved_query_file(db_ui#connections_list()[0])
  
  " File should be created
  let save_path = printf('%s/%s', g:db_ui_save_location, 'dadbod_ui_test')
  call s:expect(filereadable(save_path . '/new-query.sql')).to_be_true()
endfunction

function! s:suite.should_delete_directory_recursively() abort
  " Create a directory with files for deletion
  let save_path = printf('%s/%s', g:db_ui_save_location, 'dadbod_ui_test')
  call mkdir(save_path . '/to-delete', 'p')
  call writefile(['SELECT 100;'], save_path . '/to-delete/file1.sql')
  call writefile(['SELECT 200;'], save_path . '/to-delete/file2.sql')
  
  :DBUI
  /Saved queries
  normal o
  
  " Delete the directory
  /to-delete
  " Mock the confirm function to return Yes (1)
  let g:confirm_result = 1
  function! confirm(...) abort
    return g:confirm_result
  endfunction
  
  normal d
  
  " Directory and files should be deleted
  call s:expect(search('to-delete', 'w')).to_equal(0)
  call s:expect(isdirectory(save_path . '/to-delete')).to_be_false()
endfunction

function! s:suite.should_maintain_expanded_state_after_refresh() abort
  :DBUI
  /Saved queries
  normal o
  /connection
  normal o
  
  " Store that connection was expanded
  let db = db_ui#connections_list()[0]
  let drawer = db_ui#drawer#get()
  let db_data = drawer.dbui.dbs[db.key_name]
  
  call s:expect(has_key(db_data.saved_queries.dir_expanded, 'connection')).to_be_true()
endfunction
