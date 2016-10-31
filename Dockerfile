FROM ubuntu:14.04

MAINTAINER Yiannis Mouchakis <gmouchakis@iit.demokritos.gr>

# Install Virtuoso prerequisites
RUN apt-get update \
        && apt-get install -y build-essential debhelper autotools-dev autoconf automake unzip wget net-tools git libtool flex bison gperf gawk m4 libssl-dev libreadline-dev libreadline-dev openssl

# Virtuoso 7.1 commit
ENV VIRTUOSO_COMMIT 658e00de9b4e2e04d88bff6fcdecab28d08019d5

RUN apt-get update && apt-get install -y \
        build-essential \
        debhelper \
        autotools-dev \
        autoconf \
        automake \
        unzip \
        wget \
        net-tools \
        git \
        libtool \
        flex \
        bison \
        gperf \
        gawk \
        m4 \
        libssl-dev \
        libreadline-dev \
        libreadline-dev \
        openssl \
        && git clone https://github.com/openlink/virtuoso-opensource.git \
        && cd virtuoso-opensource \
        && git checkout ${VIRTUOSO_COMMIT} \
        && ./autogen.sh \
        && CFLAGS="-O2 -m64" && export CFLAGS && ./configure --disable-bpel-vad --enable-conductor-vad --disable-dbpedia-vad --disable-demo-vad --disable-isparql-vad --disable-ods-vad --disable-sparqldemo-vad --disable-syncml-vad --disable-tutorial-vad --with-readline --program-transform-name="s/isql/isql-v/" \
        && make && make install \
        && ln -s /usr/local/virtuoso-opensource/var/lib/virtuoso/ /var/lib/virtuoso \
	&& ln -s /var/lib/virtuoso/db /data \
        && cd .. \
        && rm -r /virtuoso-opensource

# Add Virtuoso bin to the PATH
ENV PATH /usr/local/virtuoso-opensource/bin/:$PATH

# Add Virtuoso config
ADD virtuoso.ini /virtuoso.ini

# Add startup script
ADD virtuoso.sh /virtuoso.sh

WORKDIR /data

EXPOSE 8890

CMD ["/bin/bash", "/virtuoso.sh"]
