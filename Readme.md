This script is used on Archlinux:

This script takes the content of a usb's folder and syncs it locally on a machine.
A progress image is displayed, a success image and a failure image is displayed accordingly.

You will require to setup a udev rule accordingly to set this up.
This script was made for a very specific project to reuse it you will most likely need to tweak it a bit.

Dependencies for:
Automatic mounting of usb device:
``` 
install udisks2 &&
install ldm aur
```

Detecting when the usb is connected and launching the script:
Udev rule:
 https://unix.stackexchange.com/questions/229987/udev-rule-to-match-any-usb-storage-device
