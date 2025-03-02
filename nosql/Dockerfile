FROM ubuntu:latest

CMD ["bash"]
LABEL image="CS 143 NoSQL"
LABEL maintainer="rrosario@cs.ucla.edu"
LABEL vendor="UCLA Computer Science"
LABEL edu.ucla.version="0.4.0"

ENV TZ="America/Los_Angeles"

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update -qq && \
	apt install -y gnupg curl lsb-release gpg wget curl nano software-properties-common dirmngr apt-transport-https gnupg2 ca-certificates ubuntu-keyring unzip python3 python3-pip && \
        DEBIAN_FRONTEND="noninteractive" TZ="America/Los_Angeles" 

# Install MongoDB
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
	gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
		--dearmor && \
	echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | \
		tee /etc/apt/sources.list.d/mongodb-org-8.0.list && \
	apt update && \
	apt install -y mongodb-org && \
	mkdir -p /home/cs143/.config/mongodb/data && \
	mkdir -p /home/cs143/.config/mongodb/logs

# Install Redis
RUN curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg && \
	chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg && \
	echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | \
		tee /etc/apt/sources.list.d/redis.list && \
	apt update && \
	apt install -y redis

# Install Neo4j
RUN curl -fsSL https://debian.neo4j.com/neotechnology.gpg.key | \
	gpg --dearmor -o /usr/share/keyrings/neo4j.gpg && \
	echo "deb [signed-by=/usr/share/keyrings/neo4j.gpg] https://debian.neo4j.com stable latest" | \
		tee -a /etc/apt/sources.list.d/neo4j.list && \
	apt update && \
	apt install -y neo4j


# Set up user environment
RUN useradd -s /bin/bash -g users -d /home/cs143 cs143   \
        && echo "cs143:cs143" | chpasswd  \
        && mkdir -p /home/cs143/shared \
        && mkdir -p /home/cs143/data \
        && chown -R cs143:users /home/cs143  \
        && echo "cs143 ALL=(ALL:ALL) ALL" >> /etc/sudoers  \
        && chown cs143:users /etc/redis \
        && chown -R cs143:users /home/cs143/shared \
        && chown -R cs143:users /home/cs143/data \
        && apt-get update \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache 

RUN mkdir -p /home/cs143/.config/neo4j \
	&& chown -R cs143:users /home/cs143/.config/neo4j \
	&& chmod -R 755 /home/cs143/.config/neo4j \
	&& sed -i 's|/var/lib/|/home/cs143/.config/neo4j/|g' /etc/neo4j/neo4j.conf \
	&& sed -i 's|#server.directories.run=.*|server.directories.run=/home/cs143/.config/neo4j/run|' /etc/neo4j/neo4j.conf \
	&& sed -i 's|server.directories.logs=/var/log/neo4j|server.directories.logs=/home/cs143/.config/neo4j/log/neo4j|' /etc/neo4j/neo4j.conf \
	&& sed -i 's|#dbms.security.auth_enabled=false|dbms.security.auth_enabled=false|' /etc/neo4j/neo4j.conf

# Install drivers
RUN pip install  --break-system-packages pymongo redis neo4j ipython \
        && ln -s /usr/bin/python3 /usr/bin/python \
        && echo "alias ipython='python -m IPython'" >/home/cs143/.bashrc \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache

RUN apt autoremove --yes

VOLUME [ "/home/cs143/shared" ]
VOLUME [ "/home/cs143/data" ]

# Expose necessary ports
EXPOSE 27017
EXPOSE 7474
EXPOSE 7687

COPY entrypoint.sh /home/cs143/.config/entrypoint.sh

# Ensure the script is executable
RUN chmod +x /home/cs143/.config/entrypoint.sh

# Set user and working directory
USER cs143
WORKDIR /home/cs143


ENTRYPOINT ["/home/cs143/.config/entrypoint.sh"]
CMD ["bash"]
