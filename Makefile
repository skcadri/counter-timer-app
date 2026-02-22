.PHONY: build icon app install clean

build: app

# Compile the Swift source
CounterTimer: CounterTimerApp.swift
	swiftc -parse-as-library -o CounterTimer CounterTimerApp.swift \
		-framework SwiftUI -framework AVFoundation -framework AppKit

# Generate the app icon
AppIcon.icns: generate_icon.swift
	swift generate_icon.swift
	mkdir -p icon.iconset
	sips -z 16 16 icon_512.png --out icon.iconset/icon_16x16.png
	sips -z 32 32 icon_512.png --out icon.iconset/icon_16x16@2x.png
	sips -z 32 32 icon_512.png --out icon.iconset/icon_32x32.png
	sips -z 64 64 icon_512.png --out icon.iconset/icon_32x32@2x.png
	sips -z 128 128 icon_512.png --out icon.iconset/icon_128x128.png
	sips -z 256 256 icon_512.png --out icon.iconset/icon_128x128@2x.png
	sips -z 256 256 icon_512.png --out icon.iconset/icon_256x256.png
	sips -z 512 512 icon_512.png --out icon.iconset/icon_256x256@2x.png
	cp icon_512.png icon.iconset/icon_512x512.png
	iconutil -c icns icon.iconset -o AppIcon.icns

# Bundle into a .app
app: CounterTimer AppIcon.icns
	mkdir -p "Counter Timer.app/Contents/MacOS"
	mkdir -p "Counter Timer.app/Contents/Resources"
	cp CounterTimer "Counter Timer.app/Contents/MacOS/Counter Timer"
	cp AppIcon.icns "Counter Timer.app/Contents/Resources/AppIcon.icns"
	cp Info.plist "Counter Timer.app/Contents/Info.plist"
	@echo "Built: Counter Timer.app"

# Install to /Applications
install: app
	cp -R "Counter Timer.app" "/Applications/Counter Timer.app"
	@echo "Installed to /Applications/Counter Timer.app"

clean:
	rm -rf CounterTimer "Counter Timer.app" icon.iconset icon_512.png AppIcon.icns
