xrdb -merge ~/.Xresources

# java gui fix
export _JAVA_AWT_WM_NONREPARENTING=1

# go
export GOPATH=/home/user/go

# start x
{
sleep 1; \
xrandr --output eDP-1 --mode 1920x1080; \
nitrogen --set-centered /home/user/pics/orangebird.jpg; \
/home/user/.config/polybar/launch
} &

# start ootbat
/opt/ootbat/ootbat &

# start away
away &

# disable auditctl
auditctl -e0

exec bspwm