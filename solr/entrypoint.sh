#!/bin/bash

echo "Starting Solr in standalone mode..."
/opt/solr/bin/solr start

# Wait for Solr to be ready
echo "Waiting for Solr to be available..."
until curl -s "http://localhost:8983/solr/admin/cores?action=STATUS" | grep -q "status"; do
  sleep 2
done

# Create the core (standalone only)
if curl -s "http://localhost:8983/solr/admin/cores?action=STATUS" | grep -q "\"name\":\"games_core\""; then
  echo "Core games_core already exists"
else
  echo "Creating core: games_core"
  /opt/solr/bin/solr create -c games_core
fi

# Upload data
echo "Uploading JSON..."
curl -s -X POST -H "Content-Type: application/json" \
     --data-binary @/opt/solr/games_solr.json \
     "http://localhost:8984/solr/games_core/update/json/docs?commit=true"

# Run in foreground to keep container alive
exec /opt/solr/bin/solr -f
