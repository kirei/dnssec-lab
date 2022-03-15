# DNSSEC Training


## Introduction

You as a student will have two servers. One will be configured to be the
resolver and the other will be the name server hosting your zone.

-   resolverX.lab.nxdomain.se
-   nsX.lab.nxdomain.se

*X* is the group number given to you by the teacher. The IP-addresses of
the resolver and the name server are configured directly in the
*lab.nxdomain.se* zone, and can be used from the beginning.

You will also be working with the domain *groupX.lab.nxdomain.se*. This domain
is however not present in DNS yet, because that will happen later in the
lab.


## Lab environment

The default lab servers will be runnning [Fedora Linux](https://getfedora.org/). The lab should also work mostly out-of-the-box with RedHat, Rocky and CentOS.

The default editor will `vi`. If you do not feel comfortable using `vi`, you can install [`nano`](https://www.nano-editor.org/) using `sudo dnf install nano`.

N.B. Most commands in the lab should be run as `root` and it is therefore recommended that you start each session with `sudo bash`.


### Connecting to a Server

Use an SSH client (such as OpenSSH or PuTTY) to connect to your servers.
The private key will be given to you by the teacher.

**OpenSSH**

    chmod 400 student.pem
    ssh -i student.pem fedora@ADDRESS

**PuTTY**

- Install the [latest version of Putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)
- Convert the key to PuTTY format using the PuTTYgen, save the result
  to student.ppk
- Enter address to server.
- Use the student.ppk for authentication and log in as the user "fedora".


### Documentation

Documentation can be found online at [Knot DNS](https://www.knot-dns.cz/documentation/).


### Get Started

Let's get started by installing a secure resolver:

- [Setup a Secure Resolver using BIND](recursive-bind.md)
- [Setup a Secure Resolver using Unbound](recursive-unbound.md)
