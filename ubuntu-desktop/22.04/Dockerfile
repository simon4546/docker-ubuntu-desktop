ARG BASE_IMAGE=ubuntu:22.04
From $BASE_IMAGE

LABEL maintainer "simon4546"
MAINTAINER simon4546 "https://github.com/simon4546"

ENV DEBIAN_FRONTEND=noninteractive

ENV USER=ubuntu \
    PASSWORD=ubuntu \
    UID=1000 \
    GID=1000

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV REMOTE_DESKTOP=xrdp
ENV VNC_THREADS=2

## Copy config
COPY docker_config /docker_config

## Install some common tools 
RUN apt-get update  && \
    apt-get install -y sudo wget curl git lsb-release net-tools iputils-ping \
            openssh-server software-properties-common && \
    rm -rf /var/lib/apt/lists/* 

# ## Install desktop
RUN apt-get update && \
    # install xfce4
    apt-get install -y xfce4 &&\
    # remove and disable screensaver
    apt-get remove -y xfce4-screensaver --purge &&\
    rm -rf /var/lib/apt/lists/*

## Install xrdp
RUN bash /docker_config/install_xrdp.sh

# Configure ssh 
RUN mkdir /var/run/sshd &&  \
    echo root:$PASSWORD | chpasswd && \
    sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

EXPOSE 22 3389

ENTRYPOINT ["/docker_config/entrypoint.sh"]
