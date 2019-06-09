#!/bin/bash

# home of this program
HOME_DIR="$HOME/hydrogen-backup"

backup_script_path="/usr/bin/hydrogen-backup.sh"
restore_script_path="/usr/bin/hydrogen-restore.sh"

config_file_path="$HOME_DIR/configs/config.sh"
backup_path_file_path="$HOME_DIR/configs/backup-paths"
md5_file_path="$HOME_DIR/configs/file-md5s"
ignore_file_path="$HOME_DIR/configs/ignored-extensions"
setting_folder_path="$HOME_DIR/configs"

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

  apt install -y toilet 

  # if [ "$EUID" -ne 0 ]; then
  #   echo "run failed."
  #   echo "please re-run the command with sudo"
  #   exit
  # fi

  toilet -f smblock --filter border:gay -t Hydrogen-Backup
  echo "init 初始化..."

  backup_store_folder=$HOME_DIR/backup

  # create folder to store local backups
  mkdir -p "$backup_store_folder"

  chmod 777 "$HOME_DIR"
  chmod 777 "$backup_store_folder"

  # change owner to user (to let user write to that folder)
  # chown "$SUDO_USER" "$backup_store_folder"

  # mkdir -p /etc/hydrogen-backup

	if [ ! -d $setting_folder_path ]; then
		echo "create setting folder"
		mkdir "$setting_folder_path"
    chmod 777 "$setting_folder_path"
	fi

	if [ ! -f $config_file_path ]; then
		echo "init config file"
		touch "$config_file_path"
    chmod 777 $config_file_path
	fi

	if [ ! -f $backup_path_file_path ]; then
		echo "init backup path file"
		touch "$backup_path_file_path"
    chmod 777 $backup_path_file_path
	fi

	if [ ! -f $md5_file_path ]; then
		echo "init md5 file"
		touch "$md5_file_path"
    chmod 777 $md5_file_path
	fi

	if [ ! -f $ignore_file_path ]; then
		echo "init ignore file"
		touch "$ignore_file_path"
    chmod 777 $ignore_file_path
	fi

  echo "setting $HOME as default folder to backup"
	# echo $HOME > $backup_path_file_path
  echo $HOME/Desktop > $backup_path_file_path

	echo -n "" > $config_file_path
	echo "$identity_key=$default_value" >> $config_file_path
	echo "$remote_key=false" >> $config_file_path
	echo "$username_key=$default_value" >> $config_file_path
	echo "$remote_ip_key=$default_value" >> $config_file_path
	echo "$auto_key=$default_value" >> $config_file_path
	echo "$time_key=$default_value" >> $config_file_path
	echo "$local_folder_key=$HOME_DIR/backup" >> $config_file_path
	echo "$zip_folder_key=$HOME_DIR/zips" >> $config_file_path
	echo "$md5_file_key=$md5_file_path" >> $config_file_path
	echo "$backup_path_file_key=$backup_path_file_path" >> $config_file_path
	echo "$ignore_file_path_key=$ignore_file_path" >> $config_file_path

	echo "Input a folder you want to backup (-q will  exit)"
	read source
	while [[ $source != "-q" ]]; do
		if [ -d $source ];
		then
			old=`pwd`;new=$(HOME_DIRname "$source");
			if [ "$new" != "." ];
			then
			 cd $new;
			fi;
			file=`pwd`/$(basename "$source");
			cd $old;
			echo "$file" >> $backup_path_file_path
		elif [ -f $source ]; then
			old=`pwd`;new=$(HOME_DIRname "$source");
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


		old=`pwd`;new=$(HOME_DIRname "$identity_file_path");
		if [ "$new" != "." ];
		then
		 cd $new;
		fi;
		file=`pwd`/$(basename "$identity_file_path");
		cd $old;
		echo "$file" >> $backup_path_file_path

		grep -v "$identity_key" $config_file_path > temp
		mv temp $config_file_path
		echo "$identity_key=$file" >> $config_file_path
	else
		echo "$remote_key=false" >> $config_file_path
	fi

  chmod 777 "$config_file_path"
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
			    (crontab -l ; echo "*/$2 * * * * $backup_script_path  >> $HOME_DIR/hydrogen.log ") | crontab  -
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
			$restore_script_path $2
		else
			echo "restore form $2"
			$restore_script_path $2
		fi
	else
		if [ ! -d $setting_folder_path ];
		then
			init
		fi
	fi
fi
