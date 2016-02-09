#!/bin/bash
set +x

MEAN_IT=false

RESTORE=$(echo -en '\033[0m')
RED=$(echo -en '\033[00;31m')
GREEN=$(echo -en '\033[00;32m')
YELLOW=$(echo -en '\033[00;33m')

BASEURI="https://github.com/sn0w/Awesome-WebView/archive"
BRANCH="master"
FORMAT=".tar.gz"
CACHE="repo.tmp${FORMAT}"

DOWNLOAD_ONLY=false
W_IOS=true
W_ANDROID=true
NAME="Awesome-WebView"
CUSTOM_NAME=$NAME
APP_ID="moe.lukas.awesomewebview"

function motd(){
    echo "   _                             __      __   _        _                  "
    echo "  /_\__ __ _____ ___ ___ _ __  __\ \    / /__| |____ _(_)_____ __ __      "
    echo " / _ \ V  V / -_|_-</ _ \ '  \\/ -_) \\/\\/ / -_) '_ \ V / / -_) V  V /   "
    echo "/_/ \_\_/\_/\___/__/\___/_|_|_\___|\_/\_/\___|_.__/\_/|_\___|\_/\_/       "
    echo ""                                                             
}

function cerr() {
    echo "${RED}==> $1 ${RESTORE}"
}

function cout() {
    echo "${GREEN}==> $1 ${RESTORE}"
}

function cwarn() {
    echo "${YELLOW}==> $1 ${RESTORE}"
}

function toLowerCase() {
    echo $1 | tr '[:upper:]' '[:lower:]'
}

function toUpperCase() {
    echo $1 | tr '[:lower:]' '[:upper:]'
}

function printHelp() {
    echo "
Usage:
-l | --download-only ->  Only download the repo and exit                 [false]
-b | --branch        ->  Set the branch you want to download             [master]
-n | --name          ->  Set the name of your app                        [Awesome-WebView]
-d | --id            ->  Set the id of your app                          [moe.lukas.awesomewebview]
--only-ios           ->  Build Awesome-WebView with iOS support only     [false]
--only-android       ->  Build Awesome-WebView with Android support only [false]
--debug-mode         ->  Enable debug mode                               [false]

Note: The values in square brackets are the defaults"
    exit 0
}

function download() {
    local url=$1

    command -v wget 1>/dev/null 2>&1 || {
        cerr "No wget found!"
        cerr "Falling back to cURL..."
        command -v curl 1>/dev/null 2>&1 || {
            cerr "Neither wget nor cURL is installed."
            cerr "Please install one of them and launch the script again."
            exit 1
        }

        cout "Downloading sources..."
        curl -sfL# $url -o $CACHE
    }

    cout "Downloading sources..."
    wget --quiet --show-progress $url -O $CACHE
}

function prepareIos() {
    cout "Preparing the iOS project..."
    local preparedName=$(echo $CUSTOM_NAME | sed 's/ /_/g')

    cd ios || die "ERR_PREP_IOS"
    mv $NAME $preparedName
    mv "${NAME}.xcodeproj" "${preparedName}.xcodeproj"
    mv "${preparedName}.xcodeproj/xcshareddata/xcschemes/${NAME}.xcscheme" "${preparedName}.xcodeproj/xcshareddata/xcschemes/${preparedName}.xcscheme"
    find . -type f  -print0 | xargs -0 sed -i '' "s/${NAME}/${preparedName}/g"
    cd ..
}

function prepareAndroid() {
    true
    cout "Preparing the Android project..."
}

function die() {
    cerr "The script crashed because of a $1 exception"
    exit 128
}

motd
arguments=($@)
index=0
for argument in "${arguments[@]}"; do
    index=`expr $index + 1`

    case $argument in
        --help|-h)
            printHelp
        ;;

        --branch|-b)
            BRANCH="${arguments[index]}"
        ;;

        --download-only|-l)
            DOWNLOAD_ONLY=true
        ;;

        --only-ios)
            W_ANDROID=false
        ;;

        --only-android)
            W_IOS=false
        ;;

        --name|-n)
            CUSTOM_NAME="${arguments[index]}"
        ;;

        --id|-d)
            APP_ID="${arguments[index]}"
        ;;

        --debug-mode)
            set -x
        ;;

        --force-launch)
            MEAN_IT=true
        ;;
    esac
done

if [[ $MEAN_IT == false ]]; then
    cwarn "This script is still unstable!"
    cwarn "Please refer to 'The Ultimate Setup Guide' of your platform."
    cwarn "If you love bugs, relaunch the script with '--force-launch'"
    exit 100
fi

cout "Downloading..."
download "$BASEURI/$BRANCH$FORMAT"

if [[ $DOWNLOAD_ONLY == false ]]; then
    cout "Extracting..."
    tar xfz $CACHE

    cout "Preparing desired platforms..."
    if [[ $W_ANDROID == true ]]; then
        mv "Awesome-WebView-$BRANCH/android" .
        prepareAndroid
    fi

    if [[ $W_IOS == true ]]; then
        mv "Awesome-WebView-$BRANCH/ios" .
        prepareIos
    fi

    cout "Cleaning up..."
    rm -rf "Awesome-WebView-$BRANCH"
    rm "$BRANCH$FORMAT"
fi

cout "Done!"

exit 0
