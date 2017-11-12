FROM ubuntu:trusty
# texlive 2013

ENV DEBIAN_FRONTEND noninteractive

# install latex
RUN apt-get update && \
    apt-get install --quiet --yes \
    texlive-full

# remove documentation packages of latex to save disk space
RUN apt-get remove --quiet --yes "texlive-*-doc"
#  probably do not select all packages like expected. Not sure why. However image is quite small in this old version.

# install some common tools used with latex
RUN apt-get install --quiet --yes \
    wget biber \
    python-pygments gnuplot inkscape pandoc \
    make git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


WORKDIR /home/workdir

VOLUME [ "/home/workdir" ]

