GRUB Halo terminal theme
===========================

A graphical theme for the [GNU GRUB 2][1] bootloader. This theme is inspired by the looks of [terminals][2] in Fallout, but in Halo style.

![screenshot][screenshot-img]

About
-----

This theme was designed with the intent to provide a fully customizable experience (specially for advanced users). In fact, the source for any component used by the theme is provided in native format (for example XCF Gimp native images instead of JPEGs or PNGs). This is a variation of mebeim's [grub-fallout-terminal-theme][3], kudos to him!

Building and installaton
-------------------------

Tools needed for building are `xcftools` and `imagemagick`, available on most major distributions through the default package manager (Gimp is *not* needed).

Build and install using `make`:

	$ make
	$ sudo make install

Uninstall:

	$ sudo make uninstall

Customization
-------------

Several options can be configured either editing the `Makefile` directly or passing them to `make` when building:

	$ make OPTION1=value1 OPTION2=value2 ...

Run `make clean` to remove previously built files before re-building with different options.

### List of available options:

 - `BACKGROUND_SIZE`: size of the background, in pixels, in the form `WxH`. Used to adjust the size of the scanlines and the position of the Halo Online XCF. A background size bigger than your display size can be chosen to make the scanlines appear more narrow (which is exactly what was done to create the screenshot above).
 - `FONT_SIZE`: font size to be used for all the text in GRUB's menu, in pt.
 - `ICON_SIZE`: size of the icons for boot entries, in pixels. Icons will be compiled to PNG and resized to this size to save space.
 - `THEME_COLOR`: main color of the theme, strictly in HTML 6-digit hex format. This is used as color for text, icons, terminal scanlines and the Halo Online XCF.
 - `BACKGROUND_COLOR`: screen background color, in any valid CSS color notation. This is the background color that will be applied *behind* the scanlines of the terminal screen.
 - `SELECTED_FG_COLOR`: text color for the selected boot menu entry, in HTML 6-digit hex format or valid HTML color name.
 - `SELECTED_BG_COLOR`: background color for the selected boot menu entry, in any valid CSS color notation. This is by default derived from the `THEME_COLOR`, but can be manually set to any other value.

 [screenshot-img]: https://i.imgur.com/szAdrXa.png
 [1]: https://www.gnu.org/software/grub/
 [2]: http://fallout.wikia.com/wiki/Terminal
 [3]: https://github.com/mebeim/grub-fallout-terminal-theme
