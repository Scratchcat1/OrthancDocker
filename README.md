# Orthanc for Docker

[Docker Hub](https://www.docker.com/) repository to build
[Orthanc](http://www.orthanc-server.com/) and its official
plugins. Orthanc is a lightweight, RESTful Vendor Neutral Archive for
medical imaging.

Full documentation is available in the
[Orthanc Book](http://book.orthanc-server.com/users/docker.html).

## Building for multiarch
`orthanc-big` and `orthanc-plugins-big` can be built for multiple architectures.

### Emulation
All architectures can be built on a single machine using `docker buildx`.
`docker buildx build --platform linux/amd64,linux/arm/v7 --push --tag scratchcat1/orthanc:latest ./`

### Native
For each machine build for the native architecture build and push:
`docker buildx build --platform {platform} --push --tag scratchcat1/orthanc:latest-{arch} ./`

Create and push the manifest:
`docker manifest create scratchcat1/orthanc:latest scratchcat1/orthanc:latest-{arch1} scratchcat1/orthanc:latest-{arch2} [...]`
`docker manifest push scratchcat1/orthanc:latest`

### Building particular versions/branches
Without any arguments the default branch will be pulled for all repos.  
To build from a particular branch add the relevant build args:
```
docker buildx build --platform linux/amd64 --build-arg orthanc_branch=Orthanc-1.9.0 --build-arg databases_branch=OrthancPostgreSQL-3.3
--tag scratchcat1/orthanc-plugins:1.9.0 ./
```

Available arguments:
- orthanc_branch
- databases_branch
- dicomweb_branch
- gdcm_branch
- webviewer_branch
- wsi_branch

The content of this Docker repository is licensed under the AGPLv3+
license.
