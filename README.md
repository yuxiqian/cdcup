# cdcup

## `./cdcup.sh init`

Initialize a playground environment, generate configuration files.

## `./cdcup.sh up`

Start docker containers. Note that it may take a while before database is ready.

## `./cdcup.sh pipeline <pipeline def yaml>`

Submit generated pipeline job. Before executing this, please ensure that:

1. All container are running and ready for connections
2. (For MySQL) You've created at least one database & tables to be captured

## `./cdcup.sh flink`

Prints Flink Web dashboard URL.

## `./cdcup.sh stop`

Stop all running playground containers.

## `./cdcup.sh down`

Stop and remove containers, networks, and volumes.
