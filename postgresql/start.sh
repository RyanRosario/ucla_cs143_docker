#!/bin/bash
set -e

# Initialize PostgreSQL if $PGDATA is empty
if [ -z "$(ls -A "$PGDATA")" ]; then
    echo "Initializing PostgreSQL database cluster..."
    /usr/lib/postgresql/16/bin/initdb -D "$PGDATA"
fi

# Apply initialization scripts
echo "Applying initialization scripts..."
for f in /docker-entrypoint-initdb.d/*.sql; do
    echo "Running $f..."
    psql -U postgres -f "$f" || true
done

# Start PostgreSQL in the foreground
echo "Starting PostgreSQL in foreground..."
postgres -D "$PGDATA" &
POSTGRES_PID=$!

# Optional: Switch to cs143's shell
echo "Switching to cs143's shell. Type 'exit' to leave the shell, but the container will keep running."
su - cs143

# Wait for PostgreSQL to stop
wait $POSTGRES_PID

