# Magento 2 Development Environment with Docker and rysnc for OSX

This repository includes a containerized Magento 2 development environment for MAC OSX.  All database and PHP files are synced to the host environment through rsync to improve load time for persisted data.

## Installation Prerequisites

Before running you must have the following:

* [Docker installed](https://docs.docker.com/mac/step_one/)
* [Homebrew installed](#installing-homebrew)
* [docker-osx-dev installed](#installing-docker-osx-dev)
* Entry in /etc/hosts file for docker.localhost.com ([see notes below](#/etc/hosts-file))
* [Magento authentication keys](#magento-authentication-keys)

## Installing Homebrew

```
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

## Installing docker-osx-dev

This program is what really speeds up development using Docker on OS X.  

```
$ curl -o /usr/local/bin/docker-osx-dev https://raw.githubusercontent.com/brikis98/docker-osx-dev/master/src/docker-osx-dev
$ chmod +x /usr/local/bin/docker-osx-dev
$ docker-osx-dev install
```

## /etc/hosts file

The containerized applications assume that you have the host docker.localhost.com mapped to your docker container IP.  For example my /etc/hosts file contains the line:

```
192.168.99.100 docker.localhost.com
```

You can find out the IP address to use by opening your Docker QuickStart Terminal and running the following command:

```bash
$ docker-machine ip default
```
 
## Magento authentication keys

Before you run up this application you have to create an auth.json file with your [Magento authentication keys](http://devdocs.magento.com/guides/v2.0/install-gde/prereq/connect-auth.html).  Create the auth.json file in the same directory as the M2 Start.app.  The auth.json file will look like this:

```javascript
{
   "http-basic": {
      "repo.magento.com": {
         "username": "YOUR PUBLIC KEY",
         "password": "YOUR PRIVATE KEY"
      }
   }
}
```

## Starting the environment

To spin up your development environment simply pull this repository and click the M2 Start application.  On first launch of the container(s) a directory named "volumes" will be created that contains the Magento and Mysql data directories. 

Note: The first time you run this app the build process will take several minutes.
