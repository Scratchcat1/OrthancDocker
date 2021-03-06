FROM scratchcat1/orthanc-base:buster as builder

MAINTAINER Sebastien Jodogne <s.jodogne@gmail.com>
LABEL Description="Orthanc, free DICOM server" Vendor="The Orthanc project"

RUN mkdir -p /root/artifacts

ARG orthanc_branch='default'
ADD ./build-orthanc.sh /root/build-orthanc.sh
RUN bash /root/build-orthanc.sh "$orthanc_branch"


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
COPY --from=builder /root/artifacts/base-plugins/* /usr/local/share/orthanc/plugins/

VOLUME [ "/var/lib/orthanc/db" ]
EXPOSE 4242
EXPOSE 8042

ENTRYPOINT [ "Orthanc" ]
CMD [ "/etc/orthanc/" ]
