# 测试文件总结

## 已创建的测试文件

### 1. test/test-saved-queries-directory-tree.vim
**核心功能测试** - 319 行

测试用例：
- ✓ should_show_saved_queries_with_tree_structure
- ✓ should_expand_saved_queries_section
- ✓ should_show_collapsed_directories
- ✓ should_expand_directory
- ✓ should_collapse_directory
- ✓ should_open_saved_query_file
- ✓ should_handle_nested_directories
- ✓ should_delete_saved_query_file
- ✓ should_add_saved_query_directory
- ✓ should_add_saved_query_file
- ✓ should_delete_directory_recursively
- ✓ should_maintain_expanded_state_after_refresh

### 2. test/test-saved-queries-tree-structure.vim
**树结构显示测试** - 137 行

测试用例：
- ✓ should_display_directories_when_expanded
- ✓ should_show_files_when_directory_expanded
- ✓ should_handle_multiple_files_in_directory
- ✓ should_toggle_directory_expansion
- ✓ should_open_file_from_tree
- ✓ should_handle_empty_directories
- ✓ should_display_correct_file_count

### 3. test/test-saved-queries-edge-cases.vim
**边缘情况测试** - 211 行

测试用例：
- ✓ should_handle_deeply_nested_structure (4层嵌套)
- ✓ should_handle_special_characters_in_filename
- ✓ should_handle_no_saved_queries
- ✓ should_handle_only_files_no_directories
- ✓ should_maintain_state_after_redraw
- ✓ should_handle_unicode_in_files
- ✓ should_sort_directories_alphabetically
- ✓ should_handle_symlinks
- ✓ should_handle_readonly_files

### 4. test/manual-verify.sh
**手动验证脚本** - 90 行

提供：
- 自动创建测试环境
- 目录结构展示
- 手动测试步骤指南
- 预期效果展示

### 5. test/README_TESTS.md
**测试文档** - 205 行

包含：
- 测试文件说明
- 运行测试的方法
- 测试覆盖的功能清单
- 测试数据结构示例
- 测试框架说明
- 故障排查指南
- 未来测试扩展计划

## 总计

- **测试文件**: 3 个自动化测试 + 1 个手动验证脚本
- **测试用例**: 28 个测试用例
- **代码行数**: 667 行（测试代码）+ 205 行（文档）
- **测试覆盖**: 核心功能、树结构、边缘情况

## 运行测试

### 前提条件

确保已安装测试依赖：
```bash
./run.sh  # 会克隆 vim-themis, vim-dadbod, vim-dotenv
```

### 运行所有测试

```bash
./run.sh
```

### 运行 Saved Queries 特定测试

```bash
# 核心功能测试
./vim-themis/bin/themis test/test-saved-queries-directory-tree.vim

# 树结构测试
./vim-themis/bin/themis test/test-saved-queries-tree-structure.vim

# 边缘情况测试
./vim-themis/bin/themis test/test-saved-queries-edge-cases.vim
```

### 运行单个测试用例

```bash
# 使用 grep 过滤
./vim-themis/bin/themis --grep "should_expand_directory" \
  test/test-saved-queries-directory-tree.vim

./vim-themis/bin/themis --grep "should_handle_deeply_nested_structure" \
  test/test-saved-queries-edge-cases.vim
```

## 手动验证

如果自动测试无法运行，可以使用手动验证脚本：

```bash
./test/manual-verify.sh
```

然后按照输出的说明在 Vim 中手动验证功能。

## 测试覆盖的功能矩阵

| 功能 | 测试文件 | 状态 |
|------|----------|------|
| 目录树显示 | tree-structure | ✅ |
| 展开/收缩 | directory-tree | ✅ |
| 打开文件 | directory-tree | ✅ |
| 添加目录 | directory-tree | ✅ |
| 添加文件 | directory-tree | ✅ |
| 删除文件 | directory-tree | ✅ |
| 递归删除 | directory-tree | ✅ |
| 状态保持 | directory-tree, edge-cases | ✅ |
| 嵌套结构 | edge-cases | ✅ |
| 特殊字符 | edge-cases | ✅ |
| Unicode | edge-cases | ✅ |
| 排序 | edge-cases | ✅ |
| 符号链接 | edge-cases | ✅ |
| 只读文件 | edge-cases | ✅ |
| 空目录 | tree-structure | ✅ |

## 测试数据示例

测试会创建如下结构：

```
testdb/
├── climb/
│   ├── query1.sql
│   ├── query2.sql
│   ├── another_query.sql
│   └── yet_another.sql
├── miner/
│   └── miner_query.sql
├── ops/
│   ├── maintenance.sql
│   └── reports/
│       ├── daily.sql
│       └── weekly.sql
├── user/
│   └── search.sql
├── level1/
│   └── level2/
│       └── level3/
│           └── level4/
│               └── deep.sql
└── special/
    ├── query with spaces.sql
    ├── query-with-dash.sql
    └── query_with_underscore.sql
```

## 测试框架

使用 **vim-themis** (https://github.com/thinca/vim-themis)

特点：
- BDD 风格测试
- Vim script 原生支持
- 支持 setup/teardown
- 丰富的断言方法
- Spec 格式输出

## 已知问题

1. 测试依赖需要网络下载（vim-themis, vim-dadbod）
2. 某些测试需要 SQLite 支持
3. 符号链接测试在 Windows 上可能失败

## 贡献指南

添加新测试时：
1. 遵循现有测试的命名约定
2. 每个测试函数以 `should_` 开头
3. 在 `after()` 中清理所有资源
4. 更新此文档
5. 确保测试独立运行
