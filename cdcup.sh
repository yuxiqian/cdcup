#!/usr/bin/env bash

# Do not continue after error
set -e

if [ "$1" == 'init' ]; then
  printf "1️⃣  Building bootstrap docker image..."
  docker build -q -t cdcup/bootstrap .

  rm -rf cdc && mkdir -p cdc

  printf "\n2️⃣  Starting bootstrap wizard..."
  docker run -it --rm -v "$(pwd)/cdc":/cdc cdcup/bootstrap

  printf "\n4️⃣  Submitting pipeline job..."
  mv cdc/docker-compose.yaml ./docker-compose.yaml
  docker compose up -d
  docker compose exec jobmanager bash -c 'rm -rf /opt/flink-cdc'
  docker compose cp cdc jobmanager:/opt/flink-cdc
elif [ "$1" == 'run' ]; then
  docker compose exec jobmanager bash -c "cd /opt/flink-cdc &&
       ./bin/flink-cdc.sh ./pipeline-definition.yaml --flink-home /opt/flink --jar ./lib/mysql-connector-java.jar"
elif [ "$1" == 'stop' ]; then
  docker compose stop
elif [ "$1" == 'rm' ]; then
  docker compose rm -fsv
else
  printf "Usage: ./cdcup.sh [init|run|rm]\n"
fi
