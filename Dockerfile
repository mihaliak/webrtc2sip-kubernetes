FROM ubuntu:xenial

WORKDIR /src

# install dependencies
RUN apt-get update && apt-get install --no-install-recommends -y python-pip python-setuptools git \
    libssl-dev build-essential libtool autoconf automake supervisor \
    libogg-dev pkg-config libspeex-dev libspeexdsp-dev wget libsrtp-dev libxml2-dev \
    && pip install wheel supervisor-stdout

# copy supervisord configuration
COPY etc /etc/

# download dictionary to avoid errors with missing dict word file
RUN cd /usr/share/dict \
    && wget --no-check-certificate https://sourceforge.net/projects/souptonuts/files/souptonuts/dictionary/linuxwords.1.tar.gz \
    && tar zxvf linuxwords.1.tar.gz && rm linuxwords.1.tar.gz \
    && mv linuxwords.1/linux.words ./words && rm -rf linuxwords.1

# install opus audio encoder
RUN wget --no-check-certificate http://downloads.xiph.org/releases/opus/opus-1.0.2.tar.gz \
    && tar xvzf opus-1.0.2.tar.gz && cd opus-1.0.2 && ./configure --with-pic --enable-float-approx \
    && make \
    && make install \
    && rm -rf opus-1.0.2

# install doubango framework and necessary dependencies such as ffmpeg
RUN git clone https://github.com/DoubangoTelecom/doubango.git \
    && cd doubango \
    && ./autogen.sh \
    && ./configure --with-ssl --with-srtp --with-speexdsp --prefix=/usr/local \
    && make \
    && make install \
    && cd ../ \
    && rm -rf doubango

# install webrtc2sip proxy
RUN git clone https://github.com/DoubangoTelecom/webrtc2sip.git \
    && cd webrtc2sip \
    && ./autogen.sh \
    && ./configure CFLAGS='-lpthread' LDFLAGS='-ldl' LIBS='-ldl' \
    && make \
    && make install \
    && cd ../ \
    && rm -rf webrtc2sip

# cleanup
RUN rm -rf /var/lib/apt/lists/* \
    && apt-get -y remove wget git python-pip

CMD /usr/bin/supervisord
