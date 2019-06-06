#!/bin/bash

# import config.sh
source ../settings/config.sh
backup_paths_file="../settings/backup-paths"
md5_file="../settings/file-md5s"
tmp_md5_file="temp-md5"

# init and check neccessary files
if [ ! -f "$backup_paths_file" ]; then
  echo "../settings/backup-paths file does not exist"
  echo "please create the file or run the \"hydrogen init\" command"
  exit 1;
fi

if [ ! -f "$md5_file" ]; then
  touch "$md5_file"
fi

touch "tmp_md5_file"


# loop through the backup_paths_file and for each path do the following:
# 0. use "find $path -type f" to list all files
# 1. calc the md5 and add it to tmp_md5_file
# 2. check if the md5 exists in md5_file already
# 3. if yes, skip, else do the following:
# 4. copy the file to

# store all file paths to backup into array
files_to_backup=()

while read path; do
  # echo "$path"
  while IFS= read -r line; do
    files_to_backup+=( "$line" )
  done < <( find "$path" -type f )
done <../settings/backup-paths

# printf '%s\n' "${files_to_backup[@]}"

for i in "${files_to_backup[@]}"; do
   echo "$i"
   # or do whatever with individual element of the array
done


# # 接收參數並把 "-" 符號去掉
# OPTION="${1##*-}"
#
# # 取得本腳本所在的資料夾名稱
# SRCDIR="${PWD##*/}"
#
# # 取得本腳本所在資料夾的完整路徑
# SRCDIR_ABSOLUTE="`pwd`"
#
# # 取得使用者名稱
# USER="`whoami`"
#
# # 備份檔輸出的資料夾
# DESDIR="/home/$USER/backup"
#
# # 取得日期的指令
# # 會用\是因為等等會把指令安裝到crontab
# DATE_COMMAND="\`date +\%Y-\%m-\%d_\%H\%M\%S\`"
#
# # 備份指令 (壓縮本資料夾)
# BACKUP_COMMAND="tar -cpzf "$DESDIR"/"$SRCDIR"_"$DATE_COMMAND".tgz "$SRCDIR_ABSOLUTE""
#
# # cron 排程
# CRON="*/$OPTION * * * *"
#
# # 合併cron 和備份指令
# FULL_COMMAND=""$CRON" "$BACKUP_COMMAND""
#
# # 檢查參數
# if [ "$OPTION" == "q" ]; then
#   echo "remove job"
#
#   # 將原本的cron排程輸出，grep -v 來取得所有不是本腳本產的cron job，輸出到暫存的檔案
#   crontab -l | grep -v ""$DESDIR"/"$SRCDIR"" >> tempfile
#
#   # 安裝新的crontab
#   crontab tempfile
#
#   #刪除暫存檔
#   rm tempfile
#
#  # 用regex判斷參數是否是數字
# elif [[ "$OPTION" =~ ^[0-9]+ ]]; then
#   echo "backup "$SRCDIR_ABSOLUTE" every $OPTION minutes"
#
#   # 若存備份的資料夾不存在，mkdir
#   if [ ! -d "$DESDIR" ]; then
#     # echo mkdir
#     mkdir "$DESDIR"
#   fi
#
#   # 將原本的cron排程輸出到tempfile
#   crontab -l > tempfile
#
#   # 把排程備份的指令append進去tempfile
#   echo "$FULL_COMMAND" >> tempfile
#
#   # 安裝tempfile到crontab
#   crontab tempfile
#
#   #刪除暫存檔
#   rm tempfile
# else
#   # print 使用方式
#   echo "Usage: ./backup.sh [OPTION]"
#   echo "-q to stop backup"
#   echo "-n backup current directory once every n minutes"
# fi
