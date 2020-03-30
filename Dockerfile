FROM alpine:3.10
MAINTAINER vm75 <vm75dev@gmail.com>

RUN apk --update --no-cache add minidlna tini \
  && mkdir -p /mnt/readymedia/Music /mnt/readymedia/Videos /mnt/readymedia/Pictures /mnt/readymedia/.cache \
  && chown -R minidlna:minidlna /mnt/readymedia

COPY readymedia.conf /etc/minidlna.conf
COPY readymedia.sh /

EXPOSE 8200/tcp 1900/udp

CMD ["/readymedia.sh"]
