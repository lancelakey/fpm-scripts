#!/usr/bin/env bash

# Target OS: CentOS

# On a new / clean installation of CentOS
# Install Node.js from source
# Create a RPM package using FPM


# Install Misc Dependencies
yum -y groupinstall "Development Tools"

# Install Node.js dependencies
yum -y install openssl-devel 

# Download, make, and install Node.js
# This includes npm
echo "Downloading, making, and installing Node.js"
VERSION=0.8.20
pushd /tmp/
  rm -rf /tmp/node-v${VERSION}*
  wget -nc http://nodejs.org/dist/v${VERSION}/node-v${VERSION}.tar.gz
  tar xzf node-v${VERSION}.tar.gz
  cd node-v${VERSION}
  time (make --silent clean; \
    make --silent distclean; \
    ./configure --prefix=/usr \
    && make --silent --jobs \
    && make --silent install DESTDIR=/tmp/node-v${VERSION}_fpminstalldir)
popd

# Install FPM dependencies
# We need Ruby and RubyGems in order to install and use FPM 
# Assuming Ruby is installed in this script

# Install FPM 
gem install fpm --no-ri --no-rdoc

# Create a RPM package using FPM 
echo "Creating a RPM packing using FPM"
pushd /tmp/
  fpm \
    --name node \
    --version ${VERSION} \
    --vendor "Lance Lakey" \
    --maintainer "Lance Lakey <lancelakey@gmail.com>" \
    --description "Node.js ${VERSION} Packaged by Lance Lakey" \
    --url http://www.nodejs.org/ \
    -s dir -t rpm \
    -C /tmp/node-v${VERSION}_fpminstalldir \
    --package /tmp/node-VERSION_ARCH.rpm \
    usr/bin usr/lib usr/share usr/include
popd

