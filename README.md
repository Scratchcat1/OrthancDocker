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

#### Sequential vs parallel builds
Docker's `buildx` by default builds all independent images in parallel. This can cause OOM failures on systems less than 8GB RAM such as the Raspberry Pi 4 and an [issue](https://github.com/docker/buildx/issues/359) requesting a method to limit this already exists.

As a workaround `Dockerfile.sequential` is provided which adds a dependency chain between builders to limit the number of concurrent builds. This does prevent caching of plugins later in the chain if a new version of an earlier component is built.

#### Build times
|                 | i5 450M | RPi 4 4G | RPi 3 |
|-----------------|---------|----------|-------|
| orthanc         | 1602s   | 4000s    | OOM   |
| orthanc-plugins | 7106.2s | 11084s   | OOM   |

### Building particular versions/branches
Without any arguments the default branch will be pulled for all repos.  
To build from a particular branch add the relevant build args:
```
docker buildx build --platform linux/amd64 --build-arg orthanc_branch=Orthanc-1.9.0 --build-arg databases_branch=OrthancPostgreSQL-3.3
--tag scratchcat1/orthanc-plugins:1.9.0 ./
```
Changing arguments will disable the image caching for later components, therefore ARGS are defined as late as possible.
Available arguments:

|Variable|List of branches|
|------------------|---|
|`orthanc_branch`| [List of branches](https://hg.orthanc-server.com/orthanc/branches)|
|`databases_branch`| [List of branches](https://hg.orthanc-server.com/orthanc-databases/branches)|
|`dicomweb_branch`| [List of branches](https://hg.orthanc-server.com/orthanc-dicomweb/branches)|
|`gdcm_branch`| [List of branches](https://hg.orthanc-server.com/orthanc-gdcm/branches)|
|`webviewer_branch`| [List of branches](https://hg.orthanc-server.com/orthanc-webviewer/branches)|
|`wsi_branch`| [List of branches](https://hg.orthanc-server.com/orthanc-wsi/branches)|

The content of this Docker repository is licensed under the AGPLv3+
license.
