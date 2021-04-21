# Android 11 video capture intent test
set -e

adb -d -v shell "am start -a android.media.action.IMAGE_CAPTURE" -W
