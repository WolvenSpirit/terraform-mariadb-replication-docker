

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

----

### For replication to work after master starts query with `SHOW MASTER STATUS;` and Update `init-slave.sql` if the values are different and restart the slave instance. 