# Use a minimal Linux image as the base
FROM --platform=linux/amd64 debian:bullseye-slim
# Set environment variables for PostgreSQL
ENV POSTGRES_USER=cs143
ENV POSTGRES_PASSWORD=cs143
ENV POSTGRES_DB=cs143

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

# Add PostgreSQL binaries to PATH
ENV PATH=/usr/lib/postgresql/16/bin:$PATH

# Create the cs143 user and set custom prompt
RUN useradd -ms /bin/bash cs143 && echo "cs143:cs143" | chpasswd && \
    echo 'PS1="\u@postgresql:\w\$ "' >> /home/cs143/.bashrc

# Create directories with correct ownership
RUN mkdir -p /var/lib/postgresql/data && \
    chown postgres:postgres /var/lib/postgresql && \
    chown postgres:postgres /var/lib/postgresql/data && \
    chmod 700 /var/lib/postgresql && \
    chmod 700 /var/lib/postgresql/data && \
    mkdir -p /var/log/postgresql && \
    chown postgres:postgres /var/log/postgresql

# Initialize database as postgres user
USER postgres
RUN initdb -D /var/lib/postgresql/data

# Configure PostgreSQL
RUN echo "listen_addresses='*'" >> /var/lib/postgresql/data/postgresql.conf && \
    echo "host all all 0.0.0.0/0 md5" >> /var/lib/postgresql/data/pg_hba.conf && \
    echo "local all all trust" >> /var/lib/postgresql/data/pg_hba.conf

USER root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5432

CMD ["/entrypoint.sh"]
