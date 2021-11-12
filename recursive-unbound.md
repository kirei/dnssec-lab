# Setup a Secure Resolver using Unbound

The purpose of the lab is to setup the resolver on the first server. You
should install only one of the resolvers -- not all of them.

1.  Connect to the server (resolverX.lab.nxdomain.se) by using SSH or PuTTY.

2.  Change the host name.

        hostnamectl set-hostname resolverX.lab.nxdomain.se

3.  Login and logout to get an updated command prompt.

4.  Upgrade base operating system:

        dnf upgrade

5.  Uninstall BIND if previously installed:

        dnf remove bind

6.  Install Unbound as the resolver. Also install `bind-utils` for `dig(1)`:

        dnf install openssl unbound bind-utils

7.  Enable and start Unbound:

        systemctl enable --now unbound

8.  Verify by using dig. Notice that the AD-flag is set.

        dig @127.0.0.1 +dnssec www.knot-dns.cz

9.  Also try resolving a domain where DNSSEC is broken.

        dig @127.0.0.1 www.trasigdnssec.se

    But we can see that in fact the domain does contain the information if we bypass the DNSSEC validation:

        dig @127.0.0.1 +cd +dnssec www.trasigdnssec.se



---
Next Section: [Install Knot](knot-install.md)
