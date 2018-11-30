FROM registry.sfgitlab.opr.statefarm.org/registry/hub.docker.com/hashicorp/terraform:0.11.10

RUN echo -e "https://nexus.opr.statefarm.org/repository/alpine/v3.7/community\nhttps://nexus.opr.statefarm.org/repository/alpine/v3.7/main" > /etc/apk/repositories \
&& apk update && apk upgrade && apk add bash && apk add python2 && apk add py-setuptools && apk add py-pip \
&& mkdir ~/.pip && touch ~/.pip/pip.conf && \
echo "[global]" > ~/.pip/pip.conf && \
echo "index = https://nexus.opr.statefarm.org/repository/pypi.python.org/pypi" >> ~/.pip/pip.conf && \
echo "index-url = https://nexus.opr.statefarm.org/repository/pypi.python.org/simple" >> ~/.pip/pip.conf && \
echo "trusted-host = pypi.org " >> ~/.pip/pip.conf \
&& pip install awscli boto3 --upgrade \
&& addgroup -g 1000 terraform \
&& adduser -D -u 1000 terraform -G terraform

WORKDIR /usr/local/bin
COPY tflint ./


USER 1000






FROM registry.sfgitlab.opr.statefarm.org/registry/hub.docker.com/python:3.6-alpine3.7

RUN echo -e "https://nexus.opr.statefarm.org/repository/alpine/v3.7/community\nhttps://nexus.opr.statefarm.org/repository/alpine/v3.7/main" > /etc/apk/repositories \
&& apk update && apk upgrade && apk add bash && apk add curl \
&& mkdir ~/.pip && touch ~/.pip/pip.conf && \
echo "[global]" > ~/.pip/pip.conf && \
echo "index = https://nexus.opr.statefarm.org/repository/pypi.python.org/pypi" >> ~/.pip/pip.conf && \
echo "index-url = https://nexus.opr.statefarm.org/repository/pypi.python.org/simple" >> ~/.pip/pip.conf && \
echo "trusted-host = pypi.org " >> ~/.pip/pip.conf \
&& pip install awscli --upgrade \
&& addgroup -g 1000 awsuser \
&& adduser -D -u 1000 awsuser -G awsuser

USER 1000
