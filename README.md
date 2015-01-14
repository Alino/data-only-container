Data Only Container
--------------------

This is a data-only Docker image. concept in two lines. first line is for running data only container.
```
$ docker run --name mongodb-data --entrypoint /bin/echo mongodb Data-only container for mongodb
```

And second line is for running mongodb
```
$ docker run -p 27017 --name mongodb --volumes-from mongodb-data mongodb:latest
```

Read [this](http://container42.com/2014/11/03/docker-indepth-volumes/) and take a look at [Docker Volume Manager](https://github.com/cpuguy83/docker-volumes)




## Building this image

1. from dockerfile

`docker build -t your_name/data-only-container .` and then `docker push your_name/data-only-container` (assumes that you are running boot2docker locally)

2. from other base image

```
$ docker run -i -t ubuntu /bin/bash
root@215d2696e8ad:/# sudo apt-get install -y graphviz
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following extra packages will be installed:
...
root@215d2696e8ad:/# exit

$ docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED              STATUS                     PORTS               NAMES
215d2696e8ad        ubuntu:14.04        /bin/bash     About a minute ago   Exited

$ docker commit 215d2696e8ad your_name/data-only-container
c5ad7718fc0e20fe4bf2c8a9bfade4db8617a25366ca5b64be2e1e8aa0de6e52
$ sudo docker push your_name/data-only-container
```

## Mongodb

run the container first `docker run --name mongodb-data your_name/data-only-container`. 


there is db/mongodb.conf file

```
port=27017
quiet=true
dbpath=/data/db
logpath = /data/log/mongod.log
logappend=true
journal=true
```

And in this image's dockerfile has volume.
```
RUN echo "copy files"
COPY forever.sh /usr/local/bin/
ADD db /data/db
ADD droneio /data/droneio

VOLUME ["/data"]
```


So, you can mount this image in other mongodb image as follows.

```
EXPOSE 27017
EXPOSE 28017

ENTRYPOINT ["mongod", "-f", "/data/db/mongodb.conf"]
```

And run the mongodb image

```
cd docker-env-data
docker build -t data .
docker run -d --name data data tail -f /dev/null
docker run -d -p 43153:27017 \
--name "mongo" \
--restart=always \
--volumes-from data \
jaigouk/docker-volt-mongodb
```


## Usefull resources

* [MoinMoin in Production on CoreOS - Part6: Further thinking Data Volume Container](https://masato.github.io/2014/10/20/docker-moinmoin-idcf-coreos-volumes-further-thinking/)

* [Creating a data volume container with fleet](https://masato.github.io/2014/11/03/creating-a-data-volume-container-with-fleet/)

* [MoinMoin - data volume container](https://masato.github.io/tags/DataVolumeContainer/)

* [How to correctly remove volume directories from Docker](https://masato.github.io/2014/11/05/how-to-correctly-remove-volume-directories/)

* [Docker In-depth: Volumes](http://container42.com/2014/11/03/docker-indepth-volumes/)

* [Data-only container madness](http://container42.com/2014/11/18/data-only-container-madness/)


## Further considerations

#### Sync gateway
https://tleyden.github.io/blog/2014/12/15/running-a-sync-gateway-cluster-under-coreos-on-aws/

#### Ceph
[Deis](http://docs.deis.io/en/latest/understanding_deis/components/#store) is using Ceph. [Ceph](http://ceph.com/) is a distributed object store and file system designed to provide excellent performance, reliability and scalability.

From [coreos-dev google group](https://groups.google.com/forum/#!topic/coreos-dev/s-E4sa9VxsA), I found [docker-ceph](https://github.com/ulexus/docker-ceph). And [some commits from deis](https://github.com/deis/deis/pull/1754) shows how they applied ceph. It seems that docker-ceph can be a [good starting point](https://github.com/Ulexus/docker-ceph/blob/master/ceph-mon/Dockerfile) to use it.

[Ceph, Docker, Heroku Slugs, CoreOS and Deis Overview](http://www.slideshare.net/llorieri/deis-41033421)

[google search results on this subject](https://www.google.com/search?q=coreos+stateful+containers&oq=coreos+stateful+containers&aqs=chrome..69i57j69i60.1506j0j7&sourceid=chrome&es_sm=119&ie=UTF-8#q=coreos+stateful+containers&newwindow=1&tbas=0)

https://stackoverflow.com/questions/25753451/move-docker-data-volume-containers-between-coreos-hosts

