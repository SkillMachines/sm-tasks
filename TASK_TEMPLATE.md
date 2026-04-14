# Шаблон создания задач для SkillMachines (Firecracker VM)

## Как это работает

Dockerfile описывает **файловую систему виртуальной машины**, которая запускается через Firecracker.
Контейнер не запускается через `docker run` — из него экспортируется rootfs:

```bash
docker export $(docker create <image>) | tar -C /mnt/rootfs -xf -
```

Затем Firecracker монтирует этот rootfs как диск VM и запускает `/init.sh`.

---

## Структура задачи

```
task-<name>/
├── Dockerfile
├── init.sh                          # обязательный — overlay FS + exec /sbin/init
├── check.sh                         # обязательный — автоматический чекер
└── <всё остальное нужное для задачи>
    ├── *.service                    # systemd-юниты
    ├── *.sh                         # скрипты
    └── ...
```

---

## Dockerfile — обязательный шаблон

```dockerfile
FROM --platform=amd64 nexus.devinside.tech/skillmachines-images/base-ubuntu:1.0.1

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        <пакеты> \
    && rm -rf /var/lib/apt/lists/*

# ... копирование файлов, настройка сервисов ...

RUN systemctl enable <service1> <service2>

# Чекер платформы
RUN mkdir -p /opt/skillmachines/scripts
COPY check.sh /opt/skillmachines/scripts/check.sh
RUN chmod +x /opt/skillmachines/scripts/check.sh

# Оверлей-инит — всегда последним
COPY init.sh /init.sh
RUN chmod +x /init.sh
```

**Важно:**
- Нет `CMD` и нет `ENTRYPOINT` — платформа сама вызывает `/init.sh`
- `--platform=amd64` обязателен
- `systemctl enable` работает внутри базового образа без запущенного systemd

---

## init.sh — всегда одинаковый

```sh
#!/bin/sh
set -e

mkdir -p /overlay /overlay/upper /overlay/work /mnt

mount -o remount,ro /
mount -t tmpfs tmpfs /overlay -o size=2G
mkdir -p /overlay/upper /overlay/work
mount -t overlay overlay \
    -o lowerdir=/,upperdir=/overlay/upper,workdir=/overlay/work,index=off \
    /mnt

exec switch_root /mnt /sbin/init
```

Зачем: rootfs Firecracker монтируется как read-only. init.sh делает tmpfs-оверлей поверх него,
чтобы VM могла писать файлы (логи, конфиги и т.д.). Затем передаёт управление systemd.

---

## check.sh — правила написания

- Путь в образе: `/opt/skillmachines/scripts/check.sh`
- **exit 0** — задание выполнено
- **exit 3** — задание не выполнено (стандарт платформы, не менять)
- Не использовать другие коды выхода

```bash
#!/bin/bash
set -u

# проверки...

if [ <условие провала> ]; then
    echo "FAIL: <что именно не так>"
    exit 3
fi

echo "OK: <что проверено>"
exit 0
```

**Принципы хорошего чекера:**
1. Проверять факт, а не способ — студент должен добиться результата, а не повторить конкретные шаги
2. Закрывать все очевидные обходы (убрал проблему вручную вместо автоматического решения)
3. Каждый этап независим — если один упал, сразу exit 3 с понятным сообщением
4. Короткие таймауты в curl (`--connect-timeout 2 --max-time 5`)

---

## Как сломать что-то для студента

Варианты намеренной поломки:

| Способ | Как сделать | Студент видит |
|---|---|---|
| Сервис не запускается | `systemctl enable` не вызывать | порт не слушает |
| Сервис запущен, но не работает | включить юнит, но код слушает не тот порт | `active (running)`, но нет ответа |
| Неправильный конфиг | скопировать заведомо неверный конфиг | ошибки в логах |
| Заблокированный syscall / модуль ядра | кастомный `.ko` (см. task-stuck-crond) | процесс в состоянии D |

---

## Примеры задач в репозитории

### task-stuck-crond
Crond зависает при попытке сделать дамп БД — из-за кастомного kernel-модуля,
который блокирует I/O на примонтированной FS. Студент должен найти причину через strace/ps.

**Ключевые файлы:** `stuck_dm.ko`, `mountfs.service`, `cron_task.sh`, `dbdump.sh`

### task-strace
Бинарник читает конфиг из неправильного пути. Студент должен найти нужный файл через strace.

**Ключевые файлы:** `file.c` (компилируется в multi-stage build), `check.sh`

### task-nginx-balancer (nginx-balancer/)
Один из трёх upstream'ов nginx недоступен. Студент должен собрать nginx с
`nginx_upstream_check_module` и настроить health checks.

**Ключевые файлы:** `backends/`, `nginx/`, `systemd/`, `check.sh`

---

## Чеклист перед финализацией задачи

- [ ] Базовый образ `nexus.devinside.tech/skillmachines-images/base-ubuntu:1.0.1` с `--platform=amd64`
- [ ] `init.sh` скопирован и `chmod +x`
- [ ] `check.sh` в `/opt/skillmachines/scripts/check.sh` и `chmod +x`
- [ ] Нет `CMD` / `ENTRYPOINT`
- [ ] `apt-get` с `--no-install-recommends` и `rm -rf /var/lib/apt/lists/*`
- [ ] Поломка не обходится тривиально (restart сервиса, ручное удаление из конфига и т.д.)
- [ ] `check.sh` закрывает все очевидные обходы
- [ ] `exit 3` при провале, `exit 0` при успехе — никаких других кодов
