FROM raabf/latex-versions:jessie

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update 

COPY TEXSTUDIO_VERSION* ./

# install texstudio
# (A newer version from the developer, since the version in the
#  standard repository is quite old)
RUN wget -O texstudio.deb "http://download.opensuse.org/repositories/home:/jsundermeyer/Debian_8.0/amd64/texstudio_$(head --lines=1 TEXSTUDIO_VERSION_QT5)_amd64.deb" && \
    (dpkg --install ./texstudio.deb || true) && \
    apt-get --fix-broken --yes --quiet install && \
    command -v texstudio >/dev/null 2>&1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

VOLUME [ "/home/.config/texstudio" ]

CMD [ "texstudio" ]
