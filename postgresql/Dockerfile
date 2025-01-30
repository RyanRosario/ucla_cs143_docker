FROM debian:bullseye-slim

LABEL maintainer="Ryan R. Rosario <rrosario@cs.ucla.edu>"
LABEL version="25w-2"

# Set environment variables
ENV POSTGRES_USER=cs143 \
    POSTGRES_PASSWORD=cs143 \
    POSTGRES_DB=cs143 \
    PGDATA=/var/lib/postgresql/16/main

# Install PostgreSQL and utilities
RUN apt-get update && apt-get install -y \
    curl gnupg lsb-release \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/postgresql-keyring.gpg] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/postgresql.list \
    && apt-get update \
    && apt-get install -y \
    postgresql-16 \
    postgresql-client-16 \
    wget \
    less \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Add PostgreSQL binaries to the PATH
ENV PATH="/usr/lib/postgresql/16/bin:${PATH}"

# Create cs143 user
RUN useradd -ms /bin/bash cs143 && \
    passwd -d cs143 && \
    echo 'PS1="\u@postgresql:\w\$ "' >> /home/cs143/.bashrc && \
    mkdir -p /etc/sudoers.d && \
    echo "cs143 ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/cs143

# Setup PostgreSQL directories
RUN mkdir -p "$PGDATA" && \
    chown -R postgres:postgres /var/lib/postgresql && \
    chmod -R 700 /var/lib/postgresql

# Copy initialization files
COPY init.sql /docker-entrypoint-initdb.d/
COPY start.sh /start.sh
RUN chmod +x /start.sh && \
    chown -R postgres:postgres /docker-entrypoint-initdb.d

# Volume configuration
VOLUME ["/var/lib/postgresql/data", "/home/cs143"]

# Expose PostgreSQL port
EXPOSE 5432

# Switch to postgres user and start
USER postgres
CMD ["/start.sh"]
