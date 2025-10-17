FROM nginx:1.25

COPY dockerfiles/nginx/default.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www