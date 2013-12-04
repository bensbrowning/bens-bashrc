#!/bin/bash

# bssh function to reconnect to a detached remote screen or a specified one.

bssh(){
	if [[ -z $1 ]]; then
		echo "no hostname given as first arg"
		return 1
	elif [[ -z $2 ]]; then
		#screen_name="auto-screen"
		screen_name='$(screen -ls | grep Detached | awk '{print $1}' | head -n1)'
	fi
	ssh_host=${1}
	export screen_name=${2}

	echo "screen name $screen_name "
	echo "hostname $ssh_host "
	
	### ssh connect stanza ###
	echo "running ssh connect"
		if [[ -n $ssh_host ]] ; then
			while true ; 
			do 
				# ninas version
				#ssh $ssh_host -t " sn1="$(screen -ls | grep Detached | awk '{print $1}' | head -n1 )" ; sn2=${screen_name} ; screen -RD \${sn2} ||{ screen -Rd \${sn1} ;}" && {
				# bens version
				ssh $ssh_host -t " screen -Rd $screen_name " && {
					echo "ssh'd to $ssh_host" ; break
				}||{ 
					echo "SSH no worky to $ssh_host, sleeping"
					sleep 30
				}
			done
		else
			echo "No hostname defined"
		fi
}


##### Iterm Auto SSH on Login #####
# Uncomment to run auto-ssh on login #

#if [[ $TERM_PROGRAM == "iTerm.app" ]]; then
#	. ~/iterm-auto-ssh.sh
#fi


