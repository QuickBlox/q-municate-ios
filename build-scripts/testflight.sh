#!/bin/sh
#
#  CallCenter
#
#  Created by Andrey Moskvin on 03/03/14.
#  Copyright (c) 2013 QuickBlox. All rights reserved.

IPA="${WORK_DIR}/build/Videu.ipa"

curl "http://testflightapp.com/api/builds.json" \
-F file=@"${IPA}" \
-F api_token="60d6507adf1000e247c73b22063bec28_MjIwNjc1MjAxMS0xMS0xNyAxMToyMDo0NS45NjY1Mzc" \
-F team_token="bb88bf128bdd4df6823d46b5a9938c66_MjIyNDUyMjAxMy0wNS0xMSAxMTowMTowNS4yNTA5NjE" \
-F notes="Released with Atlassian Bamboo" \
-F notify=True \
-F distribution_lists="Bamboo Distribution List"