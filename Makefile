# ########################################################## #
# Makefile for Golang Project
# Includes cross-compiling, installation, cleanup
# ########################################################## #

# Check for required command tools to build or stop immediately
EXECUTABLES = git go find pwd
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH)))

ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

OS=$(shell go env | grep GOOS | cut -d'"' -f2)
ARCH=$(shell go env | grep GOARCH | cut -d'"' -f2)

APPNAME=MoleIDS
BINARY=mole_${OS}_${ARCH}
BINDIR=build
VERSION=v0.0.0-dev
BUILD=`git rev-parse HEAD`
BUILDDATE=`date +%FT%T%z`
PACKAGE=github.com/mole-ids/mole/cmd
COVER_PROFILE=c.out

SRC=main.go

# Setup linker flags option for build that interoperate with variable names in src code
LDFLAGS=-ldflags "-X ${PACKAGE}.AppName=${APPNAME} -X ${PACKAGE}.Version=${VERSION} -X ${PACKAGE}.BuildDate=${BUILDDATE} -X ${PACKAGE}.BuildHash=${BUILD}"

default: build

all: clean install

build:
	go build -race ${LDFLAGS} -o ${BINDIR}/${BINARY} $(SRC)

build-pfring:
	go build -race -tags "pf_ring" ${LDFLAGS} -o ${BINDIR}/${BINARY} $(SRC)

install:
	go install ${LDFLAGS}

test:
	go test -v -count=1 ./...

test-race:
	go test -race -v -count=1 ./...

test-cover:
	go test -v -count=1 -cover -coverprofile=${COVER_PROFILE} ./...

docs:
	make -C ./docs docs

clean:
	rm -rf ${BINDIR}

.PHONY: check clean build build-prod test-race test-cover install all docs
