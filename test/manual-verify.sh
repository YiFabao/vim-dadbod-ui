#!/usr/bin/env bash

# 手动验证 saved queries 目录树功能的测试脚本
# 这个脚本创建一个测试环境，可以手动验证功能是否正常

set -e

echo "=== Saved Queries 目录树功能验证 ==="
echo ""

# 设置测试目录
TEST_DIR="/tmp/dbui_test_$(date +%Y%m%d_%H%M%S)"
SAVE_LOCATION="$TEST_DIR/save_location"

echo "1. 创建测试环境..."
echo "   测试目录: $TEST_DIR"
echo "   保存位置: $SAVE_LOCATION"

# 创建目录结构
mkdir -p "$SAVE_LOCATION/testdb/climb"
mkdir -p "$SAVE_LOCATION/testdb/miner"
mkdir -p "$SAVE_LOCATION/testdb/ops/reports"
mkdir -p "$SAVE_LOCATION/testdb/user"

# 创建测试查询文件
echo "-- climb query 1" > "$SAVE_LOCATION/testdb/climb/query1.sql"
echo "-- climb query 2" > "$SAVE_LOCATION/testdb/climb/query2.sql"
echo "-- miner query" > "$SAVE_LOCATION/testdb/miner/miner.sql"
echo "-- ops maintenance" > "$SAVE_LOCATION/testdb/ops/maintenance.sql"
echo "-- daily report" > "$SAVE_LOCATION/testdb/ops/reports/daily.sql"
echo "-- weekly report" > "$SAVE_LOCATION/testdb/ops/reports/weekly.sql"
echo "-- user search" > "$SAVE_LOCATION/testdb/user/search.sql"

echo "2. 创建的目录结构："
echo ""
find "$SAVE_LOCATION/testdb" -type f -o -type d | sort | sed 's|'$SAVE_LOCATION'/testdb/||' | head -20
echo ""

echo "3. 验证步骤："
echo ""
echo "   ✓ 目录结构已创建"
echo "   ✓ 查询文件已生成"
echo ""
echo "4. 手动测试指南："
echo ""
echo "   在 Vim 中执行以下操作："
echo "   a) 打开 vim"
echo "   b) 设置: let g:db_ui_save_location = '$SAVE_LOCATION'"
echo "   c) 设置: let g:dbs = [{'name': 'testdb', 'url': 'sqlite:test/dadbod_ui_test.db'}]"
echo "   d) 执行: :DBUI"
echo "   e) 展开数据库连接"
echo "   f) 展开 'Saved queries'"
echo "   g) 验证目录是否正确显示"
echo "   h) 测试展开/收缩目录"
echo "   i) 测试打开查询文件"
echo "   j) 测试删除文件/目录"
echo ""

echo "5. 预期显示效果："
echo ""
echo "   ▾ testdb ✓"
echo "       󰓰 New query"
echo "     ▾  Saved queries (7)"
echo "       ▸ climb"
echo "       ▸ miner"
echo "       ▸ ops"
echo "          daily.sql"
echo "          weekly.sql"
echo "       ▸ user"
echo ""

echo "6. 测试文件位置："
echo "   $TEST_DIR"
echo ""
echo "   测试完成后可以删除此目录"
echo ""

echo "=== 验证脚本完成 ==="
echo ""
echo "如需自动测试，请确保 vim-themis 已安装，然后运行："
echo "  ./run.sh"
echo ""
echo "或运行特定测试："
echo "  ./vim-themis/bin/themis test/test-saved-queries-directory-tree.vim"
