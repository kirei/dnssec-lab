#!/bin/sh
#
# Create student instances

. `dirname $0`/env.sh

export PAGER=cat
AWS="aws --profile ${LAB_AWS_PROFILE} --region ${LAB_EC2_REGION}"

DOMAIN="lab.nxdomain.se"

for TYPE in resolver signer; do
	RUNFILE=/tmp/ec2-student-${TYPE}.$$.tmp

	#cloud-config
	#hostname: mynode
	#fqdn: mynode.example.com
	#manage_etc_hosts: true

	## create all instances
	${AWS} ec2 run-instances \
		--count ${LAB_STUDENT_COUNT} \
		--instance-type ${LAB_EC2_TYPE} \
		--image-id ${LAB_EC2_AMI} \
		--subnet-id ${LAB_EC2_SUBNET_ID} \
		--security-group-ids ${LAB_EC2_SG_ID} \
		--key-name ${LAB_KEYPAIR_STUDENT} \
		> ${RUNFILE}

	# find instance IDs
	INSTANCES=`jq -r '.Instances[].InstanceId' < ${RUNFILE}`

	# set tags on all instances
	i=0
	for INSTANCE in $INSTANCES; do
		echo "Tagging student instance ${INSTANCE} (type ${TYPE})"
		i=`expr $i + 1`
		NAME=${TYPE}${i}
		HOSTNAME="unknown"
		case $TYPE in
			resolver)
				HOSTNAME="resolver${i}.${DOMAIN}"
				;;
			signer)
				HOSTNAME="ns${i}.${DOMAIN}"
				;;
			*)
				HOSTNAME=""
				;;
		esac
		TAG="[ { \"Key\": \"Name\", \"Value\": \"${NAME}\" },
		       { \"Key\": \"Hostname\", \"Value\": \"${HOSTNAME}\" },
		       { \"Key\": \"Domain\", \"Value\": \"${DOMAIN}\" },
		       { \"Key\": \"Type\", \"Value\": \"${TYPE}\" },
		       { \"Key\": \"ID\", \"Value\": \"${i}\" } ]"
		${AWS} ec2 create-tags --resources $INSTANCE --tags "${TAG}"
	done

	# clean up temporary files
	rm -f ${RUNFILE}
done
