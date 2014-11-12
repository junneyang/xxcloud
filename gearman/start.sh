#!/bin/sh

if [ $# != 1 ] ; then
	echo -e "ERROR : arguments missing"
	echo -e "Usage : ./start <PORT>"
	exit 1; 
fi 

PORT=$1
nohup java -jar java-gearman-service-0.6.6.jar -p $PORT >> ./log/gearmanserver.log 2>&1 &

echo -e "INFO : gearman server has started"
