ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
FROM ${CI_REGISTRY_IMAGE}/${DOCKERFS_TYPE}:${DOCKERFS_VERSION}${TAG}
LABEL maintainer="florian.sipp@inserm.fr"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    curl unzip libxkbcommon-x11-0 libxcb-keysyms1 \
    libglib2.0-0 libdbus-1-3 libxcb-icccm4 \
    libxcb-randr0 libxcb-render-util0 libxcb-shape0 && \
    curl -sSOL https://github.com/floriansipp/TRCAnonymizer/releases/download/V${APP_VERSION}/TRCAnonymizer.${APP_VERSION}.linux64.zip && \
    mkdir ./install && \
    unzip -q -d ./install TRCAnonymizer.${APP_VERSION}.linux64.zip && \
    chmod -R 757 ./install/TRCAnonymizer.${APP_VERSION}.linux64 && \
    rm TRCAnonymizer.${APP_VERSION}.linux64.zip && \
    apt-get remove -y --purge curl unzip && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV APP_SPECIAL="no"
ENV APP_CMD="/apps/${APP_NAME}/install/TRCAnonymizer.${APP_VERSION}.linux64/TRCAnonymizer"
ENV PROCESS_NAME="/apps/${APP_NAME}/install/TRCAnonymizer.${APP_VERSION}.linux64/TRCAnonymizer"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
