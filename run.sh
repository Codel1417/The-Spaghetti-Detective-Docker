#!/bin/bash
# https://stackoverflow.com/questions/32076878/logging-solution-for-multiple-containers-running-on-same-host

nohup bash -c "dockerd --host=unix:///var/run/docker.sock" \
docker-compose up  --no-start  --no-recreate
cd ~/TheSpaghettiDetective
docker-compose start

while true
do
    wait $pid
done