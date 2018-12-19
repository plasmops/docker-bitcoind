#!/bin/sh
export BITCOIN_DATA=/data

DAEMON=/usr/local/bin/bitcoind
USER=bitcoin
BITCOIN_ARGS="-conf=/conf/bitcoin.conf -datadir=${BITCOIN_DATA}"

# Set default RPC user and password (if not configured yet)
sed -i 's/^ *\# *rpcuser=.*/rpcuser=bitcoinrpc/' /conf/bitcoin.conf
sed -i 's/^ *\# *rpcuser=.*/rpcpassword=bitcoinrpcpass/' /conf/bitcoin.conf

# Chown data for an upriviliged user
chown bitcoin:bitcoin $BITCOIN_DATA /conf/bitcoin.conf
chmod 700 $BITCOIN_DATA /conf/bitcoin.conf

if ( which "$1" &> /dev/null ) || [ -x "$1" ]; then
# command line entry detected
  args="${BITCOIN_ARGS}"
  set -- "$@"
  ( echo "bitcoind bitcoin-cli" | grep -qw $(basename "$1") ) || args=""
  exec su-exec ${USER} "$@" ${args}
else
# daemon is executed
  BITCOIN_ARGS="${BITCOIN_ARGS} -printtoconsole"
  ( echo "$@" | grep -q '\-rpcallowip=' ) || BITCOIN_ARGS="${BITCOIN_ARGS} -rpcallowip=::/0"
  exec su-exec ${USER} ${DAEMON} "$@" ${BITCOIN_ARGS}
fi
