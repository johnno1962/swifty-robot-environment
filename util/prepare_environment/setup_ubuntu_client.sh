#!/bin/bash -x
#
# Setup Ubuntu 16.04 environment to use Android toolchain
#

export ANDROID_HOME=${ANDROID_HOME:-~/Android}

cd $(dirname $0)
mkdir -p $ANDROID_HOME &&
sudo mkdir -p /usr/java /usr/local/android &&
sudo chmod 777 /usr/java /usr/local/android &&
sudo ln -s $ANDROID_HOME/ndk-bundle /usr/local/android/ndk
sudo ln -s ndk/platforms/android-21/arch-arm /usr/local/android/platform
sudo ln -s /usr/local/android/ndk/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-ld.gold /usr/bin/armv7-none-linux-android-ld.gold
sudo ln -s /usr/local/android/ndk/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-ld.gold /usr/bin/armv7-none-linux-androideabi-ld.gold

sudo apt-get -y update && sudo apt-get install -y \
	git cmake ninja-build clang python uuid-dev libicu-dev icu-devtools \
	libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig libpython-dev \
	libncurses5-dev pkg-config libblocksruntime-dev libcurl4-openssl-dev \
	autoconf automake libtool curl wget unzip lib32stdc++6 lib32z1 rpl &&

cat <<EOF &&

*************************************************************************

Browse to http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
and download and install a Java SDK by extracting the zip file to /usr/java.

Browse to https://developer.android.com/studio/index.html and scroll down
to the section "Get just the command line tools" and downlaod the Linux
sdk-tools-linux-NNNNNNN.zip. Extract the archive into $ANDROID_HOME.

Press return when you've done this.
EOF

read Y &&

export JAVA_HOME="${JAVA_HOME:-$(echo /usr/java/*)}" &&

$ANDROID_HOME/tools/bin/sdkmanager --licenses &&
cat <<EOF &&

Downloading Android SDK components, please wait...
This will take a while and can also hang so if you've not seen any
network traffic for a while feel free to ^C and restart this script.

EOF
$ANDROID_HOME/tools/bin/sdkmanager "ndk-bundle" "platforms;android-25" "build-tools;25.0.3" "platform-tools" &&

cat <<EOF >>~/.bashrc &&

# Changes for Android Swift toolchain
export JAVA_HOME="$JAVA_HOME"
export ANDROID_HOME="$ANDROID_HOME"
export PATH="$PWD/usr/bin:\$ANDROID_HOME/platform-tools:\$PATH"
EOF

cd /tmp &&
git clone https://github.com/SwiftJava/swift-android-gradle &&
cd swift-android-gradle && ./gradlew install &&

cat <<EOF

Instalation complete. type source ~/.bashrc to begin.

An example project is available by typing:

git clone https://github.com/SwiftJava/swift-android-samples
cd swift-android-samples/swifthello
./gradlew installDebug

EOF
