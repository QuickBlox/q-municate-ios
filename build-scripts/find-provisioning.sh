#!/bin/sh
#
#  CallCenter
#
#  Created by Andrey Moskvin on 12/5/13.
#  Copyright (c) 2013 QuickBlox. All rights reserved.

PROVISIONING_NAME="Qmunicate_Adhoc"
FILES=/Users/macbook/Library/MobileDevice/Provisioning\ Profiles

cp -rf "${WORK_DIR}/build-scripts/${PROVISIONING_NAME}.mobileprovision" "${WORK_DIR}/build/${PROVISIONING_NAME}.mobileprovision"