FROM docker:stable-dind-rootless

ENV \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8
ARG oldVolume="     - ./web:/app"
ARG newVolume="     - /data:/app"
# Install requirements for add-on
RUN \
    cd ~ \
    && apk add --no-cache \
        bash \
        py3-pip \
        py3-paramiko \
        libffi-dev \
        openssl-dev \
        gcc \
        git \
        make \  
        libc-dev \
        curl \
    && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing --allow-untrusted \
        sd \
    && pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir "docker-compose==1.24.0" \
    && git clone https://github.com/TheSpaghettiDetective/TheSpaghettiDetective.git \
    && cd TheSpaghettiDetective \
    && sd $oldVolume $newVolume docker-compose.yaml \
    && rm -fr /var/run/docker.sock
RUN \
    export DOCKER_HOST=unix:///var/run/docker.sock \
    && dockerd --host=unix:///var/run/docker.sock & \
    && cd ~/TheSpaghettiDetective \
    && docker-compose up  --no-start  --no-recreate

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]

LABEL io.hass.version="VERSION" io.hass.type="addon" io.hass.arch="armhf|aarch64|i386|amd64"