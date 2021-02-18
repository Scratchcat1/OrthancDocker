FROM debian:buster-slim as builder

MAINTAINER Sebastien Jodogne <s.jodogne@gmail.com>
LABEL Description="Base environment to build Orthanc" Vendor="The Orthanc project"

RUN echo "deb http://http.us.debian.org/debian stable main contrib non-free" | tee /etc/apt/sources.list.d/debian.list
RUN apt-get -y clean && apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install wget nano build-essential unzip locales \
    cmake mercurial uuid-dev libcurl4-openssl-dev liblua5.1-0-dev libgtest-dev libpng-dev libopenjp2-7-dev \
    libsqlite3-dev libssl-dev libjpeg-dev zlib1g-dev libdcmtk2-dev libboost-all-dev libwrap0-dev \
    libcharls-dev libjsoncpp-dev libpugixml-dev libgdcm2-dev postgresql-server-dev-all libtiff-dev libopenslide-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/artifacts/
