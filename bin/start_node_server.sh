#!/usr/bin/env bash
cd /Users/mobilebuild/Jenkins/workspace/mobile-automation-services
echo Killing all the node process
killall node
killall -9 node
echo Updating node dependancies
/usr/local/bin/npm update
echo Starting node dependancies
/usr/local/bin/npm run console
