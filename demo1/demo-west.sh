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

. ./setup-west.sh

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

pe "watch oc get pods,svc"

pe "skupper init --site-name west --enable-console --enable-flow-collector --console-auth=internal --console-user=admin --console-password=password"

pe "watch oc get svc,pods"

echo "*** Move to East ***"

pe "skupper link create east.yaml"

pe "skupper network status"

pe "oc scale deployment/backend --replicas=0"