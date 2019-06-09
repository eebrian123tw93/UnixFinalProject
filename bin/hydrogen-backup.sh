#!/bin/bash

# import config.sh
source "$HOME/hydrogen-backup/configs/config.sh"

echo "backup_path_file: $backup_path_file"

# init and check neccessary files
if [ ! -f "$backup_path_file" ]; then
  echo "$backup_path_file does not exist"
  echo "please create the file or run the \"./hydrogen init\" command"
  exit 1;
fi

# store all file paths to backup into array
files_to_backup=()
while read path; do
  # echo "$path"
  while IFS= read -r line; do
    files_to_backup+=( "$line" )
  done < <( find "$path" -type f )
done <"$backup_path_file"

# for each file to backup
for file in "${files_to_backup[@]}"; do
  file_ext=${file##*.}
  if grep -Fxq "$file_ext" "$ignored_extensions_file"; then
    echo "ignore $file"
  else
    # copy to local backup folder
    echo "backup $file"
    file_folder=${file%/*}
    copy_folder="$local_folder_path$file_folder"
    # make folder and do copy
    mkdir -p "$copy_folder" && cp "$file" "$copy_folder"
  fi
done

mkdir -p "$zip_folder_path"
chmod 777 "$zip_folder_path"
DATE_COMMAND="`date +%Y-%m-%d_%H:%M:%S`"
tgz_name="$DATE_COMMAND".tgz

echo "$zip_folder_path/$tgz_name $local_folder_path"
cd $local_folder_path
# tar -cpzf "$zip_folder_path/$tgz_name" "$local_folder_path"
tar -cpzf "$zip_folder_path/$tgz_name" "./"
chmod 777 "$zip_folder_path/$tgz_name"
cd /usr/bin
echo "tgz file created at $zip_folder_path/$tgz_name"
echo "remove backup folder"
rm -rf "$local_folder_path"
#
if [ $remote = true ]; then
  echo "backup to remote"
  ssh -i "$identity_file" "$username@$remote_ip" "mkdir -p backup"
  scp -i "$identity_file" "$zip_folder_path/$tgz_name" "$username@$remote_ip":~/backup
fi
