#!/bin/bash
# add to anyuid terible idea
oc adm policy add-scc-to-user anyuid -z default
# oc apply -f postgres-scc.yml
##oc adm policy add-scc-to-user postgres-scc -z default