# README

## What 

This repo deploys 2 on cluster postgres setup with client side tls

## Useage

Run the script 
```bash
chmod 750 create-crt.sh
./create-crt.sh
```
certs will be genetated in the project root directory.
```bash
-rw-r--r--. 1 austincunningham austincunningham  993 Nov 12 15:24 client.crt
-rw-r--r--. 1 austincunningham austincunningham  899 Nov 12 15:24 client.csr
-rw-------. 1 austincunningham austincunningham 1704 Nov 12 15:24 client.key
-rw-r--r--. 1 austincunningham austincunningham 1107 Nov 12 15:24 rootCA.crt
-rw-------. 1 austincunningham austincunningham 1704 Nov 12 15:24 rootCA.key
-rw-r--r--. 1 austincunningham austincunningham   41 Nov 12 15:24 rootCA.srl
-rw-r--r--. 1 austincunningham austincunningham  993 Nov 12 15:24 server.crt
-rw-r--r--. 1 austincunningham austincunningham  899 Nov 12 15:24 server.csr
-rw-------. 1 austincunningham austincunningham 1704 Nov 12 15:24 server.key
-rw-r--r--. 1 austincunningham austincunningham  993 Nov 12 15:24 client.crt
-rw-r--r--. 1 austincunningham austincunningham  899 Nov 12 15:24 client.csr
-rw-------. 1 austincunningham austincunningham 1704 Nov 12 15:24 client.key
```
A secret will be created from these certs
SCC will be setup
And 2 postgres with servces will be set up in the posgres namespace

## 3scale setup
You can setup your 3scale system-database and zync secrets in the 3scale-test ns with the following commands
e.g. zync
```bash
oc create secret generic zync \
  --namespace=3scale-test \
  --from-literal=DATABASE_SSL_MODE=verify-ca \
  --from-literal=DATABASE_URL=postgresql://postgres:postgres@postgres-zync.postgres.svc.cluster.local/zync_production \
  --from-literal=ZYNC_DATABASE_PASSWORD=password \
  --from-file=DB_SSL_CA=rootCA.crt \
  --from-file=DB_SSL_CERT=client.crt \
  --from-file=DB_SSL_KEY=client.key \
  --labels=app=3scale-api-management,threescale_component=zync
```
e.g. system-database 
```bash
oc create secret generic system-database \
  --from-literal=DATABASE_SSL_MODE=verify-ca \
  --from-literal=URL=postgresql://postgres:postgres@postgres-zync.postgres.svc.cluster.local/zync_production \
  --from-literal=DB_USER=postgres \
  --from-literal=DB_PASSWORD=postgres \
  --from-file=DB_SSL_CA=rootCA.crt \
  --from-file=DB_SSL_CERT=client.crt \
  --from-file=DB_SSL_KEY=client.key \
  --labels=app=3scale-api-management,threescale_component=system
```
set your passwords as you wish using postgres above as an example
