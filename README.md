# README

CUFE MotionPro Docker Compose 版，通过 Clash 分流。

Based on: [MotionPro Download](https://client.arraynetworks.com.cn:8080/en/troubleshooting)

## USAGE

docker-compose:

```bash
# docker compose up --build -d
docker compose up -d
```

docker:

```bash
# docker build -t motionpro .
docker run -d --name motionpro --restart=unless-stopped \
    --device=/dev/net/tun \
    --cap-add=NET_ADMIN \
    -p 10801:1080 \
    -v ./logs:/var/log/MotionPro \
    lihaotong0712/docker-motionpro:latest \
    MotionPro -h vpn6.cufe.edu.cn -u USER -p PASSWD -l debug -c inf
```
