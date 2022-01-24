#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DATA="${DIR}/../data"
REFRESH=600 # Seconds for the internet speed and IP information to live
PIHOLE_REFRESH=30 # seconds for the pi-hole service to live

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

# Get the current battery charge(s)
# No inputs accepted.
# Returns a JSON representation including the % remaining, and a color indicator.
getBatt() {
	batCount=$(acpi -b | grep 'Battery ' | wc -l)
	if [[ $batCount == 1 ]]; then
		batt0=$(acpi -b | grep 'Battery 0:' | sed 's/.*, \([0-9]*\)%.*/\1/')
	elif [[ $batCount == 2 ]]; then
		batt1=$(acpi -b | grep 'Battery 1:' | sed 's/.*, \([0-9]*\)%.*/\1/')
	fi
	if [[ -n ${batt0} ]]; then
		batt="${batt0}%"
	elif [[ -n ${batt1} ]]; then
		batt="0:${batt0}% 1:${batt1}%"
	fi
	invBatt=$(echo "100-${batt0}" | bc)
	color=$(getColor ${invBatt})
	echo '{ "full_text": " Battery: '${batt}' ", "color": "'${color}'" }'
}

# Get the current volume settings.
# No inputs accepted.
# Returns a JSON representation of the % volume for each channel, and a color indicator.
getVol() {
  audio_cmd="amixer -D pulse sget Master"
	chanCount=$( ${audio_cmd} | grep '%' | wc -l)
	if [[ $chanCount == 0 ]]; then
		vol='none'
		color=${color_good}
	elif [[ $chanCount == 1 ]]; then
		lvl=$( ${audio_cmd} | grep '%' | sed 's/.*\[\([0-9]*\)%.*/\1/')
		vol="${lvl}%"
	elif [[ $chanCount == 2 ]]; then
		left=$( ${audio_cmd} | grep '%' | grep 'Left' | sed 's/.*\[\([0-9]*\)%.*/\1/')
		right=$( ${audio_cmd} | grep '%' | grep 'Right' | sed 's/.*\[\([0-9]*\)%.*/\1/')
		if [[ $left == $right ]] || [[ $left -gt $right ]]; then
			lvl=${left}
		else
			lvl=${right}
		fi
		vol="${left}% <> ${right}%"
	fi
	color=$(getColor ${lvl})
	echo '{ "full_text": " Volume: '${vol}' ", "color": "'${color}'" }'
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

# Get the current date and time, in the local time zone.
# Accepts a timezone name
# Returns a JSON representation of the time.
timeElsewhere() {
	tz=$1
        date=$(TZ=${tz} date '+%Y-%m-%d %H:%M:%S %Z')
        echo '{ "full_text": " '$tz': '$date' ", "color": "'#ffff00'" }'
}


# Determine whether DHCP is running
# No inputs accepted.
# Returns a JSON representation of whether DHCP is running
dhcp() {
	if [[ $(ls /var/run/dhcpcd-* | wc -l) > 0 ]]; then
		echo '{ "full_text": " DHCP: yes ", "color": "'$color_good'" }'
	else
		echo '{ "full_text": " DHCP: no ", "color": "'$color_bad'" }'
	fi
}

# Update the weather information if it has expired or does not exist. This
# architecture is used to keep from wasting bandwidth and resources every
# 1s. The outdoor temperature won't change on that time scale.
# No inputs accepted.
maybeUpdateWeather() {
        if [ -f "${DATA}/weather" ]; then
                current_epoch=$(date +%s)
                weather_last_checked_epoch=$(stat -c '%Y' "${DATA}/weather")
                age=$(echo "($current_epoch - $weather_last_checked_epoch)" | bc)
                if [ "$age" -lt "$REFRESH" ]; then
                        return 0
                fi
        fi
        sh "${DIR}/weather.sh"
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

# Update the ping and upload/download speeds if the data has expired or does not
# exist. This architecture is used to keep from wasting bandwidth by constantly
# checking the speeds. It will fluctuate a bit, deal with it :D
# No inputs accepted.
maybeUpdateSpeeds() {
	if [ -f "${DATA}/internet-speeds" ]; then
		current_epoch=$(date +%s)
		ips_last_checked_epoch=$(stat -c '%Y' "${DATA}/internet-speeds")
		age=$(echo "($current_epoch - $ips_last_checked_epoch)" | bc)
		if [ "$age" -lt "$REFRESH" ]; then
			return 0
		fi
	fi
	sh "${DIR}/internet-speeds.sh"
}

# Update the status of the pihole.
# No inputs accepted.
maybeUpdatePihole() {
        if [ -f "${DATA}/pihole" ]; then
                current_epoch=$(date +%s)
                weather_last_checked_epoch=$(stat -c '%Y' "${DATA}/pihole")
                age=$(echo "($current_epoch - $weather_last_checked_epoch)" | bc)
                if [ "$age" -lt "$PIHOLE_REFRESH" ]; then
                        return 0
                fi
        fi
        sh "${DIR}/rpi-status.sh"
}

# Determine the local IP address for a given network interface
# Accepts either 'wlan' for a wireless interface or 'eth' for a wired interface.
# The network interfaces for these inputs are hard-coded.
# Returns a JSON representation of the interface and its IP address if one exists.
getIfaceIp() {
	maybeUpdateIps
#	if [[ $1 == 'wlan' ]]; then
#		if [[ $(ip link | grep wlp3s0 | wc -l) == 1 ]]; then
#			dev=wlp3s0
#		elif [[ $(ip link | grep wlan | wc -l) == 1 ]]; then
#			dev=wlan0
#		fi
#		text='wlan: '
#	elif [[ $1 == 'eth' ]]; then
#		if [[ $(ip link | grep enp1s | wc -l) == 1 ]]; then
#			dev=enp1s0
#		elif [[ $(ip link | grep eth | wc -l) == 1 ]]; then
#			dev=eth1
#		elif [[ $(ip link | grep eno | wc -l) == 1 ]]; then
#			dev=eno1
#		fi
#		text='eth: '
#	fi
	ip=$(grep 'local-ipv4' "${DATA}/public-ipv4" | sed -r 's/^local-ipv4: (.*)/Local IP: \1/' )
	if [[ -z $ip ]]; then
		echo '{ "full_text": " '$text'none ", "color": "'$color_bad'" }'
	else
		echo '{ "full_text": " '$text$ip' ", "color": "'$color_good'" }'
	fi
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

# Get the public internet ping time for this computer.
# No inputs accepted.
# Returns a JSON representation of the ping time for this computer.
getPing() {
	maybeUpdateSpeeds
	pingtime=$(grep 'ping' "${DATA}/internet-speeds" | sed -r 's/.*: (.*)/\1/')
	pingms=$(printf %.0f $(echo "$pingtime" | bc -l))
	if [[ $(bc <<< "${pingms} < 20") = 1 ]]; then
		color=$color_low
	elif [[ $(bc <<< "${pingms} >= 20") = 1 ]] && [[ $(bc <<< "${pingms} < 50") = 1 ]]; then
		color=$color_medlow
	elif [[ $(bc <<< "${pingms} >= 50") = 1 ]] && [[ $(bc <<< "${pingms} < 100") = 1 ]]; then
		color=$color_med
	elif [[ $(bc <<< "${pingms} >= 100") = 1 ]] && [[ $(bc <<< "${pingms} < 250") = 1 ]]; then
		color=$color_medhigh
	elif [[ $(bc <<< "${pingms} >= 250") = 1 ]]; then
		color=$color_high
	fi
	echo '{ "full_text": "Ping: '$pingms'ms", "color": "'$color'" }'
}

# Get the upload speed for this computer.
# No inputs accepted.
# Returns a JSON representation of the upload speed for this computer.
getUpSpeed() {
	maybeUpdateSpeeds
	bpsup=$(grep 'bps-up' "${DATA}/internet-speeds" | sed -r 's/.*: (.*)/\1/')
	if [[ $(bc <<< "${bpsup} < 5000000") = 1 ]]; then
                color=$color_high
        elif [[ $(bc <<< "${bpsup} >= 5000000") = 1 ]] && [[ $(bc <<< "${bpsup} < 10000000") = 1 ]]; then
                color=$color_medhigh
        elif [[ $(bc <<< "${bpsup} >= 10000000") = 1 ]] && [[ $(bc <<< "${bpsup} < 20000000") = 1 ]]; then
                color=$color_med
        elif [[ $(bc <<< "${bpsup} >= 20000000") = 1 ]] && [[ $(bc <<< "${bpsup} < 50000000") = 1 ]]; then
                color=$color_medlow
        elif [[ $(bc <<< "${bpsup} >= 50000000") = 1 ]]; then
                color=$color_low
        fi

	if [[ $(bc <<< "${bpsup} > 1000000000") = 1 ]]; then
		upload=$(bc <<< "${bpsup}/1000000000")
		upunit="Gbps"
	elif [[ $(bc <<< "${bpsup} > 1000000") = 1 ]]; then
                upload=$(bc <<< "${bpsup}/1000000")
                upunit="Mbps"
	elif [[ $(bc <<< "${bpsup} > 1000") = 1 ]]; then
                upload=$(bc <<< "${bpsup}/1000")
                upunit="kbps"
	else
                upload=$bpsup
                upunit="bps"
	fi
        echo '{ "full_text": "Upload: '$upload''$upunit'", "color": "'$color'" }'

}

# Get the download speed for this computer.
# No inputs accepted.
# Returns a JSON representation of the download speed for this computer.
getDownSpeed() {
	maybeUpdateSpeeds
	bpsdown=$(grep 'bps-down' "${DATA}/internet-speeds" | sed -r 's/.*: (.*)/\1/')
	if [[ $(bc <<< "${bpsdown} < 5000000") = 1 ]]; then
                color=$color_high
        elif [[ $(bc <<< "${bpsdown} >= 5000000") = 1 ]] && [[ $(bc <<< "${bpsdown} < 10000000") = 1 ]]; then
                color=$color_medhigh
        elif [[ $(bc <<< "${bpsdown} >= 10000000") = 1 ]] && [[ $(bc <<< "${bpsdown} < 20000000") = 1 ]]; then
                color=$color_med
        elif [[ $(bc <<< "${bpsdown} >= 20000000") = 1 ]] && [[ $(bc <<< "${bpsdown} < 50000000") = 1 ]]; then
                color=$color_medlow
        elif [[ $(bc <<< "${bpsdown} >= 50000000") = 1 ]]; then
                color=$color_low
        fi

	if [[ $(bc <<< "${bpsdown} > 1000000000") = 1 ]]; then
		download=$(bc <<< "${bpsdown}/1000000000")
		downunit="Gbps"
	elif [[ $(bc <<< "${bpsdown} > 1000000") = 1 ]]; then
                download=$(bc <<< "${bpsdown}/1000000")
                downunit="Mbps"
	elif [[ $(bc <<< "${bpsdown} > 1000") = 1 ]]; then
                download=$(bc <<< "${bpsdown}/1000")
                downunit="kbps"
	else
                download=$bpsdown
                downunit="bps"
	fi
        echo '{ "full_text": "Download: '$download''$downunit'", "color": "'$color'" }'

}

# Get the temperature outside.
# No inputs accepted.
# Returns a JSON representation of the temperature outside.
getOutsideTemp() {
	maybeUpdateWeather
	temp=$(cat ${DATA}/weather | head -n1)
	echo '{ "full_text": "It is '$temp' °F outside" }'
}

getNetwork() {
	ssid=$(cat ${DATA}/network)
        echo '{ "full_text": "'$ssid'" }'
}

getLoad() {
	# load="$(echo "scale=1;100.0 * $(uptime | sed -r 's/.*average: (\S+),.*/\1/')/$(nproc).0" | bc)%"
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

getPiholeStatus() {
	maybeUpdatePihole
	status=$(cat ${DATA}/pihole | grep status)
	if [ "${status}" = "status:online" ]; then
		color=$color_low
		value="online"
	else
		color=$color_high
		value="offline"
	fi
	echo '{ "full_text": "PiHole: '$value'", "color":"'$color'" }'
}

# Print data out and sleep 1s forever. This updates the status bar every second.
echo '{ "version": 1 }'
echo '['
echo '[]'
while [ 1 = 1 ]; do
	echo ",[$(getDisk '/'), $(getMem), $(getLoad), $(getVol), $(getNetwork), $(getIfaceIp), $(getPublicIp), $(getPing), $(getUpSpeed), $(getDownSpeed), $(getPiholeStatus), $(getOutsideTemp), $(utcTime), $(timeElsewhere 'Australia/Perth'), $(dateTime)]"
	sleep 1
done
echo ']'
