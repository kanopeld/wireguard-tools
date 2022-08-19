#!/usr/bin/env bash

[[ -z "$WDIR" ]] && WDIR="/etc/wireguard/"

if [ ! -d "$WDIR/peers" ]; then mkdir "$WDIR/peers" fi

echo "Enter client name:"
read -r CLIENT_NAME

if [ ! -d "$WDIR/peers/$CLIENT_NAME" ]; then
  mkdir "$WDIR/peers/$CLIENT_NAME"
fi

cd "$WDIR/peers/$CLIENT_NAME" || exit 2

if [ ! -f "$CLIENT_NAME.key" ]; then
  wg genkey | tee "$CLIENT_NAME.key"
fi
if [ ! -f "$CLIENT_NAME.key.pub" ]; then
  wg pubkey < "$CLIENT_NAME.key" > "$CLIENT_NAME.key.pub"
fi

if [ -f "$CLIENT_NAME.conf" ]; then rm "$CLIENT_NAME.conf"; fi

if [ -z "$EP" ]; then EP=$(curl ifconfig.me); fi

printf "[Interface]\nPrivateKey = %s\nAddress = 10.10.10.2/32, 2001:8b0:2c1:69::2/128\nDNS = 9.9.9.9, 2620:fe::fe\n\n" "$(cat "$CLIENT_NAME.key")" >> "$CLIENT_NAME.conf"
printf "[Peer]\nPublicKey = %s\nEndpoint = %s:51830\nAllowedIPs = 0.0.0.0/0, ::0/0\nPersistentKeepalive = 30\n" "$(cat "$WDIR/server.key.pub")" "$EP" >> "$CLIENT_NAME.conf"

printf "\n\t @@@ Client QR code @@@"
qrencode -t ansiutf8 < "$CLIENT_NAME.conf"

printf "\n\tInsert this into main config with correct client IP\n"
printf "[Peer]\nPublicKey = %s\nAllowedIPs = 10.10.10.N/32, fd01:8b0:2c1::N/128\n" "$(cat "$CLIENT_NAME.key.pub")"
printf "\n\t Don't forget to reload 'wg-quick@wg0' service"