SEVERITIES = HIGH,CRITICAL

ifeq ($(ARCH),)
ARCH=$(shell go env GOARCH)
endif

BUILD_META ?= -multiarch-build$(shell date +%Y%m%d)
ORG ?= rancher
TAG ?= v1.2$(BUILD_META)
UBI_IMAGE ?= centos:7
GOLANG_VERSION ?= v1.16.6b7-multiarch

ifeq (,$(filter %$(BUILD_META),$(TAG)))
$(error TAG needs to end with build metadata: $(BUILD_META))
endif

.PHONY: image-build
image-build:
	docker build \
		--build-arg ARCH=$(ARCH) \
		--build-arg TAG=$(TAG:$(BUILD_META)=) \
                --build-arg GO_IMAGE=$(ORG)/hardened-build-base:$(GOLANG_VERSION) \
                --build-arg UBI_IMAGE=$(UBI_IMAGE) \
		--tag $(ORG)/hardened-sriov-network-resources-injector:$(TAG) \
		--tag $(ORG)/hardened-sriov-network-resources-injector:$(TAG)-$(ARCH) \
	.

.PHONY: image-push
image-push:
	docker push $(ORG)/hardened-sriov-network-resources-injector:$(TAG)-$(ARCH)

.PHONY: image-manifest
image-manifest:
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create --amend \
		$(ORG)/hardened-sriov-network-resources-injector:$(TAG) \
		$(ORG)/hardened-sriov-network-resources-injector:$(TAG)-$(ARCH)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push \
		$(ORG)/hardened-sriov-network-resources-injector:$(TAG)

.PHONY: image-scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --ignore-unfixed $(ORG)/hardened-sriov-network-resources-injector:$(TAG)
