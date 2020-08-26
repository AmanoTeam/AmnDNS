#!/bin/bash

nginx_version='1.19.2'
pcre_version='8.44'
zlib_version='1.2.11'

nginx_file="${HOME}/nginx.tar.gz"
pcre_file="${HOME}/pcre.tar.gz"
zlib_file="${HOME}/zlib.tar.gz"

nginx_dir="${HOME}/nginx-${nginx_version}"
pcre_dir="${HOME}/pcre-${pcre_version}"
zlib_dir="${HOME}/zlib-${zlib_version}"
boringssl_dir="${HOME}/quiche/deps/boringssl"
quiche_dir="${HOME}/quiche"
headers_more_dir="${HOME}/headers-more-nginx-module"
http_proxy_connect_dir="${HOME}/http_proxy_connect"

nginx_systemd="[Unit]\nDescription=A high performance web server and a reverse proxy server\nAfter=network.target\n\n[Service]\nType=forking\nPIDFile=/run/nginx.pid\nExecStartPre=/usr/sbin/nginx -t -q -g 'daemon on; master_process on;'\nExecStart=/usr/sbin/nginx -g 'daemon on; master_process on;'\nExecReload=/usr/sbin/nginx -g 'daemon on; master_process on;' -s reload\nExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx.pid\nTimeoutStopSec=5\nKillMode=mixed\n\n[Install]\nWantedBy=multi-user.target"
nginx_ufw='[Nginx HTTP]\ntitle=Web Server (Nginx, HTTP)\ndescription=Small, but very powerful and efficient web server\nports=80/tcp\n\n[Nginx HTTPS]\ntitle=Web Server (Nginx, HTTPS)\ndescription=Small, but very powerful and efficient web server\nports=443/tcp\n\n[Nginx Full]\ntitle=Web Server (Nginx, HTTP + HTTPS)\ndescription=Small, but very powerful and efficient web server\nports=80,443/tcp'

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
    --no-keepalive

cd "${HOME}"

tar --extract --file="${nginx_file}"
tar --extract --file="${pcre_file}"
tar --extract --file="${zlib_file}"

git clone --recursive \
    --branch 'master' \
    'https://github.com/cloudflare/quiche' \
    "${quiche_dir}"

git clone --branch 'master' \
     --depth '1' \
    'https://github.com/openresty/headers-more-nginx-module' \
    "${headers_more_dir}"

git clone --branch 'master' \
     --depth '1' \
    'https://github.com/chobits/ngx_http_proxy_connect_module' \
    "${http_proxy_connect_dir}"

cd "${nginx_dir}"

patch -p01 < "${quiche_dir}/extras/nginx/nginx-1.16.patch"
patch -p1 < "${http_proxy_connect_dir}/patch/proxy_connect_rewrite_1018.patch"

./configure --prefix=/usr/share/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/run/nginx.pid \
    --lock-path=/var/lock/nginx.lock \
    --user=www-data \
    --group=www-data \
    --build="$(lsb_release -si) quiche-$(git --git-dir=${quiche_dir}/.git rev-parse --short HEAD)" \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
    --http-proxy-temp-path=/var/lib/nginx/proxy \
    --http-scgi-temp-path=/var/lib/nginx/scgi \
    --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
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
    --with-http_v3_module \
    --with-http_secure_link_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-openssl="${boringssl_dir}" \
    --with-quiche="${quiche_dir}" \
    --add-module="${headers_more_dir}" \
    --add-module="${http_proxy_connect_dir}" \
    --with-cc-opt='-g -O2 -fPIE -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2' \
    --with-ld-opt='-Wl,-Bsymbolic-functions -fPIE -pie -Wl,-z,relro -Wl,-z,now'

make -j

cp -r '/etc/nginx/sites-available' "${HOME}"
cp -r '/etc/nginx/streams' "${HOME}"

systemctl stop nginx
systemctl disable nginx

rm --force --recursive '/etc/nginx'

apt --assume-yes purge --auto-remove 'nginx*'

make install

echo -e "${nginx_systemd}" > '/etc/systemd/system/nginx.service'
echo -e "${nginx_ufw}" > '/etc/ufw/applications.d/nginx'

mkdir --parents '/var/lib/nginx' \
    '/etc/nginx/sites-available' \
    '/etc/nginx/sites-enabled' \
    '/etc/nginx/streams'

cp -r "${HOME}/sites-available" '/etc/nginx'
cp -r "${HOME}/streams" '/etc/nginx'

ln -s '/etc/nginx/sites-available/'* '/etc/nginx/sites-enabled/'

sed --regexp-extended --in-place \
    's/^(http\s\{)/\1\n    include \/etc\/nginx\/sites-available\/*;\n    server_tokens off;/g' \
    '/etc/nginx/nginx.conf'

echo -e 'stream {\n    include /etc/nginx/streams/*;\n}' >> '/etc/nginx/nginx.conf'

systemctl enable nginx.service
systemctl start nginx.service

rm --force --recursive "${nginx_dir}" \
    "${pcre_dir}" \
    "${zlib_dir}" \
    "${quiche_dir}" \
    "${headers_more_dir}" \
    "${http_proxy_connect_dir}" \
    "${nginx_file}" \
    "${pcre_file}" \
    "${zlib_file}" \
    "${openssl_file}"

exit '0'