#!/bin/bash
# Hexo 博客自动备份脚本

BLOG_DIR="/var/www/blog"
BACKUP_DIR="/root/backups/blog"
DATE=$(date +%Y%m%d_%H%M%S)

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份源文件（只备份存在的目录）
tar -czf $BACKUP_DIR/hexo_source_$DATE.tar.gz \
    -C $BLOG_DIR \
    source/_posts/ \
    source/images/ \
    _config.yml \
    package.json 2>/dev/null

# 保留最近 7 天的备份
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "✅ 备份完成: hexo_source_$DATE.tar.gz"
echo "📁 备份目录: $BACKUP_DIR"
ls -lh $BACKUP_DIR/ | tail -5
