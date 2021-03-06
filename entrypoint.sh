#!/bin/bash
set -e

function request_certs {
  if [ ! -f get-certs.sh.sha1 ]; then
    sha1sum get-certs.sh > get-certs.sh.sha1
    bash get-certs.sh
  else
    exec 3>&2
    exec 2> /dev/null
    result=$(sha1sum -c get-certs.sh.sha1 | cut -d: -f 2 | xargs 2>/dev/null)
    exec 2>&3
    if [ "$result" != "OK" ]; then
      echo "* Changes detected"
      bash get-certs.sh
    fi
  fi
  sha1sum get-certs.sh > get-certs.sh.sha1
}

function start_haproxy {
  echo -e "\n * Starting HAProxy"
  haproxy -D -p /var/run/haproxy.pid -f haproxy.cfg
  echo -e "   ...done.\n"
}

function stop_haproxy {
  echo " * Stopping HAProxy"
	for pid in $(cat /var/run/haproxy.pid); do
    kill $pid
	done
	rm -f /var/run/haproxy.pid
  echo -e "   ...done.\n"
}

function renew_certs {
  certbot renew --standalone
}

mkdir -p /opt/haproxy/ssl

python3 gen_conf.py
request_certs

cat haproxy.cfg

while true; do
  bash load-certs.sh
  start_haproxy
  sleep 86400 # 1 day
  stop_haproxy
  renew_certs
done