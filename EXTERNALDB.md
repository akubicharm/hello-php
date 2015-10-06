# README_EXTERNA_DB

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
