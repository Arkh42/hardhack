
# 'Project _Avengers_' logbook


This part of the repository aims to collect daily work, tests and ideas.

This is not a summary nor a synthesis.

You're warned...


---


_Quick navigation:_


**[Entry 001: _Looking for a compiler_](#entry-001-compiler)**

**[Entry 002: _Looking for a programmer_](#entry-002-programmer)**


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

Next step: the programmer...



## Entry 002: _Looking for a programmer_ <a name="entry-002-programmer"></a>

I could get two samples of MCS-51 derivatives from Microchip:

1. [AT89S51-24PU](https://www.microchip.com/wwwproducts/en/AT89S51)
    - 24 is for the 24 MHz clock,
    - PU is for the 40-pin PDIP package,
2. [AT89C51ED2](https://www.microchip.com/wwwproducts/en/AT89C51ED2)

So, Daniel and I worked to find a solution to program those guys.


### Getting some inspiration

We found the following interesting resources among the many projects that are available on internet:

- [Make Your Own 8051 Minimal System](https://www.instructables.com/Make-Your-Own-8051-Minimal-System/)
- [Program 8051 (AT89 Series) With Arduino](https://www.instructables.com/Program-8051-With-Arduino/)
- [How to Program 8051 Using Arduino!](https://www.instructables.com/How-to-Program-8051-Using-Arduino/)
- [Programming Atmel AT89 Series Via Arduino](https://create.arduino.cc/projecthub/PatelDarshil/programming-atmel-at89-series-via-arduino-cf6201)

Of course, datasheets and application notes are essential:

- [AT89S51 - Complete Datasheet](https://ww1.microchip.com/downloads/en/DeviceDoc/doc2487.pdf)
- [AT89C51ED2 - Complete Datasheet](https://ww1.microchip.com/downloads/en/DeviceDoc/doc4235.pdf)


### One interesting solution: ISP programming with Arduino UNO

The next lines are only about the AT89S51 chip...

When looking at the product overview of the AT89S51, one line got our attention:

> On-chip flash allows program memory to be reprogrammed in-system [...]

It means that the chip can be reprogrammed without being removed from its board, even if soldered (or connected on a breadboard) to other components.
This means "easy game" (well, no, not really).

And here come's the fun!

Looking at the [Program 8051 (AT89 Series) With Arduino](https://www.instructables.com/Program-8051-With-Arduino/) is very instructive. The proposed solution is to use the Arduino UNO board to interface the AT89S51 microcontroller and enable the in-system programming (ISP) using the serial-parallel interface (SPI) bus.

Looking at the [datasheet](https://ww1.microchip.com/downloads/en/DeviceDoc/doc2487.pdf) (section 16, p. 15), this looks possible by:

1. powering the microcontroller,
2. setting RST to high,
3. sending the 'Programming Enable serial' instruction to pin MOSI/P1.5,
4. sending the code array (Byte or Page mode),
5. (optional) verifying the memory location by sending a 'Read' instruction that returns something at serial output MISO/P1.6,
6. setting RST to low to stop the programming session and start the normal device operation.

The definitions of the serial programming instructions can be found in section 20, p. 20.


### Debrief

So Daniel created the hardware based on the datasheet and I created the test programs... 

Well, it is an impressive success!

A few important remarks though.

* Compilation was done by using ASEM-51.
* An Arduino UNO board was turned into an ISP interface by uploading the ArduinoISP example without any modification 
(documentation [here](https://www.arduino.cc/en/Tutorial/BuiltInExamples/ArduinoISP), 
* GitHub repository [there](https://github.com/arduino/arduino-examples/tree/main/examples/11.ArduinoISP/ArduinoISP)).
* Then, [avrdude](http://www.nongnu.org/avrdude/) has been used to upload the code into the AT89S51 via the Arduino Uno.
* The configuration file provided in the '[Program 8051 (AT89 Series) With Arduino](https://www.instructables.com/Program-8051-With-Arduino/)' tutorial to allow AVRDUDE to recognize the microcontroller was necessary.

We tested the following programs:

- blink an LED connected to port P1.0,
- blink an LED connected to port P0.0 (not a good idea, this port is open-drain, so nothing happens if the terminal is in open-circuit),
- modify the 8 bits of the port simultaneously.

We tested the following conditions:

- external crystal of 12 MHz,
- external crystal of 16 MHz.


