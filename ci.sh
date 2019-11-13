#!/bin/bash
set -e
xcodebuild -project 'startwars.xcodeproj' -scheme 'startwars' -destination 'platform=iOS Simulator,name=iPhone 8,OS=13.2.2' test
xcodebuild -project 'startwars.xcodeproj' -scheme 'startwars' -destination 'generic/platform=iOS' -configuration Release build CODE_SIGNING_ALLOWED=NO