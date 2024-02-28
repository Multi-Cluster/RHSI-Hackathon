#!/usr/bin/env bash

#################################
# include the -=magic=-
# you can pass command line args
#
# example:
# to disable simulated typing
# . ../demo-magic.sh -d
#
# pass -h to see all options
#################################
. $HOME/bin/demo-magic.sh

. ./setup-east.sh

########################
# Configure the options
########################

#
# speed at which to simulate typing. bigger num = faster
#
# TYPE_SPEED=20

#
# custom prompt
#
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
#
#DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"
# Display git branch in prompt
DEMO_PROMPT=$PS1


# text color
# DEMO_CMD_COLOR=$BLACK

# hide the evidence
clear

# enters interactive mode and allows newly typed command to be executed
cmd

pe "oc new-project east"

pe "oc apply -f yaml/backend.yaml"

pe "oc get svc,pods"

pe "skupper init --site-name east --enable-console --enable-flow-collector --console-auth=internal --console-user=admin --console-password=password"

pe "watch oc get svc,pods"

pe "skupper token create --token-type cert east-token.yaml"

echo "*** Move to WEST ***"

pe "skupper expose deployment backend --port 8080"

# pe "oc new-project east"

# pe "skupper init --site-name east --enable-console --enable-flow-collector --console-auth=internal --console-user=admin --console-password=password"

# pe "watch oc get svc,pods"

# pe "skupper token create --token-type cert east.yaml"

# pe "oc apply -f yaml/backend.yaml"

# pe "skupper expose deployment backend --port 8080"
