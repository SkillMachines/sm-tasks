FROM --platform=amd64 nexus.devinside.tech/skillmachines-images/base-ubuntu:1.0.1

USER root

RUN apt-get update \
	&& apt-get install -y --no-install-recommends cron postgresql-16 \
	&& rm -rf /var/lib/apt/lists/*

RUN systemctl enable cron postgresql@16-main

COPY initdb.sql create_db.sql /usr/local/bin
COPY dbdump.sh cron_task.sh db-migrate.sh /usr/local/bin/
COPY db-migrate.service /etc/systemd/system/db-migrate.service
COPY check.sh /opt/skillmachines/scripts/check.sh
COPY init.sh /init.sh

COPY ./dm-mod.ko /root/dm-mod.ko
COPY ./stuck_dm.ko /root/stuck_dm.ko

RUN mkdir -p /lib/modules/5.10.234+/kernel/drivers/
COPY dm-mod.ko /lib/modules/5.10.234+/dm-mod.ko
COPY stuck_dm.ko /lib/modules/5.10.234+/stuck_dm.ko
COPY mountfs.service /etc/systemd/system/mountfs.service
COPY mount.sh /usr/local/bin/mount.sh
COPY init.sh /init.sh

RUN systemctl enable mountfs.service

RUN mkdir -p /dumps \
	&& chmod +x /usr/local/bin/dbdump.sh /usr/local/bin/cron_task.sh /usr/local/bin/db-migrate.sh /opt/skillmachines/scripts/check.sh /usr/local/bin/mount.sh \
	&& systemctl enable db-migrate.service \
	&& echo "* * * * * /usr/local/bin/cron_task.sh" | crontab -