.EXPORT_ALL_VARIABLES:

GOOS   ?=linux
GOARCH ?=amd64
DISTRO ?=centos
GREP   := $(word 1,$(shell bash -c 'command -v ag grep'))
ifeq ($(notdir $(GREP)),grep)
GREP   += --color=always
endif
GREP   += -r

build:
	go build main.go

run:
	go run main.go

list-todo:
	@find . -name '*.go' -exec $(GREP) TODO \{} \+  ||:
	@find . -name '*.go' -exec $(GREP) FIXME \{} \+ ||:
