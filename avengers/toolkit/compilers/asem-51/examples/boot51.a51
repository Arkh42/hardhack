;                *************************
;                *     B O O T - 5 1     *
;                *************************
;
; A Bootstrap Program for the MCS-51 Microcontroller Family
;
;   Version 1.1        by  W.W. Heinz        15. 12. 2002
;
;-----------------------------------------------------------------------
; File boot51.inc contains the customization data for the target system:

$INCLUDE(boot51.inc)     ; (must be generated with the CUSTOMIZ program)

        ;ASCII characters:
        BEL     EQU 7         ;beep
        BS      EQU 8         ;backspace
        CR      EQU 13        ;carriage return
        LF      EQU 10        ;line feed
        DEL     EQU 07FH      ;delete

        CPROMPT EQU '>'       ;command line prompt
        UPROMPT EQU ':'       ;upload prompt

        DSEG AT 8       ;only register bank 0 is in use

STACK:  DS 28H          ;stack starts right behind bank 0
CMDLIN: DS 47H          ;command line buffer
CMDMAX: DS 1            ;(last byte)

        CSEG AT STARTADDR

        ;on boards, where the EPROM doesn't start at address 0000H,
        ;first of all a long jump into the EPROM area may be required
        ;to remap memory:

        LJMP START

        ;on boards where the EPROM starts at address 0000H, the
        ;interrupt addresses should better be redirected to the
        ;area in extended RAM, where user programs start:

        REPT 20
        LJMP $-STARTADDR+USERPROGS
        DS 5
        ENDM

        ;Normally, 20 interrupt addresses should be enough.
        ;(The SIEMENS C517A has 17.)
        ;But you may insert some more, if required.
        ;(The Infineon C508 uses 20, but wastes 9 more!)

        ;this sign-on message is output after reset:
SIGNON: DB CR,LF,CR,LF
        DB 'BOOT-51  V1.1'
        DB '           '
        DB 'Copyright (c) 2002 by W.W. Heinz'
        DB CR,LF,0

START:  ;start of bootstrap program
        CALL INITBG             ;initialize baudrate generator
        MOV SCON,#072H          ;UART mode 1, 8 bit, ignore garbage
        CALL DELAY              ;let the UART have some clocks ...
        MOV DPTR,#SIGNON        ;display sign-on message
        CALL STRING
        CALL INTERP             ;call command line interpreter
        MOV SP,#7               ;better set to reset value
        PUSH DPL                ;save start address of user program
        PUSH DPH                ;on stack
WARTEN: CALL CONOST             ;wait until the UART is ready
        JZ WARTEN               ;for the next character to send,
        CALL DELAY              ;and the last bits have left the UART
        CALL STOPBG             ;stop baudrate generator
        MOV DPTR,#0             ;set modified SFR to reset values:
        CLR A                   ;(if possible)
        MOV SCON,A
        MOV B,A
        MOV PSW,A
        RET                     ;up'n away  (and SP --> 7)

INTERP: ;command line interpreter
        CALL RDCOMM             ;read command
        MOV R0,#CMDLIN          ;command line start address
INTER1: MOV A,@R0               ;end of command line reached ?
        JZ INTERP               ;then read a new command
        CALL UPCASE             ;convert character to upper case
        INC R0                  ;point to next character
        CJNE A,#' ',INTER2      ;is it a blank ?
        JMP INTER1              ;then ignore it
INTER2: MOV R7,A                ;save character
        CALL NEWLIN             ;new line
        MOV A,R7                ;command character
        CJNE A,#'U',INTER3      ;UPLOAD ?
        CALL NIXMER             ;check for end of line
        JNZ INTER4              ;if no: input error
        CALL LDHEXF             ;read Intel-HEX file
        JMP INTERP              ;read a new command
INTER3: CJNE A,#'G',INTER4      ;GOTO ?
        CALL EIN16              ;then read start address
        JZ INTER5               ;continue if o.k.
INTER4: MOV R7,#ILLEGAL_COMMAND ;output error message otherwise
        CALL ERROUT             ;ausgeben
        JMP INTERP              ;and wait for a new command
INTER5: MOV DPL,R5              ;load GOTO address into DPTR
        MOV DPH,R4              ;and return
        RET

NIXMER: ;checks, whether there are only trailing blanks in
        ;the command line buffer starting from position R0.
        ;When this is the case, zero is returned in A, the next
        ;non-blank character otherwise with its position in R0.
        MOV A,@R0       ;load next character
        JZ NIXME1       ;if 0, end of line
        CJNE A,#' ',NIXME1
        INC R0          ;if blank, next character
        JMP NIXMER
NIXME1: RET

RDCOMM: ;reads a command from the UART and stores it in the
        ;command line buffer at address CMDLIN in the internal
        ;RAM. The command line is terminated with a 0.
        CALL NEWLIN             ;new line
        MOV A,#CPROMPT          ;output prompt
        CALL CONOUT
        MOV R0,#CMDLIN          ;address of command line buffer
RDCOM1: MOV @R0,#0              ;always terminate buffer with a 0
        CALL CONIN              ;read character
        CJNE A,#CR,RDCOM2       ;if a CR has been input,
        RET                     ;the command is complete
RDCOM2: CJNE A,#BS,RDCOM5       ;backspace ?
RDCOM3: CJNE R0,#CMDLIN,RDCOM4  ;buffer empty ?
        JMP RDCOM1              ;then continue reading characters
RDCOM4: MOV DPTR,#BACKSP        ;otherwise delete last character
        CALL STRING
        DEC R0
        JMP RDCOM1
RDCOM5: CJNE A,#DEL,RDCOM6      ;delete ?
        JMP RDCOM3              ;then delete last character, too
RDCOM6: MOV R2,A                ;save character
        CLR C                   ;is it a control character ?
        SUBB A,#' '
        JC RDCOM1               ;then better ignore it
        MOV A,R2
        SUBB A,#DEL             ;is character >= 7F ?
        JNC RDCOM1              ;then ignore it too
        CJNE R0,#CMDMAX,RDCOM7  ;is buffer full ?
        MOV A,#BEL              ;then beep
        CALL CONOUT
        JMP RDCOM1              ;and wait for further characters
RDCOM7: MOV A,R2                ;echo character
        CALL CONOUT
        MOV A,R2                ;and append character to buffer
        MOV @R0,A
        INC R0                  ;now its one more character
        JMP RDCOM1              ;wait for input characters

BACKSP: DB BS,' ',BS,0          ;string to delete a character

LDHEXF: ;reads an Intel-Hex file from the UART and loads it
        ;to its start address in the external RAM.
        ;When something has gone wrong, LDHEXF continues
        ;reading characters until it has received nothing
        ;for about 5 seconds (depending on clock frequency),
        ;and sends a corresponding error message.
        MOV A,#UPROMPT   ;output upload prompt
        CALL CONOUT
        CALL UPLOAD      ;load Intel-Hex file into external RAM
        MOV R7,A         ;save error code
        JZ LDHEXM        ;if no error, continue
LDHEX1: MOV R0,#HIGH(TIMEBASE)  ;otherwise wait for some seconds,
        MOV R1,#LOW(TIMEBASE)   ;until no more characters are received
        MOV R2,#0
LDHEX2: CALL CONIST      ;character received ?
        JZ LDHEX3        ;if not, continue
        CALL CONIN       ;otherwise read character,
        JMP LDHEX1       ;and start from the beginning
LDHEX3: NOP
        DJNZ R2,LDHEX2
        DJNZ R1,LDHEX2
        DJNZ R0,LDHEX2
LDHEXM: MOV A,R7         ;error code
        JZ LDHEX4        ;if no error, continue
        CALL ERRONL      ;error message otherwise (code in R7)
LDHEX4: RET

ERRONL: ;outputs a new line and error message number R7.
        MOV DPTR,#ERRSTN
        SJMP ERROU1

ERROUT: ;outputs an error message with its number in R7.
        MOV DPTR,#ERRSTL
ERROU1: CALL STRING
        MOV DPTR,#ERRTAB ;address of table of error messages
        MOV A,R7         ;error code
        RL A             ;calculate address of error message
        MOVC A,@A+DPTR
        XCH A,R7
        RL A
        INC A
        MOVC A,@A+DPTR
        MOV DPL,A
        MOV DPH,R7
        CALL STRING      ;output message
        MOV DPTR,#ERRSTR
        CALL STRING
        RET

        ;error codes:
        ILLEGAL_COMMAND  EQU 0
        ILLEGAL_HEXDIGIT EQU 1
        CHECKSUM_ERROR   EQU 2
        UNEXPECTED_CHAR  EQU 3
        ILLEGAL_RECORDID EQU 4

ERRTAB: ;Table of error messages
        DW ILLCOM
        DW ILLHEX
        DW CKSERR
        DW UNXCHR
        DW ILLRID

        ;error messages:
ILLCOM: DB 'illegal command',0
ILLHEX: DB 'illegal hex digit',0
CKSERR: DB 'checksum error',0
UNXCHR: DB 'unexpected character',0
ILLRID: DB 'illegal record ID',0

ERRSTN: DB CR,LF
ERRSTL: DB '@@@@@ ',0
ERRSTR: DB ' @@@@@',0

UPLOAD: ;reads an Intel-Hex file from the UART and loads
        ;it to its start address in the external RAM.
        ;UPLOAD returns the following error codes in A:
        ;
        ; A = 0                     hex file loaded correctly
        ; A = ILLEGAL_HEXDIGIT      illegal hex digit
        ; A = CHECKSUM_ERROR        checksum error
        ; A = UNEXPECTED_CHAR       unexpected character
        ; A = ILLEGAL_RECORDID      illegal record ID
        ;
        ;UPLOAD only changes registers A,B,DPTR,R0,R1,R2, and R7.
        CALL CONIN         ;read characters
        CJNE A,#':',UPLOAD ;until a ":" is received
UPLOA0: MOV R1,#0          ;initialize checksum
        CALL NEXTB         ;convert next two characters to a byte
        JC UPLOA4          ;if they are no hex digits, error
        MOV R0,A           ;save number of data bytes
        CALL NEXTB         ;record address, HI byte
        JC UPLOA4          ;if no hex digits: error
        MOV DPH,A          ;save HI byte
        CALL NEXTB         ;record address, LO byte
        JC UPLOA4          ;if no hex digits: error
        MOV DPL,A          ;save LO byte
        CALL NEXTB         ;record ID
        JC UPLOA4          ;if no hex digits: error
        MOV R2,A           ;save record ID
        MOV A,R0           ;number of data bytes
        JZ UPLOA2          ;if 0, probably EOF record
UPLOA1: CALL NEXTB         ;next data byte
        JC UPLOA4          ;if no hex digits: error
        MOVX @DPTR,A       ;load it into external RAM
        INC DPTR           ;next byte
        DJNZ R0,UPLOA1     ;until all data bytes are loaded
UPLOA2: CALL NEXTB         ;checksum
        JC UPLOA4          ;if no hex digits: error
        MOV A,R1           ;checksum = 0 ?
        JNZ UPLOA5         ;if no, checksum error
        MOV A,R2           ;record ID
        JNZ UPLOA3         ;if <> 0, probably EOF record
        CALL CONIN         ;read character
        CJNE A,#CR,UPLOAU  ;if no CR, may be UNIX style ASCII file
        CALL CONIN         ;read next character
        CJNE A,#LF,UPLOA9  ;if no LF, may be ASCII upload with LF stripped
UPLOA8: CALL CONIN         ;read next character
UPLOA9: CJNE A,#':',UPLOA6 ;if no ":", unexpected character
        JMP UPLOA0         ;read next HEX record
UPLOAU: CJNE A,#LF,UPLOA6  ;if no LF, unexpected character
        JMP UPLOA8
UPLOA3: CJNE A,#1,UPLOA7   ;if <> 1, illegal record ID
        CALL CONIN         ;read only final CR (RDCOMM ignores LF)
        CLR A              ;hex file loaded, o.k.
        RET
UPLOA4: MOV A,#ILLEGAL_HEXDIGIT ;illegal hex digit
        RET
UPLOA5: MOV A,#CHECKSUM_ERROR   ;checksum error
        RET
UPLOA6: MOV A,#UNEXPECTED_CHAR  ;unexpected character
        RET
UPLOA7: MOV A,#ILLEGAL_RECORDID ;illegal record ID
        RET

NEXTB:  ;reads one byte in ASCII-hex representation from
        ;the UART and returns the binary value in A.
        ;The checksum in R1 is updated accordingly.
        ;(In case of error the carry flag is set.)
        ;NEXTB changes only registers A, B, R1 and R7.
        CALL CONIN      ;read first hex digit
        CALL NIBBLE     ;convert it to 4-bit binary
        JC NEXTBR       ;stop, if error
        SWAP A          ;otherwise move it to high order nibble
        MOV R7,A        ;and save it
        CALL CONIN      ;read second hex digit
        CALL NIBBLE     ;convert it to 4-bit binary
        JC NEXTBR       ;stop, if error
        ORL A,R7        ;join both nibbles
        XCH A,R1        ;add the whole byte
        ADD A,R1        ;to the checksum
        XCH A,R1
        CLR C           ;no error
NEXTBR: RET             ;finished, carry set if error

EIN16:  ;starting from the current line position R0, a 16-bit
        ;hex number is read from the command line buffer, and
        ;converted to a binary number which is returned in R4/R5.
        ;If no error was detected A=0 on return, A<>0 otherwise.
        MOV R6,#4       ;up to 4 digits
        CALL HEX16      ;convert to binary
        JNZ EIN16F      ;error, if garbage
        CALL NIXMER     ;check for end of line
EIN16F: RET             ;if garbage, error: A<>0

HEX16:  ;starting from the current line position R0, a 16-bit
        ;hex number with up to R6 digits is read from the line
        ;buffer and converted to a binary number which is
        ;returned in R4/R5.
        ;If no error was detected A=0 on return, A<>0 otherwise.
        MOV A,@R0       ;read character
        JZ HEX16F       ;error, if 0
        CJNE A,#' ',HEX161
        INC R0          ;skip leading blanks
        JMP HEX16
HEX161: MOV R4,#0       ;R4/R5 = 0
        MOV R5,#0
        CALL NIBBLE     ;convert hex digit
        JC HEX16F       ;error, when failed
        CALL SHIFT4     ;shift 4 bits into R4/R5 from the right side
        INC R0          ;next character
        DEC R6
HEX162: MOV A,@R0       ;read character
        CALL NIBBLE     ;convert to hex digit
        JC HEX16R       ;when failed, finished
        CALL SHIFT4     ;shift 4 bits into R4/R5 from the right side
        INC R0          ;next character
        DJNZ R6,HEX162  ;convert up to 4 hex digits
HEX16R: CLR A           ;o.k., number in R4/R5
        RET
HEX16F: MOV A,#0FFH     ;conversion error
        RET

NIBBLE: ;converts the hex digit in A into a 4-bit binary number
        ;which is returned in A. When the character is no hex
        ;digit, the carry flag is set on return.
        ;NIBBLE only changes registers A and B.
        CALL UPCASE     ;convert character to upper case
        MOV B,A         ;and save it
        CLR C           ;is character < 0 ?
        SUBB A,#'0'
        JC NIBBLR       ;then error
        MOV A,#'F'      ;is character > F ?
        SUBB A,B
        JC NIBBLR       ;then error, too
        MOV A,B         ;is character <= 9 ?
        SUBB A,#('9'+1)
        JC NIBBL1       ;then decimal digit
        MOV A,B         ;is character >= A ?
        SUBB A,#'A'
        JC NIBBLR       ;if not, error
NIBBL1: ADD A,#10       ;calculate binary number
        CLR C           ;digit converted correctly
NIBBLR: RET

SHIFT4: ;shifts a 4-bit binary number in A into register
        ;pair R4/R5 (HI/LO) from the right side.
        SWAP A          ;transfer nibble 4 bits to the left
        MOV R7,#6       ;Please do not ask for explaining THIS!
SHIFT0: RLC A           ;                                 ====
        XCH A,R5
        RLC A
        XCH A,R4
        DJNZ R7,SHIFT0
        RET

UPCASE: ;If the character in A is a lower case letter, it
        ;is converted to upper case and returned in A again.
        ;Otherwise it will be left unchanged.
        ;UPCASE only changes registers A and B.
        MOV B,A
        CLR C
        SUBB A,#'a'     ;is character < a ?
        JC UPCRET       ;then leave it unchanged
        MOV A,B
        SUBB A,#('z'+1) ;is character > z ?
        JNC UPCRET      ;then leave it unchanged, too
        ADDC A,#'Z'     ;otherwise convert it to upper case
        MOV B,A
UPCRET: MOV A,B
        RET

NEWLIN: ;outputs a new line.
        MOV A,#CR
        CALL CONOUT
        MOV A,#LF
        CALL CONOUT
        RET

STRING: ;String output: start address in DPTR, terminated with 0.
        ;STRING only changes registers DPTR and A.
        CLR A
        MOVC A,@A+DPTR
        JZ STRRET
        CALL CONOUT
        CALL WMSEC      ;Slow down output speed to about 9600 Baud!
        INC DPTR
        JMP STRING
STRRET: RET

CONOUT: ;output character in A.
        JNB TI,CONOUT   ;wait for UART output buffer to become clear
        CLR TI
        MOV SBUF,A      ;output character
        RET

CONIN:  ;read character and return it in A.
        JNB RI,CONIN
        MOV A,SBUF
        CLR RI
        ANL A,#07FH     ;mask parity (if any)
        RET

CONOST: ;output status: A=FF if ready, A=0 if not ready
        CLR A
        JNB TI,OSTRET   ;wait for UART output buffer to become clear
        DEC A
OSTRET: RET

CONIST: ;input status: A=FF if character received, A=0 if not
        CLR A
        JNB RI,ISTRET   ;no character received
        DEC A
ISTRET: RET

WMSEC:  ;about 1 ms delay
        PUSH AR6
        PUSH AR7
        MOV R6,#HIGH(TIMEBASE)
        MOV R7,#LOW(TIMEBASE)
WMSEC1: DJNZ R7,WMSEC1
        DJNZ R6,WMSEC1
        POP AR7
        POP AR6
        RET

DELAY:  ;wait for CHARTIME ms!
        ;CHARTIME is calculated to last for one byte sent by the UART.
        ;DELAY changes registers R6 and R7.
        MOV R6,#HIGH(CHARTIME)
        MOV R7,#LOW(CHARTIME)
DELAY1: CALL WMSEC              ;1 ms
        DJNZ R7,DELAY1
        DJNZ R6,DELAY1
        RET


        IFDEF INTEL8051
        ;baudrate generator timer 1

INITBG: ;start baudrate generator timer 1
        MOV  TCON,#0
        MOV  TMOD,#020H
        MOV  TH1,#RELOAD
        ANL  PCON,#07FH
        ORL  PCON,#SMOD
        SETB TR1
        RET

STOPBG: ;stop baudrate generator timer 1
        CLR  A
        MOV  TCON,A
        MOV  TMOD,A
        MOV  TH1,A
        MOV  TL1,A
        ANL  PCON,#07FH
        RET

        ENDIF


        IFDEF INTEL8052
        ;baudrate generator timer 2

        T2CON   DATA 0C8H
        RCAP2L  DATA 0CAH
        RCAP2H  DATA 0CBH
        TR2     BIT 0CAH

INITBG: ;start baudrate generator timer 2
        MOV  T2CON,#030H
        MOV  RCAP2H,#HIGH(RELOAD)
        MOV  RCAP2L,#LOW(RELOAD)
        SETB TR2
        RET

STOPBG: ;stop baudrate generator timer 2
        CLR  A
        MOV  T2CON,A
        MOV  RCAP2H,A
        MOV  RCAP2L,A
        RET

        ENDIF


        IFDEF SAB80535
        ;internal 80535 baudrate generator

        BD   BIT 0DFH

INITBG: ;start internal 80535 baudrate generator
        ANL  PCON,#07FH
        ORL  PCON,#SMOD
        SETB BD
        RET

STOPBG: ;stop internal 80535 baudrate generator
        CLR  BD
        ANL  PCON,#07FH
        RET

        ENDIF


        IFDEF SAB80C515A
        ;internal 80C535A baudrate generator

        SRELH   DATA 0BAH
        SRELL   DATA 0AAH
        BD      BIT  0DFH

INITBG: ;start internal 80C515A baudrate generator
        ANL  PCON,#07FH
        ORL  PCON,#SMOD
        MOV  SRELH,#HIGH(RELOAD)
        MOV  SRELL,#LOW(RELOAD)
        SETB BD
        RET

STOPBG: ;stop internal 80C515A baudrate generator
        CLR  BD
        MOV  SRELH,#3
        MOV  SRELL,#0D9H
        ANL  PCON,#07FH
        RET

        ENDIF


        IFDEF DS80C320
        ;Dallas 80C320 timer 1 with clock/12 or clock/4 prescaler

        CKCON   DATA 08EH

INITBG: ;start 80C320 baudrate generator timer 1
        MOV  CKCON,#PRESCALE
        MOV  TCON,#0
        MOV  TMOD,#020H
        MOV  TH1,#RELOAD
        ANL  PCON,#07FH
        ORL  PCON,#SMOD
        SETB TR1
        RET

STOPBG: ;stop 80C320 baudrate generator timer 1
        CLR  A
        MOV  TCON,A
        MOV  TMOD,A
        MOV  TH1,A
        MOV  TL1,A
        ANL  PCON,#07FH
        MOV  CKCON,#1
        RET

        ENDIF

        END
