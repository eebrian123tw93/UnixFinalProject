#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
echo "$DIR"


backup_script_path="$DIR/backup.sh"
resore_script_path="$DIR/restore.sh"

config_file_path="$DIR/../settings/config.sh"
backup_path_file_path="$DIR/../settings/backup-paths"
md5_file_path="$DIR/../settings/file-md5s"
ignore_file_path="$DIR/../settings/ignored-extensions"
setting_folder_path="$DIR/../settings"


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
default_value="\"\""


init(){
    echo "init 初始化..."
	# v=$(cat $config_file_path )
	# echo $v

	if [ ! -d $setting_folder_path ];
	then
		echo "create setting folder"
		mkdir "$setting_folder_path"
	fi


	if [ ! -f $config_file_path ];
	then
		echo "init config file"
		touch "$config_file_path"
	fi

	if [ ! -f $backup_path_file_path ];
	then
		echo "init backup path file"
		touch "$backup_path_file_path"
	fi

	if [ ! -f $md5_file_path ];
	then
		echo "init md5 file"
		touch "$md5_file_path"
	fi


	if [ ! -f $ignore_file_path ];
	then
		echo "init ignore file"
		touch "$ignore_file_path"
	fi

	echo $HOME > $backup_path_file_path 

	echo -n "" > $config_file_path
	echo "$identity_key=$default_value" >> $config_file_path	
	echo "$remote_key=false" >> $config_file_path	
	echo "$username_key=$default_value" >> $config_file_path	
	echo "$remote_ip_key=$default_value" >> $config_file_path
	echo "$auto_key=$default_value" >> $config_file_path	
	echo "$time_key=$default_value" >> $config_file_path
	echo "$local_folder_key=$DIR/../backup/" >> $config_file_path
	echo "$zip_folder_key=$DIR/../zips/" >> $config_file_path
	echo "$md5_file_key=$DIR/../settings/file-md5s" >> $config_file_path
	echo "$backup_path_file_key=$DIR/../settings/backup-paths" >> $config_file_path
	echo "$ignore_file_path_key=$DIR/../settings/ignored-extensions" >> $config_file_path


	echo "Input the folder you want to backup(-q will  exit)"
	read source
	while [[ $source != "-q" ]]; do

		#statements
		if [  -d $source ];
		then
			old=`pwd`;new=$(dirname "$source");
			if [ "$new" != "." ]; 
			then
			 cd $new; 
			fi;
			file=`pwd`/$(basename "$source");
			cd $old; 
			echo "$file" >> $backup_path_file_path
		elif [ -f $source ]; then
			old=`pwd`;new=$(dirname "$source");
			if [ "$new" != "." ]; 
			then
			 cd $new; 
			fi;
			file=`pwd`/$(basename "$source");
			cd $old; 
			echo "$file" >> $backup_path_file_path
		else
			echo "please input folder or file path"
		fi
		echo "Input the folder you want to backup(-q will  exit)"
		read source
	done	

	echo "遠端備份？？(yes/no)"
	read remote_backup
	while [[ $remote_backup != "yes" && $remote_backup != "no" ]]; do
		#statements
		echo "please input yes or no"
		read remote_backup
	done

	# value=$(<$config_file_path )
	grep -v "$remote_key"  $config_file_path > temp
	mv temp $config_file_path
	if [ $remote_backup = "yes" ];
	then
		echo "$remote_key=true" >> $config_file_path
		
		echo "please input remote ip"
		read remote_ip
		echo "please input remote username"
		read username
		echo "please input remote identity file path"
		read identity_file_path


		grep -v "$remote_ip_key"  $config_file_path > temp
		mv temp $config_file_path
		echo "$remote_ip_key=$remote_ip" >> $config_file_path

		grep -v "$username_key"  $config_file_path > temp
		mv temp $config_file_path
		echo "$username_key=$username" >> $config_file_path


		old=`pwd`;new=$(dirname "$identity_file_path");
		if [ "$new" != "." ]; 
		then
		 cd $new; 
		fi;
		file=`pwd`/$(basename "$identity_file_path");
		cd $old; 
		echo "$file" >> $backup_path_file_path


		grep -v "$identity_key"  $config_file_path > temp
		mv temp $config_file_path
		echo "$identity_key=$file" >> $config_file_path



	else
		echo "$remote_key=false" >> $config_file_path 
	fi
	



}


if [ $# -ge 1 ] ;
then
	if [ "$1" = "init" ] ;
	then
		
		init
	elif [ "$1" = "--backup"  ]; then
		echo "--backup"
		if [ $# -eq 1 ];then
			exec "$backup_script_path"
		else
			re='^[0-9]+$'
			if [  "$2" = "-q" ];then
				echo "cancel backup"
				crontab -l | grep -v "$backup_script_path"  | crontab  -
				
			elif [[ $2 =~ $re ]]; then
				echo "$USER"
				echo "backup  per $2 minutes"
			    (crontab -l ; echo "*/$2 * * * * $backup_script_path  >> $DIR/hydrogen.log ") | crontab  -
			fi
		fi
	elif [ "$1" = "--restore" ]; then
		echo "--restore"
		if [ $# -eq 1 ];then
			echo "Which source you want to restore?(--local/--remote)"
			read source
			while [[ $source != "--local" && $source != "--remote" ]]; do
				#statements
				echo "please input --local or --remote (CTRL+c to exit)"
				read source
			done
			echo "restore form $2"
			exec "$resore_script_path $2"
		else
			echo "restore form $2"
			exec "$resore_script_path $2"
		fi
	else
		if [ ! -d $setting_folder_path ];
		then
			init
		fi
	fi		
fi
