#!/bin/bash

temp_dir="$(mktemp --directory)"
openssl_dir="${temp_dir}/openssl"
unbound_dir="${temp_dir}/unbound"

declare -r 'temp_dir' \
	'openssl_dir' \
	'unbound_dir'

sudo apt --assume-yes install 'libmnl-dev' \
	'libevent-dev' \
	'libsystemd-dev' \
	'swig' \
	'libprotobuf-c-dev' \
	'git' || exit '1'

git clone --ipv4 \
	--single-branch \
	--no-tags \
	--branch 'OpenSSL_1_1_1-stable' \
     --depth '1' \
    'https://github.com/openssl/openssl.git' \
    "${openssl_dir}" || exit '1'

git clone --ipv4 \
	--single-branch \
	--no-tags \
	--branch 'master' \
     --depth '1' \
    'https://github.com/NLnetLabs/unbound.git' \
	"${unbound_dir}" || exit '1'

cd "${unbound_dir}"

./configure --enable-subnet \
    --enable-tfo-client \
    --enable-tfo-server \
    --enable-event-api \
    --enable-ipsecmod \
    --enable-ipset \
    --with-pthreads \
    --with-ssl="${openssl_dir}" \
    --with-libmnl \
    --build='x86_64-linux-gnu' \
    --prefix='/usr' \
    --includedir='/usr/include' \
    --mandir='/usr/share/man' \
    --infodir='/usr/share/info' \
    --sysconfdir='/etc' \
    --localstatedir='/var' \
    --libdir='/usr/lib' \
    --libexecdir='/usr/lib' \
    --disable-rpath \
    --with-pidfile='/run/unbound.pid' \
    --with-rootkey-file='/var/lib/unbound/root.key' \
    --with-libevent \
    --with-pythonmodule \
    --enable-subnet \
    --enable-dnstap \
    --enable-systemd \
    --with-chroot-dir= \
    --with-dnstap-socket-path='/run/dnstap.sock' || exit '1'

make --jobs || exit '1'
make install || exit '1'