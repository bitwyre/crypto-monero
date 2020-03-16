# Stage 1 - Build

FROM ubuntu:18.04 as builder

COPY monero /app/src/monero
WORKDIR /app/src/monero

ENV NO_QT=1

RUN apt-get update && apt-get install -y \
        git \
        build-essential \
        cmake \
        pkg-config \
        libboost-all-dev \
        libssl-dev \
        libzmq3-dev \
        libunbound-dev \
        libsodium-dev \
        libpgm-dev \
        libnorm-dev
RUN echo "\nSubmodule files:"&& \
    ls -Falg --group-directories-first && \
    echo && \
    gcc --version && \
    make -j$(nproc) release-static
RUN cd /app/src/monero/build/release && \
    ls -Falg --group-directories-first && \
    strip bin/monerod && \
    strip bin/monero-blockchain-ancestry && \
    strip bin/monero-blockchain-depth && \
    strip bin/monero-blockchain-export && \
    strip bin/monero-blockchain-import && \
    strip bin/monero-blockchain-mark-spent-outputs && \
    strip bin/monero-blockchain-prune && \
    strip bin/monero-blockchain-prune-known-spent-data && \
    strip bin/monero-blockchain-stats && \
    strip bin/monero-blockchain-usage && \
    strip bin/monero-gen-ssl-cert && \
    strip bin/monero-gen-trusted-multisig && \
    strip bin/monero-wallet-cli && \
    strip bin/monero-wallet-rpc && \
    strip lib/libwallet.a


# Stage 2 - Production Image

FROM ubuntu:18.04

LABEL maintainer "Yefta Sutanto <yefta@bitwyre.com>"

RUN apt-get update && \
    apt-get install -y --no-install-recommends gosu libnorm1 && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r monero && useradd -r -m -g monero monero
RUN mkdir -p /home/monero/.bitmonero && \
    chown -R monero:monero /home/monero

COPY --from=builder /app/src/monero/build/release/bin /usr/local/bin
COPY --from=builder /app/src/monero/build/release/lib /usr/local/lib
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

VOLUME ["/home/monero/.bitmonero"]
EXPOSE 18080 18081 28080 28081

ENV MONERO_DATA "/home/monero/.bitmonero"

ENTRYPOINT [ "/./docker-entrypoint.sh" ]
CMD ["monerod"]
