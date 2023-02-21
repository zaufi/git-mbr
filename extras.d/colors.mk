#
# Define console colors
#

# Move cursor
fn.move_to = \\033[$(1)G
# Set text color
fn.set_color = \\033[$(1)m

_c.normal    := 0
_c.bold      := 1
_c.dim       := 2
_c.nodim     := 22
_c.italic    := 3
_c.under     := 4
_c.nounder   := 24
_c.blink     := 5
_c.noblink   := 25
_c.reverse   := 7
_c.noreverse := 27
_c.hide      := 8
_c.nohide    := 28
_c.strike    := 9
_c.dblunder  := 21
_c.default   := 39

c.reset      := $(call fn.set_color,$(_c.normal);$(_c.default))
c.normal     := $(call fn.set_color,$(_c.normal))
c.dim        := $(call fn.set_color,$(_c.dim))
c.bold       := $(call fn.set_color,$(_c.bold))
c.italic     := $(call fn.set_color,$(_c.italic))
c.blink      := $(call fn.set_color,$(_c.blink))
c.reverse    := $(call fn.set_color,$(_c.reverse))
c.hide       := $(call fn.set_color,$(_c.hide))
c.strike     := $(call fn.set_color,$(_c.strike))
c.dblunder   := $(call fn.set_color,$(_c.dblunder))

c.black      := $(call fn.set_color,30)
c.l.black    := $(call fn.set_color,$(_c.bold);30)
c.i.black    := $(call fn.set_color,90)
c.bg.black   := $(call fn.set_color,40)

c.red        := $(call fn.set_color,31)
c.l.red      := $(call fn.set_color,$(_c.bold);31)
c.i.red      := $(call fn.set_color,91)
c.bg.red     := $(call fn.set_color,41)

c.green      := $(call fn.set_color,32)
c.l.green    := $(call fn.set_color,$(_c.bold);32)
c.i.green    := $(call fn.set_color,92)
c.bg.green   := $(call fn.set_color,42)

c.brown      := $(call fn.set_color,33)
c.l.brown    := $(call fn.set_color,$(_c.bold);33)
c.i.brown    := $(call fn.set_color,93)
c.bg.brown   := $(call fn.set_color,43)

c.blue       := $(call fn.set_color,34)
c.l.blue     := $(call fn.set_color,$(_c.bold);34)
c.i.blue     := $(call fn.set_color,94)
c.bg.blue    := $(call fn.set_color,44)

c.magenta    := $(call fn.set_color,35)
c.l.magenta  := $(call fn.set_color,$(_c.bold);35)
c.i.magenta  := $(call fn.set_color,95)
c.bg.magenta := $(call fn.set_color,45)

c.cyan       := $(call fn.set_color,36)
c.l.cyan     := $(call fn.set_color,$(_c.bold);36)
c.i.cyan     := $(call fn.set_color,96)
c.bg.cyan    := $(call fn.set_color,46)

c.white      := $(call fn.set_color,37)
c.l.white    := $(call fn.set_color,$(_c.bold);37)
c.i.white    := $(call fn.set_color,97)
c.bg.white   := $(call fn.set_color,47)

c.gray       := $(c.l.black)
c.purple     := $(c.l.magenta)
c.yellow     := $(c.l.brown)

help.use.indent  := $(call fn.move_to,4)
help.use2.indent := $(call fn.move_to,9)
help.text.indent := $(call fn.move_to,50)
help.opt.indent  := $(call fn.move_to,2)
