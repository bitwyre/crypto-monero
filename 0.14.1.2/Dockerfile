FROM debian:stable-slim

LABEL maintainer "Yefta Sutanto <yefta@bitwyre.com>"

RUN useradd -r monero \
    && apt-get update -y \
    && apt-get install -y curl bzip2 gosu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV MONERO_VERSION=0.14.1.2
ENV MONERO_SHA256=a4d1ddb9a6f36fcb985a3c07101756f544a5c9f797edd0885dab4a9de27a6228
ENV MONERO_DATA=/home/monero/.bitmonero
ENV PATH=/opt/monero-${MONERO_VERSION}:$PATH

RUN curl https://downloads.getmonero.org/cli/monero-linux-x64-v$MONERO_VERSION.tar.bz2 -O \
    && echo "$MONERO_SHA256  monero-linux-x64-v$MONERO_VERSION.tar.bz2" | sha256sum -c - \
    && tar -xzf monero-linux-x64-v$MONERO_VERSION.tar.bz2 -C /opt \
    && rm monero-linux-x64-v$MONERO_VERSION.tar.bz2 \
    && mv /opt/monero-x86_64-linux-gnu /opt/monero-${MONERO_VERSION}

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/home/monero/.bitmonero"]

EXPOSE 18080 18081

ENTRYPOINT ["/entrypoint.sh"]

CMD ["monerod"]
