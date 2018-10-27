xrdb .xresources
compton -bcr 4 -l-5 -t-5
exec ck-launch-session dbus-launch --sh-syntax --exit-with-session awesome
