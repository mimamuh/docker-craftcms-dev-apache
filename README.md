# Apache Craftcms 3 Dev - Docker image

A simple docker image based on the [php-apache server](https://hub.docker.com/_/php/) image to host a [craftcms 3](https://craftcms.com/) website for local development only\*. It doesn't include a database, so use a official image like [mysql](https://hub.docker.com/_/mysql/).

\* Really, don't use it for production ...

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

To use this image, make sure that you have [docker installed](https://docs.docker.com/install/) on your local machine.

### Installing

To run craftcms 3 on this image, you need at least a database. The prefered way is to use a official [mysql](https://hub.docker.com/_/mysql/) or [postgres](https://hub.docker.com/_/postgres/) image from [docker hub.](https://hub.docker.com/)

In this example, we use [docker compose](https://docs.docker.com/compose/overview/) to set up a dev environment and use the [image directly from docker hub,]() but you could also clone this repro and [build your own image from it.](https://docs.docker.com/engine/reference/commandline/image_build/)

1.  In your craft cms project root create a `docker-compose.yml` file with the following content:

```
# – docker-compose.yml file
# dev environment for craft3 projects
# don't use it for production
version: "3.2"

services:

  webserver:
    build: .
    image: mimamuh/apache-for-craftcms-dev
    ports:
      - 80:80
      # If you wanna use ssl/https, also open port 443
      #- 443:443
    volumes:
      - .:/var/www/html:cached
      # optionally you could pass your self signed ssl certificates to test with https
      #- ./000-default.conf:/etc/apache2/sites-enabled/000-default.conf:cached
      #- ./certificates/localhost.crt:/etc/apache2/sites-enabled/localhost.crt:cached
      #- ./certificates/localhost.key:/etc/apache2/sites-enabled/localhost.key:cached

  database:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: supersecureroot
      MYSQL_DATABASE: mysql
      MYSQL_USER: mysql
      MYSQL_PASSWORD: supersecuredatabase
    volumes:
      - craft-database:/var/lib/mysql

volumes:
  craft-database:
```

2.  Start your container from your terminal

```
docker-compose up
```

Now you could access your craftcms site through `http://localhost` in your browser.

### Use it with ssl/https

To use ssl/https during develpment additional steps are required. There are multiple ways
how to use a ssl certificate for develpment. In this case we use a simple approach just
using a self-signed ssl certificate.

3.  Create a [self-signed ssl certificat](https://letsencrypt.org/docs/certificates-for-localhost/) using your terminal.
    Instead of using `localhost` you could also create your own testing domain like `example.test` by adding the domain
    as an `alias` to `127.0.0.1` to your machines' [`hosts`](<https://en.wikipedia.org/wiki/Hosts_(file)>) file like so: `127.0.0.1 example.test`.
    In this case, we create a certificate for `localhost` but if you want to create an `alias`, then make sure
    to replace the `value` of `DOMAIN_FOR_CERTIFICATE=localhost` with your `alias` like `DOMAIN_FOR_CERTIFICATE=example.test`.

```
DOMAIN_FOR_CERTIFICATE=localhost \
  && mkdir certificates \
  && openssl req -x509 \
	  -keyout ./certificates/${DOMAIN_FOR_CERTIFICATE}.key \
	  -newkey rsa:2048 \
	  -nodes \
	  -sha256 \
	  -out ./certificates/${DOMAIN_FOR_CERTIFICATE}.crt \
	  -subj '/CN=${DOMAIN_FOR_CERTIFICATE}' \
	  -extensions EXT \
	  -config <( \
		  printf "[dn]\nCN=${DOMAIN_FOR_CERTIFICATE}\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:${DOMAIN_FOR_CERTIFICATE}\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
```

4.  Create a [apache v-host config file](https://httpd.apache.org/docs/2.4/vhosts/examples.html) named `000-default.conf`
    and add the necessary config to use `ssl`.

```
# – 000-default.conf file
<VirtualHost *:443>
  #ServerName example.test

  ServerAdmin webmaster@localhost
  DocumentRoot ${APACHE_DOCUMENT_ROOT}

  # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
  # error, crit, alert, emerg.
  # It is also possible to configure the loglevel for particular
  # modules, e.g.
  #LogLevel info ssl:warn

  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/access.log combined

  SSLEngine on
  SSLCertificateFile /etc/apache2/sites-enabled/my-domain.test.crt
  SSLCertificateKeyFile /etc/apache2/sites-enabled/my-domain.test.key
  #SSLCertificateChainFile /etc/apache2/sites-enabled/CustomRootCA.crt   # only needed when you have one :)
</VirtualHost>

# optionally keep the v-host for port 80 for testing http connections
<VirtualHost *:80>
  #ServerName example.test

  ServerAdmin webmaster@localhost
  DocumentRoot ${APACHE_DOCUMENT_ROOT}

  # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
  # error, crit, alert, emerg.
  # It is also possible to configure the loglevel for particular
  # modules, e.g.
  #LogLevel info ssl:warn

  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

5.  Mount the `self-signed certificate` with the `000-default.conf` config file to `/etc/apache2/sites-enabled/`
    using your `docker-compose.yml`. Uncomment the following lines and make sure to

```
    ports:
        - 80:80
        - 443:443
    volumes:
        - .:/var/www/html
        - ./000-default.conf:/etc/apache2/sites-enabled/000-default.conf
        - ./certificates/localhost.crt:/etc/apache2/sites-enabled/localhost.crt
        - ./certificates/localhost.key:/etc/apache2/sites-enabled/localhost.key
```

## Deployment

Don't use it for deployment, just use it for develpment.

## Image is based on

* [php:7.2-apache-stretch](https://hub.docker.com/_/php/) - Official php apache docker image on docker hub

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/MiMaMuh/docker-craftcms-dev-apache/releases).

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
