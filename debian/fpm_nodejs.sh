#!/usr/bin/env bash

# Target OS: Debian

# On a new / clean installation of debian squeeze
# Install Node.js from source
# Create a Debian package using FPM


# Update apt
apt-get update -qy

# Install Node.js dependencies
apt-get install -qy build-essential openssl libssl-dev python pkg-config

# Download, make, and install Node.js
# This includes npm
echo "Downloading, making, and installing Node.js"
VERSION=0.8.20
cd /tmp/
rm -rf /tmp/node-v${VERSION}*
wget -nc http://nodejs.org/dist/v${VERSION}/node-v${VERSION}.tar.gz
tar xvzf node-v${VERSION}.tar.gz
cd node-v${VERSION}
time (make --silent clean; \
  make --silent distclean; \
  ./configure --with-dtrace --prefix=/usr \
  && make --silent --jobs \
  && make --silent install DESTDIR=/tmp/node-v${VERSION}_fpminstalldir)

# Install FPM dependencies
# We need Ruby and RubyGems in order to install and use FPM 
apt-get install -qy ruby rubygems

# Install FPM 
gem1.8 install fpm --no-ri --no-rdoc

# Create a Debian package using FPM 
echo "Creating a Debian packing using FPM"
cd /tmp/
/var/lib/gems/1.8/bin/fpm \
  --name node \
  --version ${VERSION} \
  --vendor "Lance Lakey" \
  --maintainer "Lance Lakey <lancelakey@gmail.com>" \
  --description "Node.js ${VERSION} Packaged by Lance Lakey. Compiled --with-dtrace" \
  --url http://www.nodejs.org/ \
  -s dir -t deb \
  -C /tmp/node-v${VERSION}_fpminstalldir \
  --package /tmp/node-VERSION_ARCH.deb \
  usr/bin usr/lib usr/share usr/include

# Post installation test
echo "Purging any already-installed Node.js"
dpkg -l | grep -i node | cut -d " " -f 3 | xargs apt-get purge -qy
echo "Installing Node.js from the new FPM created Debian .deb package"
cd /tmp/
dpkg -i `ls -rd /tmp/node-*.deb`
echo "Node.js version installed: $(node -v)"
dpkg -l | grep -i nodejs
