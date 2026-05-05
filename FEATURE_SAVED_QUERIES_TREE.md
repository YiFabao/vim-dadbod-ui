# Saved Queries 目录树功能

## 功能概述

本次更新为 saved queries 添加了文件夹目录树功能，支持：

1. **展开/收缩文件夹** - 可以点击或使用 `o` 键展开/收缩文件夹
2. **多层级目录** - 支持嵌套的文件夹结构
3. **添加目录** - 可以添加新的文件夹
4. **添加文件** - 可以添加新的查询文件
5. **删除目录/文件** - 可以删除文件夹和文件（文件夹会递归删除）

## 目录树显示效果

```
▾ 󰆼 climb ✓
    󰓰 New query
  ▾  Saved queries (8)
    ▸ connection
    ▸ miner
    ▸ ops
       report1
       report2
    ▸ report
    ▸ sni
    ▸ test
    ▸ traffic
    ▸ user
```

## 实现细节

### 1. 数据结构变更

在 `db.saved_queries` 中添加了 `dir_expanded` 字段来跟踪每个目录的展开状态：

```vim
db.saved_queries = {
  'expanded': 0,
  'list': [...],
  'dir_expanded': {
    'connection': 1,
    'ops/report': 0,
    ...
  }
}
```

### 2. 新增函数

- `render_query_tree()` - 递归渲染目录树
- `toggle_saved_query_dir()` - 切换目录展开/收缩状态
- `add_saved_query_directory()` - 添加新目录
- `add_saved_query_file()` - 添加新文件
- `delete_saved_query_item()` - 删除目录或文件
- `build_saved_query_dir_path()` - 构建目录完整路径
- `delete_recursive()` - 递归删除目录

### 3. 文件结构

Saved queries 现在支持多层级目录：

```
~/.local/share/db_ui/
└── mydb/
    ├── connection/
    │   ├── query1.sql
    │   └── query2.sql
    ├── ops/
    │   ├── report/
    │   │   ├── daily.sql
    │   │   └── weekly.sql
    │   └── maintenance.sql
    └── user/
        └── search.sql
```

## 使用方法

### 展开/收缩目录

- 将光标移到目录上，按 `o` 或点击展开/收缩
- 使用 `<C-n>` 进入子节点，`<C-p>` 返回父节点
- 使用 `J` / `K` 在同级目录间导航

### 添加目录

在 DBUI 窗口中，确保光标在数据库连接上，然后调用：

```vim
:call db_ui#drawer#get().add_saved_query_directory(db_ui#connections_list()[0])
```

或者你可以先选择一个数据库连接，然后调用该函数。

### 添加文件

在 DBUI 窗口中，确保光标在数据库连接上，然后调用：

```vim
:call db_ui#drawer#get().add_saved_query_file(db_ui#connections_list()[0])
```

### 删除

- 将光标移到要删除的项目上（文件或目录）
- 按 `d` 键
- 确认删除操作

**注意**: 删除目录会递归删除其中所有文件和子目录！

### 重命名

- 将光标移到要重命名的文件上
- 按 `r` 键
- 输入新名称

## 技术实现

### 目录树构建逻辑

1. `load_saved_queries()` 扫描 `save_path` 下的所有文件
2. `_render_saved_queries_section()` 构建目录树结构
3. `render_query_tree()` 递归渲染每个节点

### 展开状态管理

目录的展开状态存储在 `db.saved_queries.dir_expanded` 字典中，使用完整的相对路径作为键。

### 删除逻辑

- 对于文件：直接调用 `delete()`
- 对于目录：调用 `delete_recursive()` 递归删除所有内容

## 注意事项

1. 删除文件夹会递归删除其中所有文件
2. 删除操作会弹出确认对话框
3. 目录展开状态会在刷新后保持
4. 只支持在 `g:db_ui_save_location` 配置的目录下操作

## 未来改进

1. 添加专门的快捷键来添加目录和文件（如 `A` 添加目录，`N` 添加文件）
2. 支持重命名目录
3. 支持拖拽移动文件
4. 改进目录路径显示，显示完整相对路径
5. 添加搜索/过滤功能
