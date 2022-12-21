FROM postgres:14

RUN apt-get update && apt-get -y install git make gcc python3-pip postgresql-plpython3-14 postgresql-server-dev-14
RUN pip3 install requests

# install postgres extension source code

COPY postgres_extension /postgres_extension/

# build and install custom postgres extension
RUN make -C /postgres_extension/functions
RUN make -C /postgres_extension/functions install

