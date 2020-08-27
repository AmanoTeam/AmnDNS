# AmnDNS

AmnDNS is a free DNS service offered and maintained by [Amano Team](https://amanoteam.com/).

## Servers

### DNS-over-HTTPS

* `https://doh-ca.amanoteam.com/dns-query` (`54.39.40.163`)
* `sdns://AgMAAAAAAAAADDU0LjM5LjQwLjE2MwAUZG9oLWNhLmFtYW5vdGVhbS5jb20KL2Rucy1xdWVyeQ`

### DNS-over-TLS

* `dot-ca.amanoteam.com:853` (`54.39.40.163`)
* `sdns://AwMAAAAAAAAADDU0LjM5LjQwLjE2MwAUZG90LWNhLmFtYW5vdGVhbS5jb20`

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

Note that, unlike other DNS services that focus only on filtering content related to ads, analytics and malware, we also block content related to social media (e.g. Facebook, Twitter) and pornography.

The main purpose of this project is to offer a slightly more secure internet. If you don't want anything but ads, analytics and malware to be blocked, don't use AmnDNS. It will most likely break your favorite app or website.

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