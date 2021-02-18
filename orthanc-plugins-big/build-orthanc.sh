#!/bin/bash

# Orthanc - A Lightweight, RESTful DICOM Store
# Copyright (C) 2012-2016 Sebastien Jodogne, Medical Physics
# Department, University Hospital of Liege, Belgium
# Copyright (C) 2017-2018 Osimis S.A., Belgium
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


set -e

# Get the number of available cores to speed up the build
COUNT_CORES=`grep -c ^processor /proc/cpuinfo`
echo "Will use $COUNT_CORES parallel jobs to build Orthanc"

# Check if a version number is greater than another https://stackoverflow.com/questions/16989598/comparing-php-version-numbers-using-bash/24067243#24067243
function version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

# Create the various directories as in the official Debian package
mkdir /etc/orthanc
mkdir -p /var/lib/orthanc/db
mkdir -p /usr/share/orthanc/plugins

# Clone the Orthanc repository and switch to the requested branch
cd /root/
hg clone https://hg.orthanc-server.com/orthanc/ orthanc
cd orthanc
echo "Switching Orthanc to branch: $1"
hg up -c "$1"

# Determine cmake location as it was moved in 1.7.2
orthanc_cmake_location="../"
if version_gt $1 "Orthanc-1.7.1" || [ "$1" = "default" ]; then
    orthanc_cmake_location="../OrthancServer"
else
    # Patch the orthanc REST API unit test to use the new source code location rather than the defunct bitbucket repo.
    sed -i 's/sjodogne\/orthanc\/raw\/Orthanc-0.9.3\/Resources\/Configuration.json/osimis\/orthanc-setup-samples\/raw\/master\/docker\/serve-folders\/orthanc\/serve-folders.json/g' ./UnitTestsSources/RestApiTests.cpp
    sed -i 's/ASSERT_TRUE(v.isMember("LuaScripts"));/ASSERT_TRUE(v.isMember("ServeFolders"));/g' ./UnitTestsSources/RestApiTests.cpp
fi

# Build the Orthanc core
mkdir Build
cd Build
# Need ICU variables to pass asian unit tests (See https://hg.orthanc-server.com/orthanc/file/tip/INSTALL#l95)
cmake \
    -DALLOW_DOWNLOADS=ON \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DSTANDALONE_BUILD=ON \
    -DSTATIC_BUILD=ON \
    -DUSE_DCMTK_362=ON \
    -DUSE_GOOGLE_TEST_DEBIAN_PACKAGE=ON \
    -DUSE_SYSTEM_CIVETWEB=OFF \
    -DUSE_SYSTEM_DCMTK=OFF \
    -DUSE_SYSTEM_MONGOOSE=OFF \
    -DUSE_SYSTEM_LIBBOOST=OFF \
    -DUSE_SYSTEM_OPENSSL=ON \
    -DUSE_SYSTEM_JSONCPP=OFF \
    -DBOOST_LOCALE_BACKEND=icu \
    "$orthanc_cmake_location"
make -j$COUNT_CORES

# To run the unit tests, we need to install the "en_US" locale
# For Ubuntu:
# locale-gen en_US
# locale-gen en_US.UTF-8
# For Debian (see https://unix.stackexchange.com/questions/246846/cant-generate-en-us-utf-8-locale):
sed -i 's/^# *\(en_US\)/\1/' /etc/locale.gen
sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen && locale-gen
update-locale 
./UnitTests

# Install the Orthanc core
make install

# Copy the artifacts to the artifacts directory, -L to ensure the file and not a link is copied
cp -L Orthanc /root/artifacts

# Copy these files only if they exist, appeared in 1.6.0
base_plugin_dir="/root/artifacts/base-plugins"
mkdir $base_plugin_dir
if version_gt $1 "Orthanc-1.5.8"; then
    cp -L libConnectivityChecks.so $base_plugin_dir
    cp -L libModalityWorklists.so $base_plugin_dir
    cp -L libServeFolders.so $base_plugin_dir
fi

# Remove the build directory to recover space
cd /root/
rm -rf /root/orthanc

# Auto-generate, then patch the configuration file
CONFIG=/etc/orthanc/orthanc.json
Orthanc --config=$CONFIG
sed 's/\("Name" : \)".*"/\1"Orthanc inside Docker"/' -i $CONFIG
sed 's/\("IndexDirectory" : \)".*"/\1"\/var\/lib\/orthanc\/db"/' -i $CONFIG
sed 's/\("StorageDirectory" : \)".*"/\1"\/var\/lib\/orthanc\/db"/' -i $CONFIG
sed 's/\("Plugins" : \[\)/\1 \n    "\/usr\/share\/orthanc\/plugins", "\/usr\/local\/share\/orthanc\/plugins"/' -i $CONFIG
sed 's/"RemoteAccessAllowed" : false/"RemoteAccessAllowed" : true/' -i $CONFIG
sed 's/"AuthenticationEnabled" : false/"AuthenticationEnabled" : true/' -i $CONFIG
sed 's/\("RegisteredUsers" : {\)/\1\n    "orthanc" : "orthanc"/' -i $CONFIG
