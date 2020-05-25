#!/bin/bash

# Prepare image
apt-get update -y \
&& apt-get install -y vim software-properties-common wget apt-transport-https

add-apt-repository -y "deb https://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" \
&& wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

apt-get update \
&& apt-get install -y --no-install-recommends postgresql-common \
&& echo 'create_main_cluster = false' >> /etc/postgresql-common/createcluster.conf \
&& apt-get install -y --no-install-recommends \
postgresql-12 \
postgresql-12-dbg \
postgresql-12-pgextwlist \
postgresql-client-12 \
postgresql-contrib-12

# Update locale and make dir/files
locale-gen en_US.UTF-8 && update-locale;
mkdir /database && chown postgres /database;
touch /logfile && chown postgres /logfile;
