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


init(){
    echo "这是我的第一个 shell 函数!"
}


if [ $# -ge 1 ] ;
then
	if [ "$1" = "init" ] ;
	then
		echo "init"
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
			echo "which source you want to restore?(--local/--remote)"
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
	fi		
fi
