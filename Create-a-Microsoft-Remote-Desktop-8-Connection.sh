#!/bin/sh
####################################################################################################
#
# This is free and unencumbered software released into the public domain.
# 
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
# 
# In jurisdictions that recognise copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
# 
# For more information, please refer to <http://unlicense.org/>
#
####################################################################################################
#
# More information: http://macmule.com/2013/10/22/how-to-create-a-microsoft-remote-desktop-8-connection
#
# GitRepo: https://github.com/macmule/Create-a-Microsoft-Remote-Desktop-8-Connection
#
####################################################################################################


###
# 
# Set the below to hardcode the variables. The order is as per the Edit Remote Desktops window
#
###

# The UUID for the RDC connection, reuse the same UUID if you wish to easily change the connect settings later
rdcUuid=""

# Name of the connection as shown in the Microsoft Remote Desktop window
connectionName=""

# Address of server for the RDP connection
pcName=""

# Name of the domain (optional)
domainName="" 

# Username for the connection
userName="" 

# Connections resolution dimensions, separated by space ( Width x Height )
connectionResolution=""

# Sets the depth of Colour for the connection, options are:
#	8 = High Color (8 bit)
#	16 = High Color (16 bit)
#	24 = True Color (24 bit)
#	32 = Highest Quality (32 bit)
colourDepth=""

# Sets the screen options, all are boolean & values are to be passed with spaces seperating
# for example (false true false)
screenOptions=""
fullScreen=`echo $screenOptions | awk '{ print $1 }'`
scaleWindow=`echo $screenOptions | awk '{ print $2 }'`
useAllMonitors=`echo $screenOptions | awk '{ print $3 }'`

###
#
# If variables values are not hardcoded, see if a value has been passed to them via Casper.
#
###

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "rdcUUID"
if [ "$4" != "" ] && [ "$rdcUUID" == "" ]; then
    rdcUUID=$4
elif [ -z "$4" ]; then
	echo "No UUID given.. Will generate one..."
	rdcUUID=`uuidgen`
	echo "UUID $rdcUUID generated..."
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 5 AND, IF SO, ASSIGN TO "connectionName"
if [ "$5" != "" ] && [ "$connectionName" == "" ]; then
    connectionName=$5
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 6 AND, IF SO, ASSIGN TO "pcName"
if [ "$6" != "" ] && [ "$pcName" == "" ]; then
    pcName=$6
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 7 AND, IF SO, ASSIGN TO "domainName"
if [ "$7" != "" ] && [ "$domainName" == "" ]; then
    domainName=$7
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 8 AND, IF SO, ASSIGN TO "userName"
if [ "$8" != "" ] && [ "$userName" == "" ]; then
    userName=$8
elif [ -z "$8" ]; then
	echo "No username given.. Getting username of logged in user..."
	userName=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 9 AND, IF SO, ASSIGN TO "resolutionWidth"
if [ "$9" != "" ] && [ "$connectionResolution" == "" ]; then
	connectionResolution=$9
fi


# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 10 AND, IF SO, ASSIGN TO "colourDepth"
if [ "${10}" != "" ] && [ "$colourDepth" == "" ]; then
    colourDepth=${10}
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 11 AND, IF SO, ASSIGN TO "fullScreen, scaleWindow & useAllMonitors"
if [ "${11}" != "" ] && [ "$screenOptions" == "" ]; then
	screenOptions=${11}
    fullScreen=`echo $screenOptions | awk '{ print $1 }'`
	scaleWindow=`echo $screenOptions | awk '{ print $2 }'`
	useAllMonitors=`echo $screenOptions | awk '{ print $3 }'`
fi

###
#
# Script Below
#
###

# Get the username of the currently logged in user
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

# Connections UUID
/usr/libexec/PlistBuddy -c "Add :bookmarkorder.ids: string {$rdcUUID}" /Users/$loggedInUser/Library/Containers/com.microsoft.rdc.mac/Data/Library/Preferences/com.microsoft.rdc.mac.plist

# Name of the connection as shown in the Microsoft Remote Desktop window
/usr/libexec/PlistBuddy -c "Add :bookmarks.bookmark.{$rdcUUID}.label string $connectionName" /Users/$loggedInUser/Library/Containers/com.microsoft.rdc.mac/Data/Library/Preferences/com.microsoft.rdc.mac.plist

# Address of server for the RDP connection
/usr/libexec/PlistBuddy -c "Add :bookmarks.bookmark.{$rdcUUID}.hostname string $pcName" /Users/$loggedInUser/Library/Containers/com.microsoft.rdc.mac/Data/Library/Preferences/com.microsoft.rdc.mac.plist

# Username & domain if given
if [ -z "$domainName" ]; then
	echo "No Domain given.. Will just use username..."
	/usr/libexec/PlistBuddy -c "Add :bookmarks.bookmark.{$rdcUUID}.username string $userName"  /Users/$loggedInUser/Library/Containers/com.microsoft.rdc.mac/Data/Library/Preferences/com.microsoft.rdc.mac.plist
else
	echo "Domain given..."
	/usr/libexec/PlistBuddy -c "Add :bookmarks.bookmark.{$rdcUUID}.username string $domainName'\\\'$userName"  /Users/$loggedInUser/Library/Containers/com.microsoft.rdc.mac/Data/Library/Preferences/com.microsoft.rdc.mac.plist
fi

# Connections resolution dimensions ( resolutionWidth X resolutionHeight )
/usr/libexec/PlistBuddy -c "Add :bookmarks.bookmark.{$rdcUUID}.resolution string '@Size($connectionResolution)'" /Users/$loggedInUser/Library/Containers/com.microsoft.rdc.mac/Data/Library/Preferences/com.microsoft.rdc.mac.plist

# Sets the depth of Colour for the connection
/usr/libexec/PlistBuddy -c "Add :bookmarks.bookmark.{$rdcUUID}.depth integer $colourDepth" /Users/$loggedInUser/Library/Containers/com.microsoft.rdc.mac/Data/Library/Preferences/com.microsoft.rdc.mac.plist

# Full Screen?
/usr/libexec/PlistBuddy -c "Add :bookmarks.bookmark.{$rdcUUID}.fullscreen bool $fullScreen"  /Users/$loggedInUser/Library/Containers/com.microsoft.rdc.mac/Data/Library/Preferences/com.microsoft.rdc.mac.plist

# Scale Window?
/usr/libexec/PlistBuddy -c "Add :bookmarks.bookmark.{$rdcUUID}.scaling bool $scaleWindow"  /Users/$loggedInUser/Library/Containers/com.microsoft.rdc.mac/Data/Library/Preferences/com.microsoft.rdc.mac.plist

# Use All Monitors?
/usr/libexec/PlistBuddy -c "Add :bookmarks.bookmark.{$rdcUUID}.useallmonitors bool $useAllMonitors"  /Users/$loggedInUser/Library/Containers/com.microsoft.rdc.mac/Data/Library/Preferences/com.microsoft.rdc.mac.plist

# As we're root, amend ownership back to set for plist
chown "$loggedInUser" /Users/"$loggedInUser"/Library/Containers/com.microsoft.rdc.mac/Data/Library/Preferences/com.microsoft.rdc.mac.plist

# Exit
exit 0
