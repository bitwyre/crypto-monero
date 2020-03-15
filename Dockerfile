# Stage 1 - Build

FROM gcc:8 as builder

COPY litecoin /app/src/litecoin
WORKDIR /app/src/litecoin/

ENV NO_QT=1

RUN apt-get update && apt-get install -y bsdmainutils
RUN echo "\nSubmodule files:"&& \
    ls -Falg --group-directories-first && \
    echo && \
    gcc --version && \
    cd depends && \
    mkdir x86_64-pc-linux-gnu && \
    make -j$(nproc)
RUN ./autogen.sh && \
    ./configure LDFLAGS="-static-libstdc++" --prefix="/app/src/litecoin/depends/x86_64-pc-linux-gnu" \
    --without-miniupnpc --enable-hardening --with-zmq --disable-man --disable-shared \
    --disable-bench --disable-tests --without-gui --enable-cxx
RUN make install -j$(nproc)
RUN cd /app/src/litecoin/depends/x86_64-pc-linux-gnu && \
    ls -Falg --group-directories-first && \
    strip bin/litecoind && \
    strip bin/litecoin-cli && \
    strip bin/litecoin-tx && \
    strip lib/libbitcoinconsensus.a


# Stage 2 - Production Image

FROM ubuntu:18.04

LABEL maintainer "Yefta Sutanto <yefta@bitwyre.com>"

RUN apt-get update && \
    apt-get install -y --no-install-recommends gosu && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r litecoin && useradd -r -m -g litecoin litecoin
RUN mkdir -p /home/litecoin/.litecoin && \
    chown -R litecoin:litecoin /home/litecoin

COPY --from=builder /app/src/litecoin/depends/x86_64-pc-linux-gnu /usr/local
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

VOLUME ["/home/litecoin/.litecoin"]
EXPOSE 9332 9333 19332 19333

ENV LITECOIN_DATA "/home/litecoin/.litecoin"

ENTRYPOINT [ "/./docker-entrypoint.sh" ]
CMD ["litecoind"]
