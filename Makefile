# Build variables.
BUILD_DIR   := build
THEME_DIR   := halo-terminal
INSTALL_DIR := /boot/grub/themes
GRUB_CONFIG := /etc/default/grub
GRUB_CFG    := /boot/grub/grub.cfg

# Customizable properties.
BACKGROUND_SIZE   := 1920x1080
FONT_SIZE         := 32
ICON_SIZE         := 48
THEME_COLOR       := 53ff00
BACKGROUND_COLOR  := black
SELECTED_FG_COLOR := white
SELECTED_BG_COLOR := $(THEME_COLOR)40

# Helper vars.
bg_w := $(firstword $(subst x, ,$(BACKGROUND_SIZE)))
bg_w := $(firstword $(subst X, ,$(bg_w)))

# Target vars.
bg    := $(BUILD_DIR)/background.png
sel   := $(BUILD_DIR)/selected_c.png
font  := $(BUILD_DIR)/fixedsys$(FONT_SIZE).pf2
icons := $(patsubst icons/%.xcf, $(BUILD_DIR)/icons/%.png, $(wildcard icons/*.xcf))
theme := $(BUILD_DIR)/theme.txt

.PHONY: all clean check install uninstall preview

all: $(bg) $(sel) $(font) $(icons) $(theme)

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/icons: | $(BUILD_DIR)
	mkdir -p $@

$(bg): scanline.xcf halo.xcf | $(BUILD_DIR)
	xcf2png scanline.xcf |\
		convert - -alpha deactivate -fuzz 100% -fill '#$(THEME_COLOR)' -opaque white -alpha activate \
		-background '$(BACKGROUND_COLOR)' -alpha remove - |\
		convert -size '$(BACKGROUND_SIZE)' tile:- -strip $@
	xcf2png halo.xcf |\
		convert - -resize $(bg_w) -scale 25% -alpha deactivate -fuzz 100% -fill '#$(THEME_COLOR)' -opaque white -alpha activate - |\
		convert $@ - -gravity SouthEast -geometry +40+40 -composite -strip png32:$@

$(sel): | $(BUILD_DIR)
	convert 'xc:#$(SELECTED_BG_COLOR)' -strip png32:$@

$(font): fixedsys.ttf | $(BUILD_DIR)
	rm -rf $(BUILD_DIR)/*.pf2
	grub-mkfont -s $(FONT_SIZE) -o $@ $<

$(BUILD_DIR)/icons/%.png: icons/%.xcf | $(BUILD_DIR)/icons
	xcf2png $< | convert - -alpha deactivate -fuzz 100% -fill '#$(THEME_COLOR)' -opaque white -alpha activate -resize '$(ICON_SIZE)x$(ICON_SIZE)' -strip png32:$@

$(theme): theme | $(BUILD_DIR)
	cp $< $@
	sed -i 's/@font@/fixedsys$(FONT_SIZE).pf2/' $@
	sed -i 's/@iconsize@/$(ICON_SIZE)/' $@
	sed -i 's/@themecolor@/#$(THEME_COLOR)/' $@
	sed -i 's/@selectedfgcolor@/$(SELECTED_FG_COLOR)/' $@

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
	sed -i '\|GRUB_THEME=$(INSTALL_DIR)/$(THEME_DIR)/theme|d' $(GRUB_CONFIG)
	echo 'GRUB_THEME=$(INSTALL_DIR)/$(THEME_DIR)/theme' >> $(GRUB_CONFIG)
	grub-mkconfig -o $(GRUB_CFG)

uninstall: check
	rm -rf $(INSTALL_DIR)/$(THEME_DIR)
	sed -i '\|GRUB_THEME=$(INSTALL_DIR)/$(THEME_DIR)/theme|d' $(GRUB_CONFIG)
	grub-mkconfig -o $(GRUB_CFG)
	@grep -q 'GRUB_TERMINAL' $(GRUB_CONFIG) && echo 'NOTE: Uncomment GRUB_TERMINAL=... in $(GRUB_CONFIG) and re-run this if you wish to disable the graphical terminal.' >&2 || true

preview:
	sleep 5 && kill -9 `pidof grub-emu` &
	grub-emu || true
	reset
