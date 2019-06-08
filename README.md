# evesync
[![Build Status](https://travis-ci.org/mrexox/evesync.svg?branch=master)](https://travis-ci.org/mrexox/evesync)
[![Gem Version](https://badge.fury.io/rb/evesync.svg)](https://badge.fury.io/rb/evesync)

A simple ruby-written service for automation files and packages changes between similar hosts.

## Getting started
Using evesync is very simple. All you need - install dependent gems and start daemons.

### Prerequisites

You need to install all gems. This can be easily done by calling `bundle install`.

### Installing

#### From rubygems

For Rhel (CentOS, Fedora, etc.) users:
```
# yum install rubygems ruby-devel make gcc
# gem install evesync
```

For Debian (Ubuntu, Puppet, etc.) users:
```
# apt-get update
# apt-get install rubygems ruby-dev make gcc
# gem install evesync
```

#### Manually

Installing is not well-tested yet. You need install the gem and place the script **bin/start** directory into any of your PATH-accessable folders. Or use **evesync --run**.

```bash
# Installing the gem
rake install

# Copying start script
cp bin/start /usr/bin/start-evesync
chmod +x /usr/bin/start-evesync
```

## Testing
There's the way to test without installing evesync on real systems. Using Docker.

### Starting containers with evesync service

```
docker-compose build
docker-compose up --detach
```
or
```
rake docker
rake up
```

This will build the docker image for CentOS 7.4 distribution and start 2 of the containers.

When attached, you'll see tmux session. `bin/start` will start evesync service.

### Stopping containers

```
docker-compose rm --force
```
or
```
rake down
```

For more information about realization see [description.md](./description.md)
