#!/usr/bin/env bash

# stages
#     1. base_layer
#     2. desktop_layer
#     3. package_layer
#     4. kasm_layer
#     5. config_layer
#     6. final_layer

# Note: if dns doesn't work, add --network=host to the docker build command

CORE_DOCKERFILE="dockerfile-kasm-noble-core"
TEST_DOCKERFILE="dockerfile-kasm-noble-desktop-basic"
STAGE=0

LAYER="base_layer"
((STAGE++))
STATUS="================================\nBuilding ${LAYER}(${STAGE})\n================================\n"
echo -e ${STATUS}
#docker build -f ${CORE_DOCKERFILE} --target ${LAYER} -t "stages:stage${STAGE}" --progress=plain --no-cache .
docker build -f ${CORE_DOCKERFILE} --pull --target ${LAYER} -t "stages:stage${STAGE}" --progress=plain .

LAYER="desktop_layer"
((STAGE++))
STATUS="================================\nBuilding ${LAYER}(${STAGE})\n================================\n"
echo -e ${STATUS}
docker build -f ${CORE_DOCKERFILE} --target ${LAYER} -t "stages:stage${STAGE}" --progress=plain .

LAYER="package_layer"
((STAGE++))
STATUS="================================\nBuilding ${LAYER}(${STAGE})\n================================\n"
echo -e ${STATUS}
docker build -f ${CORE_DOCKERFILE} --target ${LAYER} -t "stages:stage${STAGE}" --progress=plain .

LAYER="kasm_layer"
((STAGE++))
STATUS="================================\nBuilding ${LAYER}(${STAGE})\n================================\n"
echo -e ${STATUS}
docker build -f ${CORE_DOCKERFILE} --target ${LAYER} -t "stages:stage${STAGE}" --progress=plain .

LAYER="config_layer"
((STAGE++))
STATUS="================================\nBuilding ${LAYER}(${STAGE})\n================================\n"
echo -e ${STATUS}
docker build -f ${CORE_DOCKERFILE} --target ${LAYER} -t "stages:stage${STAGE}" --progress=plain .

LAYER="final_layer"
((STAGE++))
STATUS="================================\nBuilding ${LAYER}(${STAGE})\n================================\n"
echo -e ${STATUS}
docker build -f ${CORE_DOCKERFILE} --target ${LAYER} -t "stages:stage${STAGE}" --progress=plain .

docker image tag stages:stage6 sgroesz/kasm-core-ubuntu-noble:1.18.0-local

LAYER="TEST DESKTOP IMAGE"
((STAGE++))
STATUS="================================\nBuilding ${LAYER}(${STAGE})\n================================\n"
echo -e ${STATUS}
docker build -f 'dockerfile-kasm-noble-desktop-basic' --build-arg BASE_TAG=1.18.0-local -t 'desktop:test' --progress=plain --no-cache .

#docker image tag stages:stage6 sgroesz/kasm-core-ubuntu-noble:1.18.0-dev
#docker image tag stages:stage7 sgroesz/kasm-noble-desktop-basic:1.18.0-dev
#docker run -it --rm stages:stage1 bash
