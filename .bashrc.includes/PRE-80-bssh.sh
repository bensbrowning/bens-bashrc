#!/bin/bash

# bssh function to reconnect to a detached remote screen or a specified one.

# How long to sleep between reconnect attempts
# check before assigning so we can set defaults elsewhere
[[ -n $bssh_sleep ]] || bssh_sleep=30;

bssh(){
	ssh_host=${1}
	screen_name=${2}

	if [[ -n $ssh_host && -n $screen_name ]] ; then
		screen_msg="screen $screen_name"
	elif [[ -n $ssh_host ]] ; then
		screen_msg="first detached screen or a new one"
	else
		echo "no hostname given as first arg"
		return 1
	fi
	
	### ssh connect stanza ###
	while true ; do 
		echo "Running bssh connect, connecting to hostname $ssh_host, $screen_msg"
		ssh $ssh_host -t "[[ -n \"$screen_name\" ]] && screen -Rd $screen_name || screen -RR"  && {
			echo "Disconnected from $ssh_host"
			break
		}||{ 
			echo "SSH not working to $ssh_host, sleeping $bssh_sleep sec"
			sleep "$bssh_sleep"
			}
		done
}
