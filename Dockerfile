ARG TAG="v1.2"
ARG UBI_IMAGE
ARG GO_IMAGE

# Build the project
FROM ${GO_IMAGE} as builder
#RUN apk add --update --virtual build-dependencies build-base linux-headers bash
RUN apk add --update patch
ARG TAG
RUN git clone --depth=1 https://github.com/k8snetworkplumbingwg/network-resources-injector
WORKDIR network-resources-injector
RUN git fetch --all --tags --prune
RUN git checkout tags/${TAG} -b ${TAG}
COPY 0001-fix-modebuild.patch .
RUN patch -t -p1 < 0001-fix-modebuild.patch
RUN make

# Create the network resources injector image
FROM ${UBI_IMAGE}
RUN yum update -y       && \
    yum install -y bash && \
    rm -rf /var/cache/yum
WORKDIR /
COPY --from=builder /go/network-resources-injector/bin/webhook /usr/bin/
COPY --from=builder /go/network-resources-injector/bin/installer /usr/bin/
ENTRYPOINT ["webhook"]
