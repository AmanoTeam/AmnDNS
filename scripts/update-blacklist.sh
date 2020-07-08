#!/bin/bash

cd "$(mktemp -d)"

curl --url 'https://block.energized.pro/unified/formats/hosts' \
	--url 'https://block.energized.pro/extensions/xtreme/formats/hosts' \
	--url 'https://block.energized.pro/extensions/regional/formats/hosts' \
	--url 'https://block.energized.pro/extensions/social/formats/hosts' \
	--request 'GET' \
	--http2-prior-knowledge \
	--silent \
	--doh-url 'https://1.0.0.1/dns-query' \
	--ipv4 \
	--connect-timeout '25' \
	--no-sessionid \
	--no-keepalive >> 'hosts.txt'

sed -ri '/(<|>)/d; s/\.\././g; s/\\//g' 'hosts.txt'

awk '$1 == "0.0.0.0" { print "local-zone: \""$2"\" always_nxdomain" }' 'hosts.txt' > 'hosts.txt.new'

awk 'NF && !seen[$0]++' 'hosts.txt.new' > '/etc/unbound/unbound.conf.d/blacklist.conf'

systemctl restart unbound

exit '0'
