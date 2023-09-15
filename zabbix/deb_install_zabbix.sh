#!/bin/bash

clear
tput setaf 7; read -p "Entrez le mot de passe pour la base de données Zabbix : " DB_PASSWORD
tput setaf 2; echo ""

addr_ip=$(hostname -I | awk '{print $1}')

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

function chg_passwd ()
{
	cp docker-compose.yml docker-compose.yml.bck
	FILE=~/Docker/zabbix/docker-compose.yml
	sed -i -e "s/DB_PASSWORD/$DB_PASSWORD/g" "$FILE"
}


chg_passwd
install_docker
docker-compose up -d

rm docker-compose.yml
mv docker-compose.yml.bck docker-compose.yml

tput bold; tput setaf 7; echo "LISTES DES CONTAINERS EN COURS : "
tput setaf 3; echo ""
docker container ls
echo ""
tput setaf 7; echo "-------------------------------------------------"
tput setaf 7; echo ""
tput setaf 7; echo "   Adresse du serveur Zabbix : http://$addr_ip:8080/     "
tput setaf 7; echo "         ID : Admin / MDP : zabbix             "
tput setaf 7; echo ""
tput setaf 7; echo "-------------------------------------------------"
tput setaf 2; echo ""
