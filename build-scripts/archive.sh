#!/bin/sh

#  Script.sh
#  CallCenter
#
#  Created by Andrey Moskvin on 12/5/13.
#  Copyright (c) 2013 QuickBlox. All rights reserved.

PROVISIONING_PROFILE_PATH="${WORK_DIR}/build/${PROVISIONING_NAME}.mobileprovision"
SIGNING_IDENTITY="iPhone Distribution: Videu, LLC (82994PAQEW)"
PRODUCT_NAME="Videu"
APP="${WORK_DIR}/build/Videu.app"
IPA="${WORK_DIR}/build/Videu.ipa"

echo "Creating .ipa for ${PRODUCT_NAME}"
/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${APP}" -o "${IPA}" --sign "${SIGNING_IDENTITY}" --embed "${PROVISIONING_PROFILE_PATH}"
echo "Created .ipa for ${PRODUCT_NAME}"
