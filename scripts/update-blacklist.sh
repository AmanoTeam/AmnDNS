#!/bin/bash

cd "$(mktemp -d)"

curl --url 'https://block.energized.pro/extensions/regional/formats/unbound.conf' \
	--url 'https://block.energized.pro/extensions/social/formats/unbound.conf' \
	--url 'https://block.energized.pro/extensions/xtreme/formats/unbound.conf' \
	--url 'https://block.energized.pro/unified/formats/unbound.conf' \
	--url 'https://raw.githubusercontent.com/AmanoTeam/AmnDNS/master/etc/unbound/unbound.conf.d/blacklist.conf' \
	--silent \
	--doh-url 'https://1.0.0.1/dns-query' \
	--ipv4 \
	--connect-timeout '25' \
	--no-sessionid \
	--no-keepalive \
	| awk 'NF && !seen[$0]++' \
	| sed -r '/(<|>|\t|#|\}|\)|;)/d; s/\\//g' \
	| sed -r 's/\.{2,}/./g; s/" static/" always_nxdomain/g' \
	> 'blacklist.conf'

mv '/etc/unbound/unbound.conf.d/blacklist.conf' 'blacklist.conf.backup'
mv 'blacklist.conf' '/etc/unbound/unbound.conf.d/blacklist.conf'

unbound-checkconf '/etc/unbound/unbound.conf'

if [ "${?}" = '0' ]; then
	systemctl restart unbound
	echo "done"
else
	mv 'blacklist.conf.backup' '/etc/unbound/unbound.conf.d/blacklist.conf'
	echo "error"
fi

exit '0'
