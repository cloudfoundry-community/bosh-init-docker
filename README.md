bosh-init deploy docker
=======================

The new [bosh-init](https://github.com/cloudfoundry/bosh-init) CLI can do more than just deploy Micro BOSH.

Thanks to Ferran Rodenas we can run Docker contains backed by stateful persistent volumes (see [blog announcement](http://blog.pivotal.io/cloud-foundry-pivotal/products/managing-stateful-docker-containers-with-cloud-foundry-bosh)\)

This project will deploy a single server/VM/instance on AWS EC2 us-east-1 region running Docker and some data-backed containers. It is using the new `bosh-init` CLI and the BOSH community [docker-boshrelease](https://github.com/cf-platform-eng/docker-boshrelease).

The example manifest generated below is based on the `properties` from this example manifest for BOSH server https://github.com/cf-platform-eng/docker-boshrelease/blob/master/examples/docker-aws.yml

Usage
-----

First, fetch the required assets, including the `bosh-init` CLI:

```
./bin/fetch_assets.sh
```

Then create the `docker.yml` manifest:

```
EIP=23.23.23.23 \
ACCESS_KEY_ID=xxx SECRET_ACCESS_KEY=xxx \
KEY_NAME=xxx PRIVATE_KEY_PATH=xxx \
SECURITY_GROUP=xxx \
./bin/make_manifest.sh
```

Finally, run the `bosh-init deploy` command (via helpful wrapper):

```
./bin/deploy.sh
```

The output will look similar to:

```
Deployment manifest: '/Users/drnic/Projects/bosh-deployments/experiments/bosh-init-docker/docker.yml'
Deployment state: 'deployment.json'

Started validating
  Validating stemcell... Finished (00:00:00)
  Validating releases... Finished (00:00:00)
  Validating deployment manifest... Finished (00:00:00)
  Validating cpi release... Finished (00:00:00)
Finished validating (00:00:00)

Started installing CPI
  Compiling package 'ruby_aws_cpi/052a28b8976e6d9ad14d3eaec6d3dd237973d800'... Finished (00:01:13)
  Compiling package 'bosh_aws_cpi/deabbf731a4fedc9285324d85af6456cfa74c10c'... Finished (00:00:31)
  Rendering job templates... Finished (00:00:00)
  Installing packages... Finished (00:00:02)
  Installing job 'cpi'... Finished (00:00:00)
Finished installing CPI (00:01:46)

Starting registry... Finished (00:00:00)
Uploading stemcell 'bosh-aws-xen-ubuntu-trusty-go_agent/2830'... Finished (00:00:12)

Started deploying
  Creating VM for instance 'docker/0' from stemcell 'ami-94c187fc light'... Finished (00:00:46)
  Waiting for the agent on VM 'i-da250ef5' to be ready... Finished (00:01:55)
  Creating disk... Finished (00:00:16)
  Attaching disk 'vol-968f7dd8' to VM 'i-da250ef5'... Finished (00:00:22)
  Rendering job templates... Finished (00:00:01)
  Compiling package 'docker-server/b53d5357ab95a74c9489cd98a024e6ef6047aba0'... Finished (00:01:33)
  Updating instance 'docker/0'... Finished (00:00:08)
  Waiting for instance 'docker/0' to be running... Finished (00:00:00)
Finished deploying (00:05:05)
```

Security Group
--------------

The security group must open the following ports to the machine running `./bin/deploy.sh` or `bosh-init deploy`:

-	22
-	6868

The security group must open the following port for any clients to the docker server:

-	6379

Dependencies
------------

On Ubuntu, the following packages are required in order for the `bosh-aws-cpi` to compile Ruby successfully:

```
sudo apt-get install -y build-essential zlibc zlib1g-dev \
  openssl libxslt-dev libxml2-dev libssl-dev \
  libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev sqlite3
```

I don't know what the matching requirements are for OS X anymore. That would require buying a new Mac. Wait... let me ask my wife.
