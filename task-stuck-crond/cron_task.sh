#!/bin/bash

set -u

SCRIPT_DIR="/usr/local/bin"
DBDUMP_SCRIPT="${SCRIPT_DIR}/dbdump.sh"
LOG_FILE="/mnt/cron_task.log"

mkdir -p "$(dirname "${LOG_FILE}")"

start_epoch="$(date +%s)"
start_human="$(date '+%Y-%m-%d %H:%M:%S')"
echo "[${start_human}] START dbdump" >> "${LOG_FILE}" && sync

if /bin/bash "${DBDUMP_SCRIPT}"; then
	exit_code=0
	status="OK"
else
	exit_code=$?
	status="FAIL(${exit_code})"
fi

end_epoch="$(date +%s)"
end_human="$(date '+%Y-%m-%d %H:%M:%S')"
duration="$((end_epoch - start_epoch))"

echo "[${end_human}] END dbdump status=${status} duration=${duration}s" >> "${LOG_FILE}" && sync

exit "${exit_code}"