FROM debian:buster-slim as builder
ARG orthanc_branch='default'
ARG databases_branch='default'
ARG dicomweb_branch='default'
ARG gdcm_branch='default'
ARG webviewer_branch='default'
ARG wsi_branch='default'

MAINTAINER Sebastien Jodogne <s.jodogne@gmail.com>
LABEL Description="Orthanc, free DICOM server" Vendor="The Orthanc project"

RUN echo "deb http://http.us.debian.org/debian stable main contrib non-free" | tee /etc/apt/sources.list.d/debian.list
RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install locales

RUN apt-get -y clean && apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install wget nano build-essential unzip \
    cmake mercurial uuid-dev libcurl4-openssl-dev liblua5.1-0-dev libgtest-dev libpng-dev libopenjp2-7-dev \
    libsqlite3-dev libssl-dev libjpeg-dev zlib1g-dev libdcmtk2-dev libboost-all-dev libwrap0-dev \
    libcharls-dev libjsoncpp-dev libpugixml-dev libgdcm2-dev postgresql-server-dev-all libtiff-dev libopenslide-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ADD ./build-orthanc.sh /root/build-orthanc.sh
RUN bash /root/build-orthanc.sh "$orthanc_branch"

ADD ./build-webviewer.sh /root/build-webviewer.sh
RUN bash /root/build-webviewer.sh "$webviewer_branch"

ADD ./build-databases.sh /root/build-databases.sh
RUN bash /root/build-databases.sh "$databases_branch"

ADD ./build-dicomweb.sh /root/build-dicomweb.sh
RUN bash /root/build-dicomweb.sh "$dicomweb_branch"

ADD ./build-wsi.sh /root/build-wsi.sh
RUN bash /root/build-wsi.sh "$wsi_branch"

ADD ./build-gdcm.sh /root/build-gdcm.sh
RUN bash /root/build-gdcm.sh "$gdcm_branch"


FROM debian:buster-slim

RUN apt-get -y clean && apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install locales && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen && rm -rf /usr/share/i18n/

RUN mkdir -p /var/lib/orthanc/db && \
    mkdir -p /usr/local/sbin/ && \
    mkdir -p /usr/local/bin/ && \
    mkdir -p /usr/local/share/orthanc/plugins/

COPY --from=builder /etc/orthanc /etc/orthanc
COPY --from=builder /root/orthanc/Build/Orthanc /usr/local/sbin/
COPY --from=builder /root/orthanc-wsi/Applications/Build/OrthancWSIDicomizer /usr/local/bin/
COPY --from=builder /root/orthanc-wsi/Applications/Build/OrthancWSIDicomToTiff /usr/local/bin/
COPY --from=builder /root/orthanc/Build/libConnectivityChecks.so /usr/local/share/orthanc/plugins/
COPY --from=builder /root/orthanc/Build/libModalityWorklists.so /usr/local/share/orthanc/plugins/
COPY --from=builder /root/orthanc/Build/libServeFolders.so /usr/local/share/orthanc/plugins/

COPY --from=builder /root/orthanc-dicomweb/Build/libOrthancDicomWeb.so /usr/local/share/orthanc/plugins/
COPY --from=builder /root/orthanc-databases/PostgreBuild/libOrthancPostgreSQLIndex.so /usr/local/share/orthanc/plugins/
COPY --from=builder /root/orthanc-databases/PostgreBuild/libOrthancPostgreSQLStorage.so /usr/local/share/orthanc/plugins/
COPY --from=builder /root/orthanc-databases/MariaSQLBuild/libOrthancMySQLIndex.so /usr/local/share/orthanc/plugins/
COPY --from=builder /root/orthanc-databases/MariaSQLBuild/libOrthancMySQLStorage.so /usr/local/share/orthanc/plugins/
COPY --from=builder /root/orthanc-webviewer/Build/libOrthancWebViewer.so /usr/local/share/orthanc/plugins/
COPY --from=builder /root/orthanc-wsi/ViewerPlugin/Build/libOrthancWSI.so /usr/local/share/orthanc/plugins/
COPY --from=builder /root/orthanc-gdcm/Build/libOrthancGdcm.so /usr/local/share/orthanc/plugins/


VOLUME [ "/var/lib/orthanc/db" ]
EXPOSE 4242
EXPOSE 8042

ENTRYPOINT [ "Orthanc" ]
CMD [ "/etc/orthanc/" ]
