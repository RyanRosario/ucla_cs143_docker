FROM ubuntu:20.04

ENV TZ="America/Los_Angeles"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install wget gcc make -y
RUN apt-get install python3-software-properties python3 python3-setuptools python3-pip vim -y

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

#############################################################################################
# USER MANAGEMENT
#############################################################################################

RUN useradd -s /bin/bash -G users,tty -d /home/cs143 cs143  \
        && echo "cs143:cs143" | chpasswd  \
        && mkdir -p /home/cs143  \
        && chown -R cs143:users /home/cs143  \
        && echo "cs143 ALL=(ALL:ALL) ALL" >> /etc/sudoers # buildkit
VOLUME [ "/home/cs143/shared" ]

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
EXPOSE 6379:6379


ENTRYPOINT supervisord -c $REDIS_BASE/supervisord.conf && /bin/bash


#############################################################################################
# SETUP USER SPACE
#############################################################################################
USER cs143
WORKDIR /home/cs143
