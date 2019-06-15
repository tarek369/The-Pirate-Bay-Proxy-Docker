FROM alpine
MAINTAINER TK

ENV NGINX_VERSION nginx-1.17.0

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

RUN \
build_pkgs="build-base linux-headers openssl-dev wget zlib-dev git" && \
apk -- update  && \
apk add  --no-cache --virtual .build-dependencies  \
${build_pkgs}  \
pcre-dev && \
wget http://nginx.org/download/${NGINX_VERSION}.tar.gz && \
git clone git://github.com/yaoweibin/ngx_http_substitutions_filter_module.git && \
tar xzvf ${NGINX_VERSION}.tar.gz

RUN cd ${NGINX_VERSION} && \
./configure --with-http_ssl_module --add-module=../ngx_http_substitutions_filter_module && \
make && \
make install && \
cd /usr/local/nginx/ && \
./sbin/nginx && \
./sbin/nginx -s stop && \
cd conf && \
mv nginx.conf nginx.conf-backup

RUN rm -r /${NGINX_VERSION} && \
rm /${NGINX_VERSION}.tar.gz && \
rm -rf /tmp/* && \
apk del ${build_pkgs} && \
rm -rf /var/cache/apk/* && \
rm -rf /ngx_http_substitutions_filter_module

COPY nginx.conf /usr/local/nginx/conf/nginx.conf
EXPOSE 80 
ENTRYPOINT ["/init"]
CMD /usr/local/nginx/sbin/nginx -g "daemon off;"
