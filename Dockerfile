################################################################################# 
# Dockerfile 
# 
# Version:          3.2
# Software:         BrownDye base image
# Software Version: 2021-01-13
# Description:      Docker image for BrownDye, APBS and PDB2PQR
# Website:          http://browndye.ucsd.edu
# Tags:             Electrostatics|Brownian Dynamics|Solvation
# Base Image:       ubuntu:20.04
# Build Cmd:        docker build rokdev/bddocker . 
# Build Cmd:        docker build --tag=bddocker:v3.2 -f ./Dockerfile .
# Pull Cmd:         docker pull rokdev/bddocker 
# Run Cmd:          docker run --rm -it -u 1000:1000 \
#                      -v "$PWD":/home/browndye/data \
#                      -w /home/browndye/data rokdev/bddocker 
################################################################################# 

FROM ubuntu:20.04

LABEL version="3.2"
LABEL description="Docker image for BrownDye, APBS and PDB2PQR"
MAINTAINER Robert Konecny <rok@ucsd.edu>

ENV APBS_VERSION 3.0
ENV APBS_VERSION_MINOR 0
ENV PDB2PQR_VERSION 3.0.1
ENV BD2_VERSION "2.0-6_Dec_2020"
ENV BD2_VERSION "2.0-8_Jan_2021"
ENV BD1_VERSION "1.0-13_Feb_2019"
ENV BD_URL https://browndye.ucsd.edu

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y -q --no-install-recommends curl make gcc g++ ocaml \
    libexpat-dev nano readline-common gfortran wget liblapack-dev libboost-dev \
    unzip python3-pip libtinfo5 git cmake && \
    curl -k $BD_URL/browndye.tar.gz | tar xzf - -C /opt && \
    cd /opt/browndye && curl -k -sO $BD_URL/browndye/doc/fixes.html && \
    make all && \
    curl -k $BD_URL/browndye2.tar.gz | tar xzf - -C /opt && \
    cd /opt/browndye2 && curl -k -sO $BD_URL/browndye2/doc/fixes.html && \
    make all && \
    BD_VERSION=`sed  -n 's/.*\(BrownDye.*202.\).*/\1/p' /opt/browndye2/source/src/input_output/release_info.hh` && \
    BD_HASH=`curl -sL $BD_URL/browndye2.tar.gz | md5sum | cut -d ' ' -f 1` && \
    BD_DATE=`date --date="$(curl -sI $BD_URL/browndye2.tar.gz | sed 's/Last-Modified: \(.*\)/\1/p;d')" +%FT%T%Z` && \
    echo $BD_VERSION >> /opt/browndye2/VERSION && \
    echo "source: $BD_URL/browndye2.tar.gz" >> /opt/browndye2/VERSION && \
    echo "created on:  $BD_DATE" >> /opt/browndye2/VERSION && \
    echo "md2sum: $BD_HASH" >> /opt/browndye2/VERSION && \
    mkdir lib && cd lib && \
    curl -k -sO ${BD_URL}/coffdrop.xml.gz && \
    curl -k -sO ${BD_URL}/connectivity.xml && \
    curl -k -sO ${BD_URL}/map.xml && \
    curl -k -sO ${BD_URL}/charges.xml && \
    curl -Lk http://mirrors.kernel.org/ubuntu/pool/main/r/readline/libreadline7_7.0-3_amd64.deb \
          --output /tmp/libreadline7_7.0-3_amd64.deb && \
    dpkg -i /tmp/libreadline7_7.0-3_amd64.deb && \
    apt-get purge -y gcc g++ ocaml libexpat-dev && \
    apt-get autoremove -y && \
    apt-get install -y -q ca-certificates && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV BD1_PATH /opt/browndye
ENV BD2_PATH /opt/browndye2

# add apbs
RUN curl -L https://sourceforge.net/projects/apbs/files/apbs/apbs-${APBS_VERSION}/APBS-${APBS_VERSION}.${APBS_VERSION_MINOR}_Linux.zip/download -k -s --output /tmp/apbs.zip && \
    unzip /tmp/apbs.zip -d /opt && \
    ln -s /opt/APBS-${APBS_VERSION}.${APBS_VERSION_MINOR}.Linux /opt/apbs && \
    rm -f /opt/apbs/share/apbs/examples/protein-rna/*.dx && \
    rm -f /tmp/apbs.zip
    
ENV APBS_PATH /opt/apbs

# add pdb2pqr
RUN cd /usr/local/src && \
    git clone https://github.com/Electrostatics/pdb2pqr.git && \
    cd pdb2pqr && \
    pip3 install requests && \
    pip3 install . && \
    cd /usr/local/bin && \
    ln -s ./pdb2pqr30 ./pdb2pqr

ENV PDB2PQR_PATH /usr/local/bin

# set up browndye user
ENV user=browndye
RUN groupadd ${user} && useradd -g ${user} -l -ms /bin/bash ${user}
#USER ${user}
ENV PATH ${APBS_PATH}/bin:${PDB2PQR_PATH}:${BD2_PATH}/bin:$PATH
ENV LD_LIBRARY_PATH ${APBS_PATH}/lib
ENV HOME /home/${user}
#RUN echo "export PATH=${PATH}" >> ${HOME}/.bashrc && \
#    echo "export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}" >> ${HOME}/.bashrc
VOLUME $HOME/data
#WORKDIR $VOLUME

