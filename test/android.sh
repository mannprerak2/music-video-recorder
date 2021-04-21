set -e

name=$(adb -d shell ls "/storage/emulated/0/DCIM/Camera/VID*" | tail -1)
adb -d pull $name camvideo.mp4