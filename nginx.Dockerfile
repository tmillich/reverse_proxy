FROM nginx:1.19.2

# Removing old configs
RUN rm -rf /usr/share/nginx/html
RUN rm -rf /etc/nginx

# Coping configs
COPY ./nginx/html /usr/share/nginx/html
COPY ./nginx/config /etc/nginx

# Coping keys
COPY ./nginx/certs/*.crt /etc/ssl/certs/
COPY ./nginx/certs/*.key /etc/ssl/private/
COPY ./nginx/certs/dhparam.pem /etc/nginx/
