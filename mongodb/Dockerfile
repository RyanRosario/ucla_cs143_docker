FROM ubuntu:latest

CMD ["bash"]
LABEL image="CS 143 Winter 2024 Spark"
LABEL maintainer="rrosario@cs.ucla.edu"
LABEL vendor="UCLA Computer Science"
LABEL edu.ucla.version="0.3.0"

ENV TZ="America/Los_Angeles"

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update -qq && \
	DEBIAN_FRONTEND="noninteractive" TZ="America/Los_Angeles" \
        apt-get -yqq install --no-install-recommends -y gnupg2 wget \
                scala python3 python3-pip python3-venv \
                datamash dumb-init dos2unix emacs-nox gawk git gosu less lsof make man-db openssh-client psmisc \
                python3-requests screen gosu tmux unzip vim-tiny wget zip \
                && apt-get clean \
                && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# mongoDB on Ubuntu
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
    chown -R mongodb:mongodb /data/db

RUN pip3 install pymongo

RUN ln -fs "/usr/share/zoneinfo/America/Los_Angeles" /etc/localtime 

RUN useradd -s /bin/bash -g users -d /home/cs143 cs143  \
        && echo "cs143:cs143" | chpasswd  \
        && mkdir -p /home/cs143  \
        && chown -R cs143:users /home/cs143  \
        && echo "cs143 ALL=(ALL:ALL) ALL" >> /etc/sudoers # \
        && apt-get update \
        && apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache \
        && chown cs143:users /etc/redis \
	&& chown cs143:users /home/cs143/data && \
	&& chown cs143:users /home/cs143/logs
 
RUN apt autoremove --yes

VOLUME [ "/home/cs143/shared" ]
VOLUME [ "/home/cs143/data" ]

EXPOSE 27017
USER cs143
WORKDIR /home/cs143
CMD mongod --dbpath /home/cs143/data --logpath /home/cs143/data/mongo.log --bind_ip_all --fork -f /etc/mongod.conf >> /dev/null && \
 /bin/bash

