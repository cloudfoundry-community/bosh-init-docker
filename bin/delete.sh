#!/bin/bash

aws_cpi_version=${aws_cpi_version:-5}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR/..

export PATH=$PATH:$PWD/bin

bosh-init delete redis.yml \
  assets/bosh-aws-cpi-release-${aws_cpi_version}.tgz
