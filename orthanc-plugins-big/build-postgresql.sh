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

# Get the number of available cores to speed up the builds
COUNT_CORES=`grep -c ^processor /proc/cpuinfo`
echo "Will use $COUNT_CORES parallel jobs to build Orthanc PostgreSQL plugin"

# Clone the repository and switch to the requested branch
cd /root/
hg clone https://hg.orthanc-server.com/orthanc-databases/
cd orthanc-databases
hg up -c "$1"

# Build the postgreSQL plugin
mkdir PostgreBuild
cd PostgreBuild
cmake -DALLOW_DOWNLOADS:BOOL=ON \
    -DSTATIC_BUILD=ON \
    -DCMAKE_BUILD_TYPE=Release \
    ../PostgreSQL
make -j$COUNT_CORES
# ./UnitTests # Need postgres server
cp -L libOrthancPostgreSQLIndex.so /root/artifacts/
cp -L libOrthancPostgreSQLStorage.so /root/artifacts/

# Remove the build directory to recover space
cd /root/
rm -rf /root/orthanc-databases