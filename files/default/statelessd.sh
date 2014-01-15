#! /bin/sh

### BEGIN INIT INFO
# Provides:          statelessd
# Required-Start:    $network $local_fs $remote_fs
# Required-Stop:     $remote_fs
# Should-Start:      $named
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: HTTP to RabbitMQ Publishing Proxy
# Description:       HTTP to RabbitMQ Publishing Proxy
### END INIT INFO

NAME=statelessd
CONFIG=/etc/statelessd.yaml
DAEMON=/usr/local/bin/tinman
DAEMON_OPTS="-c $CONFIG"
DESC="HTTP to RabbitMQ Publishing Proxy"

# define LSB log_* functions.
. /lib/lsb/init-functions

check_daemon() {
  if [ ! -x $DAEMON ]; then
    log_action_msg "$DAEMON not found" || true
    log_end_msg 1 || false
    exit 1
  fi
}

check_config() {
  if [ ! -e $CONFIG ]; then
    log_action_msg "Configuration file $CONFIG not found" || true
    log_end_msg 1 || false
    exit 1
  fi
}

check_pid() {
  PIDDIR=$(dirname $PIDFILE)
  if [ ! -d $PIDDIR ]; then
    install -m 777 -o statelessd -g statelessd -d $PIDDIR
    log_action_msg "PID directory was not found and created" || true
  fi;
}

PIDFILE=$(sed -n -e 's/^[ ]*pidfile[ ]*:[ ]*//p' -e 's/[ ]*$//' $CONFIG)

export PATH="${PATH:+$PATH:}/usr/sbin:/sbin/:usr/local/sbin:/usr/local/bin"

case "$1" in
  start)
    log_daemon_msg "Starting $DESC" "$NAME" || true
    check_daemon
    check_config
    check_pid

    if [ -s $PIDFILE ] && kill -0 $(cat $PIDFILE) > /dev/null 2>&1; then
      log_action_msg "apparently already running" || true
      log_end_msg 0 || true
      exit 0
    fi

    if start-stop-daemon --oknodo --start --pidfile $PIDFILE --exec $DAEMON -- $DAEMON_OPTS; then
      log_end_msg 0 || true
    else
      log_end_msg 1 || false
    fi
  ;;
  stop)
    log_daemon_msg "Stopping $DESC" "$NAME" || true
    check_daemon

    if start-stop-daemon --oknodo --stop --pidfile $PIDFILE; then
      log_end_msg 0 || true
    else
      log_end_msg 1 || false
    fi
  ;;
  status)
   status_of_proc -p $PIDFILE $DAEMON $NAME && exit 0 || exit $?
   ;;
  restart|force-reload)
  $0 stop
  $0 start
  ;;
  *)
    echo "Usage: /etc/init.d/$NAME {start|stop|restart|force-reload}" >&2
  exit 1
  ;;
esac

exit 0