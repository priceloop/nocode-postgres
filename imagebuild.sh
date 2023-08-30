#!/bin/sh

set -Eeuox pipefail

amazon-linux-extras install postgresql14
yum -y install postgresql-server postgresql-server-devel postgresql-plpython3 git gcc jq wget tar make xz
pip3 install requests

CPU_COUNT=$(nproc --all)
CMAKE_VERSION=3.18.0
wget https://cmake.org/files/v3.18/cmake-${CMAKE_VERSION}.tar.gz \
 && tar -xvzf cmake-${CMAKE_VERSION}.tar.gz \
 && cd cmake-${CMAKE_VERSION} \
 && ./bootstrap \
 && make -j"$CPU_COUNT" \
 && make install


PLV8_BRANCH=v3.2.0
git clone --branch "$PLV8_BRANCH" --depth 1 https://github.com/plv8/plv8

sed -i 's/cmake -Denable/CXX=clang++ CC=clang cmake -Denable/' plv8/Makefile
make -C plv8 -j"$CPU_COUNT" install

make -C /postgres_extension/functions -j"$CPU_COUNT"
make -C /postgres_extension/functions install

# pgbackrest
yum -y install libxml2-devel libyaml-devel lz4-devel libzstd-devel bzip2-devel
mkdir -p /pgbackrest-build
wget -q -O - https://github.com/pgbackrest/pgbackrest/archive/release/2.42.tar.gz | tar zx -C /pgbackrest-build
cd /pgbackrest-build/pgbackrest-release-2.42/src && ./configure && make
cp /pgbackrest-build/pgbackrest-release-2.42/src/pgbackrest /usr/bin/
rm -r /pgbackrest-build
