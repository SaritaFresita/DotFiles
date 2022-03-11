compton &
setxkbmap -layout gb &
xhost +SI:localuser:$USER
xrandr --output DP1 --mode 1600x900 --right-of eDP1 &
feh --bg-scale ~/Repositories/DotFiles/wallpaper &
emacs
