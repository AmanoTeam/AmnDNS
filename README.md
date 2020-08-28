# AmnDNS

AmnDNS is a free DNS service offered and maintained by [Amano Team](https://amanoteam.com/).

## Servers

Before using any of our services, please read our [privacy policy](#privacy). It describes how your data is treated when it is received by our server.

Also, see below for some technical information on how the provided DNS services work.

* DNS services are hosted in Canada. The provider we currently use is OVH.
* We use Nginx as a reverse proxy for DoH and DoT services.
* The DoH server we use is [m13253/dns-over-https](https://github.com/m13253/dns-over-https).
* The DNSCrypt server we use is [jedisct1/encrypted-dns-server](https://github.com/jedisct1/encrypted-dns-server).
* DoH and DoT server certificates were issued by Let's Encrypt and support TLS 1.2 and TLS 1.3.
* The DoH server supports HTTP/2 and HTTP/3 (with [Quiche](https://github.com/cloudflare/quiche)).
* All DNS queries are answered by [Unbound](https://github.com/NLnetLabs/unbound).
* All DNS queries support DNSSEC and QNAME minimization.

### DNS-over-HTTPS

* `https://doh-ca.amanoteam.com/dns-query` (`54.39.40.163`)
* `sdns://AgMAAAAAAAAADDU0LjM5LjQwLjE2MyA-GhoPbFPz6XpJLVcIS1uYBwWe4FerFQWHb9g_2j24OBRkb2gtY2EuYW1hbm90ZWFtLmNvbQovZG5zLXF1ZXJ5DDU0LjM5LjQwLjE2Mw`

### DNS-over-TLS

* `dot-ca.amanoteam.com:853` (`54.39.40.163`)
* `sdns://AwMAAAAAAAAADDU0LjM5LjQwLjE2MyA-GhoPbFPz6XpJLVcIS1uYBwWe4FerFQWHb9g_2j24OBRkb3QtY2EuYW1hbm90ZWFtLmNvbQw1NC4zOS40MC4xNjM`

### DNSCrypt v2

* `54.39.40.163:8443` `sdns://AQMAAAAAAAAAETU0LjM5LjQwLjE2Mzo4NDQzILe8VlUfNSOVUK9xgeBs2AgsgraZuhq_a_DCnv3u3ScXHTIuZG5zY3J5cHQtY2VydC5hbWFub3RlYW0uY29t`

### Plaintext (unsafe)

* `54.39.40.163:53`
* `sdns://AAMAAAAAAAAADDU0LjM5LjQwLjE2Mw`

## Content blocking

We use the following host lists for content blocking:

* `https://block.energized.pro/unified/formats/unbound.conf`
* `https://block.energized.pro/extensions/xtreme/formats/unbound.conf`
* `https://block.energized.pro/extensions/regional/formats/unbound.conf`
* `https://block.energized.pro/extensions/social/formats/unbound.conf`
* `https://raw.githubusercontent.com/AmanoTeam/AmnDNS/master/etc/unbound/unbound.conf.d/blacklist.conf`

Note that, unlike other DNS services that focus only on filtering content related to ads, analytics and malware, we also block content related to social media (e.g. Facebook, Twitter) and pornography.

If you don't want anything but ads, analytics and malware to be blocked, don't use AmnDNS. It will most likely break your favorite app or website.

## Privacy

We do not collect, store, use or share any information about queries or access to our servers.

## Third party software

The AmnDNS project exists thanks to these open source softwares:

- **Unbound**
  - Author: NLnetLabs ([NLnetLabs](https://github.com/NLnetLabs))
  - Repository: [NLnetLabs/unbound](https://github.com/NLnetLabs/unbound)
  - License: [BSD-3-Clause License](https://github.com/m13253/dns-over-https/blob/master/LICENSE)

- **DNS-over-HTTPS**
  - Author: Star Brilliant ([m13253](https://github.com/m13253))
  - Repository: [m13253/dns-over-https](https://github.com/m13253/dns-over-https)
  - License: [MIT License](https://github.com/NLnetLabs/unbound/blob/master/LICENSE)

- **Energized Protection**
  - Author: Ador ([AdroitAdorKhan](https://github.com/AdroitAdorKhan))
  - Repository: [EnergizedProtection/block](https://github.com/EnergizedProtection/block)
  - License: [MIT License](https://github.com/EnergizedProtection/block/blob/master/LICENSE)

- **Nginx**
  - Author: nginx ([nginx](https://github.com/nginx))
  - Repository: [nginx/nginx](https://github.com/nginx/nginx)
  - License: [2-clause BSD](https://opensource.org/licenses/BSD-2-Clause)

- **Encrypted DNS Server**
  - Author: Frank Denis ([jedisct1](https://github.com/jedisct1))
  - Repository: [jedisct1/encrypted-dns-server](https://github.com/jedisct1/encrypted-dns-server)
  - License: [MIT License](https://github.com/jedisct1/encrypted-dns-server/blob/master/LICENSE)

## Contact

Want to say something? Need some help? [Open a issue](https://github.com/AmanoTeam/AmnDNS/issues) or [send a email](https://spamty.eu/show.php?key=d7967f0e625c5f19c9c655b8).
