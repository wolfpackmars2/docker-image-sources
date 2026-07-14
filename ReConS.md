# Repository Conventions & Standards
This repository is evolving. The standards and conventions may change regularly as needed.

## Docker commands

See `kasm-workspaces/build.sh` and `kasm-workspaces/BUILDING.md` for the canonical build and push workflow.

### Dev build (auto-loads to KASM host for testing)
```bash
./build.sh <alias> --dev
```

### Release build and push to Docker Hub
```bash
./build.sh <alias> --push
```

Note: `-dev` and release images are built separately with different build args and are **not interchangeable**.
Do not promote a `-dev` build to `-latest` — build them independently.

### Promote -latest to stable
```bash
docker pull sgroesz/kasm-calibre:1.18.0-latest
docker image tag sgroesz/kasm-calibre:1.18.0-latest sgroesz/kasm-calibre:1.18.0
docker push sgroesz/kasm-calibre:1.18.0
```

## Docker Image Naming Conventions

Image names follow the pattern: `kasm[-core][-os][-descriptor]`

- **`kasm`** — always the first segment; identifies images intended for KASM Workspaces.
- **`core`** — optional second segment; marks images used as base layers that may not be directly usable as a workspace without further modification.
- **OS name** — optional; include when the OS is the primary identity of the image (desktop/core/environment images). Omit for single-application images where the underlying OS is an implementation detail.
- **Descriptor** — short, lowercase, hyphenated application or purpose name.

```
kasm-core-noble          # Core base layer for Ubuntu 24.04 Noble
kasm-noble-dev-desktop   # Noble-specific full development desktop
kasm-noble-desktop-basic # Noble-specific base desktop for building other images
kasm-calibre             # Calibre app (OS not relevant to users)
kasm-solvespace          # Solvespace app (OS not relevant to users)
kasm-anycubic-slicer-next
```

## Docker Image Tags
Image tagging schemes will vary based on several factors.

### Kasm Image Tags
Kasm images will be tagged in a manner generally consistant with Kasm tagging schemes. This means the images will be tagged for the Kasm Workspaces version for which the image is intended to be used.

For now, two types of image tag are used for Kasm, in the form of <kasm.version>[-subtag]. Images without a -subtag will always be guaranteed to work. However, they may be out of date, may not have the latest updates, and may not have the latest features and modifications.

Images with a -subtag should generally work. The -subtag should help provide a general confidence level of the image reliability. Currently, the only standard -subtag is "-latest". The -latest image will be the most up to date image available. However, since testing is [not yet] completely implemented, and with how Kasm Workspaces functions, the -latest image may not work or may contain bugs.

The -subtag "-dev" may occasionally exist for test images which are probably broken or when testing changes which are expected to not work properly or be incomplete. "-dev" images should be removed from the repo when no longer needed.

## Kasm Image Examples

`kasm-core-noble:1.18.0` — Core Ubuntu 24.04 Noble base layer. Tested, stable, but may be out of date.

`kasm-core-noble:1.18.0-latest` — Most current build of the Noble core. Usually reliable, but may contain unknown issues.

`kasm-calibre:1.18.0-dev` — Temporary dev image (DEV=1: sudo enabled, debug output). Not suitable for production. Remove when testing is complete.

`kasm-solvespace:1.18.0` — Single-application workspace where the underlying OS is not user-facing.

`kasm-noble-dev-desktop:1.18.0-daily` — Noble dev desktop rebuilt daily for up-to-date packages.

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
