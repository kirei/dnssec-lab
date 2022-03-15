# Publish unsigned zone using Knot

1.  Connect to the server (nsX.lab.nxdomain.se) by using SSH or PuTTY.

2.  Create a zone named after your group:

        vi /var/lib/knot/groupX.lab.nxdomain.se.zone

    File contents:

        $ORIGIN groupX.lab.nxdomain.se.
        $TTL 60
        @ IN SOA nsX.lab.nxdomain.se. test.lab.nxdomain.se. (
                 1    ; serial
                 360  ; refresh (6 minutes)
                 360  ; retry (6 minutes)
                 1800 ; expire (30 minutes)
                 60   ; minimum (1 minute)
                 )
        @   IN NS nsX.lab.nxdomain.se.
        www IN CNAME nsX.lab.nxdomain.se.

3.  Add the zone to Knot:

        vi /etc/knot/knot.conf

    Add:
    
        zone:
          - domain: groupX.lab.nxdomain.se

4. Check that the configuration is valid:

        knotc conf-check

5. Reload the server:

        knotc reload

6. Check that the server answers correctly:

        dig @127.0.0.1 groupX.lab.nxdomain.se soa
        dig @127.0.0.1 groupX.lab.nxdomain.se ns

7.  Try resolving using the default resolver:

        dig groupX.lab.nxdomain.se SOA

8.  Try to perform a local zone transfer:

        dig @127.0.0.1 groupX.lab.nxdomain.se axfr

    This command is expected to fail.

9.  Configure the server to allow zone transfer from localhost:

        zone:
          - domain: groupX.lab.nxdomain.se
            acl: [acl_localhost]

10. Reload the server and try zone transfer once again:

        knotc reload
        dig @127.0.0.1 groupX.lab.nxdomain.se axfr


---
Next Section: [Knot lab](knot-dnssec.md)
