FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ARG PHP_VERSION=

RUN apt-get update && \
    apt install -y git && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update -y \
      && apt-get install --no-install-recommends -y curl gnupg2 sudo software-properties-common apt-utils \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt install -y chromium-browser && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN add-apt-repository -y ppa:ondrej/php \
      && apt-get update -y \
      && apt-get install --no-install-recommends -y dpkg-dev libargon2-0 libargon2-1 libcap2 libcryptsetup12 libdevmapper1.02.1 \
        libdpkg-perl libedit2 libkmod2 \
        libpcre2-16-0 libpcre2-32-0 libpcre2-8-0 libpcre2-dev libpq5 \
        libsodium23 libssl-dev libtool libxslt1.1 libzip4 patch \
        php$PHP_VERSION-cgi php$PHP_VERSION-cli php$PHP_VERSION-common php$PHP_VERSION-curl php$PHP_VERSION-dev php$PHP_VERSION-fpm \
        php$PHP_VERSION-intl php$PHP_VERSION-mbstring php$PHP_VERSION-mysql php$PHP_VERSION-opcache php$PHP_VERSION-pgsql \
        php$PHP_VERSION-readline php$PHP_VERSION-xml php$PHP_VERSION-bcmath php$PHP_VERSION-zip pkg-config psmisc shtool \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2.8.8 /usr/bin/composer /usr/local/bin/composer

RUN echo "memory_limit=-1" >> /etc/php/$PHP_VERSION/cli/conf.d/99_memory_limit.ini

#RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
#      && echo \
#        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
#        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
#      && apt-get update -y \
#      && apt-get install --no-install-recommends -y docker-ce docker-ce-cli containerd.io docker-compose \
#      && apt-get clean \
#      && rm -rf /var/lib/apt/lists/*

RUN apt-get update -y \
      && apt-get install --no-install-recommends -y acl \
      && apt-get clean \
    && apt-get autoremove -y \
      && rm -rf /var/lib/apt/lists/*

RUN apt-get update -y \
      && apt-get upgrade -y \
      && apt-get clean \
    && apt-get autoremove -y \
      && rm -rf /var/lib/apt/lists/*

RUN apt-get update -y \
    && apt-get install --no-install-recommends -y mysql-client \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update -y \
    && curl -L  https://github.com/fabpot/local-php-security-checker/releases/download/v1.2.0/local-php-security-checker_1.2.0_linux_386 --output local-php-security-checker \
    && chmod +x local-php-security-checker \
    && mv local-php-security-checker /usr/bin/local-php-security-checker \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install --no-install-recommends -y php-pear libmagickwand-dev libmagickcore-dev \
    && mkdir -p /tmp/imagick  \
    && cd /tmp/imagick  \
    && git clone https://github.com/Imagick/imagick.git .  \
    && git fetch origin master  \
    && git switch master  \
    && phpize  \
    && ./configure  \
    && make  \
    && make install  \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install --no-install-recommends -y php-pear \
    && pecl install xdebug \
    && echo "extension=xdebug.so" > /etc/php/$PHP_VERSION/cli/conf.d/10-xdebug.ini \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install --no-install-recommends -y wkhtmltopdf \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh \
    && chmod +x ./nodesource_setup.sh \
    && ./nodesource_setup.sh \
    && rm -f ./nodesource_setup.sh \
    && apt-get install --no-install-recommends -y nodejs gcc g++ make \
    && npm install -g gulp \
    && npm cache clean --force \
    && apt-get autoremove -y \
    && apt-get clean

RUN apt-get update \
    && apt-get install --no-install-recommends -y docker-compose \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    adwaita-icon-theme dconf-gsettings-backend dconf-service dictionaries-common \
      emacsen-common ffmpeg fonts-freefont-ttf fonts-ipafont-gothic \
      fonts-liberation fonts-noto-color-emoji fonts-tlwg-loma-otf fonts-unifont \
      fonts-wqy-zenhei glib-networking glib-networking-common \
      glib-networking-services gsettings-desktop-schemas gstreamer1.0-libav \
      gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
      gtk-update-icon-cache hicolor-icon-theme humanity-icon-theme hunspell-en-us \
      libaa1 libasound2 libasound2-data libaspell15 libass9 libasyncns0 \
      libatk-bridge2.0-0 libatk1.0-0 libatk1.0-data libatspi2.0-0 libavc1394-0 \
      libavcodec58 libavdevice58 libavfilter7 libavformat58 libavutil56 libblas3 \
      libbluray2 libbs2b0 libcaca0 libcdio-cdda2 libcdio-paranoia2 libcdio19 \
      libcdparanoia0 libchromaprint1 libcodec2-1.0 libcolord2 libdbus-glib-1-2 \
      libdc1394-25 libdca0 libdconf1 libdecor-0-0 libdv4 libdvdnav4 libdvdread8 \
      libenchant-2-2 libepoxy0 libevent-2.1-7 libfaad2 libffi7 libflac8 libflite1 \
      libfluidsynth3 libfontenc1 libfreeaptx0 libgfortran5 libgles2 libgme0 \
      libgpm2 libgsm1 libgssdp-1.2-0 libgstreamer-gl1.0-0 \
      libgstreamer-plugins-bad1.0-0 libgstreamer-plugins-good1.0-0 libgtk-3-0 \
      libgtk-3-common libgupnp-1.2-1 libgupnp-igd-1.0-4 libharfbuzz-icu0 \
      libhunspell-1.7-0 libiec61883-0 libinstpatch-1.0-2 libjack-jackd2-0 \
      libjson-glib-1.0-0 libjson-glib-1.0-common libkate1 liblapack3 \
      libldacbt-enc2 liblilv-0-0 libltc11 libmanette-0.2-0 \
      libmjpegutils-2.1-0 libmodplug1 libmp3lame0 libmpcdec6 libmpeg2encpp-2.1-0 \
      libmpg123-0 libmplex2-2.1-0 libmysofa1 libnice10 libnorm1 libnotify4 \
      libnspr4 libnss3 libogg0 libopenal-data libopenal1 libopengl0 libopenh264-6 \
      libopenmpt0 libopenni2-0 libopus0 libpgm-5.3-0 libpocketsphinx3 \
      libpostproc55 libproxy1v5 libpulse0 libqrencode4 librabbitmq4 libraw1394-11 \
      librubberband2 libsamplerate0 libsbc1 libsdl2-2.0-0 libsecret-1-0 \
      libsecret-common libserd-0-0 libshine3 libshout3 libslang2 libsnappy1v5 \
      libsndfile1 libsndio7.0 libsord-0-0 libsoundtouch1 libsoup2.4-1 \
      libsoup2.4-common libsoxr0 libspandsp2 libspeex1 libsphinxbase3 \
      libsratom-0-0 libsrt1.4-gnutls libsrtp2-1 libssh-gcrypt-4 libswresample3 \
      libswscale5 libtag1v5 libtag1v5-vanilla libtext-iconv-perl libtheora0 \
      libtwolame0 libudfread0 libusb-1.0-0 libv4l-0 libv4lconvert0 libva-drm2 \
      libva-x11-2 libva2 libvdpau1 libvidstab1.1 libvisual-0.4-0 libvo-aacenc0 \
      libvo-amrwbenc0 libvorbis0a libvorbisenc2 libvorbisfile3 libvpx7 libwavpack1 \
      libwayland-cursor0 libwayland-egl1 libwebrtc-audio-processing1 libwildmidi2 \
      libx264-163 libxaw7 libxcomposite1 libxcursor1 libxdamage1 libxfont2 libxi6 \
      libxinerama1 libxkbfile1 libxmu6 libxpm4 libxrandr2 libxss1 libxtst6 libxv1 \
      libxvidcore4 libzbar0 libzimg2 libzmq5 libzvbi-common libzvbi0 libzxingcore1 \
      ocl-icd-libopencl1 session-migration timgm6mb-soundfont ubuntu-mono \
      x11-xkb-utils xfonts-cyrillic xfonts-encodings xfonts-scalable xfonts-utils \
      xserver-common xvfb \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install --no-install-recommends -y nginx \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install --no-install-recommends -y php$PHP_VERSION-gd \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /srv/source
