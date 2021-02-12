FROM debian:buster-slim as builder
ARG orthanc_branch='default'

MAINTAINER Sebastien Jodogne <s.jodogne@gmail.com>
LABEL Description="Orthanc, free DICOM server" Vendor="The Orthanc project"

RUN echo "deb http://http.us.debian.org/debian stable main contrib non-free" | tee /etc/apt/sources.list.d/debian.list
RUN apt-get -y clean && apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install wget nano build-essential unzip \
    cmake mercurial uuid-dev libcurl4-openssl-dev liblua5.1-0-dev libgtest-dev libpng-dev \
    libsqlite3-dev libssl-dev libjpeg-dev zlib1g-dev libdcmtk2-dev libboost-all-dev libwrap0-dev \
    libcharls-dev libjsoncpp-dev libpugixml-dev locales && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/artifacts

ADD ./build-orthanc.sh /root/build-orthanc.sh
RUN bash /root/build-orthanc.sh "$orthanc_branch"

# RUN DEBIAN_FRONTEND=noninteractive apt-get -y purge wget nano build-essential unzip \
#     cmake mercurial uuid-dev libcurl4-openssl-dev liblua5.1-0-dev libgtest-dev libpng-dev \
#     libsqlite3-dev libssl-dev libjpeg-dev zlib1g-dev libdcmtk2-dev libboost-all-dev libwrap0-dev \
#     libcharls-dev libjsoncpp-dev libpugixml-dev locales
# RUN DEBIAN_FRONTEND=noninteractive apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*


FROM debian:buster-slim

RUN apt-get -y clean && apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install locales && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen && rm -rf /usr/share/i18n/

RUN mkdir -p /var/lib/orthanc/db && \
    mkdir -p /usr/local/sbin/ && \
    mkdir -p /usr/local/bin/ && \
    mkdir -p /usr/local/share/orthanc/plugins/

COPY --from=builder /etc/orthanc /etc/orthanc
COPY --from=builder /root/artifacts/Orthanc /usr/local/sbin/
COPY --from=builder /root/artifacts/libConnectivityChecks.so /usr/local/share/orthanc/plugins/
COPY --from=builder /root/artifacts/libModalityWorklists.so /usr/local/share/orthanc/plugins/
COPY --from=builder /root/artifacts/libServeFolders.so /usr/local/share/orthanc/plugins/

VOLUME [ "/var/lib/orthanc/db" ]
EXPOSE 4242
EXPOSE 8042

ENTRYPOINT [ "Orthanc" ]
CMD [ "/etc/orthanc/" ]
