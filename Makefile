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

all: build

build: $(DISTRO_PLUGIN)
	go build -o $(SYSMOON_BIN) main.go

$(DISTRO_PLUGIN):
	go build -buildmode=plugin -o $(DISTRO_PLUGIN) \
		pkg/$(DISTRO)/manager.go

run: $(DISTRO_PLUGIN)
	go run main.go

list-todo:
	@echo -e ":><: \033[0;31mTODOs\033[0m in code"
	@find . -name '*.go' -exec $(GREP) TODO  \{} \+ ||:
	@echo -e ":><: \033[0;31mFIXMEs\033[0m in code"
	@find . -name '*.go' -exec $(GREP) FIXME \{} \+ ||:

clean:
	rm -rf $(DISTRO_PLUGIN) $(SYSMOON_BIN)
