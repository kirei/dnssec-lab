# Install Knot

1.  Connect to the server (nsX.lab.nxdomain.se) by using SSH or PuTTY.

2.  Change the host name:

        hostnamectl set-hostname nsX.lab.nxdomain.se

3.  Logout and login to get an updated command prompt.

4.  Upgrade base operating system:

        dnf upgrade

5.  On RedHat, CentOS and Rocky, install [EPEL](https://docs.fedoraproject.org/en-US/epel/):

        dnf install epel-release

    Not needed here since we're using Fedora Linux.

6.  Enable Knot repostory:

        dnf install 'dnf-command(copr)'
        dnf copr enable @cznic/knot-dns-latest

7.  Install Knot. Also install `bind-utils` for `dig(1)`:

        dnf install knot knot-utils bind-utils

8.  Ensure that Knot has a reasonable default configuration:

        vi /etc/knot/knot.conf

    Add:
    
        server:
            rundir: "/run/knot"
            user: knot:knot
            listen: [ 0.0.0.0@53, ::@53 ]

        log:
          - target: syslog
            any: info

        database:
            storage: "/var/lib/knot"

        acl:
          - id: acl_localhost
            address: 127.0.0.1
            action: transfer

        template:
          - id: default
            storage: "/var/lib/knot"
            file: "%s.zone"

9.  Check that the configuration is valid:

        knotc conf-check

10. Disable `systemd-resolved(8)` as it might interfer with Knot:

        systemctl disable systemd-resolved
        systemctl stop systemd-resolved

11. Enable and start Knot:

        systemctl enable knot
        systemctl start knot

12.  Check that knot is running:

        systemctl status knot


---
Next Section: [Publish unsigned zone using Knot](publish-unsigned.md)
