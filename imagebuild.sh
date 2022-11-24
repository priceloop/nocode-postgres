#!/bin/sh

set -Eeuo pipefail

amazon-linux-extras install postgresql14
yum -y install postgresql-server postgresql-server-devel postgresql-plpython3 git gcc jq
pip3 install boto3 requests

make -C /postgres_extension/functions
make -C /postgres_extension/functions install

mkdir -p /postgres_extension/postgres-aws-s3
cd /postgres_extension/postgres-aws-s3
git init
git remote add origin https://github.com/chimpler/postgres-aws-s3
git fetch --depth 1 origin 4f601abf6960e929db672b46161fcc4313b80959
git checkout FETCH_HEAD

make -C /postgres_extension/postgres-aws-s3
make -C /postgres_extension/postgres-aws-s3 install

# pgbackrest
yum -y install libxml2-devel libyaml-devel lz4-devel libzstd-devel bzip2-devel
mkdir -p /pgbackrest-build
wget -q -O - https://github.com/pgbackrest/pgbackrest/archive/release/2.42.tar.gz | tar zx -C /pgbackrest-build
cd /pgbackrest-build/pgbackrest-release-2.42/src && ./configure && make
cp /pgbackrest-build/pgbackrest-release-2.42/src/pgbackrest /usr/bin/
rm -r /pgbackrest-build
