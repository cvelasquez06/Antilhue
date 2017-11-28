#!/bin/bash
root=$(pwd);
export $(sed -n '1,/incremental/d;/\[/,$d;/^$/d;p' $root"/"sys_options.conf | grep dirRootBackup)
dirRootIncremental=$dirRootBackup
export $(sed -n '1,/differential/d;/\[/,$d;/^$/d;p' $root"/"sys_options.conf)
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
dirDestination=$dirRootBackup$year"/"$monthNow"/Week"$numWeek"/"
dirBackupIncrmentalDestination=$dirRootIncremental$year"/"$monthNow"/"
echo "->validando si existe $dirDestination"
function_validate_dir $dirDestination
if [ $? -ne 1 ];then
	echo "->no existe directorio.....creando"
	mkdir -p $dirDestination
	echo "->directorio creado"
fi
IFS=$'\n'
echo "->Obteniendo listado de respaldos incremental desde "$dirBackupIncrmentalDestination
list_folder=$(ls -1 $dirBackupIncrmentalDestination | grep '\_'$numWeek'$' | sort)
echo "->success "$list_folder
array_list_directory=( $list_folder )
IFS=''
num_backups_dirs=2
echo "->validando minimo de dias de respaldos "$num_backups_dirs
if	[ ${#array_list_directory[@]} -eq $num_backups_dirs ]; then
	echo "->dias validados"
	echo "->copiando cada directorio desde "$dirBackupIncrmentalDestination" hacia "$dirDestination
	for i in ${array_list_directory[@]}; do
		cp -frT $dirBackupIncrmentalDestination$i $dirDestination$i
		echo "->copiado $i"
	done
else
	echo "->dias no validados"
fi
echo "->todo copiado desde "$dirBackupIncrmentalDestination" a "$dirDestination
echo "->comprimiendo respaldos incremental de la semana "$numWeek
GZIP=-9 tar -zcf $dirBackupCompressed$numWeek".tar.gz" $dirDestination
echo "->archivo generado "$dirBackupCompressed$numWeek".tar.gz"
echo "->comprobando integridad de "$dirBackupCompressed$numWeek".tar.gz"
upload=1
if ! tar -tf $dirBackupCompressed$numWeek".tar.gz" > /dev/null 2>&1; then
	echo "->Archivo malformado "$dirBackupCompressed$numWeek".tar.gz"
	upload=0
else
	echo "->integrity success"
fi
echo "->generado respaldo local"
ccp=$(cp -rfT $dirBackupCompressed$numWeek".tar.gz" $dirCompressedFinal)
echo $ccp
echo "->fin generando respaldo local"
if [ $upload -eq 1 ]; then
	echo "->preparando para subir archivo"
	ccp=$(cp -rfT $dirCompressedFinal$numWeek".tar.gz" $dirCompressedFinalUpload)
	echo $ccp
	echo "->fin preparando para subir archivo"
	echo "->upload the last differencial compress to S3" 
	start=$(date +'%s')
	s3cmd put $dirCompressedFinalUpload$numWeek".tar.gz" s3://antilhue-backup/backup/backups_diferenciales/
	time_elapsed=$(($(date +'%s') - $start))
	echo "->"$time_elapsed "second "
fi