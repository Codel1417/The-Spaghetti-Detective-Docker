FROM docker:stable-dind-rootless

ENV \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8
ARG oldVolume="     - ./web:/app"
ARG newVolume="     - /data:/app"
# Install requirements for add-on
USER root
ENV DOCKER_HOST=unix:///var/run/docker.sock
RUN \
    apk add --no-cache \
        bash
SHELL ["/bin/bash", "-c"]
WORKDIR /
RUN \
    apk add --no-cache \
        py3-pip \
        py3-paramiko \
        libffi-dev \
        openssl-dev \
        gcc \
        git \
        make \  
        libc-dev \
        curl
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing --allow-untrusted \
        sd 
RUN \
    pip3 install --no-cache-dir --upgrade \
        pip \
        "docker-compose==1.24.0" 
RUN \
    rm -fr /var/run/docker.sock \
    && mkdir /tsd \
    && chmod 777 /tsd \
    && mkdir /data \
    && chmod 777 /data

WORKDIR /tsd

RUN git clone https://github.com/TheSpaghettiDetective/TheSpaghettiDetective.git

WORKDIR /tsd/TheSpaghettiDetective

RUN sd $oldVolume $newVolume docker-compose.yaml
RUN \
    nohup bash -c "dockerd --host=unix:///var/run/docker.sock" \
    && docker-compose up  --no-start  --no-recreate

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]

LABEL io.hass.version="VERSION" io.hass.type="addon" io.hass.arch="armhf|aarch64|i386|amd64"