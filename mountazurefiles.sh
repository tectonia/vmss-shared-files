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
$installerUrl = "https://aka.ms/vs/16/release/vs_community.exe"
$downloadPath = "C:\Downloads\vs_installer.exe"

# Download Visual Studio installer
Invoke-WebRequest -Uri $installerUrl -OutFile $downloadPath

# Silent installation parameters
$installParams = "--quiet --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NetWeb --includeRecommended --wait"

# Start the installation
# run the installer and redirect the output to a temporary file
$tempFile = New-TemporaryFile
Start-Process -FilePath $downloadPath -ArgumentList $installParams -Wait -RedirectStandardOutput $tempFile

# append the contents of the temporary file to the $4/$hostname.txt file
Get-Content $tempFile | Out-File -Append -FilePath "$4/$HOSTNAME.txt"

# Optional: Add Visual Studio to the system PATH
$vsPath = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE"
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$vsPath", [EnvironmentVariableTarget]::Machine)

# Optional: Restart to apply changes
Restart-Computer -Force


