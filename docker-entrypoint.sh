#!/bin/bash
set -eu

cleanup() {
    trap - SIGTERM SIGINT EXIT

    echo "Stopping danted..."
    pkill -TERM -x danted 2>/dev/null || true

    echo "Stopping MotionPro..."
    MotionPro -s 2>&1 || true

    sleep 1

    echo "Stopping vpnd..."
    pkill -TERM -x vpnd 2>/dev/null || true
}

trap cleanup SIGTERM SIGINT EXIT

vpnd 2>&1

"$@" 2>&1

while true; do
    VPN_STATUS=$(MotionPro -a)
    if [[ "$VPN_STATUS" == "VPN Status: connected" ]]; then
        break
    else
        echo "$VPN_STATUS"
        sleep 1
    fi
done

while true; do
    DNS_SERVER=$(grep -a "dns server" /var/log/MotionPro/MotionPro_*.log 2>/dev/null | awk '{print $NF}' | tail -n 1)

    if [ -n "$DNS_SERVER" ]; then
        echo "Found DNS server: $DNS_SERVER"
        echo "nameserver $DNS_SERVER" > /etc/resolv.conf
        echo "Updated /etc/resolv.conf with DNS server: $DNS_SERVER"
        break
    else
        echo "DNS server not found."
        sleep 1
    fi
done

danted 2>&1 &

while true; do
    VPN_STATUS=$(MotionPro -a)
    if [[ "$VPN_STATUS" == "VPN Status: connected" ]]; then
        sleep 1
    elif [[ "$VPN_STATUS" == "VPN Status: connecting" ]]; then
        echo "$VPN_STATUS"
        sleep 1
    else
        echo "$VPN_STATUS"
        break
    fi
done
