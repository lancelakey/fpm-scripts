#!/usr/bin/env bash

# Target OS: Debian

# Install daemonize from source
# Create a Debian package using FPM


# Update apt
apt-get -qy update

# Install dependencies
apt-get -qy install build-essential git

# Download, make, and install
VERSION=1.7.3
cd /tmp/
rm -rf /tmp/fpm_install_directory
git clone https://github.com/bmc/daemonize.git
cd daemonize
time (make --silent clean; \
  make --silent distclean; \
  ./configure --prefix=/usr \
  && make --silent --jobs \
  && make --silent install DESTDIR=/tmp/fpm_install_directory/)


# Install FPM dependencies
# We need Ruby and RubyGems in order to install and use FPM 
apt-get install -qy ruby rubygems

# Install FPM 
gem1.8 install fpm --no-ri --no-rdoc

# Create a Debian package using FPM 
echo "Creating a Debian packing using FPM"
cd /tmp/
/var/lib/gems/1.8/bin/fpm \
-s dir -t deb \
-C /tmp/fpm_install_directory/ \
--package /tmp/daemonize-VERSION_ARCH.deb \
--name daemonize \
--version ${VERSION} \
--vendor "Lance Lakey" \
--maintainer "Lance Lakey <lancelakey@gmail.com>" \
--description "Daemonize ${VERSION} Packaged by Lance Lakey" \
--url https://github.com/bmc/daemonize \
usr/sbin usr/share

