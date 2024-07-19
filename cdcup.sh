#!/usr/bin/env bash

# Do not continue after error
set -e

if [ "$1" == 'init' ]; then
  printf "🚩 Building bootstrap docker image...\n"
  docker build -q -t cdcup/bootstrap .
  rm -rf cdc && mkdir -p cdc
  printf "🚩 Starting bootstrap wizard...\n"
  docker run -it --rm -v "$(pwd)/cdc":/cdc cdcup/bootstrap
  mv cdc/docker-compose.yaml ./docker-compose.yaml
  mv cdc/pipeline-definition.yaml ./pipeline-definition.yaml
elif [ "$1" == 'up' ]; then
  printf "🚩 Starting playground...\n"
  docker compose up -d
  docker compose exec jobmanager bash -c 'rm -rf /opt/flink-cdc'
  docker compose cp cdc jobmanager:/opt/flink-cdc
elif [ "$1" == 'pipeline' ]; then
  if [ -z "$2" ]; then
    printf "Usage: ./cdcup.sh pipeline <pipeline-definition.yaml>\n"
    exit 1
  fi
  printf "🚩 Submitting pipeline job...\n"
  docker compose cp "$2" jobmanager:/opt/flink-cdc/pipeline-definition.yaml
  startup_script="cd /opt/flink-cdc && ./bin/flink-cdc.sh ./pipeline-definition.yaml --flink-home /opt/flink"
  if test -f ./cdc/lib/hadoop-uber.jar; then
      startup_script="$startup_script --jar lib/hadoop-uber.jar"
  fi
  if test -f ./cdc/lib/mysql-connector-java.jar; then
      startup_script="$startup_script --jar lib/mysql-connector-java.jar"
  fi
  docker compose exec jobmanager bash -c "$startup_script"
elif [ "$1" == 'flink' ]; then
  port_info="$(docker compose port jobmanager 8081)"
  printf "🚩 Visit Flink Dashboard at: http://localhost:%s\n" "${port_info##*:}"
elif [ "$1" == 'stop' ]; then
  printf "🚩 Stopping playground...\n"
  docker compose stop
elif [ "$1" == 'down' ]; then
  printf "🚩 Purging playground...\n"
  docker compose down -v
else
  printf "Usage: ./cdcup.sh [init|up|pipeline|flink|stop|down]\n"
fi
