#!/bin/bash

# Start PostgreSQL silently
su postgres -c "pg_ctl start -D /var/lib/postgresql/data -l /var/log/postgresql/pgstartup.log" > /dev/null 2>&1

# Wait for PostgreSQL to start silently
until su postgres -c "pg_isready" > /dev/null 2>&1; do
	    sleep 1
    done

    # Create cs143 user and database silently
    su postgres -c "psql -c \"CREATE USER cs143 WITH SUPERUSER PASSWORD 'cs143';\"" > /dev/null 2>&1 || true
    su postgres -c "psql -c \"CREATE DATABASE cs143 OWNER cs143;\"" > /dev/null 2>&1 || true

    # Switch to cs143 user and start shell
    exec su - cs143
