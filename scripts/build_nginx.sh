#!/bin/bash
# Build NGINX and modules on Heroku.
# This program is designed to run in a web dyno provided by Heroku.
# We would like to build an NGINX binary for the builpack on the
# exact machine in which the binary will run.
# Our motivation for running in a web dyno is that we need a way to
# download the binary once it is built so we can vendor it in the buildpack.
#
# Once the dyno has is 'up' you can open your browser and navigate
# this dyno's directory structure to download the nginx binary.

NGINX_VERSION=${NGINX_VERSION-1.10.0}
PCRE_VERSION=${PCRE_VERSION-8.38}
HEADERS_MORE_VERSION=${HEADERS_MORE_VERSION-0.29}
NGX_DEVEL_KIT_VERSION=${NGX_DEVEL_KIT_VERSION-0.3.0}
SET_MISC_NGINX_MODULE_VERSION=${SET_MISC_NGINX_MODULE_VERSION-0.31}

nginx_tarball_url=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
pcre_tarball_url=https://sourceforge.net/projects/pcre/files/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.bz2
headers_more_nginx_module_url=https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_VERSION}.tar.gz
ngx_devel_kit_url=https://github.com/simpl/ngx_devel_kit/archive/v${NGX_DEVEL_KIT_VERSION}.tar.gz
set_misc_nginx_module_url=https://github.com/openresty/set-misc-nginx-module/archive/v${SET_MISC_NGINX_MODULE_VERSION}.tar.gz

temp_dir=$(mktemp -d /tmp/nginx.XXXXXXXXXX)

echo "Serving files from /tmp on $PORT"
cd /tmp
python -m SimpleHTTPServer $PORT &

cd $temp_dir
echo "Temp dir: $temp_dir"

echo "Downloading $nginx_tarball_url"
curl -L $nginx_tarball_url | tar xzv

echo "Downloading $pcre_tarball_url"
(cd nginx-${NGINX_VERSION} && curl -L $pcre_tarball_url | tar xvj )

echo "Downloading $headers_more_nginx_module_url"
(cd nginx-${NGINX_VERSION} && curl -L $headers_more_nginx_module_url | tar xvz )

echo "Downloading $ngx_devel_kit_url"
(cd nginx-${NGINX_VERSION} && curl -L $ngx_devel_kit_url | tar xvz )

echo "Downloading $set_misc_nginx_module_url"
(cd nginx-${NGINX_VERSION} && curl -L $set_misc_nginx_module_url | tar xvz )

(
	cd nginx-${NGINX_VERSION}
	sudo ./configure \
    --with-http_ssl_module \
		--with-http_secure_link_module \
		--with-pcre=pcre-${PCRE_VERSION} \
		--prefix=/tmp/nginx \
		--add-module=/${temp_dir}/nginx-${NGINX_VERSION}/headers-more-nginx-module-${HEADERS_MORE_VERSION} \
		--add-module=/${temp_dir}/nginx-${NGINX_VERSION}/ngx_devel_kit-${NGX_DEVEL_KIT_VERSION} \
   	--add-module=/${temp_dir}/nginx-${NGINX_VERSION}/set-misc-nginx-module-${SET_MISC_NGINX_MODULE_VERSION}
	sudo make install
)

while true
do
	sleep 1
	echo "."
done
