#!/usr/bin/env bash

set -x
set -euo pipefail

# For architectures except amd64 and i386, look for packages on ports.ubuntu.com instead.
# This is important if you enable additional architectures so you can install libraries to cross-compile against.
sed 's/http:\/\/\(.*\).ubuntu.com\/ubuntu\//[arch-=amd64,i386] http:\/\/ports.ubuntu.com\/ubuntu-ports\//g' /etc/apt/sources.list > /etc/apt/sources.list.d/ports.list
sed -i 's/http:\/\/\(.*\).ubuntu.com\/ubuntu\//[arch=amd64,i386] http:\/\/\1.archive.ubuntu.com\/ubuntu\//g' /etc/apt/sources.list

apt-get update

apt-get install --assume-yes --no-install-recommends \
  autoconf \
  automake \
  binutils \
  ca-certificates \
  curl \
  file \
  gcc \
  g++ \
  git \
  libc6-dev \
  libtool \
  m4 \
  make \
  pkg-config