#
# firefox Dockerfile
#
# https://github.com/jlesage/docker-firefox
#

# Build the membarrier check tool.
FROM alpine:3.14 AS membarrier
WORKDIR /tmp
COPY membarrier_check.c .
RUN apk --no-cache add build-base linux-headers
RUN gcc -static -o membarrier_check membarrier_check.c
RUN strip membarrier_check

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.23-v4.11.3

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=

# Define software versions.
ARG FIREFOX_VERSION=145.0-r0

# Define working directory.
WORKDIR /tmp

# Install Firefox.
RUN \
     add-pkg firefox=${FIREFOX_VERSION}

# Install extra packages.
RUN \
    ARCH="$(apk --print-arch)" && \
    if [ "$ARCH" = "x86" ] || [ "$ARCH" = "x86_64" ]; then \
        libva_intel_driver="libva-intel-driver"; \
    fi && \
    add-pkg \
        \
        # WebGL support.
        mesa-dri-gallium \
        mesa-va-gallium \
        $libva_intel_driver \
        \
        # Audio support.
        libpulse \
        \
        # Desktop notification support.
        libnotify \
        \
        # Icons used by folder/file selection window.
        adwaita-icon-theme \
        \
        # Used to send key presses to X process.
        xdotool \
        \
        # Fonts
        font-dejavu \
        font-noto \
        font-noto-cjk \
        font-noto-extra \
        ttf-freefont \
        && \
    \
    # Remove unneeded icons.
    find /usr/share/icons/Adwaita \
        -type d \
        -mindepth 1 \
        -maxdepth 1 \
        -not -name 16x16 \
        -not -name scalable \
        -exec rm -rf {} ';' \
    && \
    true

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://github.com/jlesage/docker-templates/raw/master/jlesage/images/firefox-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /
COPY --from=membarrier /tmp/membarrier_check /usr/bin/

# Set internal environment variables.
RUN \
    set-cont-env APP_NAME "Firefox" && \
    set-cont-env APP_VERSION "$FIREFOX_VERSION" && \
    set-cont-env DOCKER_IMAGE_VERSION "$DOCKER_IMAGE_VERSION" && \
    true

# Public environment variables.
ENV \
    FF_OPEN_URL= \
    FF_KIOSK=0 \
    FF_CUSTOM_ARGS=

# Chinese locale settings.
ENV \
    LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8

# Metadata.
LABEL \
      org.label-schema.name="firefox" \
      org.label-schema.description="Docker container for Firefox" \
      org.label-schema.version="${DOCKER_IMAGE_VERSION:-unknown}" \
      org.label-schema.vcs-url="https://github.com/jlesage/docker-firefox" \
      org.label-schema.schema-version="1.0"
