
#!/bin/bash

srcs="
  ~/.config
  ~/.xinitrc
  ~/.fonts
  ~/.xresources
  ~/.zshrc
  /etc/portage
  /usr/src/linux/.config
"
[[ ! -z "$1" ]] && dest="$1" || dest="."
echo "Copying to $dest."

for src in $srcs; do
  cp -rav ~/.config $dest
done
