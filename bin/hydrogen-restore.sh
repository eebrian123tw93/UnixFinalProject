#!/bin/bash

# SOURCE="${BASH_SOURCE[0]}"
# while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
#   DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
#   SOURCE="$(readlink "$SOURCE")"
#   [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
# done
# DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
# echo "$DIR"

DIR="$HOME/hydrogen-backup/"

source "$HOME/hydrogen-backup/configs/config.sh"

temp_zip_file_path="$DIR/tempZips"
temp_unzip_file_path="$DIR/unZips"

ignore_file_path_key="ignored_extensions_file"
md5_file_key="md5_file"
backup_path_file_key="backup_path_file"
zip_folder_key="zip_folder_path"
local_folder_key="local_folder_path"
identity_key="identity_file"
remote_key="remote"
remote_ip_key="remote_ip"
username_key="username"
auto_key="auto"
time_key="time"


if [ $1 = "--local" ];
then
	echo "--local"

elif [ $1 = "--remote" ];
 then
	echo "--remote"

	if [ $remote = "true" ];
	then
		echo "remote true"
		# ssh user@host ls -l /some/directory
		# echo "ssh -i $identity_file $username@$remote_ip mkdir backup"

		# ssh -i $identity_file -o StrictHostKeyChecking=no -l $username $remote_ip "ls backup"
		my_array=()
		while IFS= read -r line; do
		    my_array+=( "$line" )
		done < <( ssh -i $identity_file -o StrictHostKeyChecking=no -l $username $remote_ip "ls backup" )

		for ((idx=0; idx<${#my_array[@]}; ++idx)); do
			number=$(($idx + 1))
	    	echo "$number" "${my_array[idx]}"
		done

		echo "select number you want to restore ?"
		read number

		while [ $number -gt ${#my_array[@]} ]; do
			#statements
			echo "too much"
			read number
		done

		echo $number

		file_name=${my_array[$number-1]}

		echo $file_name

		if [ ! -d $temp_zip_file_path ];
		then
			mkdir $temp_zip_file_path
		fi

		if [ ! -d $temp_unzip_file_path ];
		then
			mkdir $temp_unzip_file_path
		fi

		scp $username@$remote_ip:~/backup/$file_name $temp_zip_file_path

		tar xvf $temp_zip_file_path/$file_name  -C $temp_unzip_file_path

		cp -a "$temp_unzip_file_path/backup/." /

		rm -r -f $temp_zip_file_path
		rm -r -f $temp_unzip_file_path


	else
		echo "remote false,請修改config file"
	fi
fi
