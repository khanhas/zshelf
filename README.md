# ZShelf
[Z-Library](https://z-lib.org) browser and downloader for [reMarkable](https://remarkable.com/) devices

<p align="center">
  <img src="https://i.imgur.com/O4IzQfG.png" width="300" title="Browse">
  <img src="https://i.imgur.com/n9SnfxV.png" width="300" title="Book metadata">
  <img src="https://i.imgur.com/HsHWSEF.png" width="300" title="Search UI">
</p>

## Installation
### Requirement
1. NodeJS. Please use package manager [toltec](https://github.com/toltec-dev/toltec/) to install it:
```bash
opkg update
opkg install node
```
2. **[reMarkable 2 only]** You definitely need `rm2fb` package to run any app:
```bash
opkg install rm2fb
```

### Download
1. SSH to your reMarkable
2. Run these command to download and unpack distributed package to `/home/root` location:
```bash
cd /home/root
wget "https://github.com/khanhas/zshelf/releases/download/v0.1.1/zshelf-reMarkable-0.1.1.zip"
unzip "zshelf-reMarkable-0.1.1.zip"
```

### [IMPORTANT] Configure domain and cookie
`zshelf` basically is a web crawler, which fetch and parse z-library web pages, get the gist of them and natively display book items on UI. Because it's not web browser, user needs to manually configure domain and cookie so `zshelf` can download books on demand. Free user account is still limited at downloading 10 books a day.

1. Open [https://z-lib.org](https://z-lib.org) on your web browser
2. Under "Books" link, you should notice domain part that is specifically available for your region/country. Note it down.  

<p align="center"><img src="https://i.imgur.com/RvKYY9W.png" width="800"></p>

3. Log in with your account.
4. In any page, open up Console (hit <kbd>F12</kbd> and switch to tab Console), run:
```js
document.cookie
```
It will return a string contains your ids. You can copy the parts have `remix_userkey` and `remix_userid` and ignore the rest. Or just copy them all:

<p align="center"><img src="https://i.imgur.com/zpn6EyC.png" width="800"></p>


5. SSH to your reMarkable device and open config file. Assumming your zshelf locates at `/home/root/zshelf`:
```bash
cd /home/root/zshelf
nano config.json
```
7. Replace keys `"domain"` and `"cookie"`'s values with yours.

<p align="center"><img src="https://i.imgur.com/4wXoP0f.png" width="800"></p>

8. Save file (In `nano`: <kbd>Ctrl + X</kbd> -> <kbd>Y</kbd> -> <kbd>Enter</kbd>)
9. Start zshelf to test configuration:
```bash
./zshelf
```

reMarkable 2 user, run this before starting `zshelf`:
```bash
export LD_PRELOAD=/opt/lib/librm2fb_client.so.1.0.0
```

Downloaded EPUB and PDF books will be automatically available on your reMarkable app (if not, please restart the app or restart device). `zshelf` also makes a copy of the book to location configured in `additionalBookLocation`, so you can open it in other reader like [`KOReader`](https://github.com/koreader/koreader/wiki/Installation-on-Remarkable), which has ten fold better reading experience, highly recommended and also available on `toltec`.

### Set `zshelf` up for your app launcher
If you are using `oxide` or `draft`, create an application description file for `zshelf` in `/opt/etc/draft/` (althought it's draft's location, `oxide` can read it too):
```bash
nano /opt/etc/draft/zshelf.draft
```
Paste this in:
```
name=ZShelf
desc=Z-Library browser and downloader
call=/home/root/zshelf/zshelf
term=killall zshelf
```
Save file and restart your launcher (`oxide` user: just hit "Load apps").

## Development
0. [Set up reMarkable toolchain](https://remarkablewiki.com/devel/qt_creator#toolchain), NodeJS and `npm`
1. `git clone https://github.com/khanhas/zshelf`
2. `qmake`
3. `make`

## Credits
- [Qt-Quick-Keyboard](https://github.com/mireq/Qt-Quick-Keyboard) by mireq
