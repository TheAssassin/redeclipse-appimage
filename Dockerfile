FROM debian:oldstable

MAINTAINER "TheAssassin <theassassin@users.noreply.github.com>"

ENV DEBIAN_FRONTEND=noninteractive

RUN echo 'deb-src http://deb.debian.org/debian jessie main' >> /etc/apt/sources.list && \
    echo 'deb-src http://deb.debian.org/debian jessie-updates main' >> /etc/apt/sources.list && \
    echo 'deb-src http://security.debian.org jessie/updates main' >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install --no-install-recommends -y libarchive13 wget \
        desktop-file-utils aria2 gnupg2 \
        build-essential file ca-certificates cmake gcc g++ git make \
        pkg-config wget xz-utils rsync desktop-file-utils \
        ninja-build libasound2 zlib1g libjpeg62 libpng12-0  libflac8 libogg0 \
        libvorbis0a libpciaccess0 libdrm2 libxcb-dri2-0 libxcb-dri3-0 \
        libxcb-present0 libxcb1 libxau6 libxext6 libx11-6 libx11-xcb1 \
        libxfixes3 libxcb-xfixes0 libxdamage1 libexpat1 libegl1-mesa \
        libgl1-mesa-dri libgl1-mesa-glx libglapi-mesa libgles2-mesa \
        libglu1-mesa libtinfo5 && \
    apt-get build-dep -y libsdl2 libsdl2-image libsdl2-mixer

RUN apt-get purge -y libpng\* libsdl\*
RUN cd /tmp && \
    wget https://sourceforge.net/projects/libpng/files/libpng16/1.6.34/libpng-1.6.34.tar.gz/download -O- | tar xz && \
    wget https://www.libsdl.org/release/SDL2-2.0.7.tar.gz -O- | tar xz && \
    wget https://www.libsdl.org/projects/SDL_image/release/SDL2_image-2.0.2.tar.gz -O- | tar xz && \
    wget https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-2.0.2.tar.gz -O- | tar xz && \
    (cd libpng-1.* && ./configure --prefix=/usr && make -j$(nproc) install) && \
    (cd SDL2-2.* && mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make -j$(nproc) install) && \
    (cd SDL2_image-2.* && ./configure --build=x86_64-linux-gnu --prefix=/usr --includedir=\${prefix}/include --mandir=\${prefix}/share/man --infodir=\${prefix}/share/info --sysconfdir=/etc --localstatedir=/var --disable-silent-rules --libdir=\${prefix}/lib/x86_64-linux-gnu --libexecdir=\${prefix}/lib/x86_64-linux-gnu --disable-maintainer-mode --disable-dependency-tracking --disable-jpg-shared --disable-tif-shared --disable-png-shared --disable-webp-shared && make install) && \
    (cd SDL2_mixer-2.* && ./configure --build=x86_64-linux-gnu --prefix=/usr --includedir=\${prefix}/include --mandir=\${prefix}/share/man --infodir=\${prefix}/share/info --sysconfdir=/etc --localstatedir=/var --disable-silent-rules --libdir=\${prefix}/lib/x86_64-linux-gnu --libexecdir=\${prefix}/lib/x86_64-linux-gnu --disable-maintainer-mode --disable-dependency-tracking --enable-music-cmd --enable-music-flac --disable-music-flac-shared --enable-music-midi-fluidsynth --disable-music-midi-fluidsynth-shared --enable-music-midi-timidity --enable-music-midi-native --enable-music-mod --enable-music-mod-modplug --disable-music-mod-mikmod --disable-music-mod-modplug-shared --enable-music-mp3 --disable-music-mp3-smpeg --enable-music-mp3-mad-gpl --enable-music-ogg --disable-music-ogg-shared --enable-music-wave && make install)

RUN addgroup --gid 1000 builder && \
    adduser --uid 1000 --gid 1000 --disabled-login --disabled-password \
    --gecos "" builder && \
    install -d -o 1000 -g 1000 /workspace /out

COPY AppRun /AppRun
COPY redeclipse.desktop /redeclipse.desktop
COPY redeclipse-server.desktop /redeclipse-server.desktop
COPY redeclipse.png /redeclipse.png
COPY build-appimages.sh /build-appimages.sh
COPY *.ignore /

USER 1000
