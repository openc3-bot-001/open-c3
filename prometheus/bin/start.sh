#!/bin/bash

X=$(docker inspect  openc3-prometheus 2>&1|grep Created|wc -l)

mkdir -p /data/prometheus-data
chmod 777 /data/prometheus-data

if [ ! -f /data/open-c3/prometheus/config/prometheus.yml ];then
    cp /data/open-c3/prometheus/config/prometheus.example.yml /data/open-c3/prometheus/config/prometheus.yml
fi

if [ ! -f /data/open-c3/prometheus/config/openc3_node_sd.yml ];then
    cp /data/open-c3/prometheus/config/openc3_node_sd.example.yml /data/open-c3/prometheus/config/openc3_node_sd.yml
fi

Externalur=""
MYIP=$(ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}'|grep -v ^172|head -n 1)
if [ "X" != "X$MYIP" ];then
   Externalur="--web.external-url=http://$MYIP:9090"
fi

if [ "X1" == "X$X"  ]; then
    docker start openc3-prometheus
else
    docker run -d -p 9090:9090 -v /data/prometheus-data:/data/prometheus-data -v /data/open-c3/prometheus:/data/prometheus-root --name openc3-prometheus prom/prometheus --config.file /data/prometheus-root/config/prometheus.yml --storage.tsdb.path=/data/prometheus-data $Externalur --web.enable-lifecycle
fi
