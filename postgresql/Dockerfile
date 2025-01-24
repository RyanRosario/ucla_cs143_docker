# Use a minimal Linux image as the base
FROM --platform=linux/amd64 debian:bullseye-slim

# Set environment variables for PostgreSQL
ENV POSTGRES_USER=cs143 \
    POSTGRES_PASSWORD=cs143 \
    POSTGRES_DB=cs143 \
    PGDATA=/var/lib/postgresql/16/main

RUN apt-get update && apt-get install -y curl gnupg lsb-release \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/postgresql-keyring.gpg] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/postgresql.list \
    && apt-get update \
    && apt-get install -y postgresql-16 postgresql-client-16 \
    wget \
    less \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/lib/postgresql/16/bin:$PATH"

# Set up the cs143 user
RUN mkdir -p /etc/sudoers.d && \
    useradd -ms /bin/bash cs143 && \
    passwd -d cs143 && \
    echo 'PS1="\u@postgresql:\w\$ "' >> /home/cs143/.bashrc && \
    usermod -aG sudo cs143 && \
    echo "cs143 ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/cs143

RUN usermod -aG postgres cs143

# Create directories and set ownership
RUN mkdir -p /var/lib/postgresql/16/main && \
    chown -R postgres:postgres /var/lib/postgresql && \
    chmod -R 700 /var/lib/postgresql && \
    rm -rf /var/lib/postgresql/16/main/* && \
    su - postgres -c "/usr/lib/postgresql/16/bin/initdb -D /var/lib/postgresql/16/main"


USER root
RUN mkdir -p /docker-entrypoint-initdb.d

# Copy custom initialization scripts into the container
COPY init.sql /docker-entrypoint-initdb.d/

# Switch to postgres user
USER postgres

# Start PostgreSQL, create the user and database, then stop the server
RUN /usr/lib/postgresql/16/bin/pg_ctl -D /var/lib/postgresql/16/main -l /var/log/postgresql/postgresql.log start && \
    createuser -s cs143 && \
    createdb cs143 && \
    /usr/lib/postgresql/16/bin/pg_ctl -D /var/lib/postgresql/16/main stop

VOLUME ["/var/lib/postgresql/data", "/home/cs143"]

USER root
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 5432

USER postgres
CMD ["/start.sh"]
