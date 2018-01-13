#!/bin/bash
for svc in *-svc.yaml
do
  echo -n "Creating $svc... "
  #kubectl -f $svc create
done
