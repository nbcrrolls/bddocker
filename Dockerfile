################################################################################# 
# Dockerfile 
# 
# Version:          1
# Software:         BrownDye base Image 
# Software Version: 2016-7-14
# Description:      Docker image for BrownDye, APBS and PDB2PQR
# Website:          http://browndye.ucsd.edu
# Tags:             Electrostatics|Brownian Dynamics|Solvation
# Base Image:       ubuntu:14.04.3 
# Build Cmd:        docker build rokdev/bddocker . 
# Pull Cmd:         docker pull rokdev/bddocker 
# Run Cmd:          docker run --rm -u $USER -it -v "$PWD":/home/browndye/data \
#                      -w /home/browndye/data rokdev/bddocker 
################################################################################# 

FROM ubuntu:14.04
MAINTAINER Robert Konecny <rok@ucsd.edu>

ENV APBS_VERSION 1.4.2
ENV APBS_RELEASE 1.4.2.1
ENV PDB2PQR_VERSION 2.1.1

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y -q --no-install-recommends \
    curl make gcc g++ ocaml libexpat-dev nano && \
    curl http://browndye.ucsd.edu/browndye.tar.gz | tar xzf - -C /opt && \
    cd /opt/browndye && curl -sO http://browndye.ucsd.edu/browndye/doc/fixes.html && \
    make all && \
    apt-get purge -y gcc g++ ocaml libexpat-dev && \
    apt-get autoremove -y && \
    apt-get install -y -q ca-certificates && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV BD_PATH /opt/browndye

# add apbs
RUN curl -L https://sourceforge.net/projects/apbs/files/apbs/apbs-${APBS_VERSION}/APBS-${APBS_RELEASE}-1-linux64.tgz/download \
    | tar xzf - -C /opt && \
    ln -s /opt/APBS-${APBS_RELEASE}-linux64 /opt/apbs
ENV APBS_PATH /opt/apbs

# add pdb2pqr
RUN curl -L https://sourceforge.net/projects/pdb2pqr/files/pdb2pqr/pdb2pqr-${PDB2PQR_VERSION}/pdb2pqr-linux-bin64-${PDB2PQR_VERSION}.tar.gz/download \
    | tar xzf - -C /opt && \
    ln -s /opt/pdb2pqr-linux-bin64-${PDB2PQR_VERSION} /opt/pdb2pqr
ENV PDB2PQR_PATH /opt/pdb2pqr

# set up browndye user
ENV user=browndye
RUN useradd -ms /bin/bash ${user}
ENV PATH ${APBS_PATH}/bin:${PDB2PQR_PATH}:${BD_PATH}/bin:$PATH
USER ${user}
ENV HOME /home/${user}
RUN echo "export PATH=${PATH}" >> ${HOME}/.bashrc && \
    echo "export LD_LIBRARY_PATH=${APBS_PATH}/lib" >> ${HOME}/.bashrc
VOLUME $HOME/data
WORKDIR $VOLUME
