#! /bin/bash
oc new-project west
oc apply -f yaml/ --recursive
