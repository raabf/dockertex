FROM mylatex:trusty

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update 

# install texstudio
# (A newer version from the developer, since the version in the
#  standard repository is quite old)
RUN wget -O texstudio.deb http://download.opensuse.org/repositories/home:/jsundermeyer/xUbuntu_14.04/amd64/texstudio_2.12.6-5+5.1_amd64.deb && \
    (dpkg --install ./texstudio.deb || true) && \
    apt-get --fix-broken --yes --quiet install && \
    command -v texstudio >/dev/null 2>&1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

VOLUME [ "/home/.config/texstudio" ]

CMD [ "texstudio" ]
