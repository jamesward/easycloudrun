#!/bin/bash

if [[ ! -d "/etc/custom_services" ]]; then
  mkdir /etc/custom_services
fi

cat <<'EOF' > /etc/custom_services/watcher.sh
#!/bin/bash
while true; do
  uptime=$(cat /proc/uptime | awk '{printf "%0.f", $1}')
  num_all_docker_ps=$(docker ps | tail -n +2 | wc -l)
  num_user_docker_ps=$(docker ps | grep -v stackdriver-logging-agent | tail -n +2 | wc -l)
  if ((num_all_docker_ps == "1")) && ((num_user_docker_ps == "0")) && ((uptime > 60)); then
    echo "no docker processes running, so shutting down"
    poweroff
  fi
  sleep 1
done
EOF

chmod +x /etc/custom_services/watcher.sh

cat <<'EOF' > /etc/systemd/system/watcher.service
[Unit]
Description=watcher service
[Service]
Type=simple
ExecStart=/etc/custom_services/watcher.sh
[Install]
WantedBy=multi-user.target
EOF

systemctl start watcher
