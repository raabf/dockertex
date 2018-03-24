FROM ubuntu:xenial
# texlive 2015

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="Fabian Raab <fabian@raab.link>" \
	    texlive_version="2015" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="dockertex-latex" \
      org.label-schema.description="🐋📓 Latex with multiple texlive versions and proper command line tools 🎈 suitable for CI" \
      org.label-schema.url="https://gitlab.com/raabf/dockertex/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://gitlab.com/raabf/dockertex/" \
      org.label-schema.docker.cmd="dockertex" \
      org.label-schema.docker.cmd.help="dockertex --help" \
      org.label-schema.schema-version="1.0"

ENV DEBIAN_FRONTEND noninteractive

# install latex
RUN apt-get update && \
    apt-get install --quiet --yes \
    texlive-full

# remove documentation packages of latex to save disk space
RUN apt-get remove --quiet --yes "texlive-*-doc"

# install some common tools used with latex
RUN apt-get install --quiet --yes \
    wget lsb-release biber \
    python-pygments gnuplot inkscape pandoc \
    make git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*


WORKDIR /home/workdir

VOLUME [ "/home/workdir" ]

