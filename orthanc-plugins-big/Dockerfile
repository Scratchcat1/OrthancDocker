FROM scratchcat1:orthanc-base as orthanc_builder
ARG orthanc_branch='default'
ADD ./build-orthanc.sh /root/build-orthanc.sh
RUN bash /root/build-orthanc.sh "$orthanc_branch"

FROM scratchcat1:orthanc-base as databases_builder
ARG databases_branch='default'
ADD ./build-databases.sh /root/build-databases.sh
RUN bash /root/build-databases.sh "$databases_branch"

FROM scratchcat1:orthanc-base as webviewer_builder
ARG webviewer_branch='default'
ADD ./build-webviewer.sh /root/build-webviewer.sh
RUN bash /root/build-webviewer.sh "$webviewer_branch"

FROM scratchcat1:orthanc-base as dicomweb_builder
ARG dicomweb_branch='default'
ADD ./build-dicomweb.sh /root/build-dicomweb.sh
RUN bash /root/build-dicomweb.sh "$dicomweb_branch"

FROM scratchcat1:orthanc-base as wsi_builder
ARG wsi_branch='default'
ADD ./build-wsi.sh /root/build-wsi.sh
RUN bash /root/build-wsi.sh "$wsi_branch"

FROM scratchcat1:orthanc-base as gdcm_builder
ARG gdcm_branch='default'
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

COPY --from=orthanc_builder /etc/orthanc /etc/orthanc
COPY --from=orthanc_builder /root/artifacts/Orthanc /usr/local/sbin/
COPY --from=wsi_builder /root/artifacts/OrthancWSIDicomizer /usr/local/bin/
COPY --from=wsi_builder /root/artifacts/OrthancWSIDicomToTiff /usr/local/bin/

COPY --from=orthanc_builder /root/artifacts/libConnectivityChecks.so /usr/local/share/orthanc/plugins/
COPY --from=orthanc_builder /root/artifacts/libModalityWorklists.so /usr/local/share/orthanc/plugins/
COPY --from=orthanc_builder /root/artifacts/libServeFolders.so /usr/local/share/orthanc/plugins/

COPY --from=dicomweb_builder /root/artifacts/libOrthancDicomWeb.so /usr/local/share/orthanc/plugins/
COPY --from=databases_builder /root/artifacts/libOrthancPostgreSQLIndex.so /usr/local/share/orthanc/plugins/
COPY --from=databases_builder /root/artifacts/libOrthancPostgreSQLStorage.so /usr/local/share/orthanc/plugins/
COPY --from=databases_builder /root/artifacts/libOrthancMySQLIndex.so /usr/local/share/orthanc/plugins/
COPY --from=databases_builder /root/artifacts/libOrthancMySQLStorage.so /usr/local/share/orthanc/plugins/
COPY --from=webviewer_builder /root/artifacts/libOrthancWebViewer.so /usr/local/share/orthanc/plugins/
COPY --from=wsi_builder /root/artifacts/libOrthancWSI.so /usr/local/share/orthanc/plugins/
COPY --from=gdcm_builder /root/artifacts/libOrthancGdcm.so /usr/local/share/orthanc/plugins/


VOLUME [ "/var/lib/orthanc/db" ]
EXPOSE 4242
EXPOSE 8042

ENTRYPOINT [ "Orthanc" ]
CMD [ "/etc/orthanc/" ]
