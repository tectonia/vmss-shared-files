#!/bin/bash
# $1 = Azure storage account name
# $2 = Azure storage account key
# $3 = Azure file share name
# $4 = mountpoint path
# $5 - username

# For more details refer to https://azure.microsoft.com/en-us/documentation/articles/storage-how-to-use-files-linux/

# update package lists
apt-get -y update

# install cifs-utils and mount file share
apt-get install cifs-utils
mkdir $4
mount -t cifs //$1.file.core.windows.net/$3 $4 -o vers=3.0,username=$1,password=$2,dir_mode=0777,file_mode=0666

# create a symlink from /mountpath/xxx to ~username/xxx
linkpoint=`echo $4 | sed 's/.*\///'`
eval ln -s $4 ~$5/$linkpoint

# create marker files for testing
{
    echo "Ownership of directories:"
    ls -l $4
} > $4/$HOSTNAME.txt

# Variables
installerUrl="https://aka.ms/vs/16/release/vs_community.exe"
downloadPath="/tmp/vs_installer.exe"

# Download Visual Studio installer
wget $installerUrl -O $downloadPath 2>&1 | tee -a $4/$HOSTNAME.txt

# Silent installation parameters
installParams="--quiet --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NetWeb --includeRecommended --wait"

# Start the installation
chmod +x $downloadPath
$downloadPath $installParams 2>&1 | tee -a $4/$HOSTNAME.txt

# Optional: Add Visual Studio to the system PATH
vsPath="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE"
export PATH=$PATH:$vsPath

# Optional: Restart to apply changes
# This command must be run as root
shutdown -r now

