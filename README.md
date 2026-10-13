## Rob's i3 Configuration

I use the [i3 Window Manager](https://i3wm.org/) in ~~Arch Linux~~ NixOS. This tiling window manager is fairly minimalistic yet still offers tons of great features. It is highly customizable, which is great, but this also means there are 
lots of little gotchas and tricks.

I use a triple monitor set up, which complicates things a little bit. Getting the desktop to extend and orient correctly (and consistently) is a little bit of a challenge in X/i3. I also have a organizational system that works 
well for me while I'm working.

This repo is a collection of scripts and hotkeys I have developed over the course of a few years. Shout out to [Aaron Ball](https://oper.io/) for sharing his configs with me when I started using i3. Not only did that make my 
transition from GNOME so much easier, but I learned a lot about the framework by reading and iterating on his code.

Hopefully others who are using or looking to switch to i3 can get some help and inspiration from my set up too.

### Nix / NixOS

When I moved to NixOS, managing the i3 configurations became kind of a hassle; I had to clone this repo to `~/.config/i3` and manage it there. This isn't really ideal in Nix, as the window manager is kinda crucial to the system interface, and thus should be integral to the NixOS system configuration.

I added a Nix Flake to this project, which simply defines the config and related scripts as a package. I also made use of `nixosModules`, which lets me define the software dependencies of this project independent from the software defined in my NixOS configuration.

In other words, all software needed to run the scripts in this i3 configuration are defined in such a way that when added to a NixOS repo, the resulting system will have everything it needs to run this code.

To add this to a NixOS system, simply open up the flake.nix and add this as an input:

```nix
  inputs = {
    i3-config = {
      url = "github:robsears/i3-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
```

Then make sure to add `i3-config` to your outputs, and `i3-config.nixosModules.default` to your system modules. This will ensure that your system ends up building with all necessary packages. Additionally, if you're using Home Manager, it will automatically place the output of this project in `~/.config/i3`.


### Installation

If you're pulling this in as a NixOS module (see above), all of the required packages are installed for you automatically.

If you're adapting these scripts outside of Nix, you'll need:

* [i3](https://i3wm.org/), which should include:
  - i3-dmenu-desktop
  - i3lock
  - i3status
* [MAIM](https://github.com/naelstrof/maim) (for taking screen shots)
* [Terminator](https://code.google.com/archive/p/jessies/wikis/Terminator.wiki) terminal emulator
* [feh](https://feh.finalrewind.org/) for desktop image-related functions
* [ImageMagick](https://www.imagemagick.org/script/index.php) for desktop image-related functions
* [scrot](https://github.com/dreamer/scrot) for taking screen shots
* Other system tools: `curl`, `xrandr`, `systemctl`, `amixer`, etc.

### Usage

These scripts are somewhat tailored to my set up, but I've tried to make them clean and adaptable for other users. Some notes on this:

* I have 3 monitors connected to my computer. I used XRandR and some trial and error to figure out which monitor is given which label by X. You'll need to edit `./scripts/xrandr.sh` accordingly.
* In the config file, the monitors are assigned to variables which are used later. If you don't have multiple monitors or your monitors have different labels, make sure to update this.
* This configuration launches a handful of programs at startup. You'll want to review/edit `./scripts/startup-programs.sh` accordingly
* The status bar shows your public IP address, current disk/memory/load usage, and the time (local and UTC).

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
12. Jump to a numbered workspace: Windows + `<1-8>`
13. Move a focused window to a numbered workspace: Windows + Shift + `<1-8>`

See the config file for more hotkeys.
