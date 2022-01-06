# alarm_app

An alarm Flutter project.

## Environment:

- Windows 10
- Dart 2.14.4
- Flutter 2.5.3 (stable channel)
- Android Studio 3.6
- VSCode 1.63.2

## Deployment

1. Make sure you can run Flutter project in your local PC.
2. Make sure to connect your testing device (this project was tested on Android OS only).
3. Download source code from [This Github Repository](https://github.com/jordanvalentino/alarm_app).
4. Extract files.
5. Open command prompt (Windows) inside the extracted source code directory.
6. On the command prompt, type this to install all necessary dependencies :
   > flutter pub get
7. And then type this to run flutter in your device :
   > flutter run --no-sound-null-safety
8. Note that this project is using non-null-safe package so make sure to add _--no_sound-null-safety_ flag.
9. And also, please note that some packages may be detected as obsolete/deprecated when run on different computer.

## User Manual

- To change the hour-hand of the clock, hold and drag vertically inside the clock face area.
- To change the minute-hand of the clock, hold and drag horizontally inside the clock face area.
- To turn on the alarm, press **On** button on the top right of the clock.
- To turn off the alarm, press **Off** button on the top right of the clock.
- When the alarm fired, there will be :
  - a notification popped up
  - a custom 2-second ringtone (Please note that this feature _may **not** behaved well_ with some devices)
- After touching the alarm notification item, these will happen :
  - user brought back into the apps
  - a dialog displaying a vertical bar chart of how long the user takes to open each alarm notification in the past
  - to close the dialog, just touch other area outside the dialog
- To reset the alarm history, pressed **Clear Cache** button or just do it manually via _App Info_.
- Please note that some features may not worked well if you kill the apps, e.g :
  - automatically showing chart after touching the notification

## Tested Devices

1. Oppo A83 - Android 7.1 API level 25 (custom ringtone worked well).
2. Redmi Note 8 - Android 11 API level 30 (cannot play ringtone).

## Demo

- For the demo purpose (in case the project cannot be run locally), here is the video [link](https://drive.google.com/file/d/1I9i9m5hRMwkprdmdXZzQp-q-2dlcGvLJ/view?usp=sharing).
- Here is the [link](https://drive.google.com/file/d/1VMttDc5TgT7U2yEFsgbT5ONWVL-2tTJK/view?usp=sharing) for the apk-debug file of this app.

## Support

If you need anything, please reach me via email at __jordan.v.lomanto@gmail.com__ or via WhatsApp [+62 89 636 024 777](https://wa.me/6289636024777).
