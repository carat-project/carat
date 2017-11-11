# Carat Project: Android and iOS Applications

For details, visit http://carat.cs.helsinki.fi

## Android APK Download for Devices Without Google Play

[Android Releases](https://github.com/carat-project/carat-android/releases)

## Install on iOS or Android

[App Store Page for iOS](http://itunes.apple.com/us/app/carat/id504771500)
[Google Play Page for Android](https://play.google.com/store/apps/details?id=edu.berkeley.cs.amplab.carat.android)

## Build instructions for Android

1. Find Carat Android application at https://github.com/carat-project/carat-android
2. Follow instructions

## Build instructions for iOS

1. Make sure you have the latest Xcode.
2. Make sure you have ruby version 2.2.2 or later. Here is a short guide to install Ruby 2.3.1 (you can skip the parts after that): https://gorails.com/setup/osx/10.11-el-capitan
3. Install ruby gems: https://rubygems.org/pages/download
4. Install latest CocoaPods: `gem install cocoapods`
5. Go to the app/ios folder in a terminal and run `pod install`.
6. Make sure the `SZIdentifierUtils.m ` and `.h` files still have `#define SHOULD_USE_IDFA 0`
7. Open the resulting Carat.xcodeworkspace in Xcode.
8. Build and run on an emulator or your device.
