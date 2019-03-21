#!/bin/bash
#Requires jq

pathToSettings="/opt/bin/settings/settings.detectUSB.json"
progressImgPath=($(jq -r '.progressImgPath' $pathToSettings))
successImgPath=($(jq -r '.successImgPath' $pathToSettings))
failureImgPath=($(jq -r '.failureImgPath' $pathToSettings))
folderToSearchPath=($(jq -r '.folderToSearchPath' $pathToSettings))
destinationFolderPath=($(jq -r '.destinationFolderPath' $pathToSettings))
destinationFolder=$(basename $destinationFolderPath)
progressImgSleepTime=($(jq -r '.progressImgSleepTime' $pathToSettings))
successImgSleepTime=($(jq -r '.successImgSleepTime' $pathToSettings))
failureImgSleepTime=($(jq -r '.failureImgSleepTime' $pathToSettings))

echo ${progressImgPath[@]}
echo ${successImgPath[@]}
echo ${failureImgPath[@]}
echo ${folderToSearchPath[@]}
echo ${destinationFolderPath[@]}
echo ${progressImgSleepTime[@]}
echo ${successImgSleepTime[@]}
echo ${failureImgSleepTime[@]}
echo "${destinationFolderPath[@]}-rsync"

export DISPLAY=:0

/usr/bin/feh --scale-down --auto-zoom "${progressImgPath[@]}" &
progressPng=$!

#Searches all mounted usb folders
for dir in ${folderToSearchPath[@]}/*; do
    if [ -d "${dir}" ] ; then
      echo "$(basename "$dir")"
    fi
	for dir2 in $dir/*; do
    	if [ -d "${dir2}" ] ; then
          #Searches for desired folder
	        if [ "$(basename "$dir2")" == "${destinationFolder}" ] ; then
      		    echo "${destinationFolder} was found at $dir2"
              status=5
              #Transfers desired folder when found to desired destination
              /usr/bin/rsync -Pauvr --delete --checksum "$dir2/" "${destinationFolderPath}-rsync"
              status=$?
              #When Rsync is successful deletes temporary folder, backs up current application and replaces current application with a new version
              if (($status == 0)); then
                 /usr/bin/rm -rf "${destinationFolderPath[@]}.bk"
                 /usr/bin/mv "${destinationFolderPath[@]}" "${destinationFolderPath[@]}.bk"
                 /usr/bin/mv "${destinationFolderPath[@]}-rsync" "${destinationFolderPath[@]}"
		             /usr/bin/supervisorctl stop kiosktron
                 /usr/bin/sleep ${progressImgSleepTime[@]}
                 /usr/bin/kill $progressPng
                 echo ${successImgPath[@]}
                 /usr/bin/feh --scale-down --auto-zoom  "${successImgPath[@]}" &
                 successPng=$!
                 /usr/bin/sleep ${successImgSleepTime[@]}
		             /usr/bin/supervisorctl restart appName #Restarts application through supervisor
                 /usr/bin/kill $successPng
              #When Rsync fails deletes temporary folder
              else
                 /usr/bin/rm -rf "${destinationFolderPath[@]}-rsync"
		             /usr/bin/supervisorctl stop appName #Restarts application through supervisor
                 /usr/bin/sleep ${progressImgSleepTime[@]}
                 /usr/bin/kill $progressPng
                 echo ${failureImgPath[@]}
                 /usr/bin/feh --scale-down --auto-zoom "${failureImgPath[@]}" &
                 failedPng=$!
                 /usr/bin/sleep ${failureImgSleepTime[@]}
		             /usr/bin/supervisorctl start kiosktron
                 /usr/bin/kill $failedPng
              fi
              #Echoes the return value of rsync
              echo "status="$status
		      fi
	    fi
	done
done
