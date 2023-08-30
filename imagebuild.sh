#!/bin/sh

set -Eeuxo pipefail

amazon-linux-extras install postgresql14
yum -y install postgresql-server postgresql-server-devel postgresql-plpython3 git gcc jq wget tar make xz \
               libxml2-devel libyaml-devel lz4-devel libzstd-devel bzip2-devel \
               ncurses-compat-libs


pip3 install requests

cd /
wget https://github.com/Kitware/CMake/releases/download/v3.27.4/cmake-3.27.4-linux-x86_64.tar.gz
tar -xvzf cmake-3.27.4-linux-x86_64.tar.gz
export PATH="/cmake-3.27.4-linux-x86_64/bin:${PATH}"

CPU_COUNT=$(nproc --all)

PLV8_BRANCH=v3.2.0
mkdir -p /build/
cd /build
git clone --branch "$PLV8_BRANCH" --depth 1 https://github.com/plv8/plv8

sed -i 's/cmake -Denable/CXX=clang++ CC=clang cmake -Denable/' plv8/Makefile
make -C plv8 -j"$CPU_COUNT" plv8_config.h
make -C plv8 -j"$CPU_COUNT" install
make -C /postgres_extension/functions -j"$CPU_COUNT"
make -C /postgres_extension/functions -j"$CPU_COUNT" install

# pgbackrest
mkdir -p /pgbackrest-build
wget -q -O - https://github.com/pgbackrest/pgbackrest/archive/release/2.42.tar.gz | tar zx -C /pgbackrest-build
cd /pgbackrest-build/pgbackrest-release-2.42/src && ./configure && make
cp /pgbackrest-build/pgbackrest-release-2.42/src/pgbackrest /usr/bin/
rm -r /pgbackrest-build
