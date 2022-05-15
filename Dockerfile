FROM ubuntu:20.04

LABEL image="CS 143 Systems"
LABEL vendor="UCLA Department of Computer Science"
LABEL edu.ucla.version="0.1.0"

ENV TZ="America/Los_Angeles"
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install gnupg2 curl datamash dumb-init dos2unix emacs-nox \
	gawk git gosu less lsof make man-db nano openssh-client psmisc wget gcc \
	python3-software-properties python3 python3-setuptools python3-pip python3-requests \
	screen sudo telnet tmux unzip vim zip  -y \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache # buildkit

RUN set -xe  \
	&& echo '#!/bin/sh' > /usr/sbin/policy-rc.d  \
	&& echo 'exit 101' >> /usr/sbin/policy-rc.d  \
	&& chmod +x /usr/sbin/policy-rc.d  \
	&& dpkg-divert --local --rename --add /sbin/initctl  \
	&& cp -a /usr/sbin/policy-rc.d /sbin/initctl  \
	&& sed -i 's/^exit.*/exit 0/' /sbin/initctl  \
	&& echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup  \
	&& echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean  \
	&& echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean  \
	&& echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean  \
	&& echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages  \
	&& echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes  \
	&& echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests # buildkit

RUN [ -z "$(apt-get indextargets)" ] # buildkit
RUN ln -fs "/usr/share/zoneinfo/America/Los_Angeles" /etc/localtime # buildkit
RUN apt-get -y update  \
	&& DEBIAN_FRONTEND="noninteractive" TZ="America/Los_Angeles" apt-get -yqq install tzdata  \
	&& yes | unminimize  \
	&& apt-get clean  \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache # buildkit

#############################################################################################
# USER MANAGEMENT
#############################################################################################
RUN useradd -s /bin/bash -G users,tty -d /home/cs143 cs143  \
        && echo "cs143:cs143" | chpasswd  \
        && mkdir -p /home/cs143  \
        && chown -R cs143:users /home/cs143  \
        && echo "cs143 ALL=(ALL:ALL) ALL" >> /etc/sudoers # buildkit
VOLUME [ "/home/cs143/shared" ]

##############################################################################################
# INSTALLING SPARK AND RELATED TOOLS
##############################################################################################
ENV PYSPARK_DRIVER_PYTHON=ipython
ENV SPARK_HOME=/spark/

RUN apt-get update -qq && \
	apt-get install -qq -y \
		openjdk-8-jdk scala  \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache # buildkit

RUN wget --no-verbose https://dlcdn.apache.org/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz
RUN tar -xzf /spark-3.2.1-bin-hadoop3.2.tgz && \
	mv /spark-3.2.1-bin-hadoop3.2 spark && \
	echo "export path=$PATH:/spark/bin" >> ~/.bashrc
RUN rm /spark-3.2.1-bin-hadoop3.2.tgz

RUN sed -i 's/atexit.register(lambda: sc.stop())/atexit.register((lambda sc: lambda: sc.stop())(sc))/g' /spark/python/pyspark/shell.py

RUN pip3 install pyspark
RUN pip3 install ipython
RUN ln -s /usr/bin/python3 /usr/bin/python # buildkit

RUN mkdir -p /home/cs143/data # buildkit
RUN chown -R cs143:users /home/cs143/data # buildkit

EXPOSE 4040

##############################################################################################
# INSTALLING REDIS
##############################################################################################
ENV REDIS_VERSION 7.0.0
ENV REDIS_BASE /opt/redis-$REDIS_VERSION

ADD http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz /tmp/
RUN cd /tmp && tar -xvf redis-$REDIS_VERSION.tar.gz -C /opt
RUN cd $REDIS_BASE && make install
ADD https://raw.github.com/RyanRosario/ucla_cs143_docker/master/supervisord.conf $REDIS_BASE/
RUN chmod 644 $REDIS_BASE/supervisord.conf
RUN pip3 install redis
EXPOSE 6379:6379

##############################################################################################
# INSTALLING MONGODB
##############################################################################################
ENV MONGODB_VERSION 5.0

RUN wget -qO- https://www.mongodb.org/static/pgp/server-$MONGODB_VERSION.asc | gpg --dearmor \
	> /etc/apt/trusted.gpg.d/mongo.gpg
RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(cat /etc/lsb-release | \
	grep DISTRIB_CODENAME | cut -d= -f2)/mongodb-org/$MONGODB_VERSION multiverse" | \
	tee /etc/apt/sources.list.d/mongodb-org-$MONGODB_VERSION.list

# Update apt-get sources AND install MongoDB
RUN apt-get update && apt-get install -y mongodb-org

# Create the MongoDB data directory
RUN mkdir -p /data/db
RUN mkdir -p /var/log/mongodb
RUN chown -R cs143:cs143 /var/log/mongodb
RUN chown -R cs143:cs143 /data/db 
RUN sed -i 's/dbPath: \/var\/lib\/mongodb/dbPath: \/data\/db/' /etc/mongod.conf
RUN touch /home/cs143/.mongoshrc.js

VOLUME /data/db

# Install client
RUN pip3 install bottle pymongo

# Expose port #27017 from the container to the host
EXPOSE 27017:27017

##############################################################################################
# INSTALL NEO4J
##############################################################################################
RUN wget -O-  https://debian.neo4j.com/neotechnology.gpg.key | gpg --dearmor \
	> /etc/apt/trusted.gpg.d/neo4j.gpg
RUN echo "deb [ arch=amd64,arm64 ] https://debian.neo4j.com stable latest" | \
	tee -a /etc/apt/sources.list.d/neo4j.list
RUN apt-get update && apt-get install -y neo4j
RUN sed -i 's/#dbms.default_listen_address=0\.0\.0\.0/dbms.default_listen_address=0\.0\.0\.0/' /etc/neo4j/neo4j.conf

RUN chown -R cs143:users /var/lib/neo4j /etc/neo4j /var/log/neo4j /var/lib/neo4j/plugins /var/lib/neo4j/import \
	/var/lib/neo4j/data /var/lib/neo4j/certificates  /var/lib/neo4j/licenses /var/lib/neo4j/run
VOLUME /var/lib/neo4j /etc/neo4j /var/log/neo4j /var/lib/neo4j/plugins /var/lib/neo4j/import \
        /var/lib/neo4j/data /var/lib/neo4j/certificates  /var/lib/neo4j/licenses /var/lib/neo4j/run

EXPOSE 7474
EXPOSE 7687

#############################################################################################
# INSTALL supervisord
#############################################################################################
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /var/run/supervisor
RUN chown -R cs143:users -R /var/log/supervisor
RUN pip3 install supervisor


#############################################################################################
# EXPOSE PORTS
#############################################################################################
ENTRYPOINT supervisord -c $REDIS_BASE/supervisord.conf && /bin/bash 

#############################################################################################
# SETUP USER SPACE
#############################################################################################
USER cs143
WORKDIR /home/cs143
RUN echo "alias ipython='python -m IPython'" >/home/cs143/.bashrc
