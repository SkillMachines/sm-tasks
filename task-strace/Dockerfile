FROM gcc:trixie AS build

ARG DEBIAN_FRONTEND=noninteractive

COPY file.c /file.c
RUN gcc /file.c -o /file


FROM --platform=amd64 nexus.devinside.tech/skillmachines-images/base-ubuntu:1.0.1

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y strace \
    && rm -rf /var/lib/apt/lists/*

RUN rm /etc/sudoers.d/lab_nopasswd || true
RUN rm /etc/sudoers.d/lab-nopasswd || true

RUN mkdir -p /app

COPY --from=build /file /app/config_reader
COPY check.sh /opt/skillmachines/scripts/check.sh

RUN chmod a+x /app/config_reader \
    && chmod a+x /opt/skillmachines/scripts/check.sh


RUN echo "port: 8080" > /app/config.yaml
RUN echo "port: 25565" > /etc/config.yaml

RUN ln -s /app/config_reader /usr/local/bin/config_reader
RUN chmod 777 /etc/config.yaml
RUN chmod 444 /app/config.yaml

WORKDIR /app

USER lab

CMD ["/bin/bash"]