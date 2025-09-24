

```sh

# Init, pull dependencies
terraform init

# Review plan
terraform plan

# Provision, the specified env var is needed, others are optional, if var is not created then you can declare it in main.tf
TF_VAR_PWD=$PWD terraform apply

```

The other environment variables such as `MYSQL_ROOT_PASSWORD` or `MYSQL_REPLICATION_PASSWORD` can be setup in the same manner. If passing your own mysql env vars then don't forget to update the init scripts.

Each plan should only manage the resources relevant to its own machine.

Set MYSQL_MASTER_HOST to the master's IP or hostname (reachable from the slave).

For the demo since they're on the same host we simply reference the network created by master terraform plan, to connect to another device that holds the db instance then remove the data.docker_network and in init-slave.sql fill in MASTER_HOST and MASTER_PORT.

---

### For replication to work after master starts query with `SHOW MASTER STATUS;` and Update `init-slave.sql` if the values are different and restart the slave instance. 

---

Hook up to proxysql for setup 

```sh
docker exec -it proxysql mysql -u admin -padmin -h 127.0.0.1 -P 6032 --prompt='ProxySQL Admin> '
```

Follow steps detailed here https://proxysql.com/documentation/proxysql-configuration/

Provided the steps worked you should see connect_error NULL

```sh
> select * from mysql_servers;

+----------------+------+------------------+-------------------------+---------------------------------------------------------------------+
| hostname       | port | time_start_us    | connect_success_time_us | connect_error                                                       |
+----------------+------+------------------+-------------------------+---------------------------------------------------------------------+
| mariadb-slave  | 3306 | 1758676370906097 | 2165                    | NULL                                                                |
| mariadb-master | 3306 | 1758676370893595 | 2323                    | NULL                                                                |
| mariadb-slave  | 3306 | 1758676252092182 | 2177                    | NULL                                                                |
| mariadb-master | 3306 | 1758676252081775 | 2268                    | NULL                                                                |
| mariadb-master | 3306 | 1758676132096842 | 3054                    | NULL                                                                |
| mariadb-slave  | 3306 | 1758676132080755 | 3021                    | NULL                                                                |
| mariadb-master | 3306 | 1758676012091930 | 0                       | Access denied for user 'monitor'@'172.20.0.4' (using password: YES) |
| mariadb-slave  | 3306 | 1758676012079207 | 0                       | Access denied for user 'monitor'@'172.20.0.4' (using password: YES) |
| mariadb-master | 3306 | 1758675892089143 | 0                       | Access denied for user 'monitor'@'172.20.0.4' (using password: YES) |
| mariadb-slave  | 3306 | 1758675892078288 | 0                       | Access denied for user 'monitor'@'172.20.0.4' (using password: YES) |
+----------------+------+------------------+-------------------------+---------------------------------------------------------------------+
10 rows in set (0.001 sec)
```
