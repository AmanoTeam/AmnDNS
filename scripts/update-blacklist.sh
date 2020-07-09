#!/bin/bash

cd "$(mktemp -d)"

curl --url 'https://block.energized.pro/extensions/regional/formats/unbound.conf' \
	--url 'https://block.energized.pro/extensions/social/formats/unbound.conf' \
	--url 'https://block.energized.pro/extensions/xtreme/formats/unbound.conf' \
	--url 'https://block.energized.pro/unified/formats/unbound.conf' \
	--request 'GET' \
	--http2-prior-knowledge \
	--silent \
	--doh-url 'https://1.0.0.1/dns-query' \
	--ipv4 \
	--connect-timeout '25' \
	--no-sessionid \
	--no-keepalive | awk 'NF && !seen[$0]++' > '/etc/unbound/unbound.conf.d/blacklist.conf'

systemctl restart unbound

exit '0'
