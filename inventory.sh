#!/bin/bash

parse_options() {
	TEMP=$(getopt -o 'd' -n "$0" -- "$@")
	if [ $? -ne 0 ]; then
		echo 'Error parsing options' >&2
	    exit 1
	fi
	eval set -- "$TEMP"
	unset TEMP
	
	while true; do	
		case "$1" in
			'-d')
				DEBUG=1
				shift
				continue
			;;
			'--')
				shift
				break
			;;
			*)
				echo 'Unknown error.' >&2
				exit 2
			;;
		esac
	done
}

setup_logging() {
	if [ "$DEBUG" = "1" ]; then
		log=/proc/self/fd/1
	else
		local logdir=/var/log
		test ! -d "$logdir" && logdir=/tmp
		test ! -d "$logdir" && logdir=/
		log="${logdir}/inventory.log"
		
		if ! touch "$log" 2>/dev/null; then
			printf "Unable to touch '%s'\n" "$log"
			exit 1
		fi
	fi
}

get_db_schema() {
	#curl -i $postgrest_url/computers -X GET -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json"
	curl -i $postgrest_url/computers?limit=0 -X GET -H "Content-Type: application/json"
}

parse_options "$@"

declare log
setup_logging

{
	# search for config file first in local directory then alongside script	
	if [ -f inventory.conf.sh ]; then
		. inventory.conf.sh
	elif [ -f $(dirname $0)/inventory.conf.sh ]; then
		. $(dirname $0)/inventory.conf.sh
	fi
	
	# set default server in case config file does not define it		
    postgrest_url=${postgrest_url:-http://installsrv.at.freegeekarkansas.org:3000}
	get_db_schema 


} >$log 2>&1


