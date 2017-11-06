#!/bin/bash
set -exv

cmake_version="3.9.5"
install_path="/home/jshi/bin64"
curl -O https://cmake.org/files/v3.9/cmake-${cmake_version}.tar.gz

tar -xzvf cmake-${cmake_version}.tar.gz

cd cmake-${cmake_version}

./configure --prefix=${install_path}/cmake-${cmake_version}

make&&make install
