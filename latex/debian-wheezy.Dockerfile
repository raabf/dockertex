FROM debian:wheezy
# texlive 2012

ENV DEBIAN_FRONTEND noninteractive

# install latex
RUN apt-get update && \
    apt-get install --quiet --yes \
    texlive-full

# remove documentation packages of latex to save disk space
RUN apt-get remove --quiet --yes texlive-doc-ar \
    texlive-doc-bg texlive-doc-cs+sk texlive-doc-de texlive-doc-en \
    texlive-doc-es texlive-doc-fi texlive-doc-fr texlive-doc-it texlive-doc-ja \
    texlive-doc-ko texlive-doc-mn texlive-doc-nl texlive-doc-pl texlive-doc-pt \
    texlive-doc-rs texlive-doc-ru texlive-doc-si texlive-doc-th texlive-doc-tr \
    texlive-doc-uk texlive-doc-vi texlive-doc-zh 

# install some common tools used with latex
RUN apt-get install --quiet --yes \
    wget biber \
    python-pygments gnuplot inkscape pandoc \
    make git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


WORKDIR /home/workdir

VOLUME [ "/home/workdir" ]

