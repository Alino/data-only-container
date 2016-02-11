FROM debian:jessie

RUN apt-get update && apt-get install libssl1.0.0 libssl-dev

RUN echo "create lab80 user and directories" \
    && useradd lab80
    && mkdir /data
    && chown -R lab80:lab80 /data


USER lab80

RUN echo "copy files"
COPY forever.sh /usr/local/bin/
ADD db /data/db
ADD droneio /data/droneio
ADD jenkins /data/jenkins

VOLUME ["/data"]

ENTRYPOINT ["/usr/local/bin/forever.sh"]
