#!/bin/bash -x

source /host/settings.sh

cat <<EOF > /etc/cron.daily/update_keys
#!/bin/sh
/home/vnc/update_keys.sh
EOF
chmod +x /etc/cron.daily/update_keys

cat <<EOF > /etc/issue

    _/_/_/      _/_/    _/_/_/        _/      _/  _/      _/    _/_/_/
   _/    _/  _/    _/  _/    _/      _/      _/  _/_/    _/  _/
  _/_/_/        _/    _/_/_/        _/      _/  _/  _/  _/  _/
 _/          _/      _/              _/  _/    _/    _/_/  _/
_/        _/_/_/_/  _/                _/      _/      _/    _/_/_/

EOF

### customize the configuration of the chroot system
/home/vnc/regenerate_special_keys.sh
/home/vnc/change_sshd_port.sh $SSHD_PORT

### customize the configuration of sshd
sed -i /etc/ssh/sshd_config \
    -e 's/^Port/#Port/' \
    -e 's/^PermitRootLogin/#PermitRootLogin/' \
    -e 's/^PasswordAuthentication/#PasswordAuthentication/' \
    -e 's/^X11Forwarding/#X11Forwarding/' \
    -e 's/^UseLogin/#UseLogin/' \
    -e 's/^AllowUsers/#AllowUsers/' \
    -e 's/^Banner/#Banner/'

sed -i /etc/ssh/sshd_config \
    -e '/^### p2p config/,$ d'

cat <<EOF >> /etc/ssh/sshd_config
### p2p config
Port $SSHD_PORT
PermitRootLogin no
PasswordAuthentication no
X11Forwarding no
UseLogin no
AllowUsers vnc
Banner /etc/issue
EOF

### customize the configuration of mini-httpd
sed -i /etc/mini-httpd.conf \
    -e 's/^host/#host/' \
    -e 's/^port/#port/' \
    -e 's/^chroot/#chroot/' \
    -e 's/^nochroot/#nochroot/' \
    -e 's/^data_dir/#data_dir/' \

sed -i /etc/mini-httpd.conf \
    -e '/^### p2p config/,$ d'

cat <<EOF >> /etc/mini-httpd.conf
### p2p config
host=0.0.0.0
port=$HTTPD_PORT
chroot
data_dir=/home/vnc/www
EOF

sed -i /etc/default/mini-httpd \
    -e '/^START/ c START=1'

### modify ssmtp config files
[[ -n $GMAIL_ADDRESS ]] && cat <<_EOF >> /etc/ssmtp/revaliases
vnc:$GMAIL_ADDRESS:smtp.gmail.com:587
_EOF
