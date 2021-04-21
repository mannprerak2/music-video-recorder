# music-video-recorder
Record audio on PC, video on android and merge them with sync

## App (only for Macos)
Download from [Releases](https://github.com/mannprerak2/music-video-recorder/releases) or run via `flutter run -d macos` (May not work via vscode, use iterm).

## Record via Command Line
Scripts are in `scripts` folder.

# Setup
### install dependencies ###
Ubuntu -
```bash
sudo apt-get install sox
sudo apt-get install ffmpeg
sudo apt install android-tools-adb
```

Or MacOS -
```
brew install sox ffmpeg android-tools-adb
```

> Note that these commands should be made available via `usr/local/bin`.

### Running script ###
```bash
cd /home/location/of/this/file
./pkmnrec
```
Optionally you can add it to your path variable to run it from anywhere

# How to Record
* Connect your Android phone to your PC, turn on USB debugging on it
* Set your phone to File transfer

### Via Command line -
* Run the script
* Camera app will turn on, but will not start recording, Adjust the Camera as you want
* Press enter to start recording (ctrl + c to stop recording)
* Three files will be created in that location
  * audio.mp3 (Raw audio from pc mic)
  * video.mp4 (Raw video + audio from phone)
  * project.mp4 ( Video from phone + audio from pc , merged with synchronisation )

Note: pkmnrec is made to work on macOS catalina, use pkmnrec_ubuntu for ubuntu
