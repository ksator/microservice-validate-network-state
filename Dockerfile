
FROM ubuntu:16.04

MAINTAINER Khelil Sator <ksator@juniper.net> 

ADD . /

WORKDIR /

RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y python-pip


RUN pip install -r requirements.txt  && \
    ansible-galaxy install -r requirements.ansible.yaml


ENTRYPOINT sh ./microservice_load_junos_configuration.sh 
