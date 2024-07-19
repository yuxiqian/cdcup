#!/usr/bin/env bash

# Do not continue after error
set -e

echo "👉 Building bootstrap docker image..."
docker build -q -t cdcup/bootstrap .

rm -rf conf && mkdir conf

echo "👉 Starting bootstrap wizard..."
docker run -it --rm -v "$(pwd)/conf":/conf cdcup/bootstrap