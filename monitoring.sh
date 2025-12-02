#!/bin/bash

# On masque toutes les erreurs éventuelles
exec 2>/dev/null

#####################
# RÉCUPÉRATION DES INFOS
#####################

# Architecture + version du kernel
ARCH=$(uname -a)

# Nombre de processeurs physiques
PCPU=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l)
[ "$PCPU" -eq 0 ] && PCPU=1

# Nombre de processeurs virtuels (vCPU / threads)
VCPU=$(grep -c "^processor" /proc/cpuinfo)

# RAM : utilisée / totale + pourcentage
MEM_INFO=$(free -m | awk 'NR==2 {printf "%d/%dMB (%.2f%%)", $3, $2, $3/$2*100}')

# DISQUE : somme de tous les systèmes de fichiers (hors tmpfs/udev)
DISK_INFO=$(df -Bm | awk 'NR>1 && $1!~"tmpfs" && $1!~"udev" {used+=$3; total+=$2} END {if (total>0) printf "%d/%dMB (%.2f%%)", used, total, used/total*100}')

# Charge CPU instantanée en %
CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | awk '{print 100-$8}' | awk '{printf "%.1f", $1}')

# Dernier reboot
LAST_BOOT=$(who -b | awk '{print $3" "$4}')

# LVM actif ou non
LVM_USE=$(lsblk | awk '$6=="lvm"{c++} END {if (c>0) print "yes"; else print "no"}')

# Nombre de connexions TCP établies
TCP_CONN=$(ss -ta | grep ESTAB | wc -l)

# Nombre d’utilisateurs connectés
USER_COUNT=$(users | wc -w)

# Adresse IPv4 et MAC
IPV4=$(hostname -I | awk '{print $1}')
MAC=$(ip link show | awk '/ether/ {print $2; exit}')

# Nombre de commandes sudo exécutées
SUDO_CMDS=$(journalctl _COMM=sudo 2>/dev/null | grep -c COMMAND)
if [ "$SUDO_CMDS" -eq 0 ]; then
    SUDO_CMDS=$(grep -c "sudo" /var/log/auth.log 2>/dev/null)
fi

#####################
# AFFICHAGE AVEC wall
#####################

wall "
#Architecture: $ARCH
#CPU physique: $PCPU
#vCPU: $VCPU
#Mémoire RAM: $MEM_INFO
#Mémoire disque: $DISK_INFO
#Charge CPU: $CPU_LOAD%
#Dernier reboot: $LAST_BOOT
#LVM actif: $LVM_USE
#Connexions TCP actives: $TCP_CONN
#Utilisateurs connectés: $USER_COUNT
#Adresse IPv4: $IPV4
#Adresse MAC: $MAC
#Commandes sudo: $SUDO_CMDS
"
