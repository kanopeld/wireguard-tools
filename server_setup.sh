#!/usr/bin/env bash

[[ -z "$WDIR" ]] && WDIR="/etc/wireguard/";
[[ -z "$FILE_NAME" ]] && FILE_NAME="server";

[[ ! -d "$WDIR" ]] && mkdir -p $WDIR;

[[ ! -f "$WDIR/$FILE_NAME.key" ]] && wg genkey > "$WDIR/$FILE_NAME.key";
chmod 400 "$WDIR/$FILE_NAME.key"
PRIVATE_KEY=$(cat "$WDIR/$FILE_NAME.key")

[[ ! -f "$WDIR/$FILE_NAME.key.pub" ]] && wg pubkey < "$WDIR/$FILE_NAME.key" > "$WDIR/$FILE_NAME.key.pub";
chmod 644 "$WDIR/$FILE_NAME.key.pub"

if [ -f "$WDIR/wg0.conf" ]
then
  printf "wg0.conf already exist. skip filling it"
else
  printf "filling wg0.conf"
  printf "[Interface]
PrivateKey = %s
Address = 10.10.10.1/24, fd01:8b0:2c1::1/64
ListenPort = 51830
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
" "$PRIVATE_KEY" > "$WDIR/wg0.conf"
  printf "wg0.conf generated"
fi

if [ ! -d "$WDIR/peers" ]
then
  printf "Create peers directory"
  mkdir -p "$WDIR/peers"
fi
