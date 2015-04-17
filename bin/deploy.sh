#!/bin/bash

redis_version=${redis_version:-9}
aws_cpi_version=${aws_cpi_version:-5}
stemcell_version=${stemcell_version:-2830}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR/..

export PATH=$PATH:$PWD/bin

bosh-init deploy redis.yml \
  assets/light-bosh-stemcell-${stemcell_version}-aws-xen-ubuntu-trusty-go_agent.tgz \
  assets/bosh-aws-cpi-release-${aws_cpi_version}.tgz \
  assets/redis-${redis_version}.tgz
