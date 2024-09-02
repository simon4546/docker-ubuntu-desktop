#!/bin/sh
## initialize environment
if [ ! -f "/docker_config/init_flag" ]; then
    # create user
    groupadd -g $GID $USER
    useradd --create-home --no-log-init -u $UID -g $GID $USER
    usermod -aG sudo $USER
    echo "$USER:$PASSWORD" | chpasswd
    chsh -s /bin/bash $USER
    # extra env init for developer
    if [ -f "/docker_config/env_init.sh" ]; then
        bash /docker_config/env_init.sh
    fi
    # custom env init for user
    if [ -f "/docker_config/custom_env_init.sh" ]; then
        bash /docker_config/custom_env_init.sh
    fi
    echo  "ok" > /docker_config/init_flag
fi
## startup
# custom startup for user
if [ -f "/docker_config/custom_startup.sh" ]; then
	bash /docker_config/custom_startup.sh
fi
# start sshd & remote desktop
/usr/sbin/sshd
start_xrdp_services() {
    # Preventing xrdp startup failure
    rm -rf /var/run/xrdp-sesman.pid
    rm -rf /var/run/xrdp.pid
    rm -rf /var/run/xrdp/xrdp-sesman.pid
    rm -rf /var/run/xrdp/xrdp.pid

    # Use exec ... to forward SIGNAL to child processes
    xrdp-sesman && exec xrdp -n
}
if [ "${REMOTE_DESKTOP}" = "xrdp" ]; then
    echo "start xrdp"
    start_xrdp_services
    echo "xrdp started"
    tail -f /dev/null
elif [ "${REMOTE_DESKTOP}" = "kasmvnc" ]; then
    echo "start kasmvnc"
    rm -rf /tmp/.X1000-lock /tmp/.X11-unix/X1000
    su $USER -c "vncserver :1000 -select-de xfce \
             -interface 0.0.0.0 -websocketPort 4000 -RectThreads $VNC_THREADS"
    su $USER -c "pulseaudio --start"
    tail -f /home/$USER/.vnc/*.log
else
    echo  "unspported remote desktop: $REMOTE_DESKTOP"
fi
