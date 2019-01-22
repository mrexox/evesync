.EXPORT_ALL_VARIABLES:

# Build vars
GOOS   ?=linux
GOARCH ?=amd64
DISTRO ?=arch

# Grepping utility
GREP   := $(word 1,$(shell bash -c 'command -v ag grep'))
ifeq ($(notdir $(GREP)),grep)
GREP   += --color=always
endif
GREP   += -r

# Artifacts
DISTRO_PLUGIN := sysmoon_distro.so
SYSMOON_BIN   := sysmoon

build: $(DISTRO_PLUGIN)
	go build -o $(SYSMOON_BIN) main.go

$(DISTRO_PLUGIN):
	go build -buildmode=plugin -o $(DISTRO_PLUGIN) \
		pkg/$(DISTRO)/manager.go 
		
run: $(DISTRO_PLUGIN)
	go run main.go

list-todo:
	@find . -name '*.go' -exec $(GREP) TODO  \{} \+ ||:
	@find . -name '*.go' -exec $(GREP) FIXME \{} \+ ||:
