#!/bin/bash

set -e

# Start Solr in background
echo "Starting Solr in background..."
/opt/solr/bin/solr start -force

# Wait for Solr to be ready
echo "Waiting for Solr to become available..."
until curl -s "http://localhost:8983/solr/admin/cores?action=STATUS" | grep -q "status"; do
  sleep 2
done

# Check if core exists
if curl -s "http://localhost:8983/solr/admin/cores?action=STATUS" | grep -q "\"name\":\"games_core\""; then
  echo "Core games_core already exists."
else
  echo "Creating core: games_core"
  /opt/solr/bin/solr create_core -c games_core
fi

# Upload JSON
echo "Uploading data..."
curl -s -X POST -H "Content-Type: application/json" \
     --data-binary @/opt/solr/games_solr.json \
     "http://localhost:8983/solr/games_core/update/json/docs?commit=true"

# Stop background Solr (started above)
/opt/solr/bin/solr stop

# Start Solr in foreground (final process)
exec /opt/solr/bin/solr -f

