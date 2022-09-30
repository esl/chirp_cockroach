# ChirpCockroach

## Overview
The goal of this demo is to showcase the usage of CockroachDB together with a Phoenix LiveView application,
provide basic guidelines for integration and examples of a more advanced configuration of the database itself
and how to deploy it using tools that are commonly used in production (e.g. Kubernetes, Podman).
**NOTE** This demo uses 3 node cluster to simulate features such as replication and what happens
if one of the nodes is down. This is not ideal as sometimes containers might crash as a result of running 3 of them
on one machine.

### Requirements
For setting up a demo using Phoenix development server you need to have Elixir and Erlang installed.
The easiest way to install all dependencies is to use a package manager. This project provides the needed package
versions in file the `.tool-versions` file used by `asdf` package manager. To install the packages run:
```bash
$ asdf install
```
Docker and docker-compose are assumed to be installed on the machine, and packages required for [DevOps examples](##DevOps Examples)
are also specified in the `.tool-versions` file.

## What is CockroachDB?
CockroachDB is a distributed SQL database built on a transactional and strongly-consistent key-value store.
It scales horizontally; survives disk, machine, rack, and even data center failures with minimal latency disruption
and no manual intervention; supports strongly-consistent ACID transactions;  and provides a familiar SQL API
for structuring, manipulating, and querying data.

To read more check out the official [documentation](https://www.cockroachlabs.com/docs/).

## Phoenix and Phoenix LiveView
The application is built according to [this](https://www.youtube.com/watch?v=MZvmYaFkNJI) YouTube tutorial. It's a clone of some basic Twitter features that allow showcasing some
Phoenix LiveView features, all powered by Elixir/Phoenix backend.

## Phoenix app and CockroachDB connection.
With Ecto >= 3.8 and postgrex >= 0.15 there is no need for any additional dependencies to connect the Phoenix app with CockroachDB.
Configuration is similar to normal PostgreSQL database setup.
Developers can provide database connection information as a list of keys:
```Elixir
# ~/config/dev.exs
config :chirp_cockroach, ChirpCockroach.Repo,
  username: "root",
  password: "",
  hostname: "localhost",
  port: 26257,
  database: "chirp_cockroach_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  migration_lock: false
```
or as database URL:
```elixir
  # ~/config/runtime.exs
  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  # example database_url: "postgresql://root@roach1:26257/chirp_cockroach_dev?sslmode=disable"
  config :chirp_cockroach, ChirpCockroach.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6,
    migration_lock: false
```
### Important notes
- CockroachDB does not support locking tables so we need to manually disable it by adding `migration_lock: false`
- the configuration above uses default values, but it's possible (and recommended) to enable `ssl` for a production database

## Basic setup using docker-compose
### Requirements
- Docker
- docker-compose

Start containers:
```bash
$ docker-compose up
```

This will create 4 containers:
- roach1, roach2, roach3 - CockroachDB nodes
- crdb-init - helper container for initializing cluster, will exit after initialization finishes
- web - phoenix application

## Local setup

### Requirements
- CockroachDB >= 22.1.6 [Installation](https://www.cockroachlabs.com/docs/v22.1/install-cockroachdb-mac.html)
- Elixir >= 1.14
- Phoenix >= 1.6

Setup CockroachDB cluster
```bash
# start 3 separate nodes
cockroach start --insecure --store=node3 --listen-addr=localhost:26259 \
  --http-addr=localhost:8082 --join=localhost:26257 --background
cockroach start --insecure --store=node2 --listen-addr=localhost:26258 \
  --http-addr=localhost:8081 --join=localhost:26257 --background
cockroach start --insecure --store=node1 --listen-addr=localhost:26257 \
  --http-addr=localhost:8080 --join=localhost:26257 --background
# initalize cluster
$ cockroach init --insecure
```

Fetch dependencies and compile the project
```bash
$ mix deps.get

# optional
$ mix compile
```
Setup database
```bash
$ mix ecto.setup
```
Start Phoenix server in interactive mode
```bash
$ iex -S mix phx.server
```


## Features
To access the Phoenix application visit: `localhost:4000` and you should see:
![Fresh start](./images/fresh_start.png)

Add some posts by using `New Post` link:
![New post](./images/new_post.png)
![Posts](./images/posts.png)

Using Phoenix LiveView we can have instant communication between different browsers
![LiveView demo](./images/live_view_demo.gif)

CockroachDB provides a dashboard under `localhost:8080` for monitoring cluster and database status
![CockroachDB overview](./images/cdb_overview.png)

Basic database metrics, per node or cluster aggregated (e.g. Queries per second, Service Latency, Replication)
![CockroachDB metrics](./images/cdb_metrics.png)

Automatic replication after recovery
![CockroachDB recovery](./images/cdb_recovery.mov)

## Cleanup
To stop all containers ran by `docker-compose` input `CTRL+C` two times, or if you run the example in a detached state
```bash
$ docker-compose down
```
Remove network created by docker-compose
```bash
$ docker network rm chirp_cockroach_roachnet
```
Remove stopped containers
```bash
docker container rm web roach1 roach2 roach3 crdb-init
```
Remove volumes used by docker-compose (this provides data persistence between uses)
```bash
# remove by hand
$ docker volume rm chirp_cockroach_roach1 chirp_cockroach_roach2 chirp_cockroach_roach3
# or prune volumes
$ docker volume prune
```

## Change Data Capture / Changefeeds
Changefeeds are CockroachDB mechanisms to provide a configurable sink for downstream data processing
e.g. reporting, caching, or full-text indexing.

Changefeeds can stream rows of data from single or multiple tables to services such as Kafka, Google Cloud Pub/Sub,
Cloud Storage (AWS S3, Azure Storage, Google Cloud Storage), and webhook (currently in beta).

### Changefeeds in demo
Basic implementation of changefeeds available on the go without a license (Core Changefeeds) watches specified
table/tables and emits every change to the "watched" row. The difference with Enterprise Changefeeds is that sinks are not
configurable and only `CREATE` changefeed operation is supported, which ends when the dedicated database connection is closed.

### Core Changefeeds in action
After starting the CockroachDB cluster and Phoenix app connecting to the SQL console, `DATABASE_URL` can be found in `docker-compose.yml`
```bash
# IMPORTANT specify database url and format flags
$ docker exec -it roach1 ./cockroach sql --insecure --url="DATABASE_URL" --format=csv
# enable rangefeeds for cluster
$ SET CLUSTER SETTING kv.rangefeed.enabled = true;
```
Create changefeed:
```bash
> EXPERIMENTAL CHANGEFEED FOR
```
![CockroachDB changefeed](./images/cdb_changefeed.gif)


## Advanced Examples
### CockroachDB - Features
To check out more advanced features of CockroachDB refer to the links below:
#### Replication and Rebalancing
**Summary** Start a 3-node local cluster, write some data, verify replication, add 2 more nodes and watch automatic rebalancing of the replicas
https://www.cockroachlabs.com/docs/stable/demo-replication-and-rebalancing.html

#### Fault Tolerance & Recovery
**Summary** Starting with a 6-node cluster simulate node crash and automatic recovery with uninterrupted data access
https://www.cockroachlabs.com/docs/stable/demo-fault-tolerance-and-recovery.html
#### Multi-Region Performance
**Summary** Setup example multi-region CockroachDB node cluster and run example workload
https://www.cockroachlabs.com/docs/stable/demo-low-latency-multi-region-deployment.html
#### Serializable Transactions
**Summary** Work through a hypothetical scenario demonstrating the importance of `SERIALIZABLE` isolation for data correctness.
https://www.cockroachlabs.com/docs/stable/demo-serializable.html
#### Other
- [Spatial Data](https://www.cockroachlabs.com/docs/stable/spatial-tutorial.html)
- [Cross-Cloud Migration](https://www.cockroachlabs.com/docs/stable/demo-automatic-cloud-migration.html)
- [JSON Support](https://www.cockroachlabs.com/docs/stable/demo-json-support.html)

## DevOps Examples
### Scaffold
Skaffold is a command line tool that facilitates continuous development of Kubernetes applications. You can iterate on your application source code locally and then deploy it to local or remote Kubernetes clusters. Skaffold handles the workflow of building, pushing and deploying your application. It also provides building blocks and describes customizations for a CI/CD pipeline.

For a local development environment, Skaffold can use several applications the most popular being Minikube and Kind.
- Start Minikube cluster
```bash
$ minikube start --profile custom
$ skaffold config set --global local-cluster true
% eval $(minikube -p custom docker-env)
```
- OR Start Kind cluster
```bash
$ kind create cluster
$ skaffold config set --kube-context kind-kind --global local-cluster true
```
- Start Skaffold
```bash
# in ~/chirp_cockroach directory
# start pods and watch files for changes
$ skaffold dev -f examples/skaffold.yaml
# build and deploy once
$ skaffold run -f examples/skaffold.yaml
```
- Create the database for the application (note that in logs you will see web pod crashing)
```bash
# in separate terminal list pods
$ kubectl get pods
# connect to any roach* pod
$ kubectl exec -it roach-pod -- /bin/sh
# connect to sql console
$ cockroach sql --insecure
# create the database
$ CREATE DATABASE chirp_cockroach_dev;
```
Now you can close the terminal used for creating the database

After starting of the Skaffold several things will happen:
- Image of the phoenix app will be built
- Images needed for CockroachDB will be pulled
- Skaffold will use *-deployment.yaml files to create pods in the local cluster.
- when running `scaffold dev` command Skaffold will watch files for changes and if such a change occurs
  application will be rebuilt and redeployed to the local cluster

Kubernetes services that can be found in `./examples/skaffold` folder are configured to run in headless mode.
This change was done by hand, by default `skaffold` generates services with default load balancing and single
Service IP.

It's also possible to use Skaffold for [CI/CD with GitLab](https://skaffold.dev/docs/tutorials/ci_cd/)
### Podman - DevOps
Podman is a daemonless container engine for developing, managing, and running OCI Containers on your Linux System. Containers can either be run as root or in rootless mode.
After [installation](https://podman.io/getting-started/installation), to start the containers described in the file run:
```bash
$ docker-compose up
# in separate terminal or same terminal if `docker-compose up -d` was used
$ podman ps -a
```
Podman can also generate Kubernetes manifests for running containers, to do that use:
```bash
$ podman generate kube -s -f podman.yml [container name]
```
there are examples of such files in `examples/podman` directory.
To start this demo with Podman start all with `podman play kube` in order:
```bash
$ podman play kube ./examples/podman/roach1-deployment.yml
$ podman play kube ./examples/podman/roach2-deployment.yml
$ podman play kube ./examples/podman/roach3-deployment.yml
$ podman play kube ./examples/podman/crdb-init-deployment.yml
$ podman play kube ./examples/podman/web-deployment.yml
```

To stop created services/pods use the same command as about with an additional `--down` flag.
Delete persistent volumes with `podman volume rm [volume]`

### Kubernetes StatefulSet - DevOps
StatefulSet is the workload API object used to manage stateful applications.
Manages the deployment and scaling of a set of Pods, and provides guarantees about the ordering and uniqueness of these Pods.
Like a Deployment, a StatefulSet manages Pods that are based on an identical container spec. Unlike a Deployment, a StatefulSet maintains a sticky identity for each of its Pods. These pods are created from the same spec, but are not interchangeable: each has a persistent identifier that it maintains across any rescheduling.

To deploy the application with CockroachDB StatefulSet follow these instructions:
#### Build an image with Docker
```bash
# in ~/chirp_cockroach
$ docker image build . -t chirp_cockroach_demo --build-arg MIX_ENV="prod" --build-arg PHX_SERVER="TRUE" --build-arg SECRET_KEY_BASE="X7f9dcyrqW2LBuvIxgqh6Oo27K+E7wIpugTv8IENfTM9y3TnCp99AoprFXDcQKwS" --build-arg DATABASE_URL="postgresql://root@cockroachdb.default.svc.cluster.local:26257/chirp_cockroach_dev?sslmode=disable"
```
#### Load image to minikube or kind
```bash
# minikube
$ minikube --profile 'custom' image load chirp_cockroach_dev
# kind
$ kind load docker-image chirp_cockroach_demo
```
#### Setup database cluster
```bash
# in ~/chirp_cockroach/examples/k8s_statefulset
# create headless service
$ kubectl create -f cockroach-headless-sv.yaml
# create pod budget
$ kubectl create -f cockroach-pod-budget.yaml
# create public load balancer
$ kubectl create -f cockroach-public-lb.yaml
# create CockroachDB StatefulSet
$ kubectl create -f cockroach-sts.yaml
```
When stateful set is created pods will have status running but won't be ready.
It's because we have started 3 separate nodes but we haven't initialized the cluster.
To do that run:
```bash
kubectl create -f cluster-init.yaml
```
#### Create database
The difference between docker-compose and skaffold is that when running stateful set no pod/container initializes the cluster and the database for us. We achieved cluster initialization by running a job with the above command. To create the database:
```bash
$ connect to one of the pods
# kubectl exec -it cockroachdb-0 /bin/sh
# connect CockroachDB sql console
$ cockroach sql --insecure
```
Create the database
```psql
CREATE DATABASE chirp_cockroach_dev;
# exit console
$ \q
```
After that, you can disconnect from the pod

#### Setup web application - from minikube local image
```bash
# create service for web app
$ kubectl create -f web-service.yaml
# start application
$ kubectl create -f web-pod-local-image.yaml
```
#### Connecting to the CockroachDB admin console and web application
Start port forwarding for web and cockroach services to be able to access them from
localhost:
```bash
# CockroachDB admin
$ kubectl port-forward service/cockroachdb-public 8080
# web app
$ kubectl port-forward service/web 4000
```
NOTE: `kubectl port-forward` doesn't support multiple forwards so the above commands need to be run from 2 separate terminals.

#### StatefulSet with Skaffold
In folder `./examples/k8s_statefulset` there is file `skaffold.yaml` this is a manifest that can be used with `skaffold dev` and `skaffold run` commands.
From base folder `./chirp_cockroach` run
```bash
$ skaffold dev -f examples/k8s_statefulset/skaffold.yaml
```
#### Cleanup
To delete any minikube resources run:
```bash
$ kubectl delete -f filename.yaml
# stop minikube local cluster
$ minikube stop --profile custom
```
**IMPORTANT** When running StatefulSet by hand and switching to skaffold there might be a possibility that deployment won't succeed the primary reason might be that `cluster-init` job is failing. This happens because when stateful set was created
Persisten Volume Claims were assigned to pods with CockroachDB and the cluster was already
initialized. To avoid this crash comment out `cluster-init.yaml` in the file `./examples/k8s_statefulset/skaffold.yaml` (line 32)

## Helpful links:
- [What is distributed SQL?](https://www.cockroachlabs.com/blog/what-is-distributed-sql/)
- [CockroachDB FAQ](https://www.cockroachlabs.com/docs/stable/frequently-asked-questions.html)
- [CockroachDB Change Data Capture Overview](https://www.cockroachlabs.com/docs/stable/change-data-capture-overview.html)
- [CockroachDB](https://www.cockroachlabs.com/)
- [Elixir](https://elixir-lang.org/)
- [Phoenix](https://phoenixframework.org/)
- [Skaffold](https://skaffold.dev/)
