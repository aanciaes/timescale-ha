FROM bitnami/postgresql-repmgr:15.5.0

USER root

RUN apt update \
    && apt -y install gcc cmake git clang-format clang-tidy openssl libssl-dev \
    && git clone https://github.com/timescale/timescaledb.git

RUN cd timescaledb \
 && git checkout 2.12.1 \
 && ./bootstrap \
 && cd build \
 && make \
 && make install

COPY startup.sql /docker-entrypoint-initdb.d/startup.sql

USER 1001
