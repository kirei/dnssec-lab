#!/bin/sh

. `dirname $0`/env.sh

KEYFILE=`dirname $0`/${LAB_KEYPAIR_STUDENT}.pem
SHORTNAME=$1

chmod 600 $KEYFILE
ssh -i $KEYFILE -l ubuntu ${SHORTNAME}.${LAB_DOMAIN_NAME}
