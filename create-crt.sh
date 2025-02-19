#!/bin/bash

# Root CA Certificate
openssl genpkey -algorithm RSA -out rootCA.key -pkeyopt rsa_keygen_bits:2048
openssl req -x509 -new -key rootCA.key -days 365 -out rootCA.crt -subj "/CN=RootCA"

# Server Certificate
openssl genpkey -algorithm RSA -out server.key -pkeyopt rsa_keygen_bits:2048
openssl req -new -key server.key -out server.csr -subj "/CN=PostgresServer"
openssl x509 -req -in server.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out server.crt -days 365

# Client Certificate
openssl genpkey -algorithm RSA -out client.key -pkeyopt rsa_keygen_bits:2048
openssl req -new -key client.key -out client.csr -subj "/CN=PostgresClient"
openssl x509 -req -in client.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out client.crt -days 365

# create postgres ns
oc new-project postgres

# setup scc
# add to anyuid to default is a bad idea and not to be copied in production
oc adm policy add-scc-to-user anyuid -z default

# create server side secret
kubectl create secret generic postgres-tls \
    --from-file=server.crt=server.crt \
    --from-file=server.key=server.key \
    --from-file=rootCA.crt=rootCA.crt

# deploy the postgres
oc apply -f postgres.yml
oc apply -f postgres-zync.yml

oc wait --for=condition=Ready pod -l app=postgres-zync --timeout=60s && \
oc exec -it $(kubectl get pod -l app=postgres-zync -o jsonpath='{.items[0].metadata.name}') -- psql -U postgres -c "CREATE DATABASE zync_production;"


