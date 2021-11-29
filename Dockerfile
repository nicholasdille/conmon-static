FROM golang:1.16-alpine3.14 AS base
RUN apk add --update-cache --no-cache \
        git \
        make \
        gcc \
        pkgconf \
        musl-dev \
        btrfs-progs \
        btrfs-progs-dev \
        libassuan-dev \
        lvm2-dev \
        device-mapper \
        glib-static \
        libc-dev \
        gpgme-dev \
        protobuf-dev \
        protobuf-c-dev \
        libseccomp-dev \
        libseccomp-static \
        libselinux-dev \
        ostree-dev \
        openssl \
        iptables \
        bash \
        go-md2man

FROM base AS conmon
# renovate: datasource=github-releases depName=containers/conmon
ARG CONMON_VERSION=2.0.30
WORKDIR /conmon
RUN test -n "${CONMON_VERSION}" \
 && git clone --config advice.detachedHead=false --depth 1 --branch "v${CONMON_VERSION}" \
        https://github.com/containers/conmon.git .
RUN make git-vars bin/conmon \
        PKG_CONFIG='pkg-config --static' \
        CFLAGS='-std=c99 -Os -Wall -Wextra -Werror -static' \
        LDFLAGS='-s -w -static' \
 && mv bin/conmon /usr/local/bin/conmon

FROM scratch AS local
COPY --from=conmon /usr/local/bin/conmon .
