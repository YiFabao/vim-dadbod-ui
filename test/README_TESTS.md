# Saved Queries 目录树功能 - 测试文档

## 测试文件说明

本次更新添加了三个测试文件来验证 saved queries 目录树功能：

### 1. `test-saved-queries-directory-tree.vim`
**测试核心功能**
- 目录树结构显示
- 展开/收缩目录
- 打开查询文件
- 添加/删除目录和文件
- 递归删除目录
- 展开状态维护

### 2. `test-saved-queries-tree-structure.vim`
**测试树结构显示**
- 多个目录的显示
- 文件的显示
- 目录展开/收缩
- 从树中打开文件
- 空目录处理
- 文件计数显示

### 3. `test-saved-queries-edge-cases.vim`
**测试边缘情况和特殊场景**
- 深度嵌套结构（4层目录）
- 特殊字符文件名
- 空 saved queries
- 只有文件没有目录
- 重绘后状态维护
- Unicode 内容
- 目录字母排序
- 符号链接处理
- 只读文件

## 运行测试

### 运行所有测试

```bash
./run.sh
```

### 运行特定测试

```bash
./vim-themis/bin/themis test/test-saved-queries-directory-tree.vim
./vim-themis/bin/themis test/test-saved-queries-tree-structure.vim
./vim-themis/bin/themis test/test-saved-queries-edge-cases.vim
```

### 运行单个测试用例

```bash
# 使用 themis 的 --grep 选项
./vim-themis/bin/themis --grep "should_expand_directory" test/test-saved-queries-directory-tree.vim
```

## 测试覆盖的功能

### ✅ 核心功能
- [x] 目录树结构显示
- [x] 递归渲染多层级目录
- [x] 目录展开/收缩
- [x] 展开状态跟踪（使用 `dir_expanded` 字典）
- [x] 打开 saved query 文件
- [x] 文件内容正确显示

### ✅ 添加功能
- [x] 添加新目录
- [x] 添加新文件
- [x] 删除文件
- [x] 递归删除目录
- [x] 删除确认对话框

### ✅ 导航和交互
- [x] 在目录树中导航
- [x] 使用 `o` 键展开/收缩
- [x] 使用 `d` 键删除
- [x] 文件打开和执行

### ✅ 状态管理
- [x] 展开状态在刷新后保持
- [x] 重绘后状态保持
- [x] 目录展开状态独立跟踪

### ✅ 边缘情况
- [x] 深度嵌套结构（4+层）
- [x] 特殊字符文件名
- [x] 空目录
- [x] Unicode 内容
- [x] 符号链接
- [x] 只读文件
- [x] 字母排序显示

## 测试数据结构示例

测试会创建如下目录结构：

```
~/.local/share/db_ui/dadbod_ui_test/
├── climb/
│   ├── climb_query.sql
│   ├── another_query.sql
│   └── yet_another.sql
├── miner/
│   └── miner_query.sql
├── ops/
│   ├── ops_query.sql
│   ├── reports/
│   │   ├── daily.sql
│   │   └── weekly.sql
│   └── maintenance.sql
├── report/
│   └── report_query.sql
├── sni/
│   └── sni_query.sql
├── test/
│   └── test_query.sql
├── traffic/
│   └── traffic_query.sql
└── user/
    └── user_query.sql
```

## 测试框架

使用 [vim-themis](https://github.com/thinca/vim-themis) 测试框架。

### 测试结构

```vim
let s:suite = themis#suite('Test suite name')
let s:expect = themis#helper('expect')

function! s:suite.before() abort
  " 设置测试环境
  call SetupTestDbs()
endfunction

function s:suite.after() abort
  " 清理测试环境
  call delete(g:db_ui_save_location.'/dadbod_ui_test', 'rf')
  call Cleanup()
endfunction

function! s:suite.should_test_something() abort
  " 测试逻辑
  :DBUI
  normal o  " 模拟按键
  call s:expect(某个条件).to_be_true()
endfunction
```

### 常用断言

```vim
call s:expect(条件).to_be_true()
call s:expect(条件).to_be_false()
call s:expect(值).to_equal(期望值)
call s:expect(搜索).to_be_greater_than(0)
call s:expect(搜索).to_equal(0)  " 不存在
```

## 已知限制

1. **添加目录/文件的交互**：需要通过命令调用，没有专门的快捷键
2. **重命名目录**：尚未实现
3. **拖拽移动**：尚未实现
4. **搜索/过滤**：尚未实现

## 未来测试扩展

可以添加的测试：
- [ ] 重命名文件功能
- [ ] 重命名目录功能
- [ ] 快捷键添加目录/文件
- [ ] 搜索/过滤功能
- [ ] 拖拽排序
- [ ] 批量操作
- [ ] 导入/导出查询

## 故障排查

### 测试失败：目录不存在

确保在 `before()` 中创建了必要的目录结构。

### 测试失败：文件计数不正确

检查测试后的清理是否完整，可能有残留文件。

### 测试挂起：等待输入

使用 `db_ui#utils#input` 函数模拟用户输入：

```vim
function! db_ui#utils#input(name, val)
  if a:name ==? '提示文本'
    return '模拟输入'
  endif
endfunction
```

## 贡献测试

欢迎提交更多测试用例！请遵循以下规范：

1. 文件名以 `test-` 开头，以 `.vim` 结尾
2. 使用描述性的测试套件名称
3. 每个测试函数以 `should_` 开头，描述预期行为
4. 确保在 `after()` 中清理所有创建的文件/目录
5. 使用 `s:expect` 进行断言，避免使用 `assert`
