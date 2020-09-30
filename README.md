# Reverse Proxy Nginx

![Nginx Logo](https://raw.githubusercontent.com/docker-library/docs/01c12653951b2fe592c1f93a13b4e289ada0e3a1/nginx/logo.png)

A Nginx HTTPS reverse proxy is an intermediary proxy service which takes a client request, passes it on to one or more servers, and subsequently delivers the server’s response back to the client. While most common applications are able to run as web server on their own, the Nginx web server is able to provide a number of advanced features such as load balancing, TLS/SSL capabilities and acceleration that most specialized applications lack. By using a Nginx reverse proxy all applications can benefit from these features.

After the installation you can reach Jenkins and Portainer throw subdomains.

![latest 0.7.0](https://img.shields.io/badge/latest-1.0.0-green.svg?style=flat)
![nginx 1.17.8](https://img.shields.io/badge/nginx-1.17.8-brightgreen.svg) ![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)
![Build](https://github.com/tmillich/reverse_proxy/workflows/Build/badge.svg)
![Build SSL](https://github.com/tmillich/reverse_proxy/workflows/Build%20SSL/badge.svg)


## Prerequisites

- **Docker**
- **Docker-Compose**

## Getting Started

You can choose if you wanna use TLS/SSL capabilites or not. If you dont wanna use SSL then skip the [Optional] parts and adapt the symlinks under `./nginx/config/sites-enabled/*`:

For no TLS/SSL capabilites execute:
```bash
ln -s ./nginx/config/sites-available/default ./nginx/config/sites-enabled/default
ln -s ./nginx/config/sites-available/jenkins.localhost ./nginx/config/sites-enabled/jenkins.localhost
ln -s ./nginx/config/sites-available/portainer.localhost ./nginx/config/sites-enabled/portainer.localhost
```

and delete or comment the positions in der Dockerfile where you copying the certs and keys.

```Dockerfile
FROM nginx:1.19.2

# Removing old configs
RUN rm -rf /usr/share/nginx/html
RUN rm -rf /etc/nginx

# Coping configsalt text
COPY ./nginx/html /usr/share/nginx/html
COPY ./nginx/config /etc/nginx

# Coping keys
# COPY ./nginx/certs/*.crt /etc/ssl/certs/
# COPY ./nginx/certs/*.key /etc/ssl/private/
# COPY ./nginx/certs/dhparam.pem /etc/nginx/
```

For TLS/SSL capabilites execute:
```bash
ln -s ./nginx/config/sites-available/default.ssl ./nginx/config/sites-enabled/default.ssl
ln -s ./nginx/config/sites-available/jenkins.localhost.ssl ./nginx/config/sites-enabled/jenkins.localhost.ssl
ln -s ./nginx/config/sites-available/portainer.localhost.ssl ./nginx/config/sites-enabled/portainer.localhost.ssl
```


### 1. [Optional] Creating the SSL Certificate

Create dir for key and certs.

```bash
mkdir ./nginx/certs
```

Either create a self-signed key and certificate pair with OpenSSL or use your own certificate pair and place it under `./nginx/certs`.

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./nginx/certs/nginx-selfsigned.key -out ./nginx/certs/nginx-selfsigned.crt
```

While we are using OpenSSL, we should also create a strong Diffie-Hellman group, which is used in negotiating Perfect Forward Secrecy with clients.
```bash
openssl dhparam -out ./nginx/certs/dhparam.pem 4096
```
### 2. Configuring Nginx

To add other services simply add more \*.conf Files under `./nginx/config/sites-available/` and pick the sites by adding Symlinks to `./nginx/config/sites-enabled/`.

```bash
ln -s ./nginx/config/sites-available/<docker-service> ./nginx/config/sites-enabled/<docker-service>
```

### 3. Run Docker-Compose

```bash
docker-compose up -d
```

### 4. [Optional] Trust Certificate locally

We need to add the generated SSL certificate to the database that browser uses. For this we will use “certutil” utility which is part of the libnss3-tools package.
```bash
sudo apt-get update
sudo apt-get install libnss3-tools
```
To add certificate to the database run the following command.
```bash
certutil -d sql:$HOME/.pki/nssdb -A -t "CT,c,c" -n "localhost" -i ./nginx/certs/nginx-selfsigned.crt
```
*localhost* represents the local domain you wanna choose. By choosing an other name simply replace your local domain name in the command and in the NGINX configurations.

## License

This Repository is under [MIT-Licensing](./LICENSE.md) terms.

