#!/bin/sh
export BITCOIN_DATA=/data

DAEMON=/usr/local/bin/bitcoind
BITCOIN_ARGS="-conf=/data/bitcoin.conf -datadir=${BITCOIN_DATA}"

# Default config if none exists
if [ ! -r /data/bitcoin.conf ]; then
  cp /usr/local/share/bitcoin-core/bitcoin.conf /data/
  chmod 0600 /data/bitcoin.conf
fi

if ( which "$1" &> /dev/null ) || [ -x "$1" ]; then
# command line entry detected
  args="${BITCOIN_ARGS}"
  set -- "$@"
  ( echo "bitcoind bitcoin-cli" | grep -qw $(basename "$1") ) || args=""
  exec "$@" ${args}
else
# daemon is executed
  BITCOIN_ARGS="${BITCOIN_ARGS} -printtoconsole"
  ( echo "$@" | grep -q '\-rpcallowip=' ) || BITCOIN_ARGS="${BITCOIN_ARGS} -rpcallowip=::/0"
  exec ${DAEMON} "$@" ${BITCOIN_ARGS}
fi
