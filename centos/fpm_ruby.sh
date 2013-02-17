#!/usr/bin/env bash

set -x

# Target OS: CentOS
# Install Ruby from source
# Create an RPM package using FPM
# I don't use this script anymore. Instead I use a spec file I forked. https://github.com/lancelakey/ruby-1.9.3-rpm


# Install FPM dependencies
# We need Ruby in order to use FPM 
# Assume Ruby is installed

# Install FPM 
gem install fpm --no-ri --no-rdoc

# Install Misc build dependencies
yum -y groupinstall "Development Tools"

# Install dependencies for compiling Ruby 
# apt-get install -y ruby-dev python-dev python-setuptools bison autoconf 
yum -y install libffi-devel libyaml-devel openssl-devel readline-devel zlib-devel 
yum -y install libxslt-devel libyaml-devel libxml2-devel gdbm-devel libffi-devel zlib-devel openssl-devel libyaml-devel readline-devel curl-devel openssl-devel pcre-devel
yum -y install readline readline-devel ncurses ncurses-devel gdbm gdbm-devel glibc-devel tcl-devel gcc unzip openssl-devel db4-devel byacc make

# Download Ruby source
VERSION=1.9.3-p385
PACKAGE_VERSION=1.9.3p385

url=ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-$VERSION.tar.gz
tarfile=${url##*/}
dir=${tarfile%.tar.gz}

cd /tmp/
wget "$url"
tar zxf "$tarfile"
cd "$dir"


# Compile Ruby
rm -rf /tmp/fpminstalldir 
mkdir -p /tmp/fpminstalldir
time (make clean ; make distclean ; ./configure --prefix=/usr --disable-install-doc && make --jobs && make install DESTDIR=/tmp/fpminstalldir)


# Create an RPM package using FPM 
pushd /tmp/
  fpm \
    -s dir -t rpm \
    -C /tmp/fpminstalldir \
    --package /tmp/ruby-VERSION_ARCH.rpm \
    --name ruby \
    --version $PACKAGE_VERSION \
    --vendor "Lance Lakey" \
    --maintainer "Lance Lakey <lancelakey@gmail.com>" \
    --description "Ruby $PACKAGE_VERSION Packaged by Lance Lakey" \
    -d "glibc >= 2.5" \
    -d "libffi >= 3.0.5" \
    -d "libstdc++ >= 4.1.2" \
    -d "libyaml >= 0.1.2" \
    -d "openssl >= 0.9.8" \
    -d "readline >= 5.1" \
    -d "zlib >= 1.2.3" \
    usr/bin usr/lib usr/share/man usr/include
popd


# Post installation test
# cd /tmp/
# Remove existing Ruby
# rpm -qa | grep -i ruby | xargs rpm -e
# yum install the new ruby RPM file
# ruby -ropenssl -rzlib -rreadline -ryaml -e "puts :success" 

