
#!/bin/bash

srcs="
  "$HOME"/.config/awesome
  "$HOME"/.config/gtk-3.0
  "$HOME"/.xinitrc
  "$HOME"/.fonts
  "$HOME"/.Xresources
  "$HOME"/.zshrc
  /etc/fonts
  /etc/portage
  /usr/src/linux/.config
"
[[ ! -z "$1" ]] && dest="$1" || dest="."

#for src in $srcs; do
  rsync -rav $srcs $dest
#done
