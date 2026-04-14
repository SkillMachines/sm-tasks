#!/bin/bash
set -u

# ── 1. Verify the module is compiled into the nginx binary ───────────────────
if ! nginx -V 2>&1 | grep -q "nginx_upstream_check_module"; then
    echo "FAIL: nginx is not built with nginx_upstream_check_module (run nginx -V to check)"
    exit 3
fi

# ── 2 & 3. All requests return 200, responses only from backend1 and backend2 ─
TOTAL=30
fail_count=0
seen_backend3=0
seen_backend1=0
seen_backend2=0

for i in $(seq 1 ${TOTAL}); do
    body=$(curl -s --connect-timeout 2 --max-time 5 http://127.0.0.1/)
    code=$(curl -s -o /dev/null -w "%{http_code}" \
               --connect-timeout 2 --max-time 5 \
               http://127.0.0.1/)

    if [ "${code}" != "200" ]; then
        fail_count=$((fail_count + 1))
    fi

    echo "${body}" | grep -q '"backend": "backend1"' && seen_backend1=1
    echo "${body}" | grep -q '"backend": "backend2"' && seen_backend2=1
    echo "${body}" | grep -q '"backend": "backend3"' && seen_backend3=1
done

if [ "${fail_count}" -gt 0 ]; then
    echo "FAIL: ${fail_count}/${TOTAL} requests returned non-200 (expected 0 after configuring health checks)"
    exit 3
fi

if [ "${seen_backend1}" -eq 0 ] || [ "${seen_backend2}" -eq 0 ]; then
    echo "FAIL: traffic must be distributed between backend1 and backend2"
    exit 3
fi

if [ "${seen_backend3}" -eq 1 ]; then
    echo "FAIL: backend3 must be excluded from balancing but is still receiving traffic"
    exit 3
fi

# ── 4. /status must serve the module's upstream status page ──────────────────
status_body=$(curl -s --connect-timeout 2 --max-time 5 http://127.0.0.1/status)
if ! echo "${status_body}" | grep -qi "upstream"; then
    echo "FAIL: /status does not return the upstream check status page (add check_status; to the /status location)"
    exit 3
fi

echo "OK: module compiled, all ${TOTAL} requests returned 200, backend1+backend2 active, backend3 excluded, /status available"
exit 0
