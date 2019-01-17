# Build directory:
BUILD_DIR   := build
# Theme directory name (will be created inside install dir):
THEME_DIR   := grub-fallout-terminal-theme
# Installation directory (created if not already existing):
INSTALL_DIR := /boot/grub/themes
# Location of grub user configuration file:
GRUB_CONFIG := /etc/default/grub
# Path to grub.cfg:
GRUB_CFG    := /boot/grub/grub.cfg

# Global font size:
font_size       := 40
# Size of icons near boot entries:
icon_size       := 32
# Main theme color (MUST be 6-digit hex):
theme_color     := 66d879
# BG color of selected entry (any valid CSS color, derived from theme color by default):
selection_color := $(theme_color)40

# Target vars.
bg    := $(BUILD_DIR)/background.png
sel   := $(BUILD_DIR)/selected_c.png
font  := $(BUILD_DIR)/fixedsys$(font_size).pf2
icons := $(patsubst icons/%.xcf, $(BUILD_DIR)/icons/%.png, $(wildcard icons/*.xcf))
theme := $(BUILD_DIR)/theme

.PHONY: all clean install uninstall preview

all: $(bg) $(sel) $(font) $(icons) $(theme)

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/icons: | $(BUILD_DIR)
	mkdir -p $@

$(bg): background.xcf | $(BUILD_DIR)
	xcf2png $< | convert - -strip $@

$(sel): | $(BUILD_DIR)
	convert 'xc:#$(selection_color)' -strip png32:$@

$(font): fixedsys.ttf | $(BUILD_DIR)
	rm -rf $(BUILD_DIR)/*.pf2
	grub-mkfont -s $(font_size) -o $@ $<

$(BUILD_DIR)/icons/%.png: icons/%.xcf | $(BUILD_DIR)/icons
	xcf2png $< | convert - -fuzz 100% -fill '#$(theme_color)' -opaque white -strip png32:$@
# TODO: resize to $(icon_size) to save space?

$(theme): theme | $(BUILD_DIR)
	cp $< $@
	sed -i 's/@font@/fixedsys$(font_size).pf2/' $@
	sed -i 's/@iconsize@/$(icon_size)/' $@
	sed -i 's/@themecolor@/#$(theme_color)/' $@

clean:
	rm -rf $(BUILD_DIR)

check:
	@[ $$(id -u) -eq 0 ] || echo 'ERROR: This action requires root privileges.'
	[ $$(id -u) -eq 0 ]
	@[ -f $(GRUB_CONFIG) ] || echo 'ERROR: Unable to locate grub user configuration! Edit GRUB_CONFIG at the top of this Makefile.' >&2
	@[ -f $(GRUB_CFG) ] || echo 'ERROR: Unable to locate grub.cfg! Edit GRUB_CFG at the top of this Makefile.' >&2
	[ -f $(GRUB_CONFIG) ] && [ -f $(GRUB_CFG) ]

install: check all
	[ -d $(INSTALL_DIR)/$(THEME_DIR) ] && rm -rf $(INSTALL_DIR)/$(THEME_DIR) || true
	mkdir -p $(INSTALL_DIR)
	cp -r $(BUILD_DIR) $(INSTALL_DIR)/$(THEME_DIR)
	sed -i '/GRUB_TERMINAL\s*=/ s/^#*/#/' $(GRUB_CONFIG)
	echo 'GRUB_THEME=$(INSTALL_DIR)/$(THEME_DIR)/theme' >> $(GRUB_CONFIG)
	grub-mkconfig -o $(GRUB_CFG)

uninstall: check
	rm -rf $(INSTALL_DIR)/$(THEME_DIR)
	sed -i '\|GRUB_THEME=$(INSTALL_DIR)/$(THEME_DIR)/theme|d' $(GRUB_CONFIG)
	grub-mkconfig -o $(GRUB_CFG)
	@grep -q 'GRUB_TERMINAL' $(GRUB_CONFIG) && echo 'NOTE: Uncomment GRUB_TERMINAL=... in $(GRUB_CONFIG) and re-run this if you wish to use the terminal.' >&2 || true

preview:
	sleep 5 && kill -9 `pidof grub-emu` &
	grub-emu || true
	reset
