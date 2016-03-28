#!/bin/bash
#Upgrade script HiveControl updates
# Used when going from version to version
# Includes methods to upgrade databases, as well as pull new files
# Gets the current version installed and brings up to the latest version when running the script

#Move all of this code into a script that checks for new code once a day.
# If new code is available, trigger an alert in the UI. Clicking gives instructions on how to upgrade.

#Get the latest upgrade script
Upgrade_ver="2"


#Back everything up, just in case (mainly the database)
echo "============================================="
echo "Backing up Database to hive-data.bckup"
sudo cp /home/HiveControl/data/hive-data.db /home/HiveControl/data/hive-data.bckup
echo "============================================="

#Set some variables
WWWTempRepo="/home/HiveControl/upgrade/HiveControl/www/public_html"
DBRepo="/home/HiveControl/upgrade/data"


DestWWWRepo="/home/HiveControl/www/public_html"
DestDB="/home/HiveControl/data/hive-data.db"

# Get the latest code from github into a temporary repository
echo "Getting Latest Code"
#Remove any remnants of past code upgrades
	sudo rm -rf /home/HiveControl/upgrade
#Make us a fresh directory
	sudo mkdir /home/HiveControl/upgrade
#Start in our directory
	sudo cd /home/HiveControl/upgrade
#Get the code
	sudo git clone https://github.com/rcrum003/HiveControl

#Remove some initial installation files from repository for upgrade
#Remove the offending file, since we don't want to upgrade these 
rm -rf $WWWTempRepo/include/db-connect.php
rm -rf $DBRepo/hive-data.db
rm -rf $WWWTempRepo/data/* 
	echo "....... Storing it in /home/HiveControl/upgrade"
echo "============================================="


#Upgrade www
echo "Upgrading WWW pages"
cp -R $WWWTempRepo/pages/* $DestWWWRepo/pages/
cp -R $WWWTempRepo/includes/* $DestWWWRepo/includes/



echo "============================================="

#Upgrade our code
echo "Upgrading our shell scripts"
#cp -R /home/HiveControl/scripts/
echo "============================================="

#Upgrade our DB
#Get DBVersion
#Get the latest upgrade script
DB_ver=$(cat /home/HiveControl/data/DBVERSION)
DBPatches="/home/HiveControl/patches/database"
	#Get the version available
	DB_latest_ver=$(curl -s https://raw.githubusercontent.com/rcrum003/HiveControl/master/data/DBVERSION)

	if [[ $( echo "$DB_ver < $DB_latest_ver" | bc) -eq 1 ]]; then
		echo "Upgrading DBs"
		if [[ $DB_ver -eq "1" ]]; then
			#Upgarding to version 2
			echo "Applying DB Ver1 Upgrades"
			sudo sqlite $DestDB < $DBPatches/DB_PATCH_6 
			#Set DB Ver to the next
			$DB_ver="2"		
		fi
		#if [[ $DB_ver -eq "2" ]]; then
			#Upgarding to version 2
		#	echo "Applying DB Ver2 Upgrades"
						
		#fi
	fi
	sudo echo $DB_ver > /home/HiveControl/data/DBVERSION

echo "============================================="

#Cleanup and set the flag in the DB

