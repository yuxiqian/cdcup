#!/usr/bin/env bash

# Do not continue after error
set -e

if [ "$1" == 'init' ]; then
  printf "1️⃣  Building bootstrap docker image..."
  docker build -q -t cdcup/bootstrap .
  rm -rf cdc && mkdir -p cdc
  printf "\n2️⃣  Starting bootstrap wizard..."
  docker run -it --rm -v "$(pwd)/cdc":/cdc cdcup/bootstrap
  mv cdc/docker-compose.yaml ./docker-compose.yaml
elif [ "$1" == 'up' ]; then
  printf "\n4️⃣  Starting playground..."
  docker compose up -d
  docker compose exec jobmanager bash -c 'rm -rf /opt/flink-cdc'
  docker compose cp cdc jobmanager:/opt/flink-cdc
elif [ "$1" == 'pipeline' ]; then
  docker compose cp cdc/pipeline-definition.yaml jobmanager:/opt/flink-cdc/pipeline-definition.yaml
  docker compose exec jobmanager bash -c "cd /opt/flink-cdc &&
       ./bin/flink-cdc.sh ./pipeline-definition.yaml --flink-home /opt/flink --jar ./lib/mysql-connector-java.jar"
elif [ "$1" == 'stop' ]; then
  docker compose stop
elif [ "$1" == 'down' ]; then
  docker compose down -fsv
else
  printf "Usage: ./cdcup.sh [init|up|pipeline|stop|down]\n"
fi
