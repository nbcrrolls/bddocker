################################################################################# 
# Dockerfile 
# 
# Version:          2.0
# Software:         BrownDye base image
# Software Version: 2019-3-6
# Description:      Docker image for BrownDye, APBS and PDB2PQR
# Website:          http://browndye.ucsd.edu
# Tags:             Electrostatics|Brownian Dynamics|Solvation
# Base Image:       ubuntu:18.04
# Build Cmd:        docker build rokdev/bddocker . 
# Build Cmd:        docker build --tag=bddocker:v2.0 -f ./Dockerfile .
# Pull Cmd:         docker pull rokdev/bddocker 
# Run Cmd:          docker run --rm -it -u 1000:1000 \
#                      -v "$PWD":/home/browndye/data \
#                      -w /home/browndye/data rokdev/bddocker 
################################################################################# 

FROM ubuntu:18.04

LABEL version="2.0"
LABEL description="Docker image for BrownDye, APBS and PDB2PQR"
MAINTAINER Robert Konecny <rok@ucsd.edu>

ENV APBS_VERSION 1.5
ENV PDB2PQR_VERSION 2.1.1
ENV BD2_VERSION "2.0-26_Feb_ 2019"
ENV BD1_VERSION "1.0-13-Feb_2019"
ENV BD_URL https://browndye.ucsd.edu

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y -q --no-install-recommends curl make gcc g++ ocaml \
     libexpat-dev nano readline-common libgfortran3 wget liblapack-dev libboost-dev && \
    curl -k $BD_URL/browndye.tar.gz | tar xzf - -C /opt && \
    cd /opt/browndye && curl -k -sO $BD_URL/browndye/doc/fixes.html && \
    make all && \
    curl -k $BD_URL/browndye2.tar.gz | tar xzf - -C /opt && \
    cd /opt/browndye2 && curl -k -sO $BD_URL/browndye2/doc/fixes.html && \
    make all && \
    mkdir lib && cd lib && \
    curl -k -sO ${BD_URL}/coffdrop.xml.gz && \
    curl -k -sO ${BD_URL}/connectivity.xml && \
    curl -k -sO ${BD_URL}/map.xml && \
    curl -k -sO ${BD_URL}/charges.xml && \
    curl -k https://mirrors.edge.kernel.org/ubuntu/pool/main/r/readline6/libreadline6_6.3-8ubuntu8_amd64.deb \
    -o /tmp/libreadline6_6.3-8ubuntu8_amd64.deb && \
    dpkg -i /tmp/libreadline6_6.3-8ubuntu8_amd64.deb && \
    apt-get purge -y gcc g++ ocaml libexpat-dev && \
    apt-get autoremove -y && \
    apt-get install -y -q ca-certificates && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV BD1_PATH /opt/browndye
ENV BD2_PATH /opt/browndye2

# add apbs
RUN curl -L https://sourceforge.net/projects/apbs/files/apbs/apbs-${APBS_VERSION}/APBS-${APBS_VERSION}-linux64.tar.gz/download \
    | tar xzf - -C /opt && \
    ln -s /opt/APBS-${APBS_VERSION}-linux64 /opt/apbs
ENV APBS_PATH /opt/apbs

# add pdb2pqr
RUN curl -L https://sourceforge.net/projects/pdb2pqr/files/pdb2pqr/pdb2pqr-${PDB2PQR_VERSION}/pdb2pqr-linux-bin64-${PDB2PQR_VERSION}.tar.gz/download \
    | tar xzf - -C /opt && \
    ln -s /opt/pdb2pqr-linux-bin64-${PDB2PQR_VERSION} /opt/pdb2pqr
ENV PDB2PQR_PATH /opt/pdb2pqr

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
