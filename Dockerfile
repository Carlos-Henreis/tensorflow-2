FROM amazonlinux:latest

RUN yum -y install unzip aws-cli

WORKDIR /tmp

COPY script.sh /tmp/script.sh
COPY logger.py /tmp/logger.py

ENTRYPOINT [ "/tmp/script.sh" ]
