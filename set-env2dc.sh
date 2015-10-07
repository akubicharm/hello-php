#!/bin/sh
DC_NAME=`oc get dc |grep hello-php |awk '{print $1}'`

OPTS="\
-e MYSQL_USER=root  \
-e MYSQL_PASSWORD=mysql  \
-e MYSQL_DATABASE=mydb "

echo "oc env dc $DC_NAME $OPTS"
#oc env dc $DC_NAME $OPTS
