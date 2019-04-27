# evesync
[![Build Status](https://travis-ci.org/mrexox/evesync.svg?branch=master)](https://travis-ci.org/mrexox/evesync)

A simple ruby-written service for automation files and packages changes between similar hosts.

### Testing

#### Starting containers with evesync service

```
docker-compose build
docker-compose up --detach
```

This will build the docker image for CentOS 7.4 distribution and start 2 of the containers.

When attached, you'll see tmux session. `bin/start` will start evesync service.

#### Stopping containers

```
docker-compose rm --force
```
