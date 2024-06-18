xset s off -dpms
xrdb -merge ~/.Xresources

# java gui fix
export _JAVA_AWT_WM_NONREPARENTING=1

# go
export GOPATH=/home/user/go

# xdg
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=bspwm
export GTK_USE_PORTAL=1

# start notifications daemon
dunst &

# start x
{
sleep 1; \
xrandr --output eDP-1 --mode 1920x1080; \
nitrogen --set-centered /home/user/pics/orangebird.jpg; \
/home/user/.config/polybar/launch
} &

# disable auditctl
auditctl -e0

sxhkd &
exec bspwm
