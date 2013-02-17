#!/usr/bin/env bash

# Target OS: Debian

# On a new / clean installation of debian squeeze
# Install Ruby from source
# Create a Debian package using FPM


# Update apt
apt-get update -y


# Install FPM dependencies
# We need Ruby in order to use FPM 
apt-get install -y ruby rubygems


# Install FPM 
gem1.8 install fpm --no-ri --no-rdoc


# Install dependencies for compiling Ruby 
# apt-get install -y ruby-dev python-dev python-setuptools bison autoconf 
apt-get install -y build-essential autoconf openssl libreadline6-dev zlib1g-dev libssl-dev ncurses-dev libyaml-dev


# Download Ruby source
VERSION=1.9.3-p385
url=ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-$VERSION.tar.gz
tarfile=${url##*/}
dir=${tarfile%.tar.gz}

cd /tmp/
wget "$url"
tar zxvf "$tarfile"
cd "$dir"


# Compile Ruby
rm -rf /tmp/fpm_installdir 
time (make clean ; make distclean ; ./configure --prefix=/usr --disable-install-doc && make --jobs  && make install DESTDIR=/tmp/fpm_installdir)


# Create a Debian package using FPM 
cd /tmp/
/var/lib/gems/1.8/bin/fpm \
  --name ruby$VERSION \
  --version $VERSION \
  --vendor "Lance Lakey" \
  --maintainer "Lance Lakey <lancelakey@gmail.com>" \
  --description "Ruby $VERSION Packaged by Lance Lakey" \
  --url http://www.ruby-lang.org/ \
  -s dir -t deb \
  -C /tmp/fpm_installdir \
  --package /tmp/ruby-VERSION_ARCH.deb \
  -d "libstdc++6 (>= 4.4.3)" \
  -d "libc6 (>= 2.6)" -d "libffi5 (>= 3.0.9)" -d "libgdbm3 (>= 1.8.3)" \
  -d "libncurses5 (>= 5.7)" -d "libreadline6 (>= 6.1)" \
  -d "libssl0.9.8 (>= 0.9.8)" -d "zlib1g (>= 1:1.2.2)" \
  --replaces ruby --replaces ruby18 --replaces ri --replaces rdoc --replaces libruby \
  usr/bin usr/lib usr/share/man usr/include


# Post installation test
cd /tmp/
# Remove all ruby related packages
apt-get -qy purge $(dpkg -l | grep -i ruby | cut -d " " -f 3)
# apt-get install -y libffi5 libyaml-0-2
apt-get install -y libffi5
echo "About to install package"
echo `pwd`
dpkg -i /tmp/ruby-$VERSION\_amd64.deb
ruby -ropenssl -rzlib -rreadline -ryaml -e "puts :success" 

