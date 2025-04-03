# SPDX-FileCopyrightText: Copyright (C) 2018 - 2025 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Git helper to manage multiple branches.
# https://github.com/zaufi/git-mbr
#

SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

# NOTE The other value is `utf-8`
OUTPUT ?= $(shell locale charmap)

# BEGIN Some "commands" to reuse
cmd.eecho = echo -e
cmd.error = $(cmd.eecho) "$(c.gray)make[$(MAKELEVEL)]: $(c.red)***"
ifeq '$(debug)' '1'
cmd.debug.echo = echo
cmd.debug.echo.h = @echo
endif
# END Some "commands" to reuse

# BEGIN Some "functions" to reuse
fn.unique = $(if $1,$(firstword $1) $(call fn.unique,$(filter-out $(firstword $1),$1)))
fn.apply.eval = $(eval $(call $1,$2,$3,$4,$5,$6,$7,$8,$9))
fn.make.error = $(cmd.error) "$(strip $1).$(c.reset)" 1>&2
fn.make.failure = $(cmd.error) "$(strip $1). Stop.$(c.reset)" 1>&2 && exit 1
fn.path.join = $(shell readlink -m $1/$2)
# editorconfig-checker-disable
fn.worktree.get = $(shell \
    git worktree list --porcelain \
      | grep ^$1 \
      | cut -d ' ' -f 2 \
      | grep -v '$(branch.self)' \
      $(if $2,| $2,) \
  )
# editorconfig-checker-enable
fn.show_title = $(cmd.eecho) "\n$(c.gray)---[ $(c.cyan)$1$(c.gray) ]---$(c.reset)"
# END Some "functions" to reuse

# BEGIN Terminal colors
include extras.d/colors.mk
# END Terminal colors

# BEGIN VCS variables
git.top = $(shell git rev-parse --show-toplevel)
branch.self = $(shell git symbolic-ref --short HEAD)
branches.remote = $(filter-out HEAD,$(shell git branch --remote --list --format='%(refname:strip=3)'))
branches.local = $(shell git branch --list --format='%(refname:strip=2)')
branches.all = $(call fn.unique,$(branches.remote) $(branches.local))
worktrees.all = $(patsubst refs/heads/%,%,$(call fn.worktree.get,branch))
worktrees.all.paths = $(call fn.worktree.get,worktree)
# END VCS variables

# BEGIN Help screen
_bullet := $(if $(findstring $(OUTPUT),utf utf-8 utf8 UTF UTF-8 UTF8),•,*)
define fn._render.plugin.help.targets =
$1-title:
	@$(cmd.eecho) "\n$(c.bold)$(c.italic)Targets from" \
	              "$(c.dim)$(c.magenta)\`$(lastword $(MAKEFILE_LIST))\`$(c.normal)$(c.bold)$(c.italic):$(c.reset)"
$1: $1-title
_help_plugins: $1
.PHONY: $1 $1-title
endef
fn.set.plugin.help.target = $(call fn.apply.eval,fn._render.plugin.help.targets,$1)

fn.hlp.ttl = @$(cmd.eecho) "$(c.bold)$(strip $1)$(c.reset)"
fn.hlp.tgt = @$(cmd.eecho) "$(help.use.indent)$(c.gray)$(strip $1)$(c.reset)$(if $2,$(help.text.indent)$(c.italic)# $(strip $2)$(c.reset),)"
fn.hlp.opt = @$(cmd.eecho) "$(help.opt.indent)$(_bullet) $(c.gray)$(strip $1)$(c.reset)$(if $2,$(help.text.indent)$(c.italic)# $(strip $2)$(c.reset),)"

help: _help_main _help_plugins _help_extra_options

.DEFAULT: help

_help_main:
	$(call fn.hlp.ttl, Git helper to manage multiple branches.\n)
	$(call fn.hlp.ttl, Usage:)
	$(call fn.hlp.tgt, make add-branch name=<string>, add a new branch with a given name)
	$(call fn.hlp.tgt, $(help.use2.indent)[orphan=1 | orph=1 | o=1],  (optionally make the branch orphan))
	$(call fn.hlp.tgt, make update-all [sub=1], checkout all branches as working trees)
	$(call fn.hlp.tgt, , (optionally initialize sub-modules))
	$(call fn.hlp.tgt, make for-each-working-tree exec=<cmd>, execute given command for all working trees)
	$(call fn.hlp.tgt, $(help.use2.indent)[match=<pattern>])
	$(call fn.hlp.tgt, make show-branches-as-tree, show working trees structure)

# NOTE Plug-ins' help-screen targets should add self as dependency of this target!
_help_plugins:

_help_extra_options:
	$(call fn.hlp.ttl, \nExtra debugging options:)
	$(call fn.hlp.opt, debug=1, show commands instead of run them)

.PHONY: help _help_main _help_plugins _help_extra_options
.NOTPARALLEL: help _help_plugins
# END Help screen

_prune_wt:
	$(cmd.debug.echo.h) git worktree prune -v

.PHONY: _prune_wt

# Define a rule to add a working tree for a branch
../%/.git:
	@echo 'Adding a working tree for `$*`'
	$(cmd.debug.echo.h) git worktree add --force --checkout ../$* $*
	$(if $(findstring 1,$(sub)),test -f ../$*/.gitmodules && ( $(cmd.debug.echo) cd ../$* && $(cmd.debug.echo) git submodule update --init ) || true,)

.PRECIOUS: ../%/.git
.SECONDARY: ../%/.git

# The rule to update all branches
update-all: _prune_wt $(branches.all:%=../%/.git)

_missed_name_param:
	@$(call fn.make.error, Please provide the branch name via 'name=<str>' parameter)

_add_branch_via_wt:
	$(cmd.debug.echo.h) git worktree add --force --checkout -b $(name) ../$(name) $$(git rev-list --max-parents=0 HEAD)

_add_branch_via_co:
	$(cmd.debug.echo.h) git checkout --orphan $(name)
	$(cmd.debug.echo.h) git commit -am 'misc: initial orphan branch fork'
	$(cmd.debug.echo.h) git checkout $(branch.self)
	$(cmd.debug.echo.h) git worktree add "$(call fn.path.join,$(git.top),/../$(name))" $(name) \
	  && $(cmd.debug.echo) cd "$(call fn.path.join,$(git.top),/../$(name))" \
	  && $(cmd.debug.echo) git submodule update --init

add-branch: $(if $(name), $(if $(or $(o),$(orph),$(orphan)), _add_branch_via_co, _add_branch_via_wt), _missed_name_param)

for-each-working-tree:
ifndef exec
	@$(call fn.make.error, Please provide a command to execute via 'exec=<cmd>' parameter)
else
	@for dir in $(worktrees.all); do \
	    $(if $(match),[[ ! $${dir} =~ $(match) ]] && continue || true;,) \
	    cd ../$${dir} \
	     && $(call fn.show_title,$${dir}) \
	     && ( ( $(exec) ) || true ) \
	     && cd - > /dev/null; \
	done
endif

.PHONY: for-each-working-tree

show-branches-as-tree:
	@rm -rf $${TEMP:-/tmp}/$@ \
	 && mkdir $${TEMP:-/tmp}/$@ \
	 && cd $${TEMP:-/tmp}/$@ \
	 && mkdir -p $(branches.all) \
	 && tree --noreport \
	 && rm -rf $${TEMP:-/tmp}/$@

.PHONY: show-branches-as-tree

# BEGIN Include "plug-ins"
-include extras.d/*-plugin.mk
# END Include "plug-ins"
