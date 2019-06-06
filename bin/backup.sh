#!/bin/bash

# import config.sh
source ../settings/config.sh
tmp_md5_file="temp-md5"

echo "backup_path_file: $backup_path_file"
echo "md5_file: $md5_file"

# init and check neccessary files
if [ ! -f "$backup_path_file" ]; then
  echo "../settings/backup-paths file does not exist"
  echo "please create the file or run the \"./hydrogen init\" command"
  exit 1;
fi

# if md5 file does not exist, create one
if [ ! -f "$md5_file" ]; then
  touch "$md5_file"
fi

# store all file paths to backup into array
files_to_backup=()
while read path; do
  # echo "$path"
  while IFS= read -r line; do
    files_to_backup+=( "$line" )
  done < <( find "$path" -type f )
done <"$backup_path_file"

# for each file to backup:
# check if file has changed (via md5)
# check if file extension if ignored
# if file has changed and is not ignored, do backup
for file in "${files_to_backup[@]}"; do
  file_md5=($(md5sum "$file"))
  file_id="$file:$file_md5"
  echo "$file_id" >> "$tmp_md5_file"
  if grep -Fxq "$file_id" "$md5_file"; then
      # if md5 exists, do nothing
      echo "ignore $file"
  elif grep -Fxq "${file##*.}" "$ignored_extensions_file"; then
    # ignore unwanted file extensions
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

rm "$md5_file"
cat "$tmp_md5_file" > "$md5_file"
rm "$tmp_md5_file"

mkdir -p "$zip_folder_path"
DATE_COMMAND="`date +%Y-%m-%d_%H:%M:%S`"
tgz_name="$DATE_COMMAND".tgz
tar -cpzf "$zip_folder_path$tgz_name" "$local_folder_path"
echo "tgz file created at $zip_folder_path$tgz_name"

if [ $remote ]; then
  ssh -i "$identity_file" "$username@$remote_ip" "mkdir -p backup"
  scp -i "$identity_file" "$zip_folder_path$tgz_name" "$username@$remote_ip":~/backup 
fi
