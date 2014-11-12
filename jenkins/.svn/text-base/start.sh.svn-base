#!/bin/sh

if [ $# != 1 ] ; then
	echo -e "ERROR : arguments missing"
	echo -e "Usage : ./start.sh <PORT>"
	exit 1; 
fi 

HOST=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
PORT=$1

export JENKINS_HOME=/home/users/yangjun03/protobuf/workspace/app-test/search/lbs-stat/upps_test/jenkinsFramework/protobuf/jenkins/jenkinshome
nohup java -jar jenkins.war --httpPort=$PORT >>log/start.log 2>&1 &

echo -e "INFO : jenkins has started"
echo -e "INFO : now ypu can access 'http://$HOST:$PORT/' for jenkins web page"
