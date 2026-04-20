# docker-image-sources

Repository of dockerfiles and sources used to build public docker images.

KASM images include:

```
sgroesz/solvespace-kasm
sgroesz/anycubic-slicer-next-kasm
sgroesz/kasm-core-ubuntu-noble
sgroesz/kasm-noble-desktop-basic
```

Tags for KASM images include:

```
1.18.0
    - This image which will receive infrequent updates.
    - Guaranteed to be stable, but is not up to date.

1.18.0-latest
    - This is the most up-to-date image. This image will change frequently, but should always work.

1.18.0-daily
    - Using the current 1.18.0-latest as base image, apply package updates.

1.18.0-dev
    - Unstable test build. Should not be used. Used when testing irregular changes to an image definition prior to deploying the -latest image.

1.18.0-current
    - DEPRECATED. An alternate tag for -latest. Will be removed soon.
```