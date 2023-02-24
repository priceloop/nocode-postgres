#!/bin/sh

set -Eeuo pipefail

amazon-linux-extras install postgresql14
yum -y install postgresql-server postgresql-server-devel postgresql-plpython3 git gcc jq
pip3 install requests

make -C /postgres_extension/functions
make -C /postgres_extension/functions install

# pgbackrest
yum -y install libxml2-devel libyaml-devel lz4-devel libzstd-devel bzip2-devel
mkdir -p /pgbackrest-build
wget -q -O - https://github.com/pgbackrest/pgbackrest/archive/release/2.42.tar.gz | tar zx -C /pgbackrest-build
cd /pgbackrest-build/pgbackrest-release-2.42/src && ./configure && make
cp /pgbackrest-build/pgbackrest-release-2.42/src/pgbackrest /usr/bin/
rm -r /pgbackrest-build
