#!/bin/sh

set -e

amazon-linux-extras install postgresql14
yum -y install postgresql-server postgresql-server-devel git gcc jq

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
