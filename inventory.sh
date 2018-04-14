#!/bin/bash
# Copyright 2018 Jared H. Hudson <jhhudso@volumehost.com>
# Copyright 2018 Zac Slade
# Licensed under GPL v2 or later
# Some commands based on Josh Nobert's syscript
#

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
	printf "%s %s\n" "$(date -Iseconds)" "$1" >&2
}

get() {
	if [ -z "$1" -o -z "$2" ]; then		
		log 'Error in get function. Use post <table> <query>'
		return 1
	else
		local table=$1
		local query=$2
	fi
	
	log "GETing from $postgrest_url/$table where $query"
	response=$(curl -i $postgrest_url/$table?$query -X GET \
	        	    -H "Authorization: Bearer $postgrest_token" \
	     			-H 'Content-Type: application/json' 2>/dev/null)
	response=${response//$'\r'/}
	log "Response:"
	echo "$response" >&1
	echo "$response" >&2
}

post() {
	if [ -z "$1" -o -z "$2" ]; then		
		log 'Error in post function. Use post <table> <json to post>'
		return 1
	else
		local table=$1
		local -A json=$2
	fi
	
	log "Posting to $postgrest_url/$table with $json"
	response=$(curl -i $postgrest_url/$table -X POST \
	        	    -H "Authorization: Bearer $postgrest_token" \
	     			-H 'Content-Type: application/json' \
	     			-d "$json" 2>/dev/null)
	response=${response//$'\r'/}
	log "Response:"
	echo "$response" >&1
	echo "$response" >&2
}

array_to_json() {
	local -i i=0
	printf '{'
	for idx in ${!json[*]}; do
		if [ "$1" = "nonulls" -a -z "${json[$idx]}" ]; then
			continue;
		fi
		if [ $((i++)) -gt 0 ]; then
			printf ", "
		fi
		printf '"%s":"%s"' "$idx" "${json[$idx]}"
	done
	printf '}\n'
}

post_manufacturer() {
    if [ -z "$1" ]; then
	return 1;
    fi

    declare -A json=()
    declare -i manufacturer_id=0
    json[name]=$1
    manufacturer_id=$(post manufacturers "$(array_to_json nonulls)"|awk -F. '/Location: \/manufacturers\?manufacturer_id=eq\./{print $NF;exit}')

    if [ $manufacturer_id -eq 0 ]; then
	str=$(get manufacturers select=manufacturer_id\&name=eq.$1)
	if [[ "$str" =~ \[\{\"manufacturer_id\":([0-9]+)\}\] ]]; then
	    manufacturer_id=${BASH_REMATCH[1]}
	fi
    fi

    log "Manufacuturer ID: $manufacturer_id added"
    printf "%d\n" "$manufacturer_id"

    return 0;
}

post_computer() {
        system_manufacturer=$(post_manufacturer $(dmidecode -s system-manufacturer))
        baseboard_manufacturer=$(post_manufacturer $(dmidecode -s baseboard-manufacturer))
        chassis_manufacturer=$(post_manufacturer $(dmidecode -s chassis-manufacturer))

        local -A json=()

	json[chassis_manufacturer]=$chassis_manufacturer
 	json[baseboard_manufacturer]=$baseboard_manufacturer
	json[system_manufacturer]=$system_manufacturer

 	json[system_product_name]=$(dmidecode -s baseboard-product-name) 
 	json[system_version]=$(dmidecode -s system-version) 
 	json[system_sn]=$(dmidecode -s system-serial-number)
 	
	json[baseboard_product_name]=$(dmidecode -s baseboard-product-name)
 	json[baseboard_version]=$(dmidecode -s baseboard-version)
	json[baseboard_sn]=$(dmidecode -s baseboard-serial-number)
 	json[baseboard_asset_tag]=$(dmidecode -s baseboard-asset-tag)
 	
 	json[chassis_type]=$(dmidecode -s chassis-type)
 	json[chassis_version]=$(dmidecode -s chassis-version)
 	json[chassis_sn]=$(dmidecode -s chassis-serial-number)
 	json[chassis_asset_tag]=$(dmidecode -s chassis-asset-tag)
	
	if which lsb_release &>/dev/null; then
		json[os]=$(lsb_release -a | awk -F ":" '/Description:/{sub(/^[ \t]+/, "",$2);print $2}')
	elif [ -f /etc/os-release ]; then
		eval $(cat /etc/os-release)
		json[os]=$PRETTY_NAME
	fi
	
	declare -i computer_id=0
	computer_id=$(post computers "$(array_to_json nonulls)"|awk -F. '/Location: \/computers\?computer_id=eq\./{print $NF;exit}')
	log "Computer ID: $computer_id added"
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
	
		post cpus "$(array_to_json nonulls)" >/dev/null
	done
}

post_drive() {
	local -i computer_id=$1

	IFS=$'\n'
	for disk in $(lsblk -Pdibo KNAME,SIZE,ROTA,SERIAL,TRAN,MODEL,TYPE); do
		unset KNAME SIZE ROTA SERIAL TRAN MODEL TYPE
		eval $disk
		declare -A json=( [computer_id]=$computer_id [type]=Unknown )
		
		if [ -n $SIZE ]; then
			json[size]=$SIZE
			json[size_unit]=B;
		else
			log 'failure to get disk size'
		fi

		test -z $SERIAL && SERIAL=$(hdparm -i /dev/$KNAME|awk '/SerialNo=/{match($0,/SerialNo=(.*)/,a);print a[1]}')
		test -n $SERIAL && json[sn]=$SERIAL

		if [ "$TYPE" = 'disk' ]; then
			if [ "$ROTA" = '1' ]; then
				json[type]=HDD
			else
				if [ "$TRAN" = 'sata' ]; then
					json[type]=SSD
				fi
			fi
		elif [ "$TYPE" = 'rom' ]; then
			json[type]=ROM
		fi
	
		json[model]=$MODEL
		#json[rpm]=$()
	
		post drives "$(array_to_json nonulls)" >/dev/null
	done
}

post_memory() {
	local -i computer_id=$1
	
	for handle in $(dmidecode --type 17|awk -F, '/Handle 0x/{match($1,/Handle (0x[0-9A-Z]*)/,a);print a[1]}'); do
		declare -A json=()		
		json[computer_id]=$computer_id

		memory=$(awk -F': ' -vtarget=$handle -f - <(dmidecode --type 17) <<'END'
/^Handle 0x[0-9A-F]*/        {match($0,/^Handle (0x[0-9A-F]*)/,a); handle=a[1]}
/^[[:blank:]]*/ && (handle != target) {next}
/^[[:blank:]]*Part Number:/   {match($0,/Part Number: (.*)/,a);printf("PART_NUMBER=\"%s\" ",a[1])}
/^[[:blank:]]*Speed:/         {match($0,/Speed: ([0-9]*) ([a-zA-Z]*)[\w]*$/,a); printf("SPEED=\"%s\" SPEED_UNIT=\"%s\" ",a[1],a[2])}
/^[[:blank:]]*Size:/          {match($0,/Size: ([0-9]*) ([a-zA-Z]*)[\w]*$/,a); printf("SIZE=\"%s\" SIZE_UNIT=\"%s\" ",a[1],a[2])}
/^[[:blank:]]*Type:/          {match($0,/Type: ([0-9a-zA-Z]*)[\w]*$/,a); printf("TYPE=\"%s\" ",a[1])}
/^[[:blank:]]*Form Factor:/   {match($0,/Form Factor: (.*)[\w]*$/,a); printf("FORM_FACTOR=\"%s\" ",a[1])}
/^[[:blank:]]*Serial Number:/ {match($0,/Serial Number: (.*)[\w]*$/,a); if (a[1] !~ /^0*$/ && a[1] !~ /NO DIMM/ && a[1] !~ /Unknown/ && a[1] !~ /Empty/ && a[1] !~ /Not Specified/) {printf("SN=\"%s\" \n",a[1])}}
/^[[:blank:]]*Locator:/       {match($0,/Locator: (.*)[\w]*$/,a); printf("LOCATOR=\"%s\" ",a[1])}
/^[[:blank:]]*Rank:/          {match($0,/Rank: (.*)[\w]*$/,a); printf("RANK=\"%s\" ",a[1])}
/^[[:blank:]]*Manufacturer:/  {match($0,/Manufacturer: (.*)[\w]*$/,a); printf("MANUFACTURER=\"%s\" ",a[1])}
/^$/                          {printf("\n")}
END
)
		unset PART_NUMBER SPEED SPEED_UNIT SIZE SIZE_UNIT TYPE FORM_FACTOR SN LOCATOR RANK MANUFACTURER
		eval $memory

		json[part_number]=$PART_NUMBER
		json[speed]=$SPEED
		json[speed_unit]=$SPEED_UNIT
		json[size]=$SIZE
		json[size_unit]=$SIZE_UNIT
		json[type]=$TYPE
		json[form_factor]=$FORM_FACTOR
		json[sn]=$SN
		json[locator]=$LOCATOR
		json[rank]=$RANK
		json[manufacturer]=$MANUFACTURER

		post memory "$(array_to_json nonulls)" >/dev/null
	done
}

post_host() {
    if [ -z "$1" ]; then
	return 1;
    fi

    declare -A json=()
    json[computer_id]=$1
    json[fqdn]=$(hostname -f)
    json[hostname]=$(hostname)
    json[ip]=$(ip a|grep inet|grep global|awk '{print $2;exit}')

    post hosts "$(array_to_json nonulls)"|awk -F. '/Location: \/hosts\?hosts_id=eq\./{print $NF;exit}'

    return 0;
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
		post_memory $computer_id
		post_host $computer_id
	else
		log "Error adding computer"
		exit 1
	fi
} >>$logfile 2>&1


