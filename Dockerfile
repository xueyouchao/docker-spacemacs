### Dockerfile --- spacemacs-docker dockerfile with Emacs25.x
##
## Copyright (c) 2012-2017 Sylvain Benner & Contributors
##
## Author: Eugene "JAremko" Yaremenko <w3techplayground@gmail.com>
##
##
## This file is not part of GNU Emacs.
##
### License: GPLv3
##
## See spacemacs/layers/+distributions/spacemacs-docker/README.org

FROM xueyouchao/docker-emacs:latest
#FROM jare/emacs:latest
# FROM jare/emacs:emacs24
# Emacs snapshot
# FROM jare/emacs:testing

MAINTAINER youchao xue<xueyouchao@gmail.com>

ENV UNAME="spacemacser" \
    UID="1000"

# Default fonts
ENV NNG_URL="https://github.com/google/fonts/raw/master/ofl/\
nanumgothic/NanumGothic-Regular.ttf" \
    SCP_URL="https://github.com/adobe-fonts/source-code-pro/\
archive/2.030R-ro/1.050R-it.tar.gz"
RUN apk --update add wget \
    && mkdir -p /usr/local/share/fonts \
    && wget -qO- "${SCP_URL}" | tar xz -C /usr/local/share/fonts \
    && wget -q "${NNG_URL}" -P /usr/local/share/fonts \
    && fc-cache -fv \
    && apk del wget \
    && rm -rf /tmp/* /var/lib/apt/lists/* /root/.cache/* \
    && apk add coreutils \
    && apk add make \
    && apk add linux-pam \
    && apk add shadow

# UHOME is /home/emacs (from jare/emacs)
ADD . ${UHOME}/.emacs.d

# Init Spacemacs
RUN cp ${UHOME}/.emacs.d/core/templates/.spacemacs.template ${UHOME}/ \
    && mv ${UHOME}/.spacemacs.template ${UHOME}/.spacemacs \
    && sed -i "s/\(-distribution 'spacemacs\)/\1-docker/" \
    ${UHOME}/.spacemacs \
    && asEnvUser emacs -batch -u ${UNAME} -kill \
    && chmod ug+rw -R ${UHOME}

# Test Spacemacs
RUN asEnvUser make -C ${UHOME}/.emacs.d/tests/core/ test \
    && cd ${UHOME}/.emacs.d \
    && printf "SPACEMACS REVISION: %s\n" "$(git rev-parse --verify HEAD)"

RUN ln -s \
    ${UHOME}/.emacs.d/layers/+distributions/spacemacs-docker/deps-install/run \
    /usr/local/sbin/install-deps \
    && chown root:root /usr/local/sbin/install-deps \
    && chmod 770 /usr/local/sbin/install-deps

# Install global dependencies (if any exists)
RUN install-deps

# Entrypoint and deps installation script will recreate it.
RUN userdel $UNAME \
    && groupdel $GNAME
