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


### Connecting to a Server

Use an SSH client (such as OpenSSH or PuTTY) to connect to your servers.
The private key will be given to you by the teacher.

**OpenSSH**

    chmod 400 student.pem
    ssh -i student.pem fedora@ADDRESS

**PuTTY**

-   Convert the key to PuTTY format using the PuTTYgen, save the result
    to student.ppk
-   Enter address to server.
-   Use the student.ppk for authentication and log in as the user "fedora".


### Documentation

Documentation can be found online at [Knot DNS](https://www.knot-dns.cz/documentation/).


### Get Started

Let's get started by installing a secure resolver:

- [Setup a Secure Resolver using BIND](recursive-bind.md)
- [Setup a Secure Resolver using Unbound](recursive-unbound.md)
