#!/bin/bash
set -e

SOLR_PID_FILE="/var/solr/solr-8983.pid"

if [ ! -f "$SOLR_PID_FILE" ]; then
  echo "First-time setup. Starting Solr in background..."
  /opt/solr/bin/solr start -force

  echo "Waiting for Solr to be available..."
  until curl -s "http://localhost:8983/solr/admin/cores?action=STATUS" | grep -q "status"; do
    sleep 2
  done

  if curl -s "http://localhost:8983/solr/admin/cores?action=STATUS" | grep -q "\"name\":\"games_core\""; then
    echo "Core games_core already exists."
  else
    echo "Creating core: games_core"
    /opt/solr/bin/solr create_core -c games_core
  fi

  echo "Uploading JSON..."
  curl -s -X POST -H "Content-Type: application/json" \
       --data-binary @/opt/solr/games_solr.json \
       "http://localhost:8983/solr/games_core/update/json/docs?commit=true"

  echo "Stopping background Solr after setup..."
  /opt/solr/bin/solr stop
else
  echo "Solr already initialized. Skipping setup..."
fi

echo "Starting Solr in foreground..."
exec /opt/solr/bin/solr -f
