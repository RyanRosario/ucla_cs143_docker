FROM ubuntu:23.10

# Example of usage.
# docker run -it -p 6379:6379 -v /Users/ryanrosario/Desktop:/home/cs143/shared --name nosql --hostname nosql ryanrosario/nosql

# vm.max_map_count is too low

CMD ["/bin/bash"]
LABEL image="CS 143 Winter 2024 NoSQL"
LABEL maintainer="Dr. Ryan Rosario <rrosario@cs.ucla.edu>"
LABEL vendor="UCLA Computer Science"
LABEL edu.ucla.version="0.2.0"


ENV TZ="America/Los_Angeles"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN \
	apt-get update -qq && \
		apt-get install -qq -y gnupg2 wget jq \
		python3 python3-pip python3-venv \
                curl datamash dumb-init dos2unix emacs-nox gawk git sudo less lsof make man-db nano openssh-client psmisc \
                python3-requests screen sudo telnet tmux unzip vim wget zip && \
                apt-get clean && \
                rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache && \
        useradd -s /bin/bash -g users -d /home/cs143 cs143 && \
        echo "cs143:cs143" | chpasswd && \
        mkdir -p /home/cs143  && \
        chown -R cs143:users /home/cs143 && \
	echo "cs143 ALL=(ALL:ALL) ALL" >> /etc/sudoers # \
	wget -qO- https://www.mongodb.org/static/pgp/server-7.0.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/mongo.gpg && \
	echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list && \
	apt-get update && \
        apt-get install -y mongodb-org && \
	#ln -s /usr/bin/python3 /usr/bin/python && \
	# echo "alias ipython='python -m IPython'" >/home/cs143/.bashrc && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache && \
	chown cs143:users /etc/redis && \
	chown cs143:users /etc/redis/* && \
	chown cs143:users /var/lib/redis && \
	chown cs143:users /var/log/redis  && \
	chown cs143:users /home/cs143/data && \
	chown cs143:users /home/cs143/logs && \
	apt-get -y purge --auto-remove curl && \
	rm -rf /var/lib/apt/lists/*

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV && \
	chown -R cs143:users $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

USER cs143
RUN pip3 install bottle pymongo redis # ipython
	
# Expose ports.
EXPOSE 6379 27017

VOLUME [ "/home/cs143/shared" ]
VOLUME [ "/home/cs143/data" ]

USER cs143
WORKDIR /home/cs143
CMD mongod --dbpath /home/cs143/data --logpath /home/cs143/data/mongo.log --fork -f /etc/mongod.conf >> /dev/null && \
 /bin/bash
