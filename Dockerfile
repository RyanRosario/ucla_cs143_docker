FROM ubuntu:20.04

ENV TZ="America/Los_Angeles"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install wget gcc make -y
RUN apt-get install python3-software-properties python3 python3-setuptools python3-pip vim -y

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
# INSTALLING POSTGRES
##############################################################################################


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
EXPOSE 6379:6379

##############################################################################################
# INSTALLING MONGODB
##############################################################################################
ENV MONGODB_VERSION 5.0

RUN wget -qO- https://www.mongodb.org/static/pgp/server-$MONGODB_VERSION.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/mongo.gpg
RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d= -f2)/mongodb-org/$MONGODB_VERSION multiverse" | tee /etc/apt/sources.list.d/mongodb-org-$MONGODB_VERSION.list

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
