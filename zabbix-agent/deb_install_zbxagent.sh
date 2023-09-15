#!/bin/bash

clear

read -p "Entrez l'adresse ip du serveur Zabbix: " SERVER_IP

function install_docker ()
{
    tput setaf 6; echo ""

    apt-get update
    apt-get install ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update

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

FILE=~/Docker/zabbix-agent/docker-compose.yml

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
