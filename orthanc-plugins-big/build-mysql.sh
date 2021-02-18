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

ORTHANC_BRANCH=$2

# Get the number of available cores to speed up the builds
COUNT_CORES=`grep -c ^processor /proc/cpuinfo`
echo "Will use $COUNT_CORES parallel jobs to build Orthanc MySQL plugin"

# Clone the repository and switch to the requested branch
cd /root/
hg clone https://hg.orthanc-server.com/orthanc-databases/
cd orthanc-databases
hg up -c "$1"

OLD_DOWNLOAD_ORTHANC_FILE="Resources/Orthanc/DownloadOrthancFramework.cmake"
if [ -f "$OLD_DOWNLOAD_ORTHANC_FILE" ]; then
    # Patch resource file to use new orthanc repo
    sed -i 's/bitbucket.org\/sjodogne/hg.orthanc-server.com/g' "$OLD_DOWNLOAD_ORTHANC_FILE"

    # Patch resource file to use relevant version of orthanc
    sed -i 's/ORTHANC_FRAMEWORK_BRANCH "default"/ORTHANC_FRAMEWORK_BRANCH "'$ORTHANC_BRANCH'"/g' "$OLD_DOWNLOAD_ORTHANC_FILE"
fi

# Build the MariaSQL plugin
mkdir MariaSQLBuild
cd MariaSQLBuild
cmake -DALLOW_DOWNLOADS:BOOL=ON \
    -DSTATIC_BUILD=ON \
    -DCMAKE_BUILD_TYPE=Release \
    ../MySQL
make -j$COUNT_CORES
# ./UnitTests
cp -L libOrthancMySQLIndex.so /root/artifacts/
cp -L libOrthancMySQLStorage.so /root/artifacts/

# Remove the build directory to recover space
cd /root/
rm -rf /root/orthanc-databases