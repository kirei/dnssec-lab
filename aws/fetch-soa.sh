#!/bin/sh

. `dirname $0`/env.sh

COUNT=${LAB_STUDENT_COUNT}

# set tags on all instances
i=$COUNT
while [ $i -gt 0 ]; do
	
	SERVER=ns${i}.${LAB_DOMAIN_NAME}
	DOMAIN=group${i}.${LAB_DOMAIN_NAME}
	
	echo "${DOMAIN}: "`dig +short +time=1 @${SERVER} ${DOMAIN} SOA`
	
	i=`expr $i - 1`
done
