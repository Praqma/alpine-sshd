FROM alpine:latest

# ssh-keygen -A generates all necessary host keys (rsa, dsa, ecdsa, ed25519) at default location.
RUN    apk update \
    && apk add openssh \
    && mkdir /root/.ssh \
    && chmod 0700 /root/.ssh \
    && ssh-keygen -A 

# This image expects AUTHORIZED_KEYS environment variable to contain your ssh public key.

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

# -D in CMD below prevents sshd from becoming a daemon. -e is to log everything to stderr.
CMD ["/usr/sbin/sshd", "-D", "-e"]


