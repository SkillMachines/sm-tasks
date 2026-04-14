FROM --platform=amd64 nexus.devinside.tech/skillmachines-images/base-ubuntu:1.0.1

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        nginx \
        python3 \
        curl \
        wget \
        git \
        build-essential \
        libpcre3-dev \
        zlib1g-dev \
        libssl-dev \
        libgd-dev \
    && rm -rf /var/lib/apt/lists/*

# ── Backend servers ───────────────────────────────────────────────────────────
RUN mkdir -p /opt/backends

COPY backends/backend1.py /opt/backends/backend1.py
COPY backends/backend2.py /opt/backends/backend2.py
COPY backends/backend3.py /opt/backends/backend3.py

COPY systemd/backend1.service /etc/systemd/system/backend1.service
COPY systemd/backend2.service /etc/systemd/system/backend2.service
# backend3 service is installed but NOT enabled — port 8003 stays closed
COPY systemd/backend3.service /etc/systemd/system/backend3.service

RUN systemctl enable nginx backend1 backend2

RUN rm -f /etc/nginx/sites-enabled/default

COPY nginx/upstream.conf /etc/nginx/conf.d/upstream.conf
COPY nginx/proxy.conf    /etc/nginx/conf.d/proxy.conf

ARG NGINX_VERSION=1.24.0

RUN mkdir -p /opt/student \
    && cd /opt/student \
    && wget -q "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" \
    && tar xf "nginx-${NGINX_VERSION}.tar.gz" \
    && rm "nginx-${NGINX_VERSION}.tar.gz" \
    && git clone --depth 1 https://github.com/yaoweibin/nginx_upstream_check_module.git \
    && cd nginx-${NGINX_VERSION} \
    && patch -p1 < ../nginx_upstream_check_module/check_1.20.1+.patch \
    && chmod -R a+rX /opt/student

RUN mkdir -p /opt/skillmachines/scripts
COPY check.sh /opt/skillmachines/scripts/check.sh
RUN chmod +x /opt/skillmachines/scripts/check.sh

COPY init.sh /init.sh
RUN chmod +x /init.sh
