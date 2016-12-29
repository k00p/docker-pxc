FROM debian:jessie

MAINTAINER Peter Szalatnay <theotherland@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive PERCONA_MAJOR=57

RUN \
    groupadd -r mysql && useradd -r -g mysql mysql \
    #&&  export http_proxy='http://<user>:<pass>@<proxy>' \
    #&&  export https_proxy='https://<user>:<pass>@<proxy>' \
    && apt-get update && apt-get install -y curl lsb-release \
    && curl -LO https://repo.percona.com/apt/percona-release_0.1-4.$(lsb_release -sc)_all.deb \
    && dpkg -i percona-release_0.1-4.$(lsb_release -sc)_all.deb \
    && apt-get update && apt-get install -y \
        percona-xtradb-cluster-${PERCONA_MAJOR} \
        sysbench \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/mysql \
    && mkdir /var/lib/mysql \
    && sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf \
    && echo 'skip-host-cache\nskip-name-resolve' | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf \
    && mv /tmp/my.cnf /etc/mysql/my.cnf \
    && mkdir -p /opt/rancher \
    && curl -SL https://github.com/cloudnautique/giddyup/releases/download/v0.14.0/giddyup -o /opt/rancher/giddyup \
    && chmod +x /opt/rancher/giddyup

COPY ./start_pxc /opt/rancher

COPY ./docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

VOLUME ["/var/lib/mysql", "/run/mysqld", "/etc/mysql/conf.d"]

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3306 4444 4567 4568

CMD ["mysqld"]
