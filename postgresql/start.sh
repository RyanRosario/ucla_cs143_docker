#!/bin/bash
set -e

# Initialize if needed
if [ ! -f "$PGDATA/PG_VERSION" ]; then
    initdb -D "$PGDATA"
fi

# Start PostgreSQL
postgres -D "$PGDATA" &
PG_PID=$!

# Wait for PostgreSQL to start
until pg_isready; do
    sleep 1
done

# Run initialization scripts
for f in /docker-entrypoint-initdb.d/*.sql; do
    if [ -f "$f" ]; then
        echo "Running $f..."
        psql -U postgres -f "$f"
    fi
done

# Switch to cs143
su - cs143

wait $PG_PID
