#!/bin/bash

threads_count='0'

cd "$(mktemp -d)" || exit '1'

curl --url 'http://crimeflare.net:83/domains/ipout.zip' \
	--silent \
	--doh-url 'https://1.0.0.1/dns-query' \
	--ipv4 \
	--connect-timeout '8' \
	--no-sessionid \
	--no-keepalive \
	--fail \
	--header 'User-Agent:' \
	--header 'Accept:' \
	--output 'ipout.zip' || exit '1'

while read -r 'entrie'; do
	
	(
		domain="$(awk '{ print ""$2"" }' <<< "${entrie}")"
		ip="$(awk '{ print ""$3"" }' <<< "${entrie}")"
		
		curl --url "https://${domain}/" \
			--ipv4 \
			--connect-timeout '3' \
			--no-sessionid \
			--no-keepalive \
			--silent \
			--fail \
			--raw \
			--capath "${CA_PATH}" \
			--cacert "${CA_FILE}" \
			--cert-type 'PEM' \
			--header 'User-Agent:' \
			--header 'Accept:' \
			--resolve "${domain}:443:${ip}" \
			--output '/dev/null'
		
		if [ "${?}" = '0' ]; then
			echo "local-zone: \"${domain}.\" typetransparent" >> 'cloudflare-bypass.conf'
			echo "local-data: \"${domain}. A ${ip}\"" >> 'cloudflare-bypass.conf'
		fi
	) &
	
	threads_count="$((threads_count + 1))"
	
	if [ "${threads_count}" -ge '5000' ]; then
		while [[ -z "$(pidof 'curl')" ]]; do true; done
		threads_count='0'
	fi
	
done <<< "$(unzip -p 'ipout.zip')"

awk 'NF && !seen[$0]++' 'cloudflare-bypass.conf' > '/etc/unbound/unbound.conf.d/cloudflare-bypass.conf'
