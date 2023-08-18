FROM postgres:14

RUN apt-get update && \
    apt install -y \
    wget \
    libtinfo5 \
    build-essential \
    pkg-config \
    libstdc++-12-dev \
    cmake \
    git \
    make \
    gcc \
    python3-pip \
    python3-requests \
    python3-boto3 \
    postgresql-plpython3-14 \
    postgresql-server-dev-14

ARG PLV8_BRANCH=r3.2
ENV PLV8_BRANCH=${PLV8_BRANCH}
ARG PLV8_VERSION=3.2.0
ENV PLV8_VERSION=${PLV8_VERSION}
RUN set -ex && \
    git clone --branch ${PLV8_BRANCH} https://github.com/plv8/plv8 /plv8

RUN cd /plv8 && \
    make install && \
    strip /usr/lib/postgresql/${PG_MAJOR}/lib/plv8-${PLV8_VERSION}.so

# install our own postgres extension source code
COPY postgres_extension /postgres_extension/

# build and install custom postgres extension
RUN make -C /postgres_extension/functions
RUN make -C /postgres_extension/functions install

RUN git clone https://github.com/chimpler/postgres-aws-s3.git /postgres-aws-s3 && \
    make -C /postgres-aws-s3 install
