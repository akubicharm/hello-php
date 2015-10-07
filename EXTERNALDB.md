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

### Define service
```
{
    "kind": "Service",
    "apiVersion": "v1",
    "metadata": {
        "name": "hello-php-mysql"
    },
    "spec": {
        "ports": [
            {
                "name": "mysql",
                "protocol": "TCP",
                "port": 3306,
                "targetPort": 3306,
                "nodePort": 0
            }
        ]
    },
    "selector": {}
}
```

### Define endpoind
```
{
  "kind": "Endpoints",
  "apiVersion": "v1",
  "metadata": {
    "name": "hello-php-mysql"
  },
  "subsets": [
    {
      "addresses":  [
        { "IP": "192.168.232.101" }
      ],
      "ports":  [
        { "port": 3306, "name": "mysql" }
      ]
    }
  ]
}
```

### Modify deploymentConfig
```
oc export dc hello-php -o json > hello-php-dc.json
```

```
    55                   "containers": [
    56                      {
    57                          "name": "hello-php",
    58                          "image": "172.30.131.34:5000/extdbtest/hello-php@sha256:bb766f1c8fc7aab47fce0ce9bccb24e1a18fb692e4c8ddd33c40c994c0587e00",
    59                          "ports": [
    60                              {
    61                                  "containerPort": 8080,
    62                                  "protocol": "TCP"
    63                              }
    64                          ],
    65                          "env": [
    66                            {
    67                              "name": "MYSQL_USER",
    68                              "value": "${MYSQL_USER}"
    69                            },
    70                            {
    71                              "name": "MYSQL_PASSWORD",
    72                              "value": "${MYSQL_PASSWORD}"
    73                            },
    74                            {
    75                              "name": "MYSQL_DATABASE",
    76                              "value": "${MYSQL_DATABASE}"
    77                            }
    78                          ],
    79                          "resources": {},
    80                          "terminationMessagePath": "/dev/termination-log",
    81                          "imagePullPolicy": "Always"
    82                      }
    83                  ],
```

```
oc replace --force -f hello-php-dc.json
```


### Set environment variables to DeploymentConfig
oc env dc <DEPLOYMENT CONFIG>  -e MYSQL_USER=root  -e MYSQL_PASSWORD=mysql  -e MYSQL_DATABASE=mydb


## Confirm application
```
curl hello-php.extdbtest.apps.cloud 
```
