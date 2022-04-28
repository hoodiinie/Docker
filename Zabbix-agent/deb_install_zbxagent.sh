#!/bin/bash

clear

read -p "Entrez l'adresse ip du serveur Zabbix: " SERVER_IP

function install_docker ()
{
    tput setaf 6; echo ""

    apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
    apt-get update
    apt-get -y install docker-ce docker-compose
    systemctl enable docker
    systemctl start docker

    tput setaf 7; echo ""
}

function crypto ()
{
        FILE_PSK=/apps/zabbix/agent/psk/secret.psk
        if [[ ! -e /apps ]]
        then
                mkdir /apps
        fi

        if [[ ! -e /apps/zabbix ]]
        then
                mkdir /apps/zabbix
        fi

        if [[ ! -e /apps/zabbix/agent ]]
        then
                mkdir /apps/zabbix/agent
        fi

        if [[ ! -e /apps/zabbix/agent/psk ]]
        then
                mkdir /apps/zabbix/agent/psk
        fi


        if [[ ! -e "$FILE_PSK" ]]
        then
                echo "Création fichier $FILE_PSK..."
                touch $FILE_PSK

                openssl rand -hex 32 > $FILE_PSK
                PSK=$(cat $FILE_PSK)

        else
                PSK=$(cat $FILE_PSK)

        fi
}

cp docker-compose.yml docker-compose.yml.bck

FILE=~/Docker/Zabbix-agent/docker-compose.yml

sed -i -e "s/ZBX_SERVER_IP/$SERVER_IP/g" "$FILE"
sed -i -e "s/NOM_SERVER/$HOSTNAME/g" "$FILE"

install_docker
crypto
docker-compose up -d

rm docker-compose.yml
mv docker-compose.yml.bck docker-compose.yml

echo ""
docker container ls
echo""

echo "--------------------------------------------------------------------------------------------"
echo ""
echo "                                   Hostname : $HOSTNAME                                     "
echo ""
echo "               Clé PSK : $PSK                                                               "
echo ""
echo "--------------------------------------------------------------------------------------------"
