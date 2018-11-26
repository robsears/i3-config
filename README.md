## Rob's i3 Configuration

I use the [i3 Window Manager](http://i3wm.org/) in Arch Linux. This tiling window manager is fairly minimalistic yet still offers tons of great features. It is highly customizable, which is great, but this also means there are 
lots of little gotchas and tricks.

I use a triple monitor set up, which complicates things a little bit. Getting the desktop to extend and orient correctly (and consistently) is a little bit of a challenge in X/i3. I also have a organizational system that works 
well for me while I'm working.

This repo is a collection of scripts and hotkeys I have developed over the course of a few years. Shout out to [Aaron Ball](https://oper.io/) for sharing his configs with me when I started using i3. Not only did that make my 
transition from GNOME so much easier, but I learned a lot about the framework by reading and iterating on his code.

Hopefully others who are using or looking to switch to i3 can get some help and inspiration from my set up too.


### Installation

This repo requires several packages:

* [i3](http://i3wm.org/), which should include:
  - i3-dmenu-desktop
  - i3lock
  - i3status
* [MAIM](https://github.com/naelstrof/maim) (for taking screen shots)
* [Terminator](https://code.google.com/archive/p/jessies/wikis/Terminator.wiki) terminal emulator
* [speedtest-cli](https://github.com/sivel/speedtest-cli) for periodically checking the internet speeds
* [feh](https://feh.finalrewind.org/) for desktop image-related functions
* [ImageMagick](https://www.imagemagick.org/script/index.php) for desktop image-related functions
* [scrot](https://github.com/dreamer/scrot) for taking screen shots
* Other system tools: `curl`, `iproute2`, `xrandr`, `systemctl`, `amixer`, etc.

Arch Linux users can add these through an [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers) like [yay](https://github.com/Jguer/yay) or [aurman](https://github.com/polygamma/aurman) (or [yaourt](https://archlinux.fr/yaourt-en), if you're behind the curve).

### Usage

These scripts are somewhat tailored to my set up, but I've tried to make them clean and adaptable for other users. Some notes on this:

* I have 3 monitors connected to my computer. I used XRandR and some trial and error to figure out which monitor is given which label by X. You'll need to edit `./scripts/xrandr.sh` accordingly.
* In the config file, the monitors are assigned to variables which are used later. If you don't have multiple monitors or your monitors have different labels, make sure to update this.
* This configuration launches a handful of programs at startup. You'll want to review/edit `./scripts/startup-programs.sh` accordingly
* The status bar shows information about local/public IP addresses, and uses a system device as the basis. For me, that's wlp3s0, but your system may be different.

### Hotkeys

This configuration defines some useful hotkeys:

1. Lock the screen: Ctrl + Alt + L
2. Suspend the system: Shift + Alt + S
3. Take a screen shot, OSX-style (provides a cursor to select an area):
  * Save the image to the Desktop: Shift + Alt + 4
  * Copy the image to the clipboard: Ctrl + Shift + Alt + 4
4. Launch a terminal (Terminator): Windows + Return
5. Kill a focused window: Windows + Shift + Q
6. Open the program launcher: Windows + D
7. Reload i3 Configuration: Windows + Shift + C
8. Restart i3: Windows + Shift + R
9. Exit i3: Windows + Shift + E
10. Move focus: Windows + `<arrow key>`
11. Move a focused window: Windows + Shift + `<arrow key>`
12. Jump to a numbered workspace: Windows + `<0-8>`
13. Move a focused window to a numbered workspace: Windows + Shift + `<0-8>`

See the config file for more hotkeys.
