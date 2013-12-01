#!/bin/bash
# Made by the lovely Countess Nina Kitterina von Snarf Snaplen
# Auto-ssh - auto ssh to defined hosts based on iterm session ID's #
# Mac Iterm2 users:V
# Set the Hostname values to the ITERM_SESSION_ID for
# the window/tab/pane you want to define and the
# value is the name of the host to ssh to

### Hostname and session id key-value pairs ###
### Quote and white-space delimit any id values you want a host to match, and have defined for auto-ssh - add to array below to set active #

### Session Operation Array ###
### This is an array of each session name we want to operate on, referenced from the variables above ### 

# these are now in ~/.bashrc.autossh

# SSH reconnect function for iterm2
# connects to a specified set of hosts for a
# specified list of tabs and reconnects to a specific
# screen for that window/tab/pane

ssh_connect() {
 id=$ITERM_SESSION_ID
 wtpid=${id}
 wtid=${id%%p[0-9]}
 wid=${id%%t[0-9]p[0-9]}

 echo "id: $id"
 echo "wtpid: $wtpid "
 echo "wtid: $wtid "
 echo "wid: $wid "


 ### Session ID check ###
 ### Iterate over session array, and check session id's ###
 for session in ${session_arr[*]}; 
 do
	## Pull hostnames for sessions in array ##
	echo "session array: $session"

	## indirectly reference session variable, to pull out session id list ##
	session_ids=( ${!session} )
	echo "session array ids: ${session_ids[*]}"

	## iterate over session id's for defined host/session, and check against current session ID ##
	for session_id in ${session_ids[*]};
	do
	echo "session id: $session_id"
		if echo $wtpid | grep $session_id || {
			echo $wtid | grep $session_id
			} || { 
			echo $wid | grep $session_id
			}; 
		then
			ssh_host=$session
		fi
	done
done

## No match found - abort ##
if [[ -z ${ssh_host} ]]; then
	echo "error: no host assigned to these sessions: $wtpid , $wtid , $wid , aborting auto-ssh" 
	exit 1
else
 	echo "final ssh host set: $ssh_host"
fi

 echo "id: $id"
 echo "wtpid: $wtpid "
 echo "wtid: $wtid "
 echo "wid: $wid "

### ssh connect stanza ###
echo "running ssh connect"
	if [[ -n $ssh_host ]] ; then
		while true ; 
		do 
			ssh $ssh_host -t 'screen -Rd $id'  && {
				echo "ssh'd to $ssh_host" ; break
				}||{ 
				echo "SSH no worky to $ssh_host, sleeping"
				sleep 30
				}
		done
	else
		echo "No host defined for $id"
	fi
}

ssh_connect
