openssl_dir="${HOME}/openssl"

git clone --branch 'OpenSSL_1_1_1-stable' \
     --recursive \
    'https://github.com/openssl/openssl' \
    "${openssl_dir}"

git clone --branch 'master' \
     --depth '1' \
    'https://github.com/NLnetLabs/unbound'

cd unbound

sudo apt install libmnl-dev libevent-dev libsystemd-dev swig libprotobuf-c-dev

./configure --enable-subnet \
    --enable-tfo-client \
    --enable-tfo-server \
    --enable-event-api \
    --enable-ipsecmod \
    --enable-ipset \
    --with-pthreads \
    --with-ssl="${openssl_dir}" \
    --with-libmnl \
    --build=x86_64-linux-gnu \
    --prefix=/usr \
    --includedir=/usr/include \
    --mandir=/usr/share/man \
    --infodir=/usr/share/info \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --libdir=/usr/lib/x86_64-linux-gnu \
    --libexecdir=/usr/lib/x86_64-linux-gnu \
    --disable-rpath \
    --with-pidfile=/run/unbound.pid \
    --with-rootkey-file=/var/lib/unbound/root.key \
    --with-libevent \
    --with-pythonmodule \
    --enable-subnet \
    --enable-dnstap \
    --enable-systemd \
    --with-chroot-dir= \
    --with-dnstap-socket-path=/run/dnstap.sock \
    --libdir=/usr/lib
    
make -j

make install