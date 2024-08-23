git-st:
	$(MAKE) for-each-working-tree exec='git status'

check-pre-commit:
	$(MAKE) for-each-working-tree exec='pre-commit run -a $(hook)'

_help_Git:
	$(call fn.hlp.tgt, make git-st [match=<pattern>], check Git status of all working trees)
	$(call fn.hlp.tgt, make check-pre-commit, run $(c.white)pre-commit$(c.normal) hooks check for all working trees)
	$(call fn.hlp.tgt, $(help.use2.indent)[match=<pattern>], that match an optional pattern)
	$(call fn.hlp.tgt, $(help.use2.indent)[hook=<name>])

$(call fn.set.plugin.help.target,_help_Git)
