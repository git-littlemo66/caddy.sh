#! /usr/bin/bash
clear

cat << INFO
.......... Caddy一键脚本 & 脚本来自: https://sm.link ..........

github: https://github.com/moqu66/caddy.sh


1. 安装

2. 卸载

INFO

read -p '请选择[1-2]:' input_select

case $input_select in
1)
    install()
    ;;
2)
    uninstall()
    ;;
*)
    echo '请输入正确的选项……'
    exit 1
esac

sleep 1.5s

install() {
sys_arch=$(uname -m)

case $sys_arch in
'amd64' | 'x86_64')
    caddy_arch='amd64'
    ;;
*aarch64* | *armv8*)
    caddy_arch='arm64'
    ;;
*armv7*)
    caddy_arch='armv7'
    ;;
*armv6*)
    caddy_arch='armv6'
    ;;
*armv5*)
caddy_arch='armv5'
;;
*)
    echo '这个辣鸡脚本暂时不支持你的系统。'
    exit 1
esac

latest_version=$(wget -qO- -t1 -T2 https://api.github.com/repos/caddyserver/caddy/releases/latest | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')

curl -OL "https://github.com/caddyserver/caddy/releases/latest/download/caddy_${latest_version:1}_linux_${caddy_arch}.tar.gz"

tar -zxvf caddy_2.2.1_linux_amd64.tar.gz caddy && rm -f caddy_2.2.1_linux_amd64.tar.gz

chmod +x caddy && mv caddy /usr/bin/

useradd -c 'Caddy Web Server' -r -m -g caddy -s /usr/bin/nologin caddy

cat > Caddyfile <<EOF
http://localhost {
    respond "Hello, World"
}
EOF

mv Caddyfile ~caddy/

chmod -R 755 ~caddy

chown -R caddy:caddy ~caddy

cat > caddy.service <<EOF
[Unit]
Description=Caddy
Documentation=https://caddyserver.com/docs/
After=network.target network-online.target
Requires=network-online.target

[Service]
User=caddy
Group=caddy
ExecStart=/usr/bin/caddy run --environ --config /home/caddy/Caddyfile
ExecReload=/usr/bin/caddy reload --config /home/caddy/Caddyfile
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOF

mv caddy.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable caddy
systemctl start caddy
systemctl status caddy
}

uninstall() {
systemctl stop caddy
systemctl disable caddy

rm -f /etc/systemd/system/caddy.service

systemctl daemon-reload

rm -f /usr/bin/caddy

userdel caddy
groupdel caddy
}
