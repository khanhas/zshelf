# ![title](https://gist.githubusercontent.com/khanhas/40999296b19662cdc1f877505c35a934/raw/fdc223e2c557b7be2e5e68e87f93cb3950c8b887/zshelf_title.svg)

<p align="center">
  <a href="https://z-lib.org">Z-Library</a> browser and downloader for <a href="https://remarkable.com/">reMarkable</a> devices
  <br>
  <br>
  <br>
  <img src="https://i.imgur.com/UbcwJ9L.png" width="300" title="Browse">
  <img src="https://i.imgur.com/CWWoQfk.png" width="300" title="Book metadata">
  <img src="https://i.imgur.com/38oxA3a.png" width="300" title="Search UI">
</p>

## Installation
0. Know how to SSH to your device: https://remarkablewiki.com/tech/ssh
1. Make sure package manager [toltec](https://github.com/toltec-dev/toltec/) is installed.
2. Run following command to install zshelf:
```bash
opkg update
opkg install zshelf
```
3. **[reMarkable 2 only]** You definitely need `rm2fb` package to run any app:
```bash
opkg install rm2fb
```

## [IMPORTANT] Configure domain and cookie
`zshelf` basically is a web crawler, which fetches and parses z-library web pages, gets the gist of them and natively displays book items on UI. Because it's not web browser, user needs to manually configure domain and cookie so `zshelf` can download books on demand. Free user account is still limited at downloading 10 books a day.

1. Open [https://z-lib.org](https://z-lib.org) on your web browser
2. Under "Books" link, you should notice domain part that is specifically available for your region/country. Note it down.  

<p align="center"><img src="https://i.imgur.com/khlqkaW.png" width="800"></p>

3. Log in with your account.
4. In any page, open up Console (hit <kbd>F12</kbd> and switch to tab Console), run:
```js
document.cookie
```
It will return a string contains your ids. Copy the parts have `remix_userkey` and `remix_userid` and ignore the rest:

<p align="center"><img src="https://i.imgur.com/OwkgSTp.png" width="800"></p>


5. SSH to your reMarkable device and open config file:
```bash
nano /opt/etc/zshelf/config.json
```

7. Replace keys `"domain"` and `"cookie"`'s values with yours.

<p align="center"><img src="https://i.imgur.com/5dZfQrC.png" width="800"></p>

8. Save file (In `nano`: <kbd>Ctrl + X</kbd> -> <kbd>Y</kbd> -> <kbd>Enter</kbd>)
9. Start zshelf to test configuration:
```bash
zshelf
```

reMarkable 2 user, use this instead:
```bash
LD_PRELOAD=/opt/lib/librm2fb_client.so.1.0.0 zshelf
```

Downloaded EPUB and PDF books will be automatically available on your reMarkable app (if not, please restart the app or restart device). `zshelf` also makes a copy of the book to location configured in `additionalBookLocation`, so you can open it in other reader like [`KOReader`](https://github.com/koreader/koreader/wiki/Installation-on-Remarkable), which has ten fold better reading experience, highly recommended and also available on `toltec`.

Also, install an app launcher so that you can open zshelf easier. Recommend `oxide`, `draft` or `remux`, all of them are available on `toltec`.

## Development
0. [Set up reMarkable toolchain](https://remarkablewiki.com/devel/qt_creator#toolchain), NodeJS and `npm`
1. `git clone https://github.com/khanhas/zshelf`
2. `qmake`
3. `make`
4. `cd backend`
5. `node install`

## Credits
- [Qt-Quick-Keyboard](https://github.com/mireq/Qt-Quick-Keyboard) by mireq
