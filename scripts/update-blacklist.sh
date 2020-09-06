#!/bin/bash

CA_FILE='/home/snwmds/AmnDNS/certs/ca-bundle.crt'
CA_PATH='/home/snwmds/AmnDNS/certs'

cd "$(mktemp -d)"

curl --url 'https://block.energized.pro/extensions/regional/formats/unbound.conf' \
	--url 'https://block.energized.pro/extensions/xtreme/formats/unbound.conf' \
	--url 'https://block.energized.pro/unified/formats/unbound.conf' \
	--url 'https://raw.githubusercontent.com/AmanoTeam/AmnDNS/master/etc/unbound/unbound.conf.d/blacklist.conf' \
	--silent \
	--doh-url 'https://1.0.0.1/dns-query' \
	--ipv4 \
	--connect-timeout '8' \
	--no-sessionid \
	--no-keepalive \
	--capath "${CA_PATH}" \
	--cacert "${CA_FILE}" \
	--cert-type 'PEM' \
	--header 'User-Agent:' \
	--header 'Accept:' \
	| awk 'NF && !seen[$0]++' \
	| sed -r '/(<|>|\t|#|\}|\)|;)/d; s/\\//g' \
	| sed -r 's/\.{2,}/./g; s/" static/" always_nxdomain/g' \
	> 'blacklist.conf'

mv '/etc/unbound/unbound.conf.d/blacklist.conf' 'blacklist.conf.backup'
mv 'blacklist.conf' '/etc/unbound/unbound.conf.d/blacklist.conf'

unbound-checkconf '/etc/unbound/unbound.conf'

if [ "${?}" = '0' ]; then
	systemctl restart unbound
else
	mv 'blacklist.conf.backup' '/etc/unbound/unbound.conf.d/blacklist.conf'
fi

exit '0'
