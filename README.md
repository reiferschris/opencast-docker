# mtneug/opencast

- [Introduction](#introduction)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Distributions](#distributions)
    - [`allinone`](#-allinone-)
    - [`admin`, `worker` and `presentation`](#-admin-worker-and-presentation-)
- [Configuration](#configuration)
- [References](#references)

# Introduction

This repository holds `Dockerfiles` for creating [Opencast](http://www.opencast.org/) Docker container images.

# Installation

All container images are available on [Docker Hub](https://hub.docker.com/r/mtneug/opencast/). To install the image simply pull the distribution you want:

```sh
$ docker pull "mtneug/opencast:<distribution>"
```

To install a specific version, use the following command:

```sh
$ docker pull "mtneug/opencast:<distribution>-<version>"
```

If you want to build the images yourself, there is a `Makefile` with the necessary `docker build` commands for all distributions. Running `make` in the root directory will create these images.

# Quick Start

A quick local test system can be started using [`docker-compose`](https://github.com/docker/compose). After cloning this repository you can run this command from the root directory:

```sh
$ docker-compose -p opencast-allinone -f docker-compose/docker-compose.allinone.hsql.yml up
```

This will run Opencast using the `allinone` distribution configured to use the bundled [H2 (HSQL) Database Engine](http://www.h2database.com/html/main.html). Before you start the system, you probably should change `ORG_OPENCASTPROJECT_SERVER_URL` to a proper hostname in `docker-compose/docker-compose.allinone.hsql.yml`.

# Distributions

Opencast comes in different distributions. For each of the official distribution there is a specific Docker image tag. `latest` is the same as `allinone`. In addition each version is tagged and concatenated with the distribution. For example the full image name containing the `admin` distribution at version `2.1.0` is `mtneug/opencast:admin-2.1.0`. Living the version out will install the latest one.

## `allinone`

This image contains all Opencast modules necessary to run a full Opencast installation. It's useful for small and local test setups. If you however want to run Opencast in a distributed fashion, you probably should use a combination of `admin`, `worker` and `presentation` containers.

## `admin`, `worker` and `presentation`

These images contain the Opencast modules of the corresponding Opencast distributions.

# Usage

The images come with multiple commands. You can see a full list with description by running:

```sh
$ docker run --rm mtneug/opencast:<distribution> app:help
Usage:
  app:help                Prints the usage information
  app:print:dll           Prints SQL commands to set up the database
  app:print:activemq.xml  Prints the configuration for ActiveMQ
  app:init                Checks and configures Opencast but does not run it
  app:start               Starts Opencast
  [cmd] [args...]         Runs [cmd] with given arguments
```

# Configuration

It's recommended to configure Opencast by using [Docker Volumes](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems):

```sh
$ docker run -v "/path/to/opencast-etc:/opencast/etc" mtneug/opencast:<distribution>
```

The most important settings however can be configured by [environment variables](https://docs.docker.com/engine/reference/run/#env-environment-variables). You can use this functionally to generate new configuration files. For this start a new container with specific variables and execute the `app:init` command. This will
ensure you haven't missed anything, write the configuration files and exit. Then you can copy the files to a target folder:

```sh
$ docker run --name opencast_generate_config \
  -e "ACTIVEMQ_BROKER_URL=failover://tcp://example.opencast.org:61616" \
  -e "ACTIVEMQ_BROKER_USERNAME=admin" \
  -e "ACTIVEMQ_BROKER_PASSWORD=password" \
  -e "ORG_OPENCASTPROJECT_SERVER_URL=http://localhost:8080" \
  -e "ORG_OPENCASTPROJECT_SECURITY_ADMIN_USER=admin" \
  -e "ORG_OPENCASTPROJECT_SECURITY_ADMIN_PASS=opencast" \
  -e "ORG_OPENCASTPROJECT_SECURITY_DIGEST_USER=opencast_system_account" \
  -e "ORG_OPENCASTPROJECT_SECURITY_DIGEST_PASS=CHANGE_ME" \
  mtneug/opencast:<distribution> "app:init"
$ docker cp opencast_generate_config:/opencast/etc opencast-config
$ docker rm opencast_generate_config
```

Make sure to use the correct Opencast distribution as there are slide differences.

## Opencast

* `ORG_OPENCASTPROJECT_SERVER_URL` **Required**  
  The HTTP-URL where Opencast is accessible.
* `ORG_OPENCASTPROJECT_SECURITY_ADMIN_USER`  **Required**  
  Username of the admin user.
* `ORG_OPENCASTPROJECT_SECURITY_ADMIN_PASS`  **Required**  
  Password of the admin user.
* `ORG_OPENCASTPROJECT_SECURITY_DIGEST_USER`  **Required**  
  Username for the communication between Opencast nodes and capture agents.
* `ORG_OPENCASTPROJECT_SECURITY_DIGEST_PASS`  **Required**  
  Password for the communication between Opencast nodes and capture agents.

For an installation with multiple nodes you can also set:

* `ORG_OPENCASTPROJECT_FILE_REPO_URL`  Optional  
  HTTP-URL of the file repository. Defaults to `${org.opencastproject.server.url}` in the `allinone` distribution and `${org.opencastproject.admin.ui.url}` for every other one.
* `PROP_ORG_OPENCASTPROJECT_ADMIN_UI_URL`  **Required**  
  HTTP-URL of the admin node.
* `PROP_ORG_OPENCASTPROJECT_ENGAGE_UI_URL`  **Required**  
  HTTP-URL of the engage node.

## ActiveMQ

* `ACTIVEMQ_BROKER_URL` **Required**  
  URL to ActiveMQ instances using the format specified in the [Opencast documentation](https://docs.opencast.org/latest/admin/configuration/message-broker/), e.g. `failover://tcp://example.opencast.org:61616`
* `ACTIVEMQ_BROKER_USERNAME` **Required**  
  ActiveMQ username.
* `ACTIVEMQ_BROKER_PASSWORD` **Required**  
  Password of the ActiveMQ user.

## Database

* `ORG_OPENCASTPROJECT_DB_VENDOR` Optional  
  The type of database to use. Currently you set this to either `HSQL` or `MySQL`. The default is `HSQL`.
* `ORG_OPENCASTPROJECT_DB_DDL_GENERATION` Optional  
  Specifies whether to Opencast should create the database tables or not. It defaults to `false`. In case of `HSQL` it is always set to `true`.

### HSQL

There are no additional environment variables you can set for HSQL.

### MySQL

* `ORG_OPENCASTPROJECT_DB_JDBC_URL` **Required**  
  [JDBC](http://www.oracle.com/technetwork/java/javase/jdbc/index.html) connection string.
* `ORG_OPENCASTPROJECT_DB_JDBC_USER` **Required**  
  Database username.
* `ORG_OPENCASTPROJECT_DB_JDBC_PASS` **Required**  
  Password of the database user.

# Storage

The storage directory is located at `/data/opencast`. Use [Docker Volumes](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems) to mount this directory on your host.

# References

* [Project site](https://zivgitlab.uni-muenster.de/learnweb/docker-opencast)
* [Opencast documentation](https://docs.opencast.org/latest/admin/)
* [Images on Docker Hub](https://hub.docker.com/r/mtneug/opencast/)