#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export BUILD_BROKEN_MISSING_REQUIRED_MODULES=true
export IGNORE_PATCH_ERRORS=true
sudo apt update
sudo apt install -y sudo git android-sdk-platform-tools python-is-python3 python3-yaml # libncurses5
sudo apt install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick protobuf-compiler python3-protobuf lib32readline-dev lib32z1-dev libdw-dev libelf-dev lz4 libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev
sudo apt install -y meson glslang-tools python3-mako
git config --global user.name "github-actions[bot]"
git config --global user.email "github-actions[bot]@users.noreply.github.com"
git config --global trailer.changeid.key "Change-Id"
git config --global color.ui true
git lfs install
unset REPO_URL

mkdir -p bin android/lineage
curl https://storage.googleapis.com/git-repo-downloads/repo > bin/repo
chmod a+x bin/repo
export PATH="$(realpath .)/bin:$PATH"
cd android/lineage
export PATH="$(realpath .)/prebuilts/sdk/tools/linux/bin/:$PATH"
repo init -u https://github.com/yaap/manifest.git -b sixteen --depth=1 --git-lfs --groups=default,-mips,-x86,-darwin
git clone https://github.com/Alromine95/device_xiaomi_blossom.git -b 16.2 .repo/local_manifests
repo sync -j $(nproc)
sed -i 's/-$(LINEAGE_BUILDTYPE)/-jqssun/g' vendor/lineage/config/version.mk

#Fixing audio files
AUDIO_BP="hardware/interfaces/audio/common/all-versions/default/Android.bp"
if [ -f "$AUDIO_BP" ]; then
    echo "🔧 Fixing Audio select type condition..."
    sed -i 's/"true":/true:/g' "$AUDIO_BP"
    echo "✅ Audio Android.bp patched!"
else
    echo "⚠️ Audio Android.bp not found, skipping patch."
fi

source build/envsetup.sh

# 4. Let Lineage parse your lineage.dependencies and fetch the rest
breakfast blossom

# 5. Start compilation
brunch blossom
