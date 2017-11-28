#!/bin/bash
root=$(pwd);
export $(sed -n '1,/total/d;/\[/,$d;/^$/d;p' $root"/"sys_options.conf)
export $(sed -n '1,/system/d;/\[/,$d;/^$/d;p' $root"/"sys_options.conf)
source $root"/"sys_function.conf
source $root"/"file_manager.conf
IFS=""
function_validate_dir $dirInstall
if [ $? -ne 1 ];then
	echo "->Sin directorio $dirInstall"
	exit -1
fi
function_validate_dir $dirExclude
if [ $? -ne 1 ];then
	echo "->Sin directorio $dirExclude"
	exit -1
fi
function_validate_dir $dirScript
if [ $? -ne 1 ];then
	echo "->Sin directorio $dirScript"
	exit -1
fi
function_validate_dir $dirRootBackup
if [ $? -ne 1 ];then
	echo "->Sin directorio $dirRootBackup"
	exit -1
fi
function_validate_dir $dirBackupCompressed
if [ $? -ne 1 ];then
	echo "->Sin directorio $dirBackupCompressed"
	exit -1
fi
function_validate_dir $dirBackupCompressedUpload
if [ $? -ne 1 ];then
	echo "->Sin directorio $dirBackupCompressedUpload"
	exit -1
fi
function_validate_dir $dirCompressedFinal
if [ $? -ne 1 ];then
	echo "->Sin directorio $dirCompressedFinal"
	exit -1
fi
function_validate_dir $dirCompressedFinalUpload
if [ $? -ne 1 ];then
	echo "->Sin directorio $dirCompressedFinalUpload"
	exit -1
fi
for registers in ${Array[*]}; do
	name=$(echo $registers | awk -F"," '{print $1}' )
	directory=$(echo $registers | awk -F"," '{print $2}' )
	script=$(echo $registers | awk -F"," '{print $3}' )
	maxSizeFiles=$(echo $registers | awk -F"," '{print $4}' )
 	excludeBackup=$(echo $registers | awk -F"," '{print $5}' )
 	upload=$(echo $registers | awk -F"," '{print $6}' )
 	echo ""
 	echo ""
 	if [ "$excludeBackup" != "" ];then
		function_validate_file $dirExclude$excludeBackup
		if [ $? -ne 1 ];then
			echo "->Archivo de exclusion no existe: "$dirExclude$excludeBackup
		else
			excludeBackup="--exclude-from="$dirExclude$excludeBackup
		fi
    fi
	if [ "$maxSizeFiles" != "" ]; then
		maxSizeFiles="--max-size="$maxSizeFiles
	fi
	if [ "$script" != "" ]; then
		function_validate_file $dirScript$script
		if [ $? -ne 1 ];then
			echo "->Archivo de script no existe: "$dirScript$script
		else
			echo "->"execute script $script
			start=$(date +'%s')
			exec_script_before_backup $dirScript$script
			time_elapsed=$(($(date +'%s') - $start))
			echo "->"$time_elapsed "second "
		fi
	fi
	dirDestination=$dirRootBackup$year"/"$monthNow
	function_validate_dir $dirDestination
	if [ $? -ne 1 ];then
		echo "->Directorio no existe: "$dirDestination
		echo "->Creando directorio ...."$dirDestination
		mkdir -p $dirDestination
		echo "->Directorio creado "$dirDestination
	fi
	function_validate_dir $dirDestination$directory
	if [ $? -ne 1 ];then
		echo "->Directorio no existe: "$dirDestination$directory
		echo "->Creando directorio ...."$dirDestination$directory
		mkdir -p $dirDestination$directory
		echo "->Directorio creado "$dirDestination$directory
	fi
	echo "->sync folder "$directory" "
	echo "->sync destination "$dirDestination$directory
	start=$(date +'%s')
	rsync -av --progress --stats --force --delete-before $maxSizeFiles $directory $dirDestination$directory $excludeBackup
	#echo $run
	time_elapsed=$(($(date +'%s') - $start))
	echo "->"$time_elapsed "second "
	echo "->compress folder "$dirDestination$directory
	echo "->destination "$dirBackupCompressed$name".tar.gz"
	start=$(date +'%s')
	GZIP=-9 tar -zcf $dirBackupCompressed$name".tar.gz" $dirDestination$directory > /dev/null 2>&1
	time_elapsed=$(($(date +'%s') - $start))
	echo "->"$time_elapsed "second "
	echo "->validate files compress integrity "$dirBackupCompressed$name".tar.gz"
	start=$(date +'%s')
	if ! tar -tf $dirBackupCompressed$name".tar.gz" > /dev/null 2>&1; then
		echo "->Archivo malformado "$dirBackupCompressed$name".tar.gz"
    else
    time_elapsed=$(($(date +'%s') - $start))
	echo "->"$time_elapsed "second "
		if [ "$upload" == "1" ]; then
			echo "->move file compress to upload "$dirBackupCompressed$name".tar.gz"
			cp $dirBackupCompressed$name".tar.gz" $dirBackupCompressedUpload
			echo "->success "$dirBackupCompressedUpload$name".tar.gz"
		fi
	fi
	du=$(du -bsh $dirBackupCompressed$name".tar.gz")
	echo "->final size compress "$du
done
echo "->compress all files tar.gz generateds on "$dirBackupCompressed" backup local"
echo "->destination files "$dirCompressedFinal$year$nameMonthNow".tar.gz"
start=$(date +'%s')
GZIP=-9 tar --remove-files -zcf $dirCompressedFinal$year$nameMonthNow".tar.gz" $dirBackupCompressed*".tar.gz" > /dev/null 2>&1
time_elapsed=$(($(date +'%s') - $start))
echo "->compress success "
echo "->"$time_elapsed "second "
echo "->validate files compress integrity "$dirCompressedFinal$year$nameMonthNow".tar.gz backup local"
start=$(date +'%s')
if ! tar -tf dirCompressedFinal$year$nameMonthNow".tar.gz" > /dev/null 2>&1; then
	echo "->Archivo malformado "$dirCompressedFinal$year$nameMonthNow".tar.gz"
else
	echo "->integrity success "
fi
echo "->"$time_elapsed "second "
echo "->compress all files tar.gz generateds on "$dirBackupCompressedUpload" to upload S3"
echo "->destination files "$dirCompressedFinalUpload$year$nameMonthNow".tar.gz"
start=$(date +'%s')
GZIP=-9 tar --remove-files -zcf $dirCompressedFinalUpload$year$nameMonthNow".tar.gz" $dirBackupCompressedUpload*".tar.gz" > /dev/null 2>&1
time_elapsed=$(($(date +'%s') - $start))
echo "->compress success "
echo "->"$time_elapsed "second "
echo "->validate files compress integrity "$dirCompressedFinalUpload$year$nameMonthNow".tar.gz to upload S3"
start=$(date +'%s')
upload=1
if ! tar -tf $dirCompressedFinalUpload$year$nameMonthNow".tar.gz" > /dev/null 2>&1; then
	echo "->Archivo malformado "$dirCompressedFinalUpload$year$nameMonthNow".tar.gz"
	upload=0
else
	echo "->integrity success "
fi
echo "->"$time_elapsed "second "
if [ $upload -eq 1 ];then
	echo "->upload the last compress to S3"
	start=$(date +'%s')
	s3cmd put $dirCompressedFinalUpload$year$nameMonthNow".tar.gz" s3://antilhue-backup/backup/backups_totales/
	time_elapsed=$(($(date +'%s') - $start))
	echo "->"$time_elapsed "second "
fi

