FROM raabf/latex-versions:experimental

ARG TEXSTUDIO_VERSION_QT4
ARG TEXSTUDIO_VERSION_QT5
ARG TEXSTUDIO_VERSION_QT5_DEBIAN9

ENV TEXSTUDIO_VERSION=${TEXSTUDIO_VERSION_QT5_DEBIAN9}
# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="Fabian Raab <fabian@raab.link>" \
	  texlive-version="2018" \
      texstudio-version="$TEXSTUDIO_VERSION" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="dockertex-texstudio" \
      org.label-schema.description="🐋📽 TeXstudio including Latex with multiple texlive versions and proper command line tools" \
      org.label-schema.url="https://github.com/raabf/dockertex.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/raabf/dockertex.git" \
      org.label-schema.docker.cmd="dockertexstudio" \
      org.label-schema.docker.cmd.help="dockertexstudio --help" \
      org.label-schema.usage="https://gitlab.com/raabf/dockertex/blob/master/README.md" \
      org.label-schema.schema-version="1.0"

ENV DEBIAN_FRONTEND noninteractive

# for the modern KDE Plasma look (configurable in texstudio options)
# not available in experimental yet
RUN apt-get update
#    apt-get install --quiet --yes kde-style-breeze

# install texstudio
# (A newer version from the developer, since the version in the
#  standard repository is quite old)
RUN wget -O texstudio.deb "http://download.opensuse.org/repositories/home:/jsundermeyer/Debian_9.0/amd64/texstudio_${TEXSTUDIO_VERSION}_amd64.deb" && \
    apt-get install --quiet --yes ./texstudio.deb && \
    command -v texstudio >/dev/null 2>&1 && \
    rm texstudio.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

VOLUME [ "/home/.config/texstudio" ]

CMD [ "texstudio" ]
