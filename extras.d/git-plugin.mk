git-st:
	$(MAKE) for-each-working-tree exec='git status'

_help_Git:
	$(call fn.hlp.tgt, make git-st [match=<pattern>], check Git status of all working trees)

$(call fn.set.plugin.help.target,_help_Git)
