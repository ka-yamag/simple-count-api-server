#
# Makefile to build vault-plugin-auth-athenz
# Prerequisite: Go development environment
#

PKG_DATE=$(shell date '+%Y-%m-%dT%H:%M:%S')
BINARY=server
SRC=./main.go

# check to see if go utility is installed
GO := $(shell command -v go 2> /dev/null)

ifdef GO
GO_VER_GTEQ11 := $(shell expr `go version | cut -f 3 -d' ' | cut -f2 -d.` \>= 12)
ifneq "$(GO_VER_GTEQ11)" "1"
all:
	@echo "Please install 1.12.x or newer version of golang"
else
.PHONY: pkg fmt build
all: pkg fmt build
endif

else

all:
	@echo "go is not available please install golang"

endif

pkg:
	go get -v -t -d ./...

fmt:
	gofmt -l .

build: linux arm

arm:
	@echo "Building arm client..."
	CGO_ENABLED=0 GOOS=linux GOARCH=arm go build -a -installsuffix cgo -ldflags "-X main.VERSION=$(PKG_VERSION) -X main.BUILD_DATE=$(PKG_DATE)" -o target/arm/$(BINARY) $(SRC)

linux:
	@echo "Building linux client..."
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags "-X main.VERSION=$(PKG_VERSION) -X main.BUILD_DATE=$(PKG_DATE)" -o target/linux/$(BINARY) $(SRC)

clean:
	rm -rf target
