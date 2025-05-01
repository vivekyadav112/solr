#!/bin/bash
set -e

# Start Solr in background for setup
echo "Bootstrapping Solr setup..."
/opt/solr/bin/solr start -force

# Wait for Solr
echo "Waiting for Solr to start on port 8983..."
until curl -s "http://localhost:8983/solr/admin/cores?action=STATUS" | grep -q "status"; do
  sleep 2
done

# Create core if it doesn't exist
if curl -s "http://localhost:8983/solr/admin/cores?action=STATUS" | grep -q "\"name\":\"games_core\""; then
  echo "Core games_core already exists."
else
  echo "Creating core: games_core"
  /opt/solr/bin/solr create_core -c games_core
  echo "Uploading JSON..."
  curl -s -X POST -H "Content-Type: application/json" \
       --data-binary @/opt/solr/games_solr.json \
       "http://localhost:8983/solr/games_core/update/json/docs?commit=true"
fi

# Stop background process
echo "Stopping background Solr (setup complete)..."
/opt/solr/bin/solr stop

# ✅ Now run Solr in foreground as main process to keep container alive
echo "Starting Solr in foreground..."
exec /opt/solr/bin/solr -f
