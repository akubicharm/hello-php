# README_EXTERNA_DB_USING_ENVIRONMENT_VARIABLES

In this case OpenShift connect external DB using environment variables.

## Prepare external database

### Start MySQL
```
sudo docker pull docker.io/mysql
sudo docker run --name mysql -e MYSQL_ROOT_PASSWORD=mysql -d -p 3306:3306 mysql
```

### Setup iptables
```
sudo iptables -A OUTPUT -p tcp --dport 3306 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
```

### Create table
Create database and tables.
```
docker exec -it <CONTAINER_ID> bash
mysql -u root -p
Enter password: mysql <-- input "mysql"

create database mydb;
create table hello (
msg varchar(255)
);
insert into hello(msg) values('hello opensihft');
```

### Enable client connection
```
grant all privileges on mydb.* to myuser@"%" identified by 'mysql' with grant option;
```

confirm connection
```
mysql -u myuser -p
Enter password: mysql  <-- input "mysql"
```

## Prepare application

### Create application`
```
oc new-project extdbtest
oc new-app https://github.com/akubicharm/hello-php.git#demo
```

### Set route
```
oc expose service hello-php --hostname=hello-php.extdbtest.apps.cloud
```

## Configure using external DB
### Set environment variables to DeploymentConfig
```
oc env dc/hello-php HELLO_PHP_MYSQL_SERVICE_HOST=master MYSQL_USER=mysql MYSQL_PASSWORD=mysql MYSQL_DATABASE=mydb
```

## Confirm application
```
curl hello-php.extdbtest.apps.cloud 
```
