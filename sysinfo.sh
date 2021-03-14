#!/bin/bash
# Variable Couleur
yl="\e[33m"
rst="\e[0m"
power="(🔌)"
batery="(🔋)"

intname=$(ip a | grep -wo "eth0\|ens33\|enp0s3\|enp1s0f1" | uniq)
oncharge=$(cat /sys/class/power_supply/BAT0/status)
percentpc=$(cat /sys/class/power_supply/BAT0/capacity)
totalmem=$(free -h | grep -i "^mem" | awk '{print $2}')
cpuinfo=$(grep "model name" /proc/cpuinfo | uniq | cut -d':' -f 2)
diskspace=$(df -h | grep "/$" | awk '{print $4}')
iplan=$(ip a show $intname | grep inet | head -1 | awk '{print $2}' | cut -d'/' -f 1)
netmask=$(ipcalc 24 | grep "Netmask" | cut -d':' -f2 | awk '{print $1}')
ipwan=$(curl -s ipinfo.io | grep ip | head -1 | cut -d':' -f2 | tr -d '",')
sysuptime=$(uptime | awk '{print $3}' | tr -d ',')
addressmac=$(ip a show $intname | grep -o "[a-f|0-9][a-f|0-9]:[a-f|0-9][a-f|0-9]:[a-f|0-9][a-f|0-9]:[a-f|0-9][a-f|0-9]:[a-f|0-9][a-f|0-9]\S.." | grep -v ff:ff:ff:ff:ff:ff)
establi=$(lsof -Pnl -i4 | grep 'ESTABLISHED' | awk '{print $1"   " $9}' | sort -n)
#openport=$(ss -tulprH4b | awk -F' ' '{print $7}' | sed -e 's/(("/---/g' | sed -e 's/,/ /g'  | tr -d '"' | sed -e 's/",/ /g' | sed 's/))//g')
gateway=$(ip r | head -1 | awk '{print $3}')
shortline='------------------------------------'
subline="------------------------------------\n"



#-----------------------------------------------------------------

echo -e "\n"
echo -e "Hello ${USER}, wait a Minute before I get system information\n"
echo -e "${yl} The script will fail if ipcalc is not present on the system and change net interface name\n${rst}"

sleep 1

echo  "System Uptime: ${sysuptime}"
echo -e "Machine Hostname: $(hostnamectl --static)\n"

function material() {

	echo -e "${shortline}"

		echo -e '\t Material'

	echo -e "${subline}"

# check batery / on charge

	if [[ "$oncharge" = 'Discharging' ]]; then
  		echo -e "${batery} Your computer is on Batery: ${percentpc} %\n"
	else
	  	echo -e "${power} Your computer is on charge: ${percentpc} %\n"
	fi

	echo "Memory: $totalmem"
	echo "Processor: $cpuinfo"
	echo -e "Root: Disk space left: $diskspace\n"
}

function network(){

	echo "$shortline"

		echo -e '\t Network'

	echo -e "${subline}"

	echo "Your MAC address: $addressmac"
	echo "Your LAN IP: $iplan"
	echo "Your Netmask: $netmask"
	echo "Your Gateway: $gateway"

	echo -e "Your WAN IP: ${ipwan}\n"
}

function distro() {

	echo "$shortline"

		echo -e '\t Distro'

	echo -e "${subline}"

distroname=$(grep -i "pretty" /etc/os-release | cut -d'"' -f2)
kernelname=$(uname -s)
kernelversion=$(uname -r | cut -d'-' -f1)

if [[ $distroname = 'ubuntu' ]]; then

	echo "Your distribution: ${distroname} too bad !!  "
else
	echo "Your distribution: ${distroname}"
fi

echo "Your kernel is: $kernelname"
echo "Your kernel version is: $kernelversion"
}

function security() {

	echo "$shortline"

		echo -e '\t Security'

	echo -e "${subline}"


echo -e "Established connexion: \n${establi}"


}

function usage() {

echo "${shortline}"

	echo ' -h:	Show usage'
	echo ' -a: 	Show all information'
	echo ' -d:	Show distro information'
	echo ' -m: 	Show material information'
	echo ' -n:	Show network information'
	echo ' -s: 	Show systeme security information'

echo "${shortline}"
exit 0



}

if [[ "$1" = "" ]]; then
	usage
fi


while getopts 'adhmns' opt
do
	case $opt in
		a) distro; material; network; security;;
		d) distro;;
		h) usage ;;
		m) material;;
		n) network;;
		s) security;;
		*) echo " show usage $0 [-h]" >&2; exit 0;;
	esac
done
