FROM ubuntu:xenial
# texlive 2015

ENV DEBIAN_FRONTEND noninteractive

# install latex
RUN apt-get update && \
    apt-get install --quiet --yes \
    texlive-full

# remove documentation packages of latex to save disk space
RUN apt-get remove --quiet --yes "texlive-*-doc"

# install some common tools used with latex
RUN apt-get install --quiet --yes \
    wget biber \
    python-pygments gnuplot inkscape pandoc \
    make git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


WORKDIR /home/workdir

VOLUME [ "/home/workdir" ]
