ARG BASE_IMAGE_PREFIX
FROM ${BASE_IMAGE_PREFIX}mono

# see hooks/post_checkout
ARG ARCH

# HACK: don't fail when no qemu binary provided
COPY .gitignore qemu-${ARCH}-static* /usr/bin/

ARG OPENRA_RELEASE_VERSION=20210321
ARG OPENRA_RELEASE
ARG OPENRA_RELEASE_TYPE=release

# https://www.openra.net/download/
ENV OPENRA_RELEASE_VERSION=${OPENRA_RELEASE_VERSION:-20200503}
ENV OPENRA_RELEASE_TYPE=${OPENRA_RELEASE_TYPE:-release}
ENV OPENRA_RELEASE=${OPENRA_RELEASE:-https://github.com/MustaphaTR/Romanovs-Vengeance/archive/refs/tags/release-20210409.zip}

RUN set -xe; \
        echo "=================================================================="; \
        echo "Building OpenRA:"; \
        echo "  version:\t${OPENRA_RELEASE_VERSION}"; \
        echo "  type:   \t${OPENRA_RELEASE_TYPE}"; \
        echo "  source: \t${OPENRA_RELEASE}"; \
        echo "=================================================================="; \
        \
        apt-get update; \
        apt-get -y upgrade; \
        apt-get install -y --no-install-recommends \
                    ca-certificates \
                    curl \
                    liblua5.1 \
                    libsdl2-2.0-0 \
                    libopenal1 \
                    make \
                    patch \
                    unzip \
                    xdg-utils \
                    zenity \
                    wget \
                    unzip \
                    python \
                  ; \
        wget https://packages.microsoft.com/config/ubuntu/21.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb; \
        dpkg -i packages-microsoft-prod.deb; \
        apt-get update; \
        apt-get install -y apt-transport-https && \
        apt-get update && \
        apt-get install -y dotnet-sdk-5.0; \
        useradd -d /home/openra -m -s /sbin/nologin openra; \
        mkdir /home/openra/source; \
        cd /home/openra/source; \
        wget $OPENRA_RELEASE -O openra2.zip; \
        unzip openra2.zip; \
        cd /home/openra/source/Romanovs-Vengeance-release-20210409; \
        make
 #       mkdir /home/openra/.openra \
 #             /home/openra/.openra/Logs \
 #             /home/openra/.openra/maps \
 #           ;\
 #       chown -R openra:openra /home/openra/.openra; \
 #       apt-get purge -y curl make patch unzip; \
 #       rm -rf /var/lib/apt/lists/* \
 #              /var/cache/apt/archives/*
#
EXPOSE 1234

USER openra

WORKDIR /home/openra/source/Romanovs-Vengeance-release-20210409
VOLUME ["/home/openra"]


CMD [ "/home/openra/source/Romanovs-Vengeance-release-20210409/launch-dedicated.sh" ]

# annotation labels according to
# https://github.com/opencontainers/image-spec/blob/v1.0.1/annotations.md#pre-defined-annotation-keys
LABEL org.opencontainers.image.title="OpenRA dedicated server"
LABEL org.opencontainers.image.description="Image to run a server instance for OpenRA"
LABEL org.opencontainers.image.url="https://github.com/rmoriz/openra-dockerfile"
LABEL org.opencontainers.image.documentation="https://github.com/rmoriz/openra-dockerfile#readme"
LABEL org.opencontainers.image.version=${OPENRA_RELEASE_TYPE}-${OPENRA_RELEASE_VERSION}
LABEL org.opencontainers.image.licenses="GPL-3.0"
LABEL org.opencontainers.image.authors="Roland Moriz"