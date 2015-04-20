#!/bin/bash

docker_version=${docker_version:-11}
aws_cpi_version=${aws_cpi_version:-5}
stemcell_version=${stemcell_version:-2830}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR/..

export PATH=$PWD/bin:$PATH

bosh-init deploy docker.yml \
  assets/light-bosh-stemcell-${stemcell_version}-aws-xen-ubuntu-trusty-go_agent.tgz \
  assets/bosh-aws-cpi-release-${aws_cpi_version}.tgz \
  assets/docker-${docker_version}.tgz
