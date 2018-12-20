# Docker bitcoin-core container image

The image bundles bitcoin-core and starts up **as unprivileged user 1000:1000**. It expects one `/data` volume.

## /data volume

The volume must be writable by `1000:1000` or any corresponding `uid:gid` **if userns-remap is enabled**.

## /data/bitcoin.conf

The default configuration file will be pre-created if volume does not contain the config already. You may also mount your desired config directly to `/data/bitcoin.conf`

## startup

```shell
# It's supposed you have pre-created the data volume with correct permissions

# Actually you can both path cli args directly to bitcoind and at the same time pass an existing config.
# Or pre-create a config in the data volume as you wish.
docker run -d -v /path/to/bitcoin.conf:/data/bitcoin.conf -v data:/data plasmops/bitcoind:0.17.0.1 -printtoconsole
```

## defaults

We use the defaults of bitcoin-core, but set `rpcuser=bitcoinrpc` and `rpcpassword=plasmops`. **Do not forget to override when in production!**
