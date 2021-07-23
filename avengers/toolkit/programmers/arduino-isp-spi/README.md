
# Arduino ISP over SPI


The use of an Arduino board to perform in-system programming (ISP) over SPI is mainly based on the following resources:

- [Program 8051 (AT89 Series) With Arduino](https://www.instructables.com/Program-8051-With-Arduino/),
- [Arduino as ISP and Arduino Bootloaders](https://www.arduino.cc/en/Tutorial/BuiltInExamples/ArduinoISP),
- [ArduinoISP built-in example](https://github.com/arduino/arduino-examples/tree/main/examples/11.ArduinoISP/ArduinoISP),
- [Arduino SPI library](https://www.arduino.cc/en/reference/SPI).

And, of course, the datasheet of the microcontroller.



## Basic understanding


The goal is to program an MCS-51 (derivative) microcontroller, named hereafter _the target_, by using __in-system programming (ISP)__.
This means that the target is turned in a special mode where we can upload the program (hexadecimal) that will be executed after reset.
To do so, _a programmer_ that can control and flash the target's memory is required.

For a proper implementation of the communication between the target and the programmer, two layers must be defined

1. the communication bus, e.g., the signals, directions, clocks;
2. the data exchange, e.g., program, acknowledgment, identity.


### Communication bus

The communication bus that is proposed in the [ArduinoISP built-in example](https://github.com/arduino/arduino-examples/tree/main/examples/11.ArduinoISP/ArduinoISP) is the __Serial Peripheral Interface (SPI)__.
This is a serial communication between one master and one or several slaves that needs a clock (SCLK), a communication wire from master to slaves (MOSI, for Master Output Slave Input), a communication wire from slaves to master (MISO, for Master Input Slave Output), and one slave select (SS) per slave so that the master can select which slave can communicate.
So, in our use case, 4 wires: SCLK, MOSI, MISO, and one SS (only one slave, the target).

The [Wikipedia page about SPI](https://en.wikipedia.org/wiki/Serial_Peripheral_Interface) 
is highly qualitative and can be used as a good start to understand this concept.


![SPI bus: wiring for single master, single slave][spi_1M1S_wiring]

![SPI bus: timing diagram][spi_1M1S_timing]


[spi_1M1S_wiring]: ./figures/SPI_single_slave.svg
[spi_1M1S_timing]: ./figures/SPI_timing_diagram2.svg


### Communication management

The communication "management" is one layer above SPI to enable several actions on the target, such as memory erase, programming, or identification.
The proposed method in [Program 8051 (AT89 Series) With Arduino](https://www.instructables.com/Program-8051-With-Arduino/) is the use of the __STK500__ communication protocol developed by Atmel to program their chips with AVR commands, i.e., assembly instructions.
The documentation is currently available in the [Microchip's Application Note 2525](https://www.microchip.com//wwwAppNotes/AppNotes.aspx?appnote=en592001).



## Requirements:

Here is the bill of material (BOM):

- a MCS-51 microcontroller derivative that supports ISP over SPI
    - 1 x [AT89S51-24PU](https://www.microchip.com/wwwproducts/en/AT89S51) (cf. [datasheet](https://ww1.microchip.com/downloads/en/DeviceDoc/doc2487.pdf)),
- an external time reference
    - 1 x 16 MHz crystal,
    - 2 x 33 pF capacitors,
- an external reset circuitry (cf. dedicated [guideline](http://ww1.microchip.com/downloads/en/Appnotes/doc4284.pdf) for calculation)
    - 1 x 1 µF capacitor,
    - 1 x 10 kOhm resistor,
- an Arduino board that is compatible with the ArduinoISP code
    - 1 x Arduino UNO,
- supply
    - provided by the Arduino board.



## Steps


There are _5 main steps_ to program the AT89S51 via SPI.
Each step is provided with full explanations to allow the reader to understand and to reproduce.
Feel free to skip any part if you already have a good knowledge of it.


### Step 1: Turn the Arduino into an ISP board <a name="step-1-arduino-isp"></a>

Turning the Arduino UNO board into an ISP device is really simple.
You need to upload the ['ArduinoISP' sketch](https://github.com/arduino/arduino-examples/blob/main/examples/11.ArduinoISP/ArduinoISP/ArduinoISP.ino) provided in the built-in examples.
The corresponding code is also saved in this repository for posterity. Check the [ArduinoISP](./ArduinoISP) folder.
All Arduino examples are released under the Creative Commons Zero v1.0 Universal (CC0-1.0) [license](./ArduinoISP/LICENSE.md).

To program the Arduino UNO, you can use one of the following solution:

- Arduino IDE
- Virtual Studio Code + Platform IO


Let's have a closer look at the code loaded in the Arduino board or skip to [Next step](#step-2-hardware).
To help the reader, the corresponding lines of code are written between square brackets.


#### 1.0 Arduino libraries [ln 39]

As usual with Arduino, it is necessary to include the corresponding library:
```cpp
#include "Arduino.h"
```

#### 1.1 The clock frequency for SPI communication [ln 53]

The first thing to do is to configure the SPI clock frequency:

```cpp
#define SPI_CLOCK (1000000/6)
```

Looking at the AT89S51's datasheet, one can see that

> The maximum serial clock (SCK) frequency should be less than 1/16 of the crystal frequency.
> With a 33 MHz oscillator clock, the maximum SCK frequency is 2 MHz.

As our crystal is 12 MHz, the SPI clock frequency should be less than 750 kHz.
So the default value matches our specifications.


#### 1.2 Choose between hardware of software communication [ln 60-66]  <a name="step-1-2-hard-soft-SPI"></a>

There are two possibilities when using communication protocols:

1. use the dedicated hardware (in this case, hardware specific to SPI communication),
2. emulate with software the protocol on generic hardware.

The latter is sometimes called _bit-banged_.

As this can depend on the Arduino board specifications, the code's authors have written conditions to enable the hardware SPI communication:

```cpp
#if defined(ARDUINO_ARCH_AVR)
  #if SPI_CLOCK > (F_CPU / 128)
    #define USE_HARDWARE_SPI
  #endif
#endif
```


#### 1.3 The pin mapping for SPI communication and user information [ln 71-118 + 161-222]

Then, we must describe the pin mapping, i.e., which ports of the Arduino board will be used to interact with the AT89S51 microcontroller:

```cpp
// The standard pin configuration. HOODLOADER2 means running sketches on the atmega16u2 
// serial converter chips on Uno or Mega boards.
#ifndef ARDUINO_HOODLOADER2
  #define RESET     	10
  #define LED_HB    	9
  #define LED_ERR   	8
  #define LED_PMODE 	7

  // uncoment to use the old Uno style wiring [...] on Leonardo, Due...
  // #define USE_OLD_STYLE_WIRING

  #ifdef USE_OLD_STYLE_WIRING
    #define PIN_MOSI	11
    #define PIN_MISO	12
    #define PIN_SCK	13
  #endif
#else 
  #define RESET     	4
  #define LED_HB    	7
  #define LED_ERR   	6
  #define LED_PMODE 	5
#endif
```

They also ensure the use of hardware SPI if defined, of bit-banged SPI if not:

```cpp
// By default, use hardware SPI pins:
#ifndef PIN_MOSI
  #define PIN_MOSI 	MOSI
#endif
#ifndef PIN_MISO
  #define PIN_MISO 	MISO
#endif
#ifndef PIN_SCK
  #define PIN_SCK 	SCK
#endif

// Force bitbanged SPI if not using the hardware SPI pins:
#if (PIN_MISO != MISO) ||  (PIN_MOSI != MOSI) || (PIN_SCK != SCK)
  #undef USE_HARDWARE_SPI
#endif
```

Using the hardware SPI is definitely easier because you can simply include the Arduino SPI library, `SPI.h`.
Otherwise, a deficated class has been designed the code's authors to manage the bit-banged SPI, `BitBangedSPI`.
An interface to configure the SPI has been introduced in ArduinoCore-API 1.0.1: `SPISettings`. So, for older version, the authors have recreated this interface.

```cpp
#ifdef USE_HARDWARE_SPI
  #include "SPI.h"
#else
  #define SPI_MODE0 0x00
  #if !defined(ARDUINO_API_VERSION) || ARDUINO_API_VERSION != 10001 // A SPISettings class is declared by ArduinoCore-API 1.0.1
    class SPISettings {
      // some code
    };
  #endif
  class BitBangedSPI {
    public:
      // some code
  };
  static BitBangedSPI SPI;
#endif
```


#### 1.4 Serial communication between the Arduino board and the computer [ln 40 + 133-142 + 225]

The SPI communication is between the Arduino board and the AT89S51 microcontroller.
However, we need to send the hexadecimal file that programs the AT89S51 from the computer to the Arduino.
To do so, we will use the serial port.

The code's authors explain that is it recommended to use a USB virtual port to avoid autoreset and to enable USB handshaking.
To selection of the correct serial port regarding the Arduino board in use is encapsulated under the same name, `SERIAL`.
But, to be able to do that, as the symbol `SERIAL` is already defined in `Arduino.h`, it must be undefined first.

```cpp
#undef SERIAL

// [...] some code

#ifdef SERIAL_PORT_USBVIRTUAL
    #define SERIAL SERIAL_PORT_USBVIRTUAL
#else
    #define SERIAL Serial
#endif

#define BAUDRATE	19200
```

The default baudrate is 19200 baud.

Then of course, the serial communication is started in the `setup()`function:

```cpp
SERIAL.begin(BAUDRATE);
```


#### 1.5 Communication management with STK500 [ln 152-157]

The programmer will send STK sequences over SPI to program the target.
The target will answer, so the programmer needs to react according to theses answers.
Hence the definition of the STK sequences that can be received by the programmer:

```cpp
#define STK_OK      	0x10
#define STK_FAILED  	0x11
#define STK_UNKNOWN 	0x12
#define STK_INSYNC  	0x14
#define STK_NOSYNC  	0x15
#define CRC_EOP     	0x20
```

These definitions can be found in the source code of the [Microchip's Application Note 2525](https://www.microchip.com//wwwAppNotes/AppNotes.aspx?appnote=en592001), in the `command.h` file, lines 16 to 32.
(Yeah, that was awfully hard to find...)


#### 1.6 Visual information for user [ln 159 + 227-232 + 263-280 + 319-327]

The code's authors have also decided to provide some visual information to the user by using an LED.
The pin mapping is already shown in [step 1.2](#step-1-2-hard-soft-SPI).

Then, several functions that are supposed to work on pins connected to LEDs are created:

- `pulse(int pin, int times)`, only used in Arduino's `setup()`function to inform the user that the programmer board is starting up;
- `heartbeat()`, only used in Arduino's `loop()`function to inform the user that the programmer's software is running.

The `pulse()` function's prototype is written before `setup()`, whereas the description is written after `loop()`.
It makes `times` blink on the passed `pin` at a period of 2*`PTIME`, i.e., 30 ms:

```cpp
#define PTIME 30
void pulse(int pin, int times) {
  do {
    digitalWrite(pin, HIGH);
    delay(PTIME);
    digitalWrite(pin, LOW);
    delay(PTIME);
  } while (times--);
}
```

The `heartbeat()` function checks the last time it has been executed and creates a PWM signal according to it:

```cpp
uint8_t hbval = 128;
int8_t hbdelta = 8;
void heartbeat() {
  static unsigned long last_time = 0;
  unsigned long now = millis();
  // some code
  analogWrite(LED_HB, hbval);
}
```


### Step 2: Implement the hardware  <a name="step-2-hardware"></a>

...



### Step 3: Develop a demo code in assembly  <a name="step-3-assembly"></a>

...



### Step 4: Compile the assembly into a hexadecimal file  <a name="step-4-compilation"></a>

...



### Step 5: Upload the HEX file to the AT89S51 via the Arduino programmer  <a name="step-5-upload"></a>

...


#### 5.1 Veryfing the communication (conf file)

To read the device signature in serial mode, we have to read the following adresses and values:

> (000H) = 1EH indicates manufactured by Atmel
> (100H) = 51H indicates AT89S51
> (200H) = 06H

Chip erase:

> In the serial programming mode, a chip erase operation is initiated by issuing the Chip Erase instruction.
> In this mode, chip erase is self-timed and takes about 500 ms.
> During chip erase, a serial read from any address location will return 00H at the data output.


