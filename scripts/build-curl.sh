#!/bin/bash

ca_path='/etc/curl-certs'
ca_bundle="${ca_path}/certs.pem"

mkdir --parents "${ca_path}" --mode '644'

temp_dir="$(mktemp --directory)"

openssl_source="${temp_dir}/openssl"
openssl_local="${HOME}/.local/openssl"

nghttp3_source="${temp_dir}/nghttp3"
nghttp3_local="${HOME}/.local/nghttp3"

ngtcp2_source="${temp_dir}/ngtcp2"
ngtcp2_local="${HOME}/.local/ngtcp2"

nghttp2_source="${temp_dir}/nghttp2"
nghttp2_local="${HOME}/.local/nghttp2"

curl_source="${temp_dir}/curl"

declare -r 'ca_bundle' \
	'ca_path' \
	'temp_dir' \
	'openssl_source' \
	'openssl_local' \
	'nghttp3_source' \
	'nghttp3_local' \
	'ngtcp2_source' \
	'ngtcp2_local' \
	'nghttp2_source' \
	'curl_source'
	
wget 'https://curl.haxx.se/ca/cacert.pem' \
	--connect-timeout='5' \
	--output-document="${ca_bundle}" || exit '1'

# OpenSSL

cd "${temp_dir}"

git clone --ipv4 \
	--single-branch \
	--no-tags \
	--depth '1' \
	--branch 'OpenSSL_1_1_1d-quic-draft-27' \
	'https://github.com/tatsuhiro-t/openssl' \
	"${openssl_source}" || exit '1'

cd "${openssl_source}"

./config enable-ec_nistp_64_gcc_128 \
    no-nextprotoneg \
    no-weak-ssl-ciphers \
    no-ssl2 \
    no-ssl3 \
    enable-tls1_2 \
    enable-tls1_3 \
	--prefix="${openssl_local}" || exit '1'

make --jobs --silent || exit '1'
make --silent install_sw || exit '1'

# nghttp3

cd "${temp_dir}"

git clone --ipv4 \
	--single-branch \
	--no-tags \
	--depth '1' \
	--branch 'master' \
	'https://github.com/ngtcp2/nghttp3.git' \
	"${nghttp3_source}" || exit '1'
	
cd "${nghttp3_source}"

autoreconf -i

./configure --prefix="${nghttp3_local}" --enable-lib-only || exit '1'

make --jobs --silent || exit '1'
make --silent install || exit '1'

# ngtcp2

cd "${temp_dir}"

git clone --ipv4 \
	--single-branch \
	--no-tags \
	--depth '1' \
	--branch 'master' \
	'https://github.com/ngtcp2/ngtcp2.git' \
	"${ngtcp2_source}" || exit '1'
	
cd "${ngtcp2_source}"

autoreconf -i

env PKG_CONFIG_PATH="${openssl_local}/lib/pkgconfig:${nghttp3_local}/lib/pkgconfig" \
	LDFLAGS="-Wl,-rpath,${openssl_local}/lib" \
	./configure --prefix="${ngtcp2_local}" --enable-lib-only || exit '1'

make --jobs --silent || exit '1'
make --silent install || exit '1'

# nghttp2

cd "${temp_dir}"

git clone --ipv4 \
	--single-branch \
	--no-tags \
	--depth '1' \
	--branch 'master' \
	'https://github.com/nghttp2/nghttp2.git' \
	"${nghttp2_source}" || exit '1'

cd "${nghttp2_source}"

autoreconf -i

./configure --prefix="${nghttp2_local}" --enable-lib-only || exit '1'

make --jobs --silent || exit '1'
make --silent install || exit '1'

# curl

cd "${temp_dir}"

git clone --ipv4 \
	--single-branch \
	--no-tags \
	--depth '1' \
	--branch 'master' \
	'https://github.com/curl/curl.git' \
	"${curl_source}" || exit '1'

cd "${curl_source}"

autoreconf -i

env LDFLAGS="-Wl,-rpath,${openssl_local}/lib" ./configure \
	--prefix='/usr' \
	--enable-optimize \
	--enable-symbol-hiding \
	--enable-http \
	--enable-ftp \
	--enable-ldap \
	--enable-ldaps \
	--enable-rtsp \
	--enable-proxy \
	--enable-dict \
	--enable-telnet \
	--enable-tftp \
	--enable-pop3 \
	--enable-imap \
	--enable-smb \
	--enable-smtp \
	--enable-gopher \
	--enable-mqtt \
	--disable-manual \
	--enable-libcurl-option \
	--disable-ipv6 \
	--enable-libgcc \
	--enable-openssl-auto-load-config \
	--enable-threaded-resolver \
	--enable-sspi \
	--enable-crypto-auth \
	--enable-tls-srp \
	--enable-unix-sockets \
	--enable-cookies \
	--enable-http-auth \
	--enable-doh \
	--enable-mime \
	--enable-dateparse \
	--enable-netrc \
	--disable-progress-meter \
	--enable-dnsshuffle \
	--without-winssl \
	--without-schannel \
	--without-darwinssl \
	--without-secure-transport \
	--without-amissl \
	--without-ca-fallback \
	--with-ca-bundle="${ca_bundle}" \
	--with-ca-path="${ca_path}" \
	--with-ssl="${openssl_local}" \
	--with-nghttp3="${nghttp3_local}" \
	--with-ngtcp2="${ngtcp2_local}" \
	--with-nghttp2="${nghttp2_local}" \
	--enable-alt-svc || exit '1'

make --jobs --silent || exit '1'
make --silent install || exit '1'

exit '0'