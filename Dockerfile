FROM debian:buster

ENV LANG C.UTF-8
WORKDIR /opt/intelmq-manager

COPY . /opt/intelmq-manager
COPY ./intelmq_manager/* /var/www/html/

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    gcc \
    python3-nose \
    python3-yaml \
    python3-cerberus \
    python3-requests-mock \
    python3-dev \
    python3-setuptools \
    python3-pip \
    git \
    libapache2-mod-php \
    php-json \
    sudo

RUN rm -rf /var/lib/apt/lists/*

RUN useradd -d /opt/intelmq -U -s /bin/bash intelmq
RUN usermod -a -G intelmq www-data

RUN chown -R www-data.www-data /var/www/html/
RUN mkdir -p /opt/intelmq/etc/manager/

RUN touch /opt/intelmq/etc/manager/positions.conf \
    && chgrp www-data /opt/intelmq/etc/manager/positions.conf \
    && chmod g+w /opt/intelmq/etc/manager/positions.conf

RUN pip3 install hug mako
RUN pip3 install --no-cache-dir -e .
RUN chown -R intelmq:intelmq /opt/intelmq

USER intelmq

ENTRYPOINT [ "hug", "-f", "/var/www/html/serve.py", "-p8080" ]
