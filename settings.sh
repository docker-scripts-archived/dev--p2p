APP=p2p
IMAGE=p2p
CONTAINER=p2p

### ports
SSHD_PORT=2201
HTTPD_PORT=800
PORTS="$SSHD_PORT:22 $HTTPD_PORT:80"

### email account for sending server notifications
GMAIL_ADDRESS=
GMAIL_PASSWD=
