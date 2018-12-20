FROM alpine:3.8
ARG release
ARG version

LABEL com.plasmops.vendor=PlasmOps \
      com.plasmops.version=${release}

ENV LANG=C.UTF-8 \
    GLIBC_APKVER=2.28-r0 \
    BITCOIN_VERSION=${version}

RUN \
# boost boost-program_options libevent libressl libzm
  apk --virtual .deps --no-cache --update add gnupg tar curl && \
# glibc compatibility
  cd /tmp && echo \
    "-----BEGIN PUBLIC KEY-----\
    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
    y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
    tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
    m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
    KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
    Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
    1QIDAQAB\
    -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" && \
  curl -#SLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_APKVER/glibc-i18n-$GLIBC_APKVER.apk && \
  curl -#SLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_APKVER/glibc-$GLIBC_APKVER.apk && \
  curl -#SLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_APKVER/glibc-bin-$GLIBC_APKVER.apk && \
  # install glibc package
  apk add --no-cache glibc-$GLIBC_APKVER.apk glibc-bin-$GLIBC_APKVER.apk glibc-i18n-$GLIBC_APKVER.apk && \
  # configure locale
  echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
  /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap ${LANG#*.} ${LANG} || true && \
# install bitcoind
  cd /tmp && export GNUPGHOME=/tmp && \
  curl --remote-name-all -#SL \
    "https://bitcoin.org/bin/bitcoin-core-${version}/{SHA256SUMS.asc,bitcoin-${version}-x86_64-linux-gnu.tar.gz}" && \
  curl -#SL https://bitcoin.org/laanwj-releases.asc | gpg --import && \
  gpg --batch --verify SHA256SUMS.asc && \
  tar -xzf *.tar.gz --strip-components 1 -C /usr/local && rm -rf /usr/local/share/man && \
# populate fs
  mkdir /data /usr/local/share/bitcoin-core/ && chmod 700 /data && chown 1000:1000 /data && \
# cleanup
  apk del .deps glibc-i18n && rm -rf /etc/apk/keys/sgerrand.rsa.pub /tmp/*

# ports possible for exposure
EXPOSE 8332 8333 18332 18333

ADD /bitcoin.conf /usr/local/share/bitcoin-core/
ADD /entrypoint.sh /
RUN chown 1000:1000 /data && chmod 700 /data

USER 1000:1000
ENTRYPOINT [ "/entrypoint.sh" ]
# CMD []
