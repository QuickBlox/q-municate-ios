#!/bin/sh
#  mogen.sh
#
COREDATA_DIR="${PROJECT_DIR}/Q-municate/Classes/CoreData/"
HUMAN_DIR="${PROJECT_DIR}/Q-municate/Classes/CoreData/Entries"
MACHINE_DIR="${PROJECT_DIR}/Q-municate/Classes/CoreData/EntriesMachine"
INCLUDE_H="${PROJECT_DIR}/Q-municate/Classes/CoreData/ModelIncludes.h"

mogenerator = mogenerator

#mogenerator=/usr/local/bin/mogenerator

echo $mogenerator --model \"${INPUT_FILE_PATH}\" --machine-dir "$MACHINE_DIR/" --human-dir "$HUMAN_DIR/" --includeh "$INCLUDE_H" --template-var arc=true
$mogenerator --model \"${INPUT_FILE_PATH}\" --machine-dir "$MACHINE_DIR/" --human-dir "$HUMAN_DIR/" --includeh "$INCLUDE_H" --template-var arc=true

echo ${DEVELOPER_BIN_DIR}/momc -XD_MOMC_TARGET_VERSION=10.6 \"${INPUT_FILE_PATH}\" \"${TARGET_BUILD_DIR}/${EXECUTABLE_FOLDER_PATH}/${INPUT_FILE_BASE}.mom\"
${DEVELOPER_BIN_DIR}/momc -XD_MOMC_TARGET_VERSION=10.6 "${INPUT_FILE_PATH}" "${TARGET_BUILD_DIR}/${EXECUTABLE_FOLDER_PATH}/${INPUT_FILE_BASE}.mom"

echo "that's all folks. mogen.sh is done"