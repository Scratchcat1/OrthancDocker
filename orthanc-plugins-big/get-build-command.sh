#!/bin/sh

usage_help() {
    echo "Output a command to build orthanc-plugins-big with compatible plugin versions according to the Ubuntu package versions"
    echo "Usage: ./get-build-command.sh [ORTHANC_VERSION]"
    echo "Example: ./get-build-command.sh 1.9.0"
    exit 0
}

if [ $# -eq 0 ]
then
    usage_help
fi

ORTHANC_VER=$1
ORTHANC_BRANCH="Orthanc-$ORTHANC_VER"
case $ORTHANC_VER in
    1.3.*)  echo "Using versions from Ubuntu 18.04 LTS"
            DICOMWEB_BRANCH="OrthancDicomWeb-0.4";
            POSTGRESQL_BRANCH="OrthancPostgreSQL-2.2";
            WEBVIEWER_BRANCH="OrthancWebViewer-2.3";
            WSI_BRANCH="OrthancWSI-0.4";
            GDCM_BRANCH="default";;
    1.5.*)  echo "Using versions from Ubuntu 20.04 LTS"
            DICOMWEB_BRANCH="OrthancDicomWeb-1.0";
            POSTGRESQL_BRANCH="OrthancPostgreSQL-3.2";
            WEBVIEWER_BRANCH="OrthancWebViewer-2.5";
            WSI_BRANCH="OrthancWSI-0.6";
            GDCM_BRANCH="default";;
    1.7.*)  echo "Using versions from Ubuntu 20.10"
            DICOMWEB_BRANCH="OrthancDicomWeb-1.2";
            POSTGRESQL_BRANCH="OrthancPostgreSQL-3.2";
            WEBVIEWER_BRANCH="OrthancWebViewer-2.6";
            WSI_BRANCH="OrthancWSI-0.7";
            GDCM_BRANCH="default";;
    1.9.*)  echo "Using versions from Ubuntu 21.04"
            DICOMWEB_BRANCH="OrthancDicomWeb-1.5";
            POSTGRESQL_BRANCH="OrthancPostgreSQL-3.3";
            WEBVIEWER_BRANCH="OrthancWebViewer-2.7";
            WSI_BRANCH="OrthancWSI-1.0";
            GDCM_BRANCH="OrthancGdcm-1.2";;
    *)      echo "No matching version found";
            exit 1;;
esac

echo "Orthanc branch: $ORTHANC_BRANCH"
echo "DICOMWeb branch: $DICOMWEB_BRANCH"
echo "PostgreSQL branch: $POSTGRESQL_BRANCH"
echo "Webviewer branch: $WEBVIEWER_BRANCH"
echo "WSI branch: $WSI_BRANCH"
echo "GDCM branch: $GDCM_BRANCH"

echo "docker buildx build \
 --build-arg orthanc_branch=$ORTHANC_BRANCH \
 --build-arg databases_branch=$POSTGRESQL_BRANCH \
 --build-arg dicomweb_branch=$DICOMWEB_BRANCH \
 --build-arg webviewer_branch=$WEBVIEWER_BRANCH \
 --build-arg wsi_branch=$WSI_BRANCH \
 --build-arg gdcm_branch=$GDCM_BRANCH \
 --tag scratchcat1/orthanc-plugins:$ORTHANC_VER ./"