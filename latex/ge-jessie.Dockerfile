ARG BASE_IMAGE
FROM $BASE_IMAGE
# Generic Docker file for greater than ubuntu jessie (including debian).

ARG TEXLIVE_VERSION
ARG PACKAGES_INSTALL
ARG DEBLINE
# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="Fabian Raab <fabian@raab.link>" \
	    texlive_version=$TEXLIVE_VERSION \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="dockertex-latex" \
      org.label-schema.description="🐋📓 Latex with multiple texlive versions and proper command line tools 🎈 suitable for CI" \
      org.label-schema.url="https://github.com/raabf/dockertex" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/raabf/dockertex.git" \
      org.label-schema.docker.cmd="dockertex" \
      org.label-schema.docker.cmd.help="dockertex --help" \
      org.label-schema.usage="https://gitlab.com/raabf/dockertex/blob/master/README.md" \
      org.label-schema.schema-version="1.0"

ENV DEBIAN_FRONTEND noninteractive

# DEBLINE will include repository for ttf-mscorefonts-installer
# install latex
# remove documentation packages of latex to save disk space
RUN echo "$DEBLINE" >> "/etc/apt/sources.list" && \
    cat "/etc/apt/sources.list" && \
    apt-get update && \
    apt-get install --quiet --yes texlive-full && \
    apt-get remove --quiet --yes "texlive-*-doc"

# install some common tools used with latex
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections && \
    apt-get install --quiet --yes \
    wget lsb-release biber \
    gnuplot inkscape pandoc \
    make git \
    ${PACKAGES_INSTALL} \
    ttf-mscorefonts-installer fonts-liberation \
    fonts-dejavu fonts-cmu lmodern tex-gyre && \
    fc-cache -f -v && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

WORKDIR /home/workdir

VOLUME [ "/home/workdir" ]

