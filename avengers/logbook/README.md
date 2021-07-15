
# 'Project _Avengers_' logbook


This part of the repository aims to collect daily work, tests and ideas.

This is not a summary nor a synthesis.

You're warned...


---


_Quick navigation:_


**[Entry 001: _Looking for a compiler_](#entry-001-compiler)**


---


## Entry 001: _Looking for a compiler_ <a name="entry-001-compiler"></a>

For teaching and amusement, I need to use the assembler instructions to program the MCS-51 microcontroller from Intel, and its current derivatives.
Of course, the first step consists in finding a compiler that accepts the assembly and generates a hexadecimal file to load into the microcontroller to program it.

After a quite long Googling session, I finally found the holy grail: a FREE compiler, namely [ASEM-51](http://plit.de/asem-51/).
This work by W. W. Heinz is absolutely wonderful.
I would shed tears of joy if I had a soul.

The tool is cross-platform and very easy to use.
It is provided with manuals and a long demo file that recaps all MCS-51 assembly instructions, as well as macros to control the compiler.
You can't make any mistake.

I tested the tool on a Linux CentOS 7 distribution. Worked perfectly!

Next step: the hardware...


