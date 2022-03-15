# Knot DNSSEC Lab

N.B. As Knot is a bit picky about ordering, remember to add all configuration sections in the order in which they appear in the instructions below.

## Creating a Policy

We will create a KASP policy named "lab-p256". It uses ridiculously low values on the timing parameters, just so that key rollovers will go faster in this lab environment.

1. Open the knot configuration file:

        vi /etc/knot/knot.conf

2. First we define a keystore "default" using the "pem" backend. This will keep a keys on disk.

        keystore:
          - id: default
            backend: pem


3. Now we will define a DNSSEC signing policy (KASP):

        policy:
          - id: lab_p256
            algorithm: ECDSAP256SHA256
            ksk-lifetime: 0
            zsk-lifetime: 30m
            keystore: default
            dnskey-ttl: 300
            rrsig-lifetime: 15m
            rrsig-refresh: 5m
            rrsig-pre-refresh: 1m
            propagation-delay: 0

4. Save and exit.

5. Verify that the configuration is valid:

        knotc conf-check

6. Reload the new configuration:

        knotc reload


## Create Template for Signed Zones

Before we can enable zone signing, we will create a new zone template that refers to our recently defined KASP policy.

1. Open the knot configuration file:

        vi /etc/knot/knot.conf

2. Add the following entry to the `template` section:

        template:
         - id: signed
           storage: "/var/lib/knot"
           file: "%s.zone"
           serial-policy: unixtime
           journal-content: all
           zonefile-load: difference-no-serial
           semantic-checks: true
           dnssec-signing: on
           dnssec-policy: lab_p256

3. Save and exit.

4. Verify that the configuration is valid:

        knotc conf-check

5. Reload the new configuration:

        knotc reload

## Enable Zone Signing

In order to activate signing, configure the lab zone to use the `signed` template:

1. Open the knot configuration file:

        vi /etc/knot/knot.conf

2. Add the template to the zone:

        zone:
          - domain: groupX.lab.nxdomain.se
            template: signed
            acl: [acl_localhost]

3. Save and exit.

4. Verify that the configuration is valid:

        knotc conf-check

5. Perform a zone transfer (AXFR) and verify the zone is not yet signed:

        dig @127.0.0.1 groupX.lab.nxdomain.se axfr

6. Reload the new configuration:

        knotc reload

7. Perform another zone transfer (AXFR) and verify the zone is now signed:

        dig @127.0.0.1 groupX.lab.nxdomain.se axfr

    You can also look at the signed zone file on disk:
    
        cat /var/lib/knot/groupX.lab.nxdomain.se.zone

8. Also check that DNSSEC records are correctly served for this zone:

        dig @127.0.0.1 groupX.lab.nxdomain.se SOA +dnssec


## Publishing the DS RR

The zone is now signed and we have verified that DNSSEC is working. It is now time to publish the DS RR.

1. Wait until the KSK is ready to be published in the parent zone. This is indicated by the timestamp `ready` being non-zero:

        keymgr groupX.lab.nxdomain.se list

2. Show the DS RRs that we are about to publish. Notice that they share the key tag with the KSK:

        keymgr groupX.lab.nxdomain.se ds

3. Ask your teacher to update the DS in the parent zone.

4. Wait until the DS has been uploaded. Check the DS with the following command:

        dig @ns.lab.nxdomain.se groupX.lab.nxdomain.se DS

5. As of now, we must manually tell the signer that the KSK has been submitted. Later on we will configure the signer to automatically scan for new DS records. After the signer knows the DS is in place at the parent, the initial key usage period will commence.

        knotc zone-ksk-submitted groupX.lab.nxdomain.se

6. Verify that we can query the zone from the *resolver* machine.
   The AD-flag should be set:

        dig @127.0.0.1 +dnssec www.groupX.lab.nxdomain.se


## Manual KSK Rollover

The KSK rollover is usually done at the end of its lifetime. But a key rollover can be forced before that by issuing the rollover command.

Our KASP policy is configured to not perform KSK rollovers automatically, but we can still request one manually:

1. Initiate a KSK rollover:

        knotc zone-key-rollover groupX.lab.nxdomain.se ksk

2. Check that the new KSK has been generated:

        keymgr groupX.lab.nxdomain.se list

3. Show the DS RRs that we are about to publish. Notice that they share the key tag with the KSK:

        keymgr groupX.lab.nxdomain.se ds

4. Ask your teacher to update the DS in the parent zone.

5. Wait until the DS has been uploaded. Check the DS with the following command:

        dig @ns.lab.nxdomain.se groupX.lab.nxdomain.se DS

6. As of now, we must manually tell the signer that the KSK has been submitted. Later on we will configure the signer to automatically scan for new DS records.

        knotc zone-ksk-submitted groupX.lab.nxdomain.se

    If the KSK is not yet ready to be submitted, you must wait a bit and try again later.
    
7. After the KSK has been submitted, check the key list and not that the old KSK has been removed.

        keymgr groupX.lab.nxdomain.se list


## Manual ZSK Rollover

The ZSK rollover is usually done at the end of its lifetime. But a key rollover can be forced before that by issuing the rollover command.

Our KASP policy is configured to perform ZSK rollovers automatically, but we can still request one manually:

1. Initiate a ZSK rollover:

        knotc zone-key-rollover groupX.lab.nxdomain.se zsk

2. Check that the new ZSK has been generated:

        keymgr groupX.lab.nxdomain.se list
  
3. After some time, the new ZSK is active and the old ZSK is removed:

        keymgr groupX.lab.nxdomain.se list


## Automatic KSK Rollover

1. Open the knot configuration file:

        vi /etc/knot/knot.conf

2. Add remote and submission sections for a resolver to be used for DS submission checks. In this lab we will use Google Public DNS.

        remote:
          - id: resolver
            address: 8.8.8.8

        submission:
          - id: test_submission
            check-interval: 10s
            parent: resolver

   Note that the `remote` and `submission` sections must be inserted before the `policy` section.

3. Now update our KASP policy to rotate KSK every hour and to check KSK submission using our new submission configuration:

        policy:
          - id: lab_p256
            ksk-lifetime: 1h
            ksk-submission: test_submission

4. Save and exit.

5. Verify that the configuration is valid:

        knotc conf-check

6. Reload the new configuration:

        knotc reload

7. Initiate a KSK rollover:

        knotc zone-key-rollover groupX.lab.nxdomain.se ksk

8. Check that the new KSK has been generated:

        keymgr groupX.lab.nxdomain.se list

9. Show the DS RRs that we are about to publish. Notice that they share the key tag with the KSK:

        keymgr groupX.lab.nxdomain.se ds

10. Ask your teacher to update the DS in the parent zone.

11. Once the new DS record has been published, the signer will automatically start using the new KSK. Check that the old key is now marked for removal.

        dig @ns.lab.nxdomain.se groupX.lab.nxdomain.se DS


## Signing with NSEC3

1. Open the knot configuration file:

        vi /etc/knot/knot.conf

2. Update the KASP policy to sign with NSEC3:

        policy:
          - id: lab_p256
            nsec3: true
            nsec3-iterations: 0

   Guidance on recommended NSEC3 parameter settings can be found in [draft-hardaker-dnsop-nsec3-guidance-03](https://datatracker.ietf.org/doc/html/draft-hardaker-dnsop-nsec3-guidance-03). The default number of iterations in Knot is 10, but we choose to use the newer recommendation (0) from the draft.

4. Save and exit.

5. Verify that the configuration is valid:

        knotc conf-check

6. Reload the new configuration:

        knotc reload

7. Perform a zone transfer (AXFR) and verify the zone is now signed with NSEC3:

        dig @127.0.0.1 groupX.lab.nxdomain.se axfr



---
Next Section: [Testing](testing.md)
