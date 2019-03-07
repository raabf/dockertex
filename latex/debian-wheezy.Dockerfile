FROM debian:wheezy
# texlive 2012

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="Fabian Raab <fabian@raab.link>" \
      texlive_version="2012" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="dockertex-latex" \
      org.label-schema.description="🐋📓 Latex with multiple texlive versions and proper command line tools 🎈 suitable for CI" \
      org.label-schema.url="https://github.com/raabf/dockertex.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/raabf/dockertex.git" \
      org.label-schema.docker.cmd="dockertex" \
      org.label-schema.docker.cmd.help="dockertex --help" \
      org.label-schema.usage="https://gitlab.com/raabf/dockertex/blob/master/README.md" \
      org.label-schema.schema-version="1.0"

ENV DEBIAN_FRONTEND noninteractive

# install latex
# remove documentation packages of latex to save disk space
RUN apt-get update && \
    apt-get install --quiet --yes texlive-full && \
    apt-get remove --quiet --yes texlive-doc-ar \
      texlive-doc-bg texlive-doc-de texlive-doc-en texlive-doc-cs+sk \
      texlive-doc-es texlive-doc-fi texlive-doc-fr texlive-doc-it texlive-doc-ja \
      texlive-doc-ko texlive-doc-mn texlive-doc-nl texlive-doc-pl texlive-doc-pt \
      texlive-doc-rs texlive-doc-ru texlive-doc-si texlive-doc-th texlive-doc-tr \
      texlive-doc-uk texlive-doc-vi texlive-doc-zh

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

