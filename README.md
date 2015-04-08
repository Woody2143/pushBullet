# pushBullet
Scripts for using the Push Bullet APIs (https://www.pushbullet.com)

Currently just a simple script for sending PushBullet Notices

Create an account at https://www.pushbullet.com/, look at your account settings for your Access Token.
Save the token to ~/.pushbulletrc
 apiKey=<ACCESS KEY>

Use the program by piping in text to the script that you want in the body of the notification.
Set the title by specifying it as the first argument after the script.

Example:
  echo "Message Body" | pushNotice.pl "Notice Subject"
