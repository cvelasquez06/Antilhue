# Backup Rsync
Local and remote backup system for Antilhue Comercial SpA
## Getting Started
Copy all files and configure sys_options.conf into system label with the you need directories. For run application execute run.sh file.
Only available for Linux Platform.
### Prerequisites
You need install:
1. s3cmd
2. rsync
3. tar
4. du
5. necesary permission for create and handing files and directories from bash script.
### Installing
1. Copy all files and folders into your favourite path.
2. Configure the sys_options.conf file into system section and section total and incremental. The diferential section is used into old versions.
3. Configure file_manager.conf. Follow the instruction into file.
4. Create entry register into crontab for run run.sh file with two parameters total or incremental depending backup type you need.
5. You can also run directly of console linux with command run.sh and the parameter you need.
6. Example:
```

run.sh total *for backup total*
run.sh incremental *for backup incremental*

```
## Built With
* [Linux Bash](https://www.gnu.org/software/bash/) GNU Shell
## Authors
* **Cesar Velasquez** - *Software Development* - [Underline](https://www.underline.cl)