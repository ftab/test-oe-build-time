#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengin)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b zeus 73fe0e273b4e00dcb08122c4f54fc65316e2a793
# this fix is needed to build qemu-native with newer glibc on host (e.g. ubuntu 20.04 I'm using now)
git cherry-pick b8809d338005eeea4085692281dda20fe85dc52d
git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b zeus a582fd4c810529e9af0c81700407b1955d1391d2
cd ..
git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b zeus 1697014a05967ed54b294f3c4b5621df494d6551
cd ..
git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b zeus e855ecc6d35677e79780adc57b2552213c995731
cd ..
git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b zeus 0c393398a91713a108f319ac75337c02b7ebeaa7
cd ..
git clone https://github.com/meta-rust/meta-rust.git
cd meta-rust
git checkout -b zeus 5d1ada0c97723e1526bf5599b2fa2cbb56c2c0dc
cd ..

. ./oe-init-build-env
if ! grep meta-qt5 conf/bblayers.conf ; then
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-qt5/g' conf/bblayers.conf
fi
if ! grep meta-clang conf/bblayers.conf ; then
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-clang/g' conf/bblayers.conf
fi
if ! grep meta-oe conf/bblayers.conf ; then
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-openembedded\/meta-oe/g' conf/bblayers.conf
fi
if ! grep meta-rust conf/bblayers.conf ; then
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-rust/g' conf/bblayers.conf
fi
if ! grep meta-browser conf/bblayers.conf ; then
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-browser/g' conf/bblayers.conf
fi

cat > conf/site.conf << EOF
IMAGE_INSTALL_append_pn-core-image-sato = " qtwebengine qtwebkit chromium-x11 firefox epiphany"
MACHINE = "qemux86-64"
INHERIT += "rm_work"
DL_DIR = "${HOME}/.yocto/downloads"
EOF
