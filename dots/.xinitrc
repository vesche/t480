xrdb -merge ~/.Xresources

# java gui fix
export _JAVA_AWT_WM_NONREPARENTING=1

{
sleep 1; \
xrandr --output eDP1 --mode 1920x1080; \
nitrogen --set-centered /home/user/pics/orangebird.jpg; \
/home/user/.config/polybar/launch
} &

exec bspwm
