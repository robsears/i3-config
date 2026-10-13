#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DATA="${HOME}/.config/i3-data"
REFRESH=600 # Seconds for the IP information to live

# Dracula?
#color_high="#50FA7B"
#color_medhigh="#A0FA84"
#color_med="#F1FA8C"
#color_medlow="F8A871"
#color_low="#FF5555"
#color_degraded=$color_med
#color_bad="#ee7777"
#color_good="#77ee77"


# Light colors
color_bad="#ee7777"
color_good="#77ee77"
color_high="#ee7777"
color_medhigh="#eebb77"
color_med="#eeee77"
color_medlow="#bbee77"
color_low="#77ee77"

# Dark colors
# TODO: Parameterize? Make this selectable?
#
# color_bad="#993333"
# color_good="#339933"
#
# color_high="#993333"
# color_medhigh="#997733"
# color_med="#999933"
# color_medlow="#669933"
# color_low="#339933"

# Get a color indicator.
# Accepts a numerical input between 0 and 100, representing the percentage of a
# resource in use.
# Returns a color indicating whether this value is low (green hues), medium
# (yellow hues), or high (red hues).
getColor() {
	if [[ $1 -gt 80 ]] || [[ $1 -eq 80 ]]; then
		echo -n $color_high
	elif [[ $1 -gt 65 ]] || [[ $1 -eq 65 ]]; then
		echo -n $color_medhigh
	elif [[ $1 -gt 50 ]] || [[ $1 -eq 50 ]]; then
		echo -n $color_med
	elif [[ $1 -gt 35 ]] || [[ $1 -eq 35 ]]; then
		echo -n $color_medlow
	elif [[ $1 -gt 0 ]]  || [[ $1 -eq 0 ]] && [[ $1 -lt "35" ]]; then
		echo -n $color_low
	fi
}

# Determine the percentage of memory currently in use.
# No inputs accepted.
# Returns a JSON representation including the % used, and a color indicator.
getMem() {
	max=$(grep MemTotal /proc/meminfo | tr -s ' ' | cut -d ' ' -f 2)
	used=$(grep Buffers /proc/meminfo | tr -s ' ' | cut -d ' ' -f 2)
	free=$(echo "$max - $used" | bc)
	percent=$(echo "${used}00 / ${max}" | bc)
	color=$(getColor ${percent})
	echo '{ "full_text": " Mem: '${percent}'%", "color": "'$color'" }'
}

# Determine the percentage of disk currently in use.
# Accepts a string reference to a *mounted* block device, such as '/dev/sdX1'.
# Will also accept '/' in reference to current root partition.
# Returns a JSON representation including the % used, and a color indicator.
getDisk() {
	partition=$1
	if [[ "${partition}" = "/" ]]; then
		diskname="Root"
	else
		diskname=partition
	fi

	if [[ -z "${partition/ /}" ]]; then
		echo '{ "full_text": " No partition", "color": "'$color_bad'" }'
	else
		disk=$(df -h $partition | grep -v Filesystem | sed -r 's/.* ([\.0-9]{1,})%.*/\1/')
		if [[ -z "${disk}" ]]; then
			echo '{ "full_text": " No such partition: '$1'", "color": "'$color_bad'" }'
		else
	    color=$(getColor ${disk})
      echo '{ "full_text": " '${diskname}': '${disk}'%", "color": "'$color'" }'
		fi
	fi
}

# Get the current date and time, in the local time zone.
# No inputs accepted.
# Returns a JSON representation of the time.
dateTime() {
	date=$(date '+%Y-%m-%d %H:%M:%S %Z')
	echo '{ "full_text": " '$date' ", "color": "'${color_good}'" }'
}

# Get the current date and time, in the local time zone.
# No inputs accepted.
# Returns a JSON representation of the time.
utcTime() {
        date=$(date -u '+%Y-%m-%d %H:%M:%S %Z')
        echo '{ "full_text": " UTC: '$date' ", "color": "'#BFFFF4'" }'
}

# Update the IP address information if it has expired or does not exist. This
# architecture is used to keep from wasting bandwidth by checking the public
# IPv4 every 1s. It's not going to change *that* often.
# No inputs accepted.
maybeUpdateIps() {
	if [ -f "${DATA}/public-ipv4" ]; then
		current_epoch=$(date +%s)
		ips_last_checked_epoch=$(stat -c '%Y' "${DATA}/public-ipv4")
		age=$(echo "($current_epoch - $ips_last_checked_epoch)" | bc)
		if [ "$age" -lt "$REFRESH" ]; then
			return 0
		fi
	fi
	sh "${DIR}/network-info.sh"
}

# Get the public IP address for this computer.
# No inputs accepted.
# Returns a JSON representation of the public IP address for this computer.
getPublicIp() {
	maybeUpdateIps
	public_ipv4=$(grep 'public-ipv4' "${DATA}/public-ipv4" | sed -r 's/.*: (.*)/\1/')
	if [[ -z "${public_ipv4}" ]]; then
		echo '{ "full_text": "No public IP", "color": "'$color_bad'" }'
	else
		echo '{ "full_text": "Public IP: '$public_ipv4'", "color": "'$color_good'" }'
	fi
}

getLoad() {
	load=$(uptime | sed -r 's/.*average: (\S+),.*/\1/')
	cpus=$(nproc)
        if [[ $(bc <<< "${load} < (0.25 * $(nproc))") = 1 ]]; then
                color=$color_low
        elif [[ $(bc <<< "${load} >= (0.25 * $(nproc))") = 1 ]] && [[ $(bc <<< "${load} < (0.5 * $(nproc))") = 1 ]]; then
                color=$color_medlow
        elif [[ $(bc <<< "${load} >= (0.5 * $(nproc))") = 1 ]] && [[ $(bc <<< "${load} < (0.75 * $(nproc))") = 1 ]]; then
                color=$color_med
        elif [[ $(bc <<< "${load} >= (0.75 * $(nproc))") = 1 ]] && [[ $(bc <<< "${load} < $(nproc)") = 1 ]]; then
                color=$color_medhigh
        elif [[ $(bc <<< "${load} >= $(nproc)") = 1 ]]; then
                color=$color_high
        fi

	loadstr="$(echo "scale=1;100.0*${load}/${cpus}" | bc)%"
	echo '{ "full_text": "System load: '$loadstr'", "color":"'$color'" }'
}

# Print data out and sleep 1s forever. This updates the status bar every second.
echo '{ "version": 1 }'
echo '['
echo '[]'
while [ 1 = 1 ]; do
	echo ",[$(getDisk '/'), $(getMem), $(getLoad), $(getPublicIp), $(utcTime), $(dateTime)]"
	sleep 1
done
