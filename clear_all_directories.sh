#!/bin/bash

# export $(sed -n '1,/total/d;/\[/,$d;/^$/d;p' $root"/"sys_options.conf)
# 
# rm -rf $dirRootBackup*
# rm -rf $dirBackupCompressed*
# rm -rf $dirBackupCompressedUpload*
# rm -rf $dirCompressedFinal*
# rm -rf $dirCompressedFinalUpload*
# 
# export $(sed -n '1,/incremental/d;/\[/,$d;/^$/d;p' $root"/"sys_options.conf)
# 
# rm -rf $dirRootBackup*
# rm -rf $dirBackupCompressed*
# rm -rf $dirBackupCompressedUpload*
# rm -rf $dirCompressedFinal*
# rm -rf $dirCompressedFinalUpload*
# 
# export $(sed -n '1,/differential/d;/\[/,$d;/^$/d;p' $root"/"sys_options.conf)
# 
# rm -rf $dirRootBackup*
# rm -rf $dirBackupCompressed*
# rm -rf $dirBackupCompressedUpload*
# rm -rf $dirCompressedFinal*
# rm -rf $dirCompressedFinalUpload*