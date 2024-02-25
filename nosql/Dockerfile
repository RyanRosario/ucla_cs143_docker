FROM ubuntu:latest

CMD ["bash"]
LABEL image="CS 143 Winter 2024 NoSQL"
LABEL maintainer="rrosario@cs.ucla.edu"
LABEL vendor="UCLA Computer Science"
LABEL edu.ucla.version="0.3.0"

ENV TZ="America/Los_Angeles"

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update -qq && \
	DEBIAN_FRONTEND="noninteractive" TZ="America/Los_Angeles"  \
        apt-get -yqq install --no-install-recommends -y gnupg2 wget lsb-release gpg \
                python3 python3-pip python3-venv \
                datamash dumb-init dos2unix emacs-nox gawk git gosu less lsof make man-db openssh-client psmisc \
                python3-requests screen gosu tmux unzip vim-tiny zip \
                && apt-get clean \
                && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# MongoDB on Ubuntu
RUN apt-get update -qq && \
        DEBIAN_FRONTEND="noninteractive" TZ="America/Los_Angeles" \
	apt-get -yqq install --no-install-recommends -y gnupg curl && \
    curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
    	gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
    tee /etc/apt/sources.list.d/mongodb-org-7.0.list && \
    apt-get update && \
    apt-get install -y mongodb-org && \
    mkdir -p /data/db && \
    chown -R mongodb:mongodb /data/db && \
    curl -fsSL https://packages.redis.io/gpg  | \
    gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/redis.list  && \
    apt-get update && \
    apt-get -yqq install --no-install-recommends -y redis && \ 
    sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf && \
    sed -i 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf && \
    apt-get install -yqq openjdk-11-jdk apt-transport-https && \
    wget -O - https://debian.neo4j.com/neotechnology.gpg.key | \
    apt-key add - && \
    echo 'deb https://debian.neo4j.com stable latest' | \
    tee /etc/apt/sources.list.d/neo4j.list && \
    apt-get update && \
    apt-get install -yqq neo4j && \
    chmod 777 /etc/neo4j/neo4j.conf

RUN sed -i 's/^#\(server\..*\.listen_address=:[0-9]\+\)$/\1/' /etc/neo4j/neo4j.conf
RUN sed -i 's/^#\(server\..*\.advertised_address=:[0-9]\+\)$/\1/' /etc/neo4j/neo4j.conf
RUN mkdir -p ~/shared/logs/neo4j
RUN sed -i 's/server.directories.logs=\/var\/log\/neo4j/server.directories.logs=\/home\/cs143\/data\/logs\/neo4j/' /etc/neo4j/neo4j.conf
RUN chmod -R 777 /var/lib/neo4j/run/

    

RUN pip3 install pymongo redis 
# neo4j

RUN ln -fs "/usr/share/zoneinfo/America/Los_Angeles" /etc/localtime 

RUN useradd -s /bin/bash -g users -d /home/cs143 cs143   \
        && echo "cs143:cs143" | chpasswd  \
        && mkdir -p /home/cs143  \
        && mkdir -p /home/cs143/shared  \
        && mkdir -p /home/cs143/data  \
        && mkdir -p /home/cs143/data/logs  \
        && chown -R cs143:users /home/cs143  \
        && echo "cs143 ALL=(ALL:ALL) ALL" >> /etc/sudoers  \
        && apt-get update \
        && apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache \
        && chown cs143:users /etc/redis \
	&& chown cs143:users /home/cs143/shared \
	&& chown cs143:users /home/cs143/data \
	&& chown cs143:users /home/cs143/data/logs

RUN pip3 install ipython \
        && ln -s /usr/bin/python3 /usr/bin/python \
        && echo "alias ipython='python -m IPython'" >/home/cs143/.bashrc \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache
 
RUN apt autoremove --yes

VOLUME [ "/home/cs143/shared" ]
VOLUME [ "/home/cs143/data" ]

EXPOSE 27017 6379 7474 7473 7687
USER cs143
WORKDIR /home/cs143
CMD mongod --dbpath /home/cs143/data --logpath /home/cs143/data/mongo.log --bind_ip_all --fork -f /etc/mongod.conf >> /dev/null && \
  redis-server --protected-mode no --daemonize yes >> /dev/null  && \
  neo4j start >> /dev/null && \
  /bin/bash

