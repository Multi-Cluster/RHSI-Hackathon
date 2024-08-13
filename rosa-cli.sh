rosa create idp --cluster=`rosa list clusters | awk -F " " '{print $2}' | grep -v NAME` --type htpasswd  --from-file ./passwordfile --name Hackathon
# delete the users from the clusters if they are already bound to any other IDP, in this case IDP name is hackathon
# oc delete user cluster-admin admin red blue green yellow orange purple hack-admin
rosa edit machinepool worker -c `rosa list clusters --output json | jq -r '.[].name'` --replicas=10
