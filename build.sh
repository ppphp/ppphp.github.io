#!/bin/bash

# 构建脚本 - 用于更新和构建Hugo网站

set -e  # 遇到错误时立即退出

echo "========================================="
echo "Hugo网站构建脚本"
echo "========================================="

echo "步骤1: 检查Hugo是否安装..."
if ! command -v hugo &> /dev/null; then
    echo "错误: Hugo未安装，请先安装Hugo"
    exit 1
fi
echo "Hugo版本: $(hugo version)"

echo ""
echo "步骤2: 更新Hugo模块..."
hugo mod get -u || echo "警告: 模块更新可能有问题，但继续构建..."

echo ""
echo "步骤3: 清理旧的构建文件..."
rm -rf public/*
echo "清理完成"

echo ""
echo "步骤4: 构建网站..."
if hugo; then
    echo "构建成功！网站文件已生成到public目录"
else
    echo "错误: 构建失败"
    exit 1
fi

echo ""
echo "========================================="
echo "构建完成！"
echo "========================================="

# 如果需要部署到GitHub Pages，取消下面的注释
# echo ""
# echo "步骤5: 部署到GitHub Pages..."
# ./gh-pages
