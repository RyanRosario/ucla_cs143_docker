#!/bin/bash

# TODO:
# Check connectivity from outside container
# Prevent Neo4j from asking for username

# --- Check & Start MongoDB ---
if pgrep -x "mongod" > /dev/null; then
    echo "MongoDB is already running!"
else
    echo "Starting MongoDB..."
    mongod --dbpath /home/cs143/mongodb/data --bind_ip_all --fork --logpath /home/cs143/mongodb/logs/mongod.log > /dev/null 2>&1
    sleep 5
    tput cuu1 && tput el && echo "Starting MongoDB...done!"
fi

# --- Check & Start Redis ---
if pgrep -x "redis-server" > /dev/null; then
    echo "Redis is already running!"
else
    echo "Starting Redis..."
    redis-server --daemonize yes
    sleep 2
    tput cuu1 && tput el && echo "Starting Redis...done!"
fi

# --- Fix & Start Neo4j ---
NEO4J_PID_FILE="/home/cs143/neo4j/run/neo4j.pid"

# If Neo4j is not running, restart it
if ! pgrep -x "java" | grep -q "neo4j"; then
    echo "Starting Neo4j..."

    # If stale PID file exists, remove it
    if [ -f "$NEO4J_PID_FILE" ]; then
        echo "Removing stale Neo4j PID file..."
        rm -f "$NEO4J_PID_FILE"
    fi

    # Start Neo4j
    neo4j start > /dev/null 2>&1
    sleep 5
    tput cuu1 && tput el && echo "Starting Neo4j...done!"
else
    echo "Neo4j is already running!"
fi

exec "$@"

