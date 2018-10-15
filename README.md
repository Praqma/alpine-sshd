# The simplest/smallest SSH Server
This is a very simple alpine based SSHD server, listening on port 22. It has no fancy stuff. Just SSHD service running in foreground. It allows only key based access, and the user is root. Useful as a jump host inside kubernetes clusters, to further connect to your other secure services behind firewall, etc. You can use it for port forwarding, ssh-agent forwarding, etc.

## Security features:
* The user root's password is un-assigned. 
* The only authentication enabled over ssh is key based authentication. Repeat: Password based authentication is disabled.
* The container expects a ENV variable named "AUTHORIZED_KEYS" containing your SSH public key in it. If this ENV var is found empty, this container does not start. This prevents it becoming an open-(ssh)-relay. 

So simply pass your ssh public key as env var AUTHORIZED_KEYS to the container at run time, and you are good to go. You can actually pass multiple SSH public keys by putting them in one file, and then letting the entire file load as a string in this ENV variable. For example:

```
AUTHORIZED_KEYS="$(cat .ssh/my_many_ssh_public_keys_in_one_file.txt)"
```



# Example with key: 
(key is truncated for convenience, of-course)
```
[kamran@kworkhorse alpine-sshd]$ AUTHORIZED_KEYS="ssh-rsa AAAAB3NzaC1yc2JADfoDX5w== kaz@parqma.net"

[kamran@kworkhorse alpine-sshd]$ docker run -e AUTHORIZED_KEYS="${AUTHORIZED_KEYS}" -d praqma/alpine-sshd
a85de77b70a195531570ac45e63a94dd270ad1dd917f3f470daeb9f6a88e2daf

[kamran@kworkhorse alpine-sshd]$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
a85de77b70a1        praqma/alpine-sshd    "/docker-entrypoint.…"   2 seconds ago       Up 2 seconds                            relaxed_fermi
[kamran@kworkhorse alpine-sshd]$ 

[kamran@kworkhorse alpine-sshd]$ docker inspect relaxed_fermi | grep -w IPAddress
            "IPAddress": "172.17.0.2",
                    "IPAddress": "172.17.0.2",

```

Now access this container using ssh:
```
[kamran@kworkhorse alpine-sshd]$ ssh root@172.17.0.2
Welcome to Alpine!

The Alpine Wiki contains a large amount of how-to guides and general
information about administrating Alpine systems.
See <http://wiki.alpinelinux.org>.

You can setup the system with the command: setup-alpine

You may change this message by editing /etc/motd.

a85de77b70a1:~# 
```



# Example without passing the SSH key:
```
[kamran@kworkhorse alpine-sshd]$ docker run  -d praqma/alpine-sshd
32cf51a135275f76f2c1866dbf3c36ee1891b3644b0c2bfa24af510e506e4f24

[kamran@kworkhorse alpine-sshd]$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

[kamran@kworkhorse alpine-sshd]$ docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                            PORTS               NAMES
32cf51a13527        praqma/alpine-sshd    "/docker-entrypoint.…"   9 seconds ago       Exited (1) 8 seconds ago                              fervent_galileo

[kamran@kworkhorse alpine-sshd]$ docker logs fervent_galileo 
Need your ssh public key as AUTHORIZED_KEYS env variable. Abnormal exit ...
[kamran@kworkhorse alpine-sshd]$
```

# Example with wrong / miss-match ssh key:
```
[kamran@kworkhorse alpine-sshd]$ docker run -e AUTHORIZED_KEYS="some random string" -d test/alpine-sshd
f240cea71d36fec8d0a556b97d488ceaf53bcd781d36111695a3225471e6b02f

[kamran@kworkhorse alpine-sshd]$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
f240cea71d36        test/alpine-sshd    "/docker-entrypoint.…"   4 seconds ago       Up 4 seconds        22/tcp              hungry_murdock

[kamran@kworkhorse alpine-sshd]$ ssh root@172.17.0.2
root@172.17.0.2: Permission denied (publickey,keyboard-interactive).
[kamran@kworkhorse alpine-sshd]$ 
```
