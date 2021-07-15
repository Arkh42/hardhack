;                  Test Program for BOOT-51
;                  ========================
;                  W.W. Heinz,  25. 6. 2002
;
; This program simply toggles the logic level of the port pin LEDPIN
; every second (12 MHz) to verify, whether all components of the chain
; assembly -> serial interface -> target system <-> bootstrap program
; are working together correctly.
; It can be adapted to your requirements with little efforts:
;
; 1. If your target system carries a LED that can be switched with a
;    bit-addressable port pin, please change the BIT symbol LEDPIN
;    accordingly. Then the program will make the LED blink.
;
;    If your LED can only be switched with a non-bit-addressable
;    port pin (say bit 2 of a port P6), simply replace the statement
;    "CPL LEDPIN" by "XRL P6,#00000100B" or something like that.
;
; 2. Change the program start address START to the location, where
;    user programs are usually loaded on your target system.
;    The program code itself is position-independent!
;
; If there is no LED on your target system, connect the port pin LEDPIN
; to a volt-meter. This may also do. Aside of P0 and P2 you may use every
; port with LEDs or spare outputs.

        LEDPIN BIT P3.5  ;your favorite port pin (LED preferred)

        START CODE 8000H ;start address of user programs

        TIME EQU 8       ;time constant in units of 250 ms (for 12 MHz)

        ORG START        ;program start address

BLINK:  CPL LEDPIN       ;toggle pin  (Great, if connected to a LED!)
        MOV R3,#TIME     ;wait for  TIME * 125 ms  (12 MHz)
        MOV R2,#0
        MOV R1,#0
LOOP:   DJNZ R1,LOOP
        DJNZ R2,LOOP
        DJNZ R3,LOOP
        SJMP BLINK       ;This is repeated forever,
                         ;if you don't press reset ...
        END
