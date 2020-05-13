#!/bin/bash

NETDISCOVER=/usr/sbin/netdiscover
db="expedientes"
host="192.168.0.103"
user="expedientes"
password="expedientes"

hora=`date +'%T'`
if [ $hora \< "13:00:00" ]; then
	#statements
	turno="M"
else
	turno="T"
fi
filesql="/tmp/"`date -I`"_"$turno"_discover.sql"
filehora="/tmp/discover_"$turno"_hora.txt"
fileawk="/usr/local/src/red_discover/discover.awk"
filescan="/tmp/"`date -I`"_"$turno"_scan.txt"
filescanaux="/tmp/scanaux.txt"


fileestado="/tmp/discover_estado.txt"
if [ ! -f $fileestado ]; then
	#statements
	echo "inicio">$fileestado
fi
estado=`cat $fileestado`

if [ $estado = "inicio" ]; then
	#statements
	if [ -f $filescan ]; then
		exit 1
	fi
	fecha=`date +'%F'`
	if [[ $EUID -ne 0 ]]; then
		sudo $NETDISCOVER -S -P > $filescan && echo "escaneado">$fileestado
		sudo logger -s "Netdiscover - Escaneo $turno"
	else
		$NETDISCOVER -S -P > $filescan && echo "escaneado">$fileestado
		logger -s "Netdiscover - Escaneo $turno"
	fi
	echo "$fecha $hora">$filehora
	sed '1,3d' $filescan| sed '$d'| sed '$d'> $filescanaux
	rm $filescan
	mv $filescanaux $filescan
fi

estado=`cat $fileestado`
if [ $estado = "escaneado" ]; then
	#statements
	if [ ! -f $filescan ]; then
		#statements
		exit 1
	fi
	sed '1,3d' $filescan| sed '$d'|sed '$d'>$filescanaux
	rm $filescan
	mv $filescanaux $filescan

	if [ ! -f $fileawk ]; then
		#statements
		if [[ $EUID -ne 0 ]]; then
			sudo logger -s "Netdiscover - Archivo Awk No encontrado"
		else
			logger -s "Netdiscover - Archivo Awk No encontrado"
		fi
		exit 1
	fi

	if [ ! -f $filehora ]; then
		fechahora=`date +'%F %T'`
	else
		fechahora=`cat $filehora`
	fi
	awk -v date="$fechahora" -f $fileawk $filescan > $filesql && echo "procesar">$fileestado
fi

estado=`cat $fileestado`
if [ $estado = "procesar" ]; then
	#statements
	if [ ! -f $filesql ]; then
		#statements
		if [ ! -f $filescan ]; then
			echo "inicio">$fileestado
		else
			echo "escaneado">$fileestado
		fi
		exit 1
	fi

	if [[ $EUID -ne 0 ]]; then
	    MYSQL_PWD="$password" mysql $DB -u $user --password="$password" --host=$host < $filesql
	else
	    sudo mysql $db < $filesql
	fi
	if [[ $EUID -ne 0 ]]; then
		sudo logger -s "Netdiscover - Carga base de datos "
	else
		logger -s "Netdiscover - Carga base de datos "
	fi
	echo "inicio">$fileestado
fi
