FROM registry.access.redhat.com/ubi9-minimal

ARG USER_HOME_DIR="/home/user"

ENV HOME=${USER_HOME_DIR}
ENV BUILDAH_ISOLATION=chroot

COPY --chown=0:0 entrypoint.sh /

RUN microdnf --disableplugin=subscription-manager install -y openssl shadow-utils bash zsh podman buildah skopeo fuse-overlayfs; \
    microdnf update -y ; \
    microdnf clean all ; \
    mkdir -p ${HOME} ; \
    chgrp -R 0 /home ; \
    #
    # Setup for root-less podman
    #
    setcap cap_setuid+ep /usr/bin/newuidmap ; \
    setcap cap_setgid+ep /usr/bin/newgidmap ; \
    touch /etc/subgid /etc/subuid ; \
    chmod +x /entrypoint.sh ; \
    chmod -R g=u /etc/passwd /etc/group /etc/subuid /etc/subgid /home

WORKDIR ${HOME}
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "tail", "-f", "/dev/null" ]