#!/bin/bash

/app/update.sh

echo "${BACKUP_SCHEDULE} /bin/bash /app/mysqlBackUp.sh"

# 创建crontab条目，cron中执行bash脚本没法直接读环境变量，所以重新定义到crontab -l里面，可以通过crontab -e查看
{
    echo "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}"
    echo "BACKUP_DAY=${BACKUP_DAY}"
    echo "HOST=${HOST}"
    echo "PORT=${PORT}"
    echo "${BACKUP_SCHEDULE} /bin/bash /app/mysqlBackUp.sh >> /app/backup/cron.log 2>&1"
} > /app/cronCMD

crontab /app/cronCMD

# # 启动cron服务
# service cron start

cron -f
