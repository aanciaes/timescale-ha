docker network create my-network --driver bridge

docker build -t timescale-ha .

docker run --rm --name pg-0 \
  --network my-network \
  --env REPMGR_PARTNER_NODES=pg-0,pg-1 \
  --env REPMGR_NODE_NAME=pg-0 \
  --env REPMGR_NODE_NETWORK_NAME=pg-0 \
  --env REPMGR_PRIMARY_HOST=pg-0 \
  --env REPMGR_PASSWORD=repmgrpass \
  --env POSTGRESQL_PASSWORD=secretpass \
  --env POSTGRESQL_SHARED_PRELOAD_LIBRARIES=repmgr,pgaudit,timescaledb \
  timescale-ha
  
docker run --rm --name pg-1 \
  --network my-network \
  --env REPMGR_PARTNER_NODES=pg-0,pg-1 \
  --env REPMGR_NODE_NAME=pg-1 \
  --env REPMGR_NODE_NETWORK_NAME=pg-1 \
  --env REPMGR_PRIMARY_HOST=pg-0 \
  --env REPMGR_PASSWORD=repmgrpass \
  --env POSTGRESQL_PASSWORD=secretpass \
  --env POSTGRESQL_SHARED_PRELOAD_LIBRARIES=repmgr,pgaudit,timescaledb \
  timescale-ha

# TODO: Check for these authentication user/passwords. What are all these, are they all needed?
docker run --rm --name pgpool \
  --network my-network \
  --env PGPOOL_BACKEND_NODES=0:pg-0:5432,1:pg-1:5432 \
  --env PGPOOL_SR_CHECK_USER=repmgr \
  --env PGPOOL_SR_CHECK_PASSWORD=repmgrpass \
  --env PGPOOL_ENABLE_LDAP=no \
  --env PGPOOL_POSTGRES_USERNAME=postgres \
  --env PGPOOL_POSTGRES_PASSWORD=secretpasss \
  --env PGPOOL_ADMIN_USERNAME=postgres \
  --env PGPOOL_ADMIN_PASSWORD=secretpasss \
  -p 5432:5432 \
  bitnami/pgpool:latest


docker exec -it /opt/bitnami/scripts/postgresql-repmgr/entrypoint.sh /bin/bash

# TODO: Volumes for data persistence - -v /path/to/postgresql-repmgr-persistence:/bitnami/postgresql \
# TODO: Test that restart with data persitance wont wipe all data
# TODO: Test with IP's instead of names
# TODO: Test on cloud with diferent machine locations
# TODO: Should we have pg_pool for load balacing?
# TODO: Test how to add nodes
# TODO: Test how to detach nodes
# TODO: Test how to rejoin nodes
# TODO: Document everything here