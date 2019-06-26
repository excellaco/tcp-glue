# tcp-glue

Note: This is intended to run on Linux (Ubuntu 16.04 preferred) or Mac OS. Windows has not been tested (though PRs are welcome).

## Getting Started

Once you have installed Docker and built the tcp-glue repo (see the Installation section below) then run the following to get off the ground:

Run the apps from the tcp-glue repo directory:

`docker-compose up`

Alternatively you can use the fpg script that wraps docker-compose from any directory:

`fpg up`

To learn about how to:

...use the tailored fpg script to make your life better see the wiki (recommended).
...use docker-compose in the context of this repo see the wiki.

Checkout the FAQ if you have questions.

## Installation

### MAC

Docker can run at near-native speeds on [Mac](https://docs.docker.com/docker-for-mac/install) with the osxfs filesharing solution.

[Install Docker (CE) + Docker Compose](https://download.docker.com/mac/stable/Docker.dmg)

Start Docker.

Add more available memory for Docker: `Under Docker > Preferences > Advanced` and set the following:
Memory: 4 Gb

Clone this repo and cd into it

Clone all of the repos, build the docker images, setup the databases, and download dependencies:

`./build.sh`

Note: if you need to run the build again for a specific app you can run ./build.sh <app-name> to skip rebuilding the other apps.

You're done!

### Ubuntu Linux

This is how Docker is designed to run: natively on Linux.

Install Docker (CE) and [follow these steps](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-docker-ce)

Add your user to the docker group so that you don't have to add sudo to each command:

```
sudo groupadd docker
sudo gpasswd -a ${USER} docker
sudo service docker restart
newgrp docker
```

Install Docker Compose:

```
COMPOSE_VERSION=`git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oP "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | tail -n 1`
sudo sh -c "curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose
sudo sh -c "curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"
```

If you haven't already, clone this repo into a directory where you would like all of the fema repos cloned.

```
mkdir ~/github
cd ~/github
git clone git@github.com:excellaco/tcp-glue.git
```

So the parent directory should look like:

```
~/github
└── tcp-glue
```

Clone all of the fema repos, build the docker images, setup the databases, and download dependencies:

`./build.sh`

Note: if you need to run the build again for a specific app you can run ./build.sh <app-name> to skip rebuilding the other apps.

You're done!

## Contributing

There are a few rules to follow when making changes to the repo:

Try not to make Dockerfile changes unless you need to. This causes folks to need to rebuild their images when pulling down the latest changes, which takes a while.

We use the Major.Minor.Patch version strategy, enforced by git hooks:  
Major: indicates a breaking change that must require a rebuild immediately (use major++ in your commit message to bump the major version)  
Minor: a significant change that may suggests a rebuild (use minor++ in your commit message to bump the major version)  
Patch: a non-Dockerfile change that will not break anything (patch versions are automatically bumped on each commit)
