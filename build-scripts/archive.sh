#!/bin/sh

#  Script.sh
#  CallCenter
#
#  Created by Andrey Moskvin on 12/5/13.
#  Copyright (c) 2013 QuickBlox. All rights reserved.

PROVISIONING_PROFILE_PATH="${WORK_DIR}/build-scripts/Qmunicate_AdHoc.mobileprovision"
SIGNING_IDENTITY="iPhone Distribution: Injoit LTD (8885H5G2YX)"
PRODUCT_NAME="Qmunicate"
APP="${WORK_DIR}/build/Qmunicate.app"
IPA="${WORK_DIR}/build/Qmunicate.ipa"

echo "Creating .ipa for ${PRODUCT_NAME}"
/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${APP}" -o "${IPA}" --sign "${SIGNING_IDENTITY}" --embed "${PROVISIONING_PROFILE_PATH}"
echo "Created .ipa for ${PRODUCT_NAME}"
