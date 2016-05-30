# Carat Project: Android and iOS Applications

For details, visit http://carat.cs.helsinki.fi

## Build instructions for Android

1. Find Carat Android application at https://github.com/carat-project/carat-android
2. Follow instructions

## Build instructions for iOS

1. Install ruby gems: https://rubygems.org/pages/download
2. Install CocoaPods 0.33.1: http://rubygems.org/gems/cocoapods/versions/0.33.1
3. Make sure you have the latest Xcode.
4. Go to the app/ios folder in a terminal and run `pod install`.
5. Make sure the `SZIdentifierUtils.m ` and `.h` files still have `#define SHOULD_USE_IDFA 0`
6. Open the resulting Carat.xcodeworkspace in Xcode.
7. Build and run on an emulator or your device.
