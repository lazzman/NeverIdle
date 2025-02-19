FROM golang:1-alpine AS builder

LABEL maintainer="mritd <mritd@linux.com>"

# GOPROXY is disabled by default, use:
# docker build --build-arg GOPROXY="https://goproxy.io" ...
# to enable GOPROXY.
ARG GOPROXY=""

ENV GOPROXY ${GOPROXY}

COPY . /go/src/github.com/lazzman/NeverIdle

WORKDIR /go/src/github.com/lazzman/NeverIdle

RUN set -ex \
    && apk add git build-base bash
RUN chmod 777 ./build.sh \
    && ./build.sh \
    && mv ./build/NeverIdle-* /go/bin/NeverIdle

# multi-stage builds to create the final image
FROM alpine AS dist

LABEL maintainer="mritd <mritd@linux.com>"

# set up nsswitch.conf for Go's "netgo" implementation
# - https://github.com/golang/go/blob/go1.9.1/src/net/conf.go#L194-L275
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
RUN if [ ! -e /etc/nsswitch.conf ]; then echo 'hosts: files dns' > /etc/nsswitch.conf; fi

# bash is used for debugging, tzdata is used to add timezone information.
# Install ca-certificates to ensure no CA certificate errors.
#
# Do not try to add the "--no-cache" option when there are multiple "apk"
# commands, this will cause the build process to become very slow.
RUN set -ex \
    && apk upgrade \
    && apk add bash tzdata ca-certificates \
    && rm -rf /var/cache/apk/* \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' >/etc/timezone

# 设置编码
ENV LANG C.UTF-8

COPY --from=builder /go/bin/NeverIdle /usr/local/bin/NeverIdle

ENTRYPOINT ["NeverIdle"]
