FROM postgres:14

RUN apt-get update && apt-get -y install git make gcc python3-pip postgresql-plpython3-14 postgresql-server-dev-14
RUN pip3 install boto3 requests

# install postgres extension source code

COPY postgres_extension /postgres_extension/

# build and install custom postgres extension
RUN make -C /postgres_extension/functions
RUN make -C /postgres_extension/functions install

# clone, build and install aws-s3 postgres extension
RUN mkdir -p /postgres_extension/postgres-aws-s3 && \
    cd /postgres_extension/postgres-aws-s3 && \
    git init && \
    git remote add origin https://github.com/chimpler/postgres-aws-s3 && \
    git fetch --depth 1 origin 4f601abf6960e929db672b46161fcc4313b80959 && \
    git checkout FETCH_HEAD
RUN make -C /postgres_extension/postgres-aws-s3
RUN make -C /postgres_extension/postgres-aws-s3 install
