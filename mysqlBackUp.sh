#!/bin/bash
# mysql_backup.sh: backup mysql databases and keep newest 7 days backup.  

db_user="root"
db_password=${MYSQL_ROOT_PASSWORD}
db_host=${HOST}
db_port=${PORT}
basedir="/app/backup"
backup_day=${BACKUP_DAY}
BACKUP_DATE=$(date +%Y-%m-%d)
BACKUP_TIME=$(date +%H%M)
xing="*"

logdir=$basedir"/logs"
backupdir=$basedir"/data/"$BACKUP_DATE
logfile=$logdir"/backup.log"

all_db="$(mysql -u ${db_user} -h ${db_host} -P ${db_port} -p${db_password} -Bse 'show databases')"


time="$(date +"%Y-%m-%d")"

# the directory for story the newest backup  #
test ! -d ${backupdir} && mkdir -p ${backupdir}
test ! -d ${logdir} && mkdir -p ${logdir}


#备份数据库函数#
mysql_backup()
{
    # 取所有的数据库名 #
    for db in ${all_db}
    do
        backname=${db}"_bk"
        dumpfile=${backupdir}/${backname}

        #将备份的时间、数据库名存入日志
        echo ""$(date +'%Y-%m-%d %T')" backup database "${db}"" >>${logfile}
        mysqldump -F -u${db_user} -h${db_host} -P ${db_port} -p${db_password} ${db} > ${dumpfile}.sql 2>>${logfile} 2>&1
        
        
        #开始将压缩数据日志写入log
        echo $(date +'%Y-%m-%d %T')" zip ${dumpfile}.sql" >>${logfile}
        #将备份数据库文件库压成ZIP文件，并删除先前的SQL文件. #
        tar -czvf ${backname}.tar.gz ${backname}.sql 2>&1 && rm ${dumpfile}.sql 2>>${logfile} 2>&1 
        
        #将压缩后的文件名存入日志。
        echo $(date +'%Y-%m-%d %T')" backup file "${dumpfile}".tar.gz" >>${logfile}
        echo -e ""$(date +'%Y-%m-%d %T')" database "${db}" backup success\n" >>${logfile}    
        
    done
}

delete_old_backup()
{    
    echo -e $(date +'%Y-%m-%d %T') "delete backup file:\n" >>${logfile}
    # 删除旧的备份 查找出当前目录下七天前生成的文件夹，并将之删除
    find $basedir/data -mindepth 1 -type d -mtime +${backup_day} | tee delete_list.log | xargs rm -rf
    cat delete_list.log >>${logfile}
}



echo -e "-------------- "$(date +'%Y-%m-%d')" ----------------\n" >>${logfile}

#进入数据库备份文件目录
cd ${backupdir}
mysql_backup
delete_old_backup

echo -e "-------------- backup done at "$(date +'%Y-%m-%d %T')" ----------------\n\n">>${logfile}