#!/bin/bash

# script for starting the mongodb server

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DB1_PORT=27017
DB2_PORT=27018
REPLSET=NSpyreSet
OPLOG=1024
# may be required to start the mongodb daemon?
#systemctl start mongodb.service

# kill existing mongod instances
killall mongod

# start the db servers
mongod --dbpath $DIR/db1 --logpath $DIR/logs/db1 --bind_ip_all \
		--port $DB1_PORT --replSet $REPLSET --oplogSize $OPLOG --fork
mongod --dbpath $DIR/db2 --logpath $DIR/logs/db2 --bind_ip_all \
		--port $DB2_PORT --replSet $REPLSET --oplogSize $OPLOG --fork

# only needs to performed for first-time setup
# or if the db1/db2 directories were cleared,
# but no disadvantage of running it anyway
# add both servers to a replica set to allow them to start serving the db
# make db1 be the preferred primary using priorities
mongo --eval "rs.initiate({_id:'${REPLSET}', members:[ \
{_id: 0, host: 'localhost:${DB1_PORT}', priority: 2}, \
{_id: 1, host: 'localhost:${DB2_PORT}', priority: 1}  \
]})"