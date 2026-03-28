#!/bin/bash

WORKDIR=/app
APP=/app/config_reader

cd "$WORKDIR"

OUTPUT=$($APP 2>/dev/null)
APP_STATUS=$?

if [[ $APP_STATUS -eq 0 ]]; then
  echo "Application executed successfully."
  exit 0;
else
  echo "Application failed to execute."
  exit 3;
fi
