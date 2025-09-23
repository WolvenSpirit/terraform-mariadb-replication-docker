CHANGE MASTER TO   
    MASTER_HOST='mariadb-master',
    MASTER_USER='replicauser',
    MASTER_PASSWORD='pass123',
    MASTER_LOG_FILE='mysql-bin.000002',  -- Replace with actual file from master
    MASTER_LOG_POS=342;                  -- Replace with actual position from master
START SLAVE;
FLUSH PRIVILEGES;
