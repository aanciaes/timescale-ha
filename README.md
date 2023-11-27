# Highly Available Timescale 

## How to Run Locally

1. Create a network

```
docker network create my-network --driver bridge
```

2. Build the images

```
docker build -t timescale-ha .
```

3. Run the primary node

```
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
```

4. Run the standby node

```
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
```

5. Repeat step 4 with the ammount of standby nodes required

6. Run the proxy

```
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
```

## TODOs


1. Check for these authentication user/passwords. What are all these, are they all needed?
2. Volumes for data persistence - `-v /path/to/postgresql-repmgr-persistence:/bitnami/postgresql`
3. Test that restart with data persitance wont wipe all data
4. Test with IP's instead of names
5. Test on cloud with diferent machine locations
6. Should we have pg_pool for load balacing?
7. Test how to add nodes
8. Test how to detach nodes
9. Test how to rejoin nodes
10. Document everything here

## Replication Manager useful commands:

- Start a bash
```
docker exec -it /opt/bitnami/scripts/postgresql-repmgr/entrypoint.sh /bin/bash
```
