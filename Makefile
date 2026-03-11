.PHONY: generate open build clean

# Generate Xcode project from project.yml (requires: brew install xcodegen)
generate:
	xcodegen generate

# Generate and open in Xcode
open: generate
	open Jot.xcodeproj

# Build from command line (Debug)
build:
	xcodebuild -scheme Jot -configuration Debug -destination "platform=macOS" build

clean:
	rm -rf Jot.xcodeproj DerivedData
