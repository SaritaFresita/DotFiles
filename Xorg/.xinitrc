compton &
setxkbmap -layout gb
xrandr --output DP1 --mode 1600x900 --right-of eDP1
xhost +SI:localuser:$USER
feh --bg-scale ~/Repositories/DotFiles/wallpaper
exec emacs
