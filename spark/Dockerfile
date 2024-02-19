FROM ubuntu:23.10

CMD ["bash"]
LABEL image="CS 143 Winter 2024 Spark"
LABEL maintainer="rrosario@cs.ucla.edu"
LABEL vendor="UCLA Computer Science"
LABEL edu.ucla.version="0.3.0"

ENV TZ="America/Los_Angeles"

ENV SPARK_VERSION=3.5.0
ENV HADOOP_VERSION=3
ENV OPENJDK_VERSION=17
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYSPARK_DRIVER_PYTHON=ipython
ENV SPARK_HOME=/spark/

RUN [ -z "$(apt-get indextargets)" ] # buildkit
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update -qq && \
	DEBIAN_FRONTEND="noninteractive" TZ="America/Los_Angeles" \
        apt-get -yqq install --no-install-recommends -y gnupg2 wget \
                openjdk-$OPENJDK_VERSION-jdk scala python3 python3-pip python3-venv \
                datamash dumb-init dos2unix emacs-nox gawk git gosu less lsof make man-db openssh-client psmisc \
                python3-requests screen gosu tmux unzip vim-tiny wget zip \
                && apt-get clean \
                && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN wget --no-verbose https://dlcdn.apache.org/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz \
        && tar -xzf /spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz && \
        mv /spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION spark && \
        echo "export path=$PATH:/spark/bin" >> ~/.bashrc \
        && rm /spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz \
        && sed -i 's/atexit.register(lambda: sc.stop())/atexit.register((lambda sc: lambda: sc.stop())(sc))/g' /spark/python/pyspark/shell.py \
        &&  set -xe  \
        && echo '#!/bin/sh' > /usr/sbin/policy-rc.d  \
        && echo 'exit 101' >> /usr/sbin/policy-rc.d  \
        && chmod +x /usr/sbin/policy-rc.d  \
        && dpkg-divert --local --rename --add /sbin/initctl 
RUN cp -a /usr/sbin/policy-rc.d /sbin/initctl  \
        && sed -i 's/^exit.*/exit 0/' /sbin/initctl  \
        && echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup  \
        && echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean  \
        && echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean  \
        && echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean  \
        && echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages  \
        && echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes  \
        && echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests 

RUN ln -fs "/usr/share/zoneinfo/America/Los_Angeles" /etc/localtime 

RUN useradd -s /bin/bash -g users -d /home/cs143 cs143  \
        && echo "cs143:cs143" | chpasswd  \
        && mkdir -p /home/cs143  \
        && chown -R cs143:users /home/cs143  \
        && echo "cs143 ALL=(ALL:ALL) ALL" >> /etc/sudoers # \
        && apt-get update \
        && apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache
 
RUN pip3 install pyspark ipython \
        && ln -s /usr/bin/python3 /usr/bin/python \
        && mkdir -p /home/cs143/data \
        && chown -R cs143:users /home/cs143/data \
        && echo "alias ipython='python -m IPython'" >/home/cs143/.bashrc \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache 

RUN apt autoremove --yes

VOLUME [ "/home/cs143/shared" ]
EXPOSE 4040
USER cs143
WORKDIR /home/cs143

