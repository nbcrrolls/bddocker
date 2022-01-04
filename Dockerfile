################################################################################# 
# Dockerfile 
# 
# Version:          3.5
# Software:         BrownDye base image
# Software Version: 2022-01-04
# Description:      Docker image for BrownDye, APBS and PDB2PQR
# Website:          https://browndye.ucsd.edu
# Tags:             Electrostatics|Brownian Dynamics|Solvation
# Base Image:       ubuntu:20.04
# Build Cmd:        docker build rokdev/bddocker . 
# Build Cmd:        docker build --tag=bddocker:v3.5 -f ./Dockerfile .
# Pull Cmd:         docker pull rokdev/bddocker 
# Run Cmd:          docker run --rm -it -u 1000:1000 \
#                      -v "$PWD":/home/browndye/data \
#                      -w /home/browndye/data rokdev/bddocker 
################################################################################# 

FROM ubuntu:20.04

LABEL version="3.5"
LABEL description="Docker image for BrownDye, APBS and PDB2PQR"
MAINTAINER Robert Konecny <rok@ucsd.edu>

ENV APBS_VERSION 3.0.0
ENV BD2_VERSION "2.0-3_Jan_2022"
ENV BD_URL https://browndye.ucsd.edu

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y -q --no-install-recommends curl wget make cmake \
    liblapack-dev nano readline-common unzip python3-pip libtinfo5 less vim-nox apbs && \
    curl -sk $BD_URL/downloads/browndye2-ubuntu-20.04.tar.gz | tar xzf - -C /opt && \
    curl -sLk http://mirrors.kernel.org/ubuntu/pool/main/r/readline/libreadline7_7.0-3_amd64.deb \
          --output /tmp/libreadline7_7.0-3_amd64.deb && \
    dpkg -i /tmp/libreadline7_7.0-3_amd64.deb && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

ENV BD2_PATH /opt/browndye2

# add apbs
RUN curl -L https://github.com/Electrostatics/apbs-pdb2pqr/releases/download/vAPBS-${APBS_VERSION}/APBS-${APBS_VERSION}_Linux.zip -k -s --output /tmp/apbs.zip && \
    unzip /tmp/apbs.zip -d /opt && \
    ln -s /opt/APBS-${APBS_VERSION}.Linux /opt/apbs && \
    rm -f /opt/apbs/share/apbs/examples/protein-rna/*.dx && \
    rm -f /tmp/apbs.zip

ENV APBS_PATH /opt/apbs

# add pdb2pqr
RUN pip install pdb2pqr && \
    ln -s /usr/local/bin/pdb2pqr30 /usr/local/bin/pdb2pqr

# set up browndye user
ENV user=browndye
RUN groupadd ${user} && useradd -g ${user} -l -ms /bin/bash ${user}
ENV PATH ${APBS_PATH}/bin:${BD2_PATH}/bin:${PATH}
ENV LD_LIBRARY_PATH ${APBS_PATH}/lib
ENV HOME /home/${user}
#RUN echo "export PATH=${PATH}" >> ${HOME}/.bashrc && \
#    echo "export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}" >> ${HOME}/.bashrc
VOLUME $HOME/data
#WORKDIR $VOLUME

