#!/bin/bash
# Copyright 2018 Jared H. Hudson <jhhudso@volumehost.com>
# Licensed under GPL v2 or later

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
		logfile=/proc/self/fd/1
	else
		local logdir=/var/log
		test ! -d "$logdir" && logdir=/tmp
		test ! -d "$logdir" && logdir=/
		logfile="${logdir}/inventory.log"
		
		if ! touch "$logfile" 2>/dev/null; then
			printf "Unable to touch '%s'\n" "$logfile"
			exit 1
		fi
	fi
}

log() {
	printf "%s %s\n" "$(date -Iseconds)" "$1"
}

post() {
	if [ -z "$1" -o -z "$2" ]; then		
		echo 'Error in post function. Use post <table> <json to post>' >&2
		return 1
	else
		local table=$1
		local -A json=$2
	fi
	
	log "Posting to $postgrest_url/$table with $json" >&2
	response=$(curl -i $postgrest_url/$table -X POST \
	        	    -H "Authorization: Bearer $postgrest_token" \
	     			-H 'Content-Type: application/json' \
	     			-d "$json" 2>/dev/null)
	response=${response//$'\r'/}
	log "Response:" >&2
	echo "$response" >&1
	echo "$response" >&2
}

array_to_json() {
	local -i i=0
	printf '{'
	for idx in ${!json[*]}; do
		if [ $((i++)) -gt 0 ]; then
			printf ", "
		fi
		printf '"%s":"%s"' "$idx" "${json[$idx]}"
	done
	printf '}\n'
}

post_computer() {
	declare -A json=()
	json[motherboard_model]=$(dmidecode -s baseboard-product-name)
	json[motherboard_sn]=$(dmidecode -s baseboard-serial-number)
	
	if which lsb_release &>/dev/null; then
		json[os]=$(lsb_release -a | awk -F ":" '/Description:/{sub(/^[ \t]+/, "",$2);print $2}')
	elif -f /etc/os-release; then
		eval $(cat /etc/os-release)
		json[os]=$PRETTY_NAME
	fi
		
	
	declare -i computer_id=0
	computer_id=$(post computers "$(array_to_json)"|awk -F. '/Location: \/computers\?computer_id=eq\./{print $NF;exit}')
	log "Computer ID: $computer_id added" >&2
	echo $computer_id
}

post_cpu() {
	local -i computer_id=$1
	
	for cpu in $(grep 'physical id' /proc/cpuinfo|sort|uniq|awk '{print $NF}'); do
		declare -A json=()
		json[computer_id]=$computer_id
	 	json[model]=$(awk -F': ' -vpackage=$cpu -f - /proc/cpuinfo <<'END'
/physical id/ {physical_id=$NF}
/core id/     {core_id=$NF}
/model name/  {model=$2}
/^$/          {if (core_id==0 && physical_id==package){print model; exit}}
END
)
		json[cores]=$(awk -F': ' -vpackage=$cpu -f - /proc/cpuinfo <<'END'
/physical id/ {physical_id=$NF}
/core id/     {core_id=$NF}
/cpu cores/   {cores=$2}
/^$/          {if (core_id==0 && physical_id==package){print cores;exit}}
END
)
		json[threads_per_core]=$(awk -F': ' -vpackage=$cpu -f - /proc/cpuinfo <<'END'
/physical id/{physical_id=$NF}
/core id/    {core_id=$NF}
/siblings/   {siblings=$NF}
/cpu cores/  {cores=$2}
/^$/         {if (core_id==0 && physical_id==package){print siblings/cores;exit}}
END
)
		json[speed]=$(dmidecode -s processor-frequency|awk -vpackage=$cpu '{if (NR==package+1){print $1;exit}}')
		json[speed_unit]=$(dmidecode -s processor-frequency|awk -vpackage=$cpu '{if (NR==package+1){print $2;exit}}')
	
		post cpus "$(array_to_json)" >/dev/null
	done
}

post_drive() {
	local -i computer_id=$1

	IFS=$'\n'
	for disk in $(lsblk -Pdibo KNAME,SIZE,ROTA,SERIAL,TRAN,MODEL); do
		unset KNAME SIZE ROTA SERIAL TRAN MODEL
		eval $disk
		declare -A json=()

		json[computer_id]=$computer_id
		json[type]="Unknown"
		if [[ -n $MODEL ]]; then json[model]=$MODEL; fi
		if [[ -n $SIZE ]]; then
			json[size]=$SIZE
			json[size_unit]=B;
		else
			log "failure to get disk size"
		fi

		if [ -z "$SERIAL" ]; then
			SERIAL=$(hdparm -i /dev/$KNAME|awk '/SerialNo=/{match($0,/SerialNo=(.*)/,a);print a[1]}')
		fi
		if [ ! -z "$SERIAL" ]; then
			json[sn]=$SERIAL
		fi
		if [[ $ROTA -eq 1 ]]; then
			json[type]="HDD"
		else
			if [[ $TRAN == 'sata' ]]; then
				json[type]="SSD"
			else
				json[type]="Unknown"
			fi
		fi

		#json[rpm]=$()
	
		post drives "$(array_to_json)" >/dev/null
	done
}

post_memory() {
	local -i computer_id=$1
	
	for handle in $(dmidecode --type 17|awk -F, '/Handle 0x/{match($1,/Handle (0x[0-9A-Z]*)/,a);print a[1]}'); do
		declare -A json=()
		
		json[computer_id]=$computer_id
		json[model]=$(awk -F': ' -vtarget=$handle -f - <(dmidecode --type 17) <<'END'
/Handle 0x[0-9A-F]*/ {match($0,/Handle (0x[0-9A-F]*)/,a); handle=a[1]}
/Part Number/        {model=$2}
/^$/                 {if (handle==target){print model; exit}}
END
)
		json[speed]=$(awk -F': ' -vtarget=$handle -f - <(dmidecode --type 17) <<'END'
/Handle 0x[0-9A-F]*/ {match($0,/Handle (0x[0-9A-F]*)/,a); handle=a[1]}
/Speed/              {match($0,/Speed: ([0-9]*) /,a); speed=a[1]}
/^$/                 {if (handle==target){print speed; exit}}
END
)
		if [ -z "${json[speed]}" ]; then
			json[speed]=0
		fi
		
		json[speed_unit]=$(awk -F': ' -vtarget=$handle -f - <(dmidecode --type 17) <<'END'
/Handle 0x[0-9A-F]*/ {match($0,/Handle (0x[0-9A-F]*)/,a); handle=a[1]}
/Speed/              {match($0,/Speed: ([0-9]*) ([a-zA-Z]*)/,a); speed=a[2]}
/^$/                 {if (handle==target){print speed; exit}}
END
)
		unset json[speed_unit] #until we work out MHz vs MT/s
		#json[size]=$()
		#json[size_unit]=$()
		#json[type]=$()
	
		post memory "$(array_to_json)" >/dev/null
	done
}

parse_options "$@"

umask 027

declare logfile=
setup_logging

{
	log "Starting $0"
	
	# search for config file first in local directory then alongside script	
	if [ -f inventory.conf.sh ]; then
		. inventory.conf.sh
	elif [ -f $(dirname $0)/inventory.conf.sh ]; then
		. $(dirname $0)/inventory.conf.sh
	fi
	
	if [ "$(id -u)" != "0" ]; then
		printf "Must be root to run.\n\n"
		exit 1
	fi
	
	# set default server in case config file does not define it		
    postgrest_url=${postgrest_url:-http://installsrv.at.freegeekarkansas.org:3000}
	
	declare -i computer_id=0
	computer_id=$(post_computer)
	if [ $computer_id -gt 0 ]; then
		post_cpu $computer_id
		post_drive $computer_id
		#post_memory $computer_id
	else
		log "Error adding computer"
		exit 1
	fi
} >>$logfile 2>&1


