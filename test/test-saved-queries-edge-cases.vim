let s:suite = themis#suite('Saved queries edge cases')
let s:expect = themis#helper('expect')

function! s:suite.before() abort
  call SetupTestDbs()
endfunction

function s:suite.after() abort
  call delete(g:db_ui_save_location.'/dadbod_ui_test', 'rf')
  call Cleanup()
endfunction

function! s:suite.should_handle_deeply_nested_structure() abort
  let save_path = printf('%s/%s', g:db_ui_save_location, 'dadbod_ui_test')
  
  " Create deeply nested structure
  call mkdir(save_path . '/level1/level2/level3/level4', 'p')
  call writefile(['-- deep query'], save_path . '/level1/level2/level3/level4/deep.sql')
  call writefile(['-- level2 query'], save_path . '/level1/level2/mid.sql')
  call writefile(['-- level1 query'], save_path . '/level1/top.sql')
  
  :DBUI
  normal o
  /Saved queries
  normal o
  
  " Expand level1
  /level1
  normal o
  call s:expect(search('top.sql')).to_be_greater_than(0)
  call s:expect(search('level2')).to_be_greater_than(0)
  
  " Expand level2
  /level2
  normal o
  call s:expect(search('mid.sql')).to_be_greater_than(0)
  call s:expect(search('level3')).to_be_greater_than(0)
  
  " Expand level3
  /level3
  normal o
  call s:expect(search('level4')).to_be_greater_than(0)
  
  " Expand level4
  /level4
  normal o
  call s:expect(search('deep.sql')).to_be_greater_than(0)
endfunction

function! s:suite.should_handle_special_characters_in_filename() abort
  let save_path = printf('%s/%s', g:db_ui_save_location, 'dadbod_ui_test')
  call mkdir(save_path . '/special', 'p')
  
  " Create files with various characters
  call writefile(['-- query with spaces'], save_path . '/special/query with spaces.sql')
  call writefile(['-- query with dash'], save_path . '/special/query-with-dash.sql')
  call writefile(['-- query with underscore'], save_path . '/special/query_with_underscore.sql')
  
  :DBUI
  normal o
  /Saved queries
  normal o
  /special
  normal o
  
  call s:expect(search('query with spaces.sql')).to_be_greater_than(0)
  call s:expect(search('query-with-dash.sql')).to_be_greater_than(0)
  call s:expect(search('query_with_underscore.sql')).to_be_greater_than(0)
endfunction

function! s:suite.should_handle_no_saved_queries() abort
  :DBUI
  normal o
  
  " Should show Saved queries (0)
  call s:expect(search('Saved queries (0)', 'w')).to_be_greater_than(0)
endfunction

function! s:suite.should_handle_only_files_no_directories() abort
  let save_path = printf('%s/%s', g:db_ui_save_location, 'dadbod_ui_test')
  
  " Create files directly in save_path, no subdirectories
  call writefile(['-- root query 1'], save_path . '/root1.sql')
  call writefile(['-- root query 2'], save_path . '/root2.sql')
  
  :DBUI
  normal o
  /Saved queries
  normal o
  
  call s:expect(search('root1.sql')).to_be_greater_than(0)
  call s:expect(search('root2.sql')).to_be_greater_than(0)
endfunction

function! s:suite.should_maintain_state_after_redraw() abort
  let save_path = printf('%s/%s', g:db_ui_save_location, 'dadbod_ui_test')
  call mkdir(save_path . '/test-dir', 'p')
  call writefile(['-- test'], save_path . '/test-dir/test.sql')
  
  :DBUI
  normal o
  /Saved queries
  normal o
  /test-dir
  normal o  " Expand
  
  " Redraw
  R
  
  " Directory should still be expanded
  call s:expect(search('test.sql', 'w')).to_be_greater_than(0)
endfunction

function! s:suite.should_handle_unicode_in_files() abort
  let save_path = printf('%s/%s', g:db_ui_save_location, 'dadbod_ui_test')
  call mkdir(save_path . '/unicode', 'p')
  
  " Create file with unicode content
  call writefile(['-- 查询测试 🎉'], save_path . '/unicode/unicode.sql')
  
  :DBUI
  normal o
  /Saved queries
  normal o
  /unicode
  normal o
  /unicode.sql
  normal o
  
  call s:expect(&filetype).to_equal('sql')
  " Check that the file content is readable
  call s:expect(search('查询测试', 'w')).to_be_greater_than(0)
endfunction

function! s:suite.should_sort_directories_alphabetically() abort
  let save_path = printf('%s/%s', g:db_ui_save_location, 'dadbod_ui_test')
  
  " Create directories in non-alphabetical order
  call mkdir(save_path . '/zebra', 'p')
  call mkdir(save_path . '/alpha', 'p')
  call mkdir(save_path . '/middle', 'p')
  
  call writefile(['-- z'], save_path . '/zebra/z.sql')
  call writefile(['-- a'], save_path . '/alpha/a.sql')
  call writefile(['-- m'], save_path . '/middle/m.sql')
  
  :DBUI
  normal o
  /Saved queries
  normal o
  
  " Check that directories appear in alphabetical order
  let alpha_line = search('alpha', 'w')
  let middle_line = search('middle', 'w')
  let zebra_line = search('zebra', 'w')
  
  call s:expect(alpha_line).to_be_greater_than(0)
  call s:expect(middle_line).to_be_greater_than(0)
  call s:expect(zebra_line).to_be_greater_than(0)
  call s:expect(alpha_line < middle_line).to_be_true()
  call s:expect(middle_line < zebra_line).to_be_true()
endfunction

function! s:suite.should_handle_symlinks() abort
  let save_path = printf('%s/%s', g:db_ui_save_location, 'dadbod_ui_test')
  let target_path = save_path . '/target'
  let link_path = save_path . '/link'
  
  call mkdir(target_path, 'p')
  call writefile(['-- target query'], target_path . '/query.sql')
  
  " Create symlink
  call system('ln -s ' . target_path . ' ' . link_path)
  
  :DBUI
  normal o
  /Saved queries
  normal o
  
  " Should handle symlinks gracefully
  call s:expect(search('target')).to_be_greater_than(0)
endfunction

function! s:suite.should_handle_readonly_files() abort
  let save_path = printf('%s/%s', g:db_ui_save_location, 'dadbod_ui_test')
  call mkdir(save_path . '/readonly', 'p')
  call writefile(['-- readonly query'], save_path . '/readonly/readonly.sql')
  call system('chmod 444 ' . save_path . '/readonly/readonly.sql')
  
  :DBUI
  normal o
  /Saved queries
  normal o
  /readonly
  normal o
  
  " Should still show readonly files
  call s:expect(search('readonly.sql')).to_be_greater_than(0)
  
  " Cleanup
  call system('chmod 644 ' . save_path . '/readonly/readonly.sql')
endfunction
