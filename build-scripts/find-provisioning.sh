#!/bin/sh
#
#  CallCenter
#
#  Created by Andrey Moskvin on 12/5/13.
#  Copyright (c) 2013 QuickBlox. All rights reserved.

PROVISIONING_NAME="Videu_AdHoc_Provision_Profile"
FILES=/Users/macbook/Library/MobileDevice/Provisioning\ Profiles

find "$FILES" -print0 | while read -d $'\0' file
do
	get_the_profile_name=$(grep -i '<key>name</key>' -A1 -a "$file" | grep -v "Name" | cut -f2 -d\> | cut -f1 -d\<)

	if [ "$get_the_profile_name" == "$PROVISIONING_NAME" ]; then
		echo "$file"
		cp -rf "$file" "${WORK_DIR}/build/${PROVISIONING_NAME}.mobileprovision"
	fi

done
