#
# Git helper to manage multiple storage branches.
# https://github.com/zaufi/git-mbr
#
# Copyright (c) 2018-2019 Alex Turbov <i.zaufi@gmail.com>
#

SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

# NOTE The other value is `utf-8`
OUTPUT ?= $(shell locale charmap)

_bullet := $(if $(findstring $(OUTPUT),utf utf-8 utf8 UTF UTF-8 UTF8),•,*)

help: _help_main _help_plugins _help_extra_options

.DEFAULT: help

_help_main:
	@echo 'Git helper to manage multiple storage branches.'
	@echo ''
	@echo 'Usage:'
	@echo '    make add-branch name=<string>'
	@echo '    make update-all'
	@echo '    make for-each-working-tree exec=<cmd> [match=<pattern>]'
	@echo '    make show-branches-as-tree'
	@echo ''

# NOTE Plug-ins' help-screen targets should add self as dependency of this target!
_help_plugins:

_help_extra_options:
	@echo 'Extra debugging options:'
	@echo '  $(_bullet) `debug=1`        show commands instead of run them'

#BEGIN Some "commands" to reuse
cmd.error = echo "make[$(MAKELEVEL)]: ***"
ifeq '$(debug)' '1'
cmd.debug.echo = echo
cmd.debug.echo.h = @echo
endif
#END Some "commands" to reuse

#BEGIN Some "functions" to reuse
fn.unique = $(if $1,$(firstword $1) $(call fn.unique,$(filter-out $(firstword $1),$1)))
fn.apply.eval = $(eval $(call $1,$2,$3,$4,$5,$6,$7,$8,$9))
fn.make.error = $(cmd.error) "$(strip $1)." 1>&2
fn.make.failure = $(cmd.error) "$(strip $1). Stop." 1>&2 && exit 1
#END Some "functions" to reuse

branches.remote = $(filter-out HEAD,$(shell git branch --remote --list --format='%(refname:strip=3)'))
branches.local = $(shell git branch --list --format='%(refname:strip=2)')
branches.all = $(call fn.unique,$(branches.remote) $(branches.local))
worktrees.all = $(patsubst \
    refs/heads/%,%,$(shell git worktree list --porcelain | grep ^branch | sed 's,branch ,,' | grep -v $$(git symbolic-ref HEAD)) \
  )

_prune_wt:
	$(cmd.debug.echo.h) git worktree prune -v

# Define a rule to add a working tree for a branch
define fn.render.fetch
../$1/.git:
	$(cmd.debug.echo.h) git worktree add --force --checkout ../$1 $1 \
	  && cd ../$1 \
	  && git checkout $1
endef

# Render rules to add working tree for a branch
$(foreach _b,$(branches.all),$(call fn.apply.eval,fn.render.fetch,$(_b)))

# The rule to update all branches
update-all: _prune_wt $(patsubst %,../%/.git,$(branches.all))

add-branch:
ifndef name
	@$(call fn.make.error, Please provide the branch name via 'name=<str>' parameter)
else
	$(cmd.debug.echo.h) git worktree add --force --checkout -b $(name) ../$(name) $$(git rev-list --max-parents=0 HEAD)
endif

for-each-working-tree:
ifndef exec
	@$(call fn.make.error, Please provide a command to execute via 'exec=<cmd>' parameter)
else
	@for dir in $(worktrees.all); do \
	    if [[ $(if $(match),$${dir} =~ $(match), true) ]]; then \
	        cd ../$${dir} && echo -e "\n---[ $${dir} ] ---" && ( ( $(exec) ) || true ) && cd - > /dev/null; \
	    fi; \
	done
endif

show-branches-as-tree:
	@rm -rf $${TEMP:-/tmp}/$@
	@mkdir $${TEMP:-/tmp}/$@
	@cd $${TEMP:-/tmp}/$@ && mkdir -p $(branches.all) && tree --noreport
	@rm -rf $${TEMP:-/tmp}/$@

#BEGIN Include "plug-ins"
-include extras.d/*-plugin.mk
#END Include "plug-ins"
