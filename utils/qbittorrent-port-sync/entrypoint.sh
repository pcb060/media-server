#!/usr/bin/env bash
set -u

GLUETUN_NAME="${GLUETUN_NAME:-gluetun}"
QBT_HOST="${QBT_HOST:-${GLUETUN_NAME}}"
QBT_PORT="${QBT_PORT:-8081}"

: "${QBT_USER:?QBT_USER must be set}"
: "${QBT_PASS:?QBT_PASS must be set}"

cookie=$(mktemp)
trap 'rm -f "$cookie"' EXIT

login() {
  curl -s -c "$cookie" --max-time 5 \
    -d "username=${QBT_USER}&password=${QBT_PASS}" \
    "http://${QBT_HOST}:${QBT_PORT}/api/v2/auth/login" >/dev/null
}

qbt_current_port() {
  curl -s -b "$cookie" --max-time 5 \
    "http://${QBT_HOST}:${QBT_PORT}/api/v2/app/preferences" |
    python3 -c 'import json,sys; print(json.load(sys.stdin).get("listen_port"))' 2>/dev/null
}

qbt_set_port() {
  local port=$1
  curl -s -b "$cookie" --max-time 5 -X POST \
    --data-urlencode "json={\"listen_port\":${port}}" \
    "http://${QBT_HOST}:${QBT_PORT}/api/v2/app/setPreferences" >/dev/null
}

glue_port() {
  docker exec "${GLUETUN_NAME}" cat /tmp/gluetun/forwarded_port 2>/dev/null | tr -d '[:space:]'
}

restart_qbt() {
  docker restart qbittorrent >/dev/null 2>&1
}

echo "[sync] starting; waiting for qbittorrent to come up..."
for _ in $(seq 1 60); do
  if login 2>/dev/null; then
    break
  fi
  sleep 5
done
echo "[sync] qbittorrent reachable"

current=""
last_event_ts=0

while true; do
  if ! login 2>/dev/null; then
    sleep 5
    continue
  fi

  cur=$(qbt_current_port 2>/dev/null || echo "")
  gp=$(glue_port 2>/dev/null || echo "")

  if [ -z "$gp" ]; then
    echo "[$(date +%H:%M:%S)] gluetun has no forwarded port yet"
  elif ! [[ "$gp" =~ ^[0-9]+$ ]]; then
    echo "[$(date +%H:%M:%S)] gluetun port unreadable: ${gp}"
  elif [ "$cur" != "$gp" ]; then
    echo "[$(date +%H:%M:%S)] port change: ${cur:-?} -> ${gp}; restarting qbittorrent"
    qbt_set_port "$gp" || echo "[sync] setPreferences failed"
    restart_qbt || true
    sleep 10
    login || true
    current="$gp"
  else
    echo "[$(date +%H:%M:%S)] in sync (port=${cur})"
  fi

  if [ -S /var/run/docker.sock ]; then
    timeout 120 docker events \
      --filter "container=${GLUETUN_NAME}" \
      --filter event=restart \
      --filter event=die \
      --filter event=start \
      --filter event=health_status \
      >/dev/null 2>&1 || true
  else
    sleep 60
  fi
done
