#!/usr/bin/env bash

set -x

# Target OS: CentOS

# Install daemonize from source
# Create an RPM package using FPM


# Install Misc Dependencies
yum -y groupinstall "Development Tools"

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
yum -y install ruby rubygems

# Install FPM 
gem install fpm --no-ri --no-rdoc

# Create an RPM package using FPM 
echo "Creating an RPM package using FPM"
cd /tmp/
fpm \
-s dir -t rpm \
-C /tmp/fpm_install_directory/ \
--package /tmp/daemonize-VERSION_ARCH.rpm \
--name daemonize \
--version ${VERSION} \
--vendor "Lance Lakey" \
--maintainer "Lance Lakey <lancelakey@gmail.com>" \
--description "Daemonize ${VERSION} Packaged by Lance Lakey" \
--url https://github.com/bmc/daemonize \
usr/sbin usr/share

