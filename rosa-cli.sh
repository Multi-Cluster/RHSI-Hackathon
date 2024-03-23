rosa create idp --cluster=rosa-kzp2h --type htpasswd  --from-file ./passwordfile --name Hackathon
# delete the users from the clusters if they are already bound to any other IDP, in this case IDP name is hackathon
# oc delete user cluster-admin admin red blue green yellow orange purple hack-admin
