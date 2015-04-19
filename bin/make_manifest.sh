#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR/..

if [[
"${EIP}X" == "X" ||
"${ACCESS_KEY_ID}X" == "X" ||
"${SECRET_ACCESS_KEY}X" == "X" ||
"${KEY_NAME}X" == "X" ||
"${PRIVATE_KEY_PATH}X" == "X" ||
"${SECURITY_GROUP}X" == "X" ]]; then
  echo "USAGE: EIP=xxx ACCESS_KEY_ID=xxx SECRET_ACCESS_KEY=xxx KEY_NAME=xxx PRIVATE_KEY_PATH=xxx SECURITY_GROUP=xxx ./bin/make_manifest.sh"
  exit 1
fi

cat >docker.yml <<EOF
---
name: docker

resource_pools:
- name: default
  network: default
  cloud_properties:
    instance_type: m3.medium
    availability_zone: us-east-1c

jobs:
- name: docker
  instances: 1
  persistent_disk: 10240
  templates:
  - {name: docker, release: docker}
  - {name: containers, release: docker}
  networks:
  - name: vip
    static_ips: [$EIP]
  - name: default

  properties:
    containers:
      - name: redis
        image: "redis"
        command: "--dir /var/lib/redis/ --appendonly yes"
        bind_ports:
          - "6379:6379"
        bind_volumes:
          - "/var/lib/redis"
        entrypoint: "redis-server"
        memory: "256m"
        cpu_shares: 1
        env_vars:
          - "EXAMPLE_VAR=1"

      - name: mysql
        image: "google/mysql"
        bind_ports:
          - "3306:3306"
        bind_volumes:
          - "/mysql"

      - name: elasticsearch
        image: "bosh/elasticsearch"
        links:
          - mysql:db
        depends_on:
          - mysql
        bind_ports:
          - "9200:9200"
          - "9300:9300"
        bind_volumes:
          - "/data"
        dockerfile: |
          FROM dockerfile/java
          RUN \
            cd /tmp && \
            wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.1.tar.gz && \
            tar xvzf elasticsearch-1.1.1.tar.gz && \
            rm -f elasticsearch-1.1.1.tar.gz && \
            mv /tmp/elasticsearch-1.1.1 /elasticsearch
          WORKDIR /data
          CMD ["/elasticsearch/bin/elasticsearch"]
          EXPOSE 9200
          EXPOSE 9300

networks:
- name: default
  type: dynamic
- name: vip
  type: vip

cloud_provider:
  template: {name: cpi, release: bosh-aws-cpi}

  ssh_tunnel:
    host: $EIP
    port: 22
    user: vcap
    private_key: $PRIVATE_KEY_PATH

  registry: &registry
    username: admin
    password: admin
    port: 6901
    host: localhost

  # Tells bosh-micro how to contact remote agent
  mbus: https://nats:nats@$EIP:6868

  properties:
    aws:
      access_key_id: $ACCESS_KEY_ID
      secret_access_key: $SECRET_ACCESS_KEY
      default_key_name: $KEY_NAME
      default_security_groups: [$SECURITY_GROUP]
      region: us-east-1

    # Tells CPI how agent should listen for requests
    agent: {mbus: "https://nats:nats@0.0.0.0:6868"}

    registry: *registry

    blobstore:
      provider: local
      path: /var/vcap/micro_bosh/data/cache

    ntp: [0.north-america.pool.ntp.org]
EOF
