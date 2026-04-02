#!/bin/bash

set -u

CHECK_SCRIPT="/usr/local/bin/cron_task.sh"
TIMEOUT_SECONDS="${CHECK_TIMEOUT_SECONDS:-5}"
POLL_INTERVAL=1

fail() {
	echo "Failed to complete the check within ${TIMEOUT_SECONDS} seconds or the process got stuck. Exiting."
	exit 3
}

if [ ! -x "${CHECK_SCRIPT}" ]; then
	fail
fi

/bin/bash "${CHECK_SCRIPT}" >/dev/null 2>&1 &
check_pid=$!
start_epoch="$(date +%s)"

while kill -0 "${check_pid}" >/dev/null 2>&1; do
	current_state="$(ps -o state= -p "${check_pid}" 2>/dev/null | tr -d '[:space:]')"
	if [ "${current_state}" = "D" ]; then
		kill -TERM "${check_pid}" >/dev/null 2>&1 || true
		sleep 1
		kill -KILL "${check_pid}" >/dev/null 2>&1 || true
		fail
	fi

	elapsed="$(( $(date +%s) - start_epoch ))"
	if [ "${elapsed}" -ge "${TIMEOUT_SECONDS}" ]; then
		kill -TERM "${check_pid}" >/dev/null 2>&1 || true
		sleep 1
		kill -KILL "${check_pid}" >/dev/null 2>&1 || true
		fail
	fi

	sleep "${POLL_INTERVAL}"
done

wait "${check_pid}" >/dev/null 2>&1 || fail

echo "Check passed successfully within ${TIMEOUT_SECONDS} seconds."
exit 0