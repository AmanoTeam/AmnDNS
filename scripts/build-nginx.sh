#!/bin/bash

temp_dir="$(mktemp --directory)"

nginx_version='1.19.2'
pcre_version='8.44'
zlib_version='1.2.11'

nginx_file="${temp_dir}/nginx.tar.gz"
pcre_file="${temp_dir}/pcre.tar.gz"
zlib_file="${temp_dir}/zlib.tar.gz"

nginx_dir="${temp_dir}/nginx"
pcre_dir="${temp_dir}/pcre-${pcre_version}"
zlib_dir="${temp_dir}/zlib-${zlib_version}"
openssl_dir="${temp_dir}/openssl"

headers_more_dir="${temp_dir}/headers-more-nginx-module"

declare -r 'temp_dir' \
	'nginx_version' \
	'pcre_version' \
	'zlib_version' \
	'nginx_file' \
	'pcre_file' \
	'zlib_file' \
	'nginx_dir' \
	'pcre_dir' \
	'zlib_dir' \
	'openssl_dir' \
	'headers_more_dir'

sudo apt --assume-yes install 'git' \
	'curl' \
	'tar' \
	'build-essential' || exit '1'

curl --url "https://nginx.org/download/nginx-${nginx_version}.tar.gz" \
    --url "https://ftp.pcre.org/pub/pcre/pcre-${pcre_version}.tar.gz" \
    --url "http://www.zlib.net/zlib-${zlib_version}.tar.gz" \
    --output "${nginx_file}" \
    --output "${pcre_file}" \
    --output "${zlib_file}" \
    --silent \
    --header 'User-Agent:' \
    --header 'Accept:' \
    --ipv4 \
    --connect-timeout '15' \
    --insecure \
    --no-sessionid \
    --no-keepalive || exit '1'

git clone --ipv4 \
	--single-branch \
	--no-tags \
	--branch 'OpenSSL_1_1_1-stable' \
    --depth '1' \
    'https://github.com/openssl/openssl.git' \
    "${openssl_dir}" || exit '1'

cd "${temp_dir}"

tar --extract --file="${nginx_file}" || exit '1'
tar --extract --file="${pcre_file}" || exit '1'
tar --extract --file="${zlib_file}" || exit '1'

git clone --ipv4 \
	--single-branch \
	--no-tags \
	--branch 'master' \
     --depth '1' \
    'https://github.com/openresty/headers-more-nginx-module.git' \
    "${headers_more_dir}" || exit '1'

cd "${nginx_dir}"

./configure --prefix='/usr/share/nginx' \
    --sbin-path='/usr/sbin/nginx' \
    --modules-path='/usr/lib/nginx/modules' \
    --conf-path='/etc/nginx/nginx.conf' \
    --error-log-path='/var/log/nginx/error.log' \
    --http-log-path='/var/log/nginx/access.log' \
    --pid-path='/run/nginx.pid' \
    --lock-path='/var/lock/nginx.lock' \
    --user='www-data' \
    --group='www-data' \
    --build='x86_64-linux-gnu' \
    --http-client-body-temp-path='/var/lib/nginx/body' \
    --http-fastcgi-temp-path='/var/lib/nginx/fastcgi' \
    --http-proxy-temp-path='/var/lib/nginx/proxy' \
    --http-scgi-temp-path='/var/lib/nginx/scgi' \
    --http-uwsgi-temp-path='/var/lib/nginx/uwsgi' \
    --with-pcre="${pcre_dir}" \
    --with-pcre-jit \
    --with-zlib="${zlib_dir}" \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_sub_module \
    --with-http_stub_status_module \
    --with-http_v2_module \
    --with-http_secure_link_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-openssl="${openssl_dir}" \
    --with-openssl-opt=enable-ec_nistp_64_gcc_128 \
    --with-openssl-opt=no-nextprotoneg \
    --with-openssl-opt=no-weak-ssl-ciphers \
    --with-openssl-opt=no-ssl3 \
    --with-openssl-opt=no-ssl2 \
    --with-openssl-opt=enable-tls1_2 \
    --with-openssl-opt=enable-tls1_3 \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-cc-opt='-g -O2 -fPIE -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2' \
    --with-ld-opt='-Wl,-Bsymbolic-functions -fPIE -pie -Wl,-z,relro -Wl,-z,now' || exit '1'

make --jobs || exit '1'
make install || exit '1'

systemctl enable nginx
systemctl start nginx

exit '0'