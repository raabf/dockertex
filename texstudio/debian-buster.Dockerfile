FROM mylatex:buster

ENV DEBIAN_FRONTEND noninteractive

# for the modern KDE Plasma look (configurable in texstudio options)
RUN apt-get update && \
    apt-get install --quiet --yes kde-style-breeze

# install texstudio
# (A newer version from the developer, since the version in the
#  standard repository is quite old)
RUN wget -O texstudio.deb http://download.opensuse.org/repositories/home:/jsundermeyer/Debian_9.0/amd64/texstudio_2.12.6-5+5.2_amd64.deb && \
    apt-get install --quiet --yes ./texstudio.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

VOLUME [ "/home/.config/texstudio" ]

CMD [ "texstudio" ]
