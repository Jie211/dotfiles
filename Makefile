DOTPATH    := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
EXCLUSIONS := .DS_Store .git .gitmodules .travis.yml
CANDIDATES := $(wildcard ./src/.??*)
DOTFILES   := $(filter-out $(EXCLUSIONS), $(CANDIDATES))

.PHONY: all install uninstall

all: install

install:
	@DOTPATH=$(DOTPATH) bash $(DOTPATH)/setup.sh

uninstall:
	@DOTPATH=$(DOTPATH) bash $(DOTPATH)/unset.sh
