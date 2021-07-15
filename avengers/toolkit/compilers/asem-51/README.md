
# ASEM-51

The tool is described as

> ASEM-51 is a two-pass macro assembler for the Intel MCS-51 family of microcontrollers.
> It is running on the PC under MS-DOS, Windows and Linux.
> The ASEM-51 assembly language is based on the standard Intel syntax, and implements conditional assembly, macros, and include file processing.
> The assembler can output object code in Intel-HEX or Intel OMF-51 format as well as a detailed list file.
> The ASEM-51 package includes support for more than two hundred 8051 derivatives, a bootstrap program for MCS-51 target boards, and documentation in ASCII and HTML format.
> And it is free ... 


It comes together with a bootstrap program, BOOT-51, that is a

> suitable firmware that can receive a program from the host computer, store it in the external RAM, and finally execute it.

The bootstrap program can be created

> by burning a customized version of BOOT-51 into the EPROM of the target board. After system reset, it can receive an Intel-HEX file over the serial interface, store it in the external RAM, and finally jump to the program start address.
> BOOT-51 itself doesn't need any external RAM, and requires only 1 kB of EPROM.


It is available at the following address: http://plit.de/asem-51/.

As the author granted me the [permission](./PERMISSION.md) to share the tool here on GitHub, you can find:

- the [license](./LICENSE.md),
- the [release (v1.3)](./releases/v1.3/)
    - for DOS/Windows (ZIP archive)
    - for Linux (TAR.GZ archive, rpm package, and deb package)
- the [documentation](./doc)
