FROM raabf/latex-versions:xenial

ENV DEBIAN_FRONTEND noninteractive

# for the modern KDE Plasma look (configurable in texstudio options)
RUN apt-get update && \
    apt-get install --quiet --yes kde-style-breeze

COPY TEXSTUDIO_VERSION* ./

# install texstudio
# (A newer version from the developer, since the version in the
#  standard repository is quite old)
RUN wget -O texstudio.deb "http://download.opensuse.org/repositories/home:/jsundermeyer/xUbuntu_16.04/amd64/texstudio_$(head --lines=1 TEXSTUDIO_VERSION_QT5)_amd64.deb" && \
    apt-get install --quiet --yes ./texstudio.deb && \
    command -v texstudio >/dev/null 2>&1 && \
    rm texstudio.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

VOLUME [ "/home/.config/texstudio" ]

CMD [ "texstudio" ]
