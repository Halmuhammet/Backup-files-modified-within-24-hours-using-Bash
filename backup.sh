#!/bin/bash

# This checks if the number of arguments is correct
# If the number of arguments is incorrect ( $# != 2) print error message and exit
if [[ $# != 2 ]]
then
  echo "backup.sh target_directory_name destination_directory_name"
  exit
fi

# This checks if argument 1 and argument 2 are valid directory paths
if [[ ! -d $1 ]] || [[ ! -d $2 ]]
then
  echo "Invalid directory path provided"
  exit
fi

targetDirectory=$1
destinationDirectory=$2

echo "$targetDirectory"
echo "$destinationDirectory"

currentTS=$(date +%s)

backupFileName="backup-$currentTS.tar.gz"

# We're going to:
  # 1: Go into the target directory
  # 2: Create the backup file
  # 3: Move the backup file to the destination directory

# Define some useful variables

origAbsPath=$(pwd)

# cd to destination directory to get its absulote path
cd "$destinationDirectory" 
destDirAbsPath=$(pwd)

# now, get back to the original path, then go to target directory to perform the backup on desired files
cd "$origAbsPath" 
cd "$targetDirectory" 

# Get the timestamp for files that have been modified within 24 hours (expressed in seconds)
yesterdayTS=$(($currentTS - 24 * 60 * 60))

# Create an array called toBackup that will store paths to files that need to be backed
declare -a toBackup

# Go through the files and check each whether their modified date is within the last 24 hours
for file in *
do
  if [[ $(date -r "$file" +%s) -gt $yesterdayTS ]]
  then
    toBackup+=("$file")
  fi
done

# Archive and compress, adding each archive name a timestamp
tar -czvf $backupFileName ${toBackup[@]}

# Then move that archive to the destination directory
mv $backupFileName $destDirAbsPath
