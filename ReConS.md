# Repository Conventions & Standards
This repository is evolving. The standards and conventions may change regularly as needed.

## Docker commands

### Push -latest to STABLE
```bash
docker pull sgroesz/kasm-noble-dev-desktop:1.18.0-latest
docker image tag sgroesz/kasm-noble-dev-desktop:1.18.0-latest sgroesz/kasm-noble-dev-desktop:1.18.0
docker push sgroesz/kasm-noble-dev-desktop:1.18.0
```

### Push -dev to -latest
```bash
docker image tag sgroesz/kasm-noble-dev-desktop:1.18.0-dev sgroesz/kasm-noble-dev-desktop:1.18.0-latest
docker push sgroesz/kasm-noble-dev-desktop:1.18.0-latest
```

### Build and push -daily
```bash
docker build --network=host --build-arg PATCH_DATE="$(date -u "+%Y-%m-%d %Z")" -f dockerfile-kasm-dev-desktop-daily -t "sgroesz/kasm-noble-dev-desktop:1.18.0-daily"
docker push sgroesz/kasm-noble-dev-desktop:1.18.0-latest
```

## Docker Image Naming Conventions
- The first part of the image name is an optional group name. Images created for use with KASM will be group "kasm". This helps identify images which work best with Kasm Workspaces.
- Following the optional group name will be an optional IMAGE CATEGORY. CORE images will use "core" as the IMAGE CATEGORY. This will identify images which are intended to be used as a base for building more images. CORE images may not be functionally complete by themselves and may not run without further modifications.
- The third optional name will be the OS base distro name. If the base distro is not relevant or there is no base distro included in the image, the distro name will be omitted.
- The remainder of the image name will be short and descriptive

## Docker Image Tags
Image tagging schemes will vary based on several factors.

### Kasm Image Tags
Kasm images will be tagged in a manner generally consistant with Kasm tagging schemes. This means the images will be tagged for the Kasm Workspaces version for which the image is intended to be used.

For now, two types of image tag are used for Kasm, in the form of <kasm.version>[-subtag]. Images without a -subtag will always be guaranteed to work. However, they may be out of date, may not have the latest updates, and may not have the latest features and modifications.

Images with a -subtag should generally work. The -subtag should help provide a general confidence level of the image reliability. Currently, the only standard -subtag is "-latest". The -latest image will be the most up to date image available. However, since testing is [not yet] completely implemented, and with how Kasm Workspaces functions, the -latest image may not work or may contain bugs.

The -subtag "-dev" may occasionally exist for test images which are probably broken or when testing changes which are expected to not work properly or be incomplete. "-dev" images should be removed from the repo when no longer needed.

## Kasm Image Examples
`kasm-core-noble:1.18.0` Core Ubuntu 24.04 Noble image for Kasm Workspaces version 1.18. This image has been tested and proven to work, but may be out of date and doesn't contain the most current updates and changes.

`kasm-core-noble:1.18.0-latest` Core Ubuntu 24.04 Noble image for Kasm Workspaces version 1.18. This image is the most current available, but may contain unknown bugs or issues which may prevent the image from running properly. Eventually, a testing scheme will be implemented which should make these more reliable. Even so, these images are usually reliable, and any problems will be fixed quickly after discovery.

`kasm-noble-simple-desktop:1.18.0-dev` A temporary -dev image for testing.

`kasm-solvespace:1.18.0` A single application Kasm workspace where the underlying OS is not important.

# Dockerfile and Image Conventions
Dockerfiles should generate images with traceable layers, as much as possible. Images should be broken up into layers in such a way that image updates are as small as possible. Image layers should be grouped such that when an update occurs, the fewest image layers possible should be affected.

Some valuable guidance is available here https://devopscube.com/build-docker-image/ with special focus on best practices https://devopscube.com/build-docker-image/#dockerfile-best-practices. Definitely follow this guidance: https://docs.docker.com/build/building/best-practices/.

Use stages to build the layers if needed. Use stages where practical.

## Example Image Layers
- Base OS layer
- Applications grouped by how frequently they are expected to be updated. For example, Kasm programs which are updated infrequently should be grouped together.
- Configuration files. Data that is relatively small but may change occasionally, even if other image layers may not change.
- Applications that are frequently updated. For example, software which is built from the latest source code and may change frequently. Each application with very frequent updates should be in their own layer.
- Applications which are semi-frequently updated can be grouped together such that when one application is updated, the other applications in the same group are updated together.
- Squash layers together when it makes sense to do so. For example, it may be worthwhile to squash the official Base Ubuntu image with apt updates applied on occasion.

# Git standards

## Branch names
Branch names should be grouped into sub-branches in a sensible manner. Branches for testing changes to Kasm Workspaces images should be in the kasm branch. Branch names should generally follow the docker image naming convention.

Follow the guidance provided by github https://conventional-branch.github.io/.

## Commits
Commits should generally be complete, when possible. Each commit should contain source files which can be successfully built into a working end product. When practical.

Commits can be squashed together only when doing so will not have any possible impact on other developers. Commits can be squashed together to correct egregious mistakes or errors in the code base. For example, in order to remove leaked secrets - though this should never happen.
