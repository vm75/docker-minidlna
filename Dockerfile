FROM alpine:3.11 as builder

RUN apk update --no-cache \
	&& apk add --no-cache git g++ bsd-compat-headers autoconf automake pkgconf make libexif-dev libid3tag-dev libvorbis-dev sqlite-dev ffmpeg-dev imagemagick-dev jpeg-dev flac-dev gettext gettext-dev \
	&& git clone https://github.com/vm75/minidlna.git \
	&& cd minidlna && git checkout dev \
	&& ./autogen.sh \
	&& ./configure --enable-tivo --prefix=/usr --with-db-path=/var/lib/minidlna --with-log-path=/var/log/minidlna \
	&& make

FROM alpine:3.11

COPY --from=builder /minidlna/minidlnad /usr/local/bin
COPY minidlna.conf /etc/minidlna.conf
COPY minidlna.sh /

RUN	apk add --no-cache libexif libid3tag libvorbis sqlite-libs jpeg flac gettext-libs imagemagick-libs ffmpeg mplayer \
	&& mkdir -p /mnt/minidlna/config /mnt/minidlna/Music /mnt/minidlna/Videos /mnt/minidlna/Pictures /mnt/minidlna/.cache

EXPOSE 8200/tcp 1900/udp

CMD ["/minidlna.sh"]