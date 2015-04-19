bosh-init deploy docker
=======================

The new [bosh-init](https://github.com/cloudfoundry/bosh-init) CLI can do more than just deploy Micro BOSH.

Thanks to Ferran Rodenas we can run Docker contains backed by stateful persistent volumes (see [blog announcement](http://blog.pivotal.io/cloud-foundry-pivotal/products/managing-stateful-docker-containers-with-cloud-foundry-bosh)\)

This project will deploy a single server/VM/instance on AWS EC2 us-east-1 region running Docker and some data-backed containers. It is using the new `bosh-init` CLI and the BOSH community [docker-boshrelease](https://github.com/cf-platform-eng/docker-boshrelease).

The example manifest generated below is based on the `properties` from this example manifest for BOSH server https://github.com/cf-platform-eng/docker-boshrelease/blob/master/examples/docker-aws.yml

![example](http://cl.ly/image/3g1K1Y2l0o3d/docker_-_redis.png)

In this tutorial example the VM will be running the following containers:

-	redis on port 6379
-	mysql on port 3306
-	elasticsearch on ports 9200/9300

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
  Compiling package 'ruby_aws_cpi/052a28b8976e6d9ad14d3eaec6d3dd237973d800'... Finished (00:00:00)
  Compiling package 'bosh_aws_cpi/deabbf731a4fedc9285324d85af6456cfa74c10c'... Finished (00:00:00)
  Rendering job templates... Finished (00:00:00)
  Installing packages... Finished (00:00:02)
  Installing job 'cpi'... Finished (00:00:00)
Finished installing CPI (00:00:03)

Starting registry... Finished (00:00:00)
Uploading stemcell 'bosh-aws-xen-ubuntu-trusty-go_agent/2830'... Skipped [Stemcell already uploaded] (00:00:00)

Started deploying
  Waiting for the agent on VM 'i-4634bebb'... Finished (00:00:01)
  Stopping jobs on instance 'unknown/0'... Finished (00:00:00)
  Unmounting disk 'vol-cb6a1cdd'... Finished (00:00:00)
  Deleting VM 'i-4634bebb'... Finished (00:01:16)
  Creating VM for instance 'docker/0' from stemcell 'ami-94c187fc light'... Finished (00:00:52)
  Waiting for the agent on VM 'i-46f366bb' to be ready... Finished (00:02:50)
  Attaching disk 'vol-cb6a1cdd' to VM 'i-46f366bb'... Finished (00:00:56)
  Rendering job templates... Finished (00:00:03)
  Compiling package 'bosh-helpers/55717f488eb12fd47c95fd524ab1cd6304c7ce7e'... Finished (00:00:02)
  Compiling package 'docker/88892c10d791121cbc0582e2a68cfb00b4721d7b'... Finished (00:01:07)
  Compiling package 'remote_syslog/89692d361000e340f4a84518a14db23717665a99'... Finished (00:00:12)
  Updating instance 'docker/0'... Finished (00:00:08)
  Waiting for instance 'docker/0' to be running... Finished (00:00:03)
Finished deploying (00:07:50)
```

Security Group
--------------

The security group must open the following ports to the machine running `./bin/deploy.sh` or `bosh-init deploy`:

-	22
-	6868

The security group must open the following port for any clients to the docker server:

-	redis on port 6379
-	mysql on port 3306
-	elasticsearch on ports 9200/9300

If you add/remove other docker containers to the `docker.yml` manifest then ensure your clients can access the corresponding ports.

Dependencies
------------

On Ubuntu, the following packages are required in order for the `bosh-aws-cpi` to compile Ruby successfully:

```
sudo apt-get install -y build-essential zlibc zlib1g-dev \
  openssl libxslt-dev libxml2-dev libssl-dev \
  libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev sqlite3
```

I don't know what the matching requirements are for OS X anymore. That would require buying a new Mac. Wait... let me ask my wife.
