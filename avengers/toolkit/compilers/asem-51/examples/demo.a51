;                      Demo Program for ASEM-51 V1.3
;                      =============================
;
;                         W.W. Heinz, 25. 6. 2002


; 1. Primary Controls:
; --------------------

$DATE(June 2002)      ;set date string

$DEBUG                ;generate debug information (OMF-51 output only)

$PAGELENGTH (60)      ;set list file page length to 60 lines

$PAGEWIDTH (110)      ;set list file line width to 110 columns

$NOTABS               ;expand all tab characters to blanks

; $NOPAGING           ;no page formatting in list file

$NOSYMBOLS            ;don't generate a symbol table

$XREF                 ;generate a cross reference listing

; $PHILIPS            ;switch to the reduced Philips 83C75x instruction set

; $NOMACRO            ;suppress macro expansion

$NOBUILTIN            ;do not list predefined symbols (SFR)

$NOMOD51              ;disable predefined standard 8051 SFR symbols


; 2. General Controls:
; --------------------

$TITLE(The original ASEM-51 Demo Program!)      ;set page header title

$NOLIST               ;listing off

$INCLUDE (8052.mcu)   ;include 8052 SFR symbol definitions

$LIST                 ;listing on

$EJECT                ;start new page in list file

$NOGEN                ;list macro calls only
$GENONLY              ;list macro expansion lines only
$GEN                  ;list macro calls and expansion lines

$NOCOND               ;don't list lines in false IFxx branches
$CONDONLY             ;list assembled lines in IFxx constructions only
$COND                 ;list full IFxx .. ENDIF constructions

$SAVE                 ;save current $LIST/$GEN/$COND state
$RESTORE              ;restore old $LIST/$GEN/$COND state


; 3. Symbol Definitions:
; ----------------------

        NAME       ASEM_51_DEMO         ;module name

        TARZAN     EQU  -1              ;constant number
        INDEXREG   EQU   R1             ;invariant register

        JANE       SET   10             ;number
        JANE       SET   65535          ;(may be redefined)
        COUNTREG   SET   R5             ;register
        COUNTREG   SET   A              ;(may be redefined)

        CHEETA     DATA  30H            ;DATA address

        JONES      IDATA 90H            ;IDATA address

        MICKEY     XDATA 5000H          ;XDATA address

        GOOFY      BIT   080H.3         ;BIT address

        DONALD     CODE  0f000h         ;CODE address

?ABCDEFGHIJKLMNopqrstuvwxyz_0123456789: ;label (31 significant characters)


; 4. Constants and other Operands
; -------------------------------

        KONST1  EQU   1774      ;decimal
        KONST1d EQU   1774d     ;decimal again
        KONST2  EQU   1774H     ;hex
        KONST3  EQU   1774Q     ;octal
        KONST3o EQU   1774o     ;octal again
        KONST4  EQU   10101010B ;binary
        KONST5  EQU   '@~'      ;ASCII (1 or 2 characters)

        KONST12 EQU   KONST1    ;symbol
        KONST20 EQU   AR0       ;register 0
        KONST21 EQU   AR1       ;   .
        KONST22 EQU   AR2       ;   .
        KONST23 EQU   AR3       ;   .
        KONST24 EQU   AR4       ;   .
        KONST25 EQU   AR5       ;   .
        KONST26 EQU   AR6       ;   .
        KONST27 EQU   AR7       ;register 7
        KONST29 EQU   $         ;location counter


; 5. Operators and Expressions
; ----------------------------

; Operator Precedance:
;
;       ( )                                                   ^   highest
;       + - NOT HIGH LOW                       (unary)        |
;       .                                                     |
;       * / MOD                                               |
;       SHL SHR                                               |
;       + -                                    (binary)       |
;       EQ = NE <> LT < LE <= GT > GE >=                      |
;       AND                                                   |
;       OR XOR                                                v   lowest


        POSITIV EQU      +5193          ;unary plus
        NEGATIV EQU      -5193          ;unary minus
        KOMPLEM EQU  NOT  05555H        ;logical complement
        HIBYTE  EQU  HIGH 01234H        ;high byte
        LOBYTE  EQU  LOW  01234H        ;low byte

        BITNO5  EQU  0B8H.5             ;bit operator

        PRODUC  EQU  83 * 67            ;multiplication
        QUOTIE  EQU  84 / 4             ;division
        MODULO  EQU  83 MOD 8           ;remainder

        SHIFTL  EQU  1234H SHL  4       ;shift left
        SHIFTR  EQU  1234H SHR  4       ;shift right

        SUMME   EQU  83 + 67            ;addition       (binary plus)
        DIFFER  EQU  83 - 67            ;subtraction    (binary minus)

        EQUAL1  EQU   827  EQ  827      ;equal to
        EQUAL2  EQU   827  =  -827      ;equal to

        NOTEQ1  EQU   235  NE  235      ;not equal to
        NOTEQ2  EQU   235  <> -235      ;not equal to

        LESS1   EQU   367  LT  597      ;less than
        LESS2   EQU  -367  <   597      ;less than

        LESSEQ1 EQU   367  LE  597      ;less or equal
        LESSEQ2 EQU  -367  <=  597      ;less or equal

        GREAT1  EQU   367  GT  597      ;greater than
        GREAT2  EQU  -367  >   597      ;greater than

        GREQ1   EQU   367  GE  597      ;greater or equal
        GREQ2   EQU  -367  >=  597      ;greater or equal

        LOGAND  EQU  0AAAAH AND 05555H  ;logical and
        LOGOR   EQU  0AAAAH  OR 05555H  ;logical or
        LOGXOR  EQU  055AAH XOR 05555H  ;exclusive or

        KONST30 EQU  5*(JANE-$+AR5 OR 2) AND 0FFH    ;expression (=30)


; 6. Pseudo Commands:
; -------------------

        ORG  07ff0H    ;set location counter of current segment

        DB   1,7       ;define byte
        DW   2,12,9    ;define word
        DS   3         ;define space

        DSEG           ;switch to DATA segment

        DS   32        ;define space for registers and stack
RAM:    DS   1         ;define space for a variable
RAM1:   DS   1
RAM2:   DS   1

        ISEG AT 080H   ;switch to IDATA segment and set location counter

        DS   10H       ;define space

        XSEG           ;switch to XDATA segment
        ORG  0C000H    ;and set location counter

        DS   5         ;define space

        BSEG AT 040h   ;switch to BIT segment and set location counter
        ORG  050H      ;change location counter

BITAD:  DBIT 4         ;define bits

        CSEG           ;return to CODE segment

STRING: DB 'this is text',0
MIXED:  DB 'a',062H,'cdefghij',06bh,'l',060h+13,'n',MIXED-STRING

        USING 1        ;set register bank


; 7. Instruction Set:
; -------------------

        ;Jumps and Calls:
        ;----------------

PROCED: NOP     ;subroutine
        RET

INTSER: NOP     ;interrupt service routine
        RETI

THERE:  ACALL PROCED
        LCALL PROCED
        CALL  PROCED

        AJMP  THERE
        LJMP  THERE
        SJMP  THERE
        JMP   @A+DPTR
        JMP   THERE

        JZ    THERE
        JNZ   THERE

        JC    THERE
        JNC   THERE

        CJNE A,RAM,THERE
        CJNE A,#KONST4,THERE

        CJNE R0,#KONST4,THERE
        CJNE R1,#KONST4,THERE
        CJNE R2,#KONST4,THERE
        CJNE R3,#KONST4,THERE
        CJNE R4,#KONST4,THERE
        CJNE R5,#KONST4,THERE
        CJNE R6,#KONST4,THERE
        CJNE R7,#KONST4,THERE

        CJNE @R0,#KONST4,THERE
        CJNE @R1,#KONST4,THERE

        DJNZ R0,THERE
        DJNZ R1,THERE
        DJNZ R2,THERE
        DJNZ R3,THERE
        DJNZ R4,THERE
        DJNZ R5,THERE
        DJNZ R6,THERE
        DJNZ R7,THERE

        DJNZ RAM,THERE

        JB BITAD,THERE
        JNB BITAD,THERE
        JBC BITAD,THERE

        ;Arithmetic Instructions:
        ;------------------------

        ADD A,R0
        ADD A,R1
        ADD A,R2
        ADD A,R3
        ADD A,R4
        ADD A,R5
        ADD A,R6
        ADD A,R7

        ADD A,RAM

        ADD A,@R0
        ADD A,@R1

        ADD A,#KONST4

        ADDC A,R0
        ADDC A,R1
        ADDC A,R2
        ADDC A,R3
        ADDC A,R4
        ADDC A,R5
        ADDC A,R6
        ADDC A,R7

        ADDC A,RAM

        ADDC A,@R0
        ADDC A,@R1

        ADDC A,#KONST4

        SUBB A,R0
        SUBB A,R1
        SUBB A,R2
        SUBB A,R3
        SUBB A,R4
        SUBB A,R5
        SUBB A,R6
        SUBB A,R7

        SUBB A,RAM

        SUBB A,@R0
        SUBB A,@R1

        SUBB A,#KONST4

        INC A

        INC R0
        INC R1
        INC R2
        INC R3
        INC R4
        INC R5
        INC R6
        INC R7

        INC RAM

        INC @R0
        INC @R1

        DEC A

        DEC R0
        DEC R1
        DEC R2
        DEC R3
        DEC R4
        DEC R5
        DEC R6
        DEC R7

        DEC RAM

        DEC @R0
        DEC @R1

        INC DPTR
        MUL AB
        DIV AB
        DA A

        ;Logical Instructions:
        ;---------------------

        ANL A,R0
        ANL A,R1
        ANL A,R2
        ANL A,R3
        ANL A,R4
        ANL A,R5
        ANL A,R6
        ANL A,R7

        ANL A,RAM

        ANL A,@R0
        ANL A,@R1

        ANL A,#KONST4

        ANL RAM,A

        ANL RAM,#KONST4

        ORL A,R0
        ORL A,R1
        ORL A,R2
        ORL A,R3
        ORL A,R4
        ORL A,R5
        ORL A,R6
        ORL A,R7

        ORL A,RAM

        ORL A,@R0
        ORL A,@R1

        ORL A,#KONST4

        ORL RAM,A

        ORL RAM,#KONST4

        XRL A,R0
        XRL A,R1
        XRL A,R2
        XRL A,R3
        XRL A,R4
        XRL A,R5
        XRL A,R6
        XRL A,R7

        XRL A,RAM

        XRL A,@R0
        XRL A,@R1

        XRL A,#KONST4

        XRL RAM,A

        XRL RAM,#KONST4

        CLR A
        CPL A
        RL A
        RLC A
        RR A
        RRC A
        SWAP A

        ;Move Instructions:
        ;------------------

        MOV A,R0
        MOV A,R1
        MOV A,R2
        MOV A,R3
        MOV A,R4
        MOV A,R5
        MOV A,R6
        MOV A,R7

        MOV A,RAM

        MOV A,@R0
        MOV A,@R1

        MOV A,#KONST4

        MOV R0,A
        MOV R1,A
        MOV R2,A
        MOV R3,A
        MOV R4,A
        MOV R5,A
        MOV R6,A
        MOV R7,A

        MOV R0,RAM
        MOV R1,RAM
        MOV R2,RAM
        MOV R3,RAM
        MOV R4,RAM
        MOV R5,RAM
        MOV R6,RAM
        MOV R7,RAM

        MOV R0,#KONST4
        MOV R1,#KONST4
        MOV R2,#KONST4
        MOV R3,#KONST4
        MOV R4,#KONST4
        MOV R5,#KONST4
        MOV R6,#KONST4
        MOV R7,#KONST4

        MOV RAM,A

        MOV RAM,R0
        MOV RAM,R1
        MOV RAM,R2
        MOV RAM,R3
        MOV RAM,R4
        MOV RAM,R5
        MOV RAM,R6
        MOV RAM,R7

        MOV RAM2,RAM1

        MOV RAM,@R0
        MOV RAM,@R1

        MOV RAM,#KONST4

        MOV @R0,A
        MOV @R1,A

        MOV @R0,RAM
        MOV @R1,RAM

        MOV @R0,#KONST4
        MOV @R1,#KONST4

        MOV DPTR,#KONST5

        MOVC A,@A+DPTR
        MOVC A,@A+PC

        MOVX A,@R0
        MOVX A,@R1
        MOVX A,@DPTR

        MOVX @R0,A
        MOVX @R1,A
        MOVX @DPTR,A

        PUSH RAM
        POP RAM

        XCH A,R0
        XCH A,R1
        XCH A,R2
        XCH A,R3
        XCH A,R4
        XCH A,R5
        XCH A,R6
        XCH A,R7

        XCH A,RAM

        XCH A,@R0
        XCH A,@R1

        XCHD A,@R0
        XCHD A,@R1

        ;Bit Instructions:
        ;-----------------

        CLR C
        CLR BITAD

        SETB C
        SETB BITAD

        CPL C
        CPL BITAD

        ANL C,BITAD
        ANL C,/BITAD

        ORL C,BITAD
        ORL C,/BITAD

        MOV C,BITAD
        MOV BITAD,C


; 8. Register Symbols:
; --------------------

        MOV @R1,A
        MOV @R1,COUNTREG            ;same as:  MOV @R1,A
        MOV @INDEXREG,A             ;same as:  MOV @R1,A
        MOV @INDEXREG,COUNTREG      ;same as:  MOV @R1,A


; 9. Predefined Symbols:
; ----------------------

        ; Special Function Registers:
        ; ---------------------------

        MOV A,B
        MOV R1,ACC
        MOV A,PSW
        MOV A,IP
        MOV A,P3
        MOV A,IE
        MOV A,P2
        MOV A,SBUF
        MOV A,SCON
        MOV A,P1
        MOV A,TH1
        MOV A,TH0
        MOV A,TL1
        MOV A,TL0
        MOV A,TMOD
        MOV A,TCON
        MOV A,PCON
        MOV A,DPH
        MOV A,DPL
        MOV A,SP
        MOV A,P0

        ;SFR Bit Addresses:
        ;------------------

        MOV C,CY        ;PSW
        MOV C,AC
        MOV C,F0
        MOV C,RS1
        MOV C,RS0
        MOV C,OV
        MOV C,P

        MOV C,PS        ;IP
        MOV C,PT1
        MOV C,PX1
        MOV C,PT0
        MOV C,PX0

        MOV C,RD        ;P3
        MOV C,WR
        MOV C,T1
        MOV C,T0
        MOV C,INT1
        MOV C,INT0
        MOV C,TXD
        MOV C,RXD

        MOV C,EA        ;IE
        MOV C,ES
        MOV C,ET1
        MOV C,EX1
        MOV C,ET0
        MOV C,EX0

        MOV C,SM0       ;SCON
        MOV C,SM1
        MOV C,SM2
        MOV C,REN
        MOV C,TB8
        MOV C,RB8
        MOV C,TI
        MOV C,RI

        MOV C,TF1       ;TCON
        MOV C,TR1
        MOV C,TF0
        MOV C,TR0
        MOV C,IE1
        MOV C,IT1
        MOV C,IE0
        MOV C,IT0

        MOV C,P1.0      ;P1
        MOV C,P1.1
        MOV C,P1.2
        MOV C,P1.3
        MOV C,P1.4
        MOV C,P1.5
        MOV C,P1.6
        MOV C,P1.7

        MOV C,P3.0      ;P3
        MOV C,P3.1
        MOV C,P3.2
        MOV C,P3.3
        MOV C,P3.4
        MOV C,P3.5
        MOV C,P3.6
        MOV C,P3.7

        ; ROM Addresses:
        ; --------------

        MOV DPTR,#RESET
        MOV DPTR,#EXTI0
        MOV DPTR,#TIMER0
        MOV DPTR,#EXTI1
        MOV DPTR,#TIMER1
        MOV DPTR,#SINT


; 10. Conditional Assembly:
; -------------------------
; The most important meta instructions for conditional assembly are
; introduced in this section. The general controls $WARNING and $ERROR,
; and the predefined symbols ??ASEM_51 and ??VERSION are also shown here,
; because the make sense in conjunction with conditional assembly only.

; a.) The IF, IFN, ELSE, and ENDIF meta instructions:

        IF NOTEQ1
          DB 'string 1',0
        ELSE
          IFN EQUAL2
            DB 'string 2',0
          ELSE
            DB 'string 3',0
          ENDIF
        ENDIF

; b.) The IFDEF and IFNDEF meta instructions:

        IFDEF GHOST
          DB 'haunting',0
        ELSE
          DB 'nothing',0
          IFNDEF VAMPIRE
            DB 'boring',0
          ELSE
            DB 'sucking',0
          ENDIF
        ENDIF

; c.) The predefined symbols ??ASEM_51 and ??VERSION,
;     and the general controls $WARNING and $ERROR:

        IFDEF ??ASEM_51               ;product identification
          IF ??VERSION < 0130H        ;version number
            ;display a user-defined warning:
$WARNING(Warning: ASEM-51 version 1.3 (or later)) required.)
          ENDIF
        ELSE
          ;fire a user-defined error message:
$ERROR(Fatal: Assembler is not ASEM-51!)
        ENDIF


; 11. Macro Processing:
; ---------------------
; Macro processing is by far too complex, to show all possibilities in a
; small demo program. So, only a few simple (but typical) constructions
; are listed here. Furthermore, some assembler controls and meta
; instructions for conditional assembly are introduced in this section,
; because they make sense in conjunction with macro processing only.

; a.) The MACRO, LOCAL and ENDM meta instructions, macro
;     parameters, and the macro commentary operator ;; :

        ;define macro CJEQ: "compare and jump if equal"

        CJEQ MACRO param1, param2, param3
          LOCAL temp
          CJNE param1, param2, temp   ;;continue if not equal
          JMP param3                  ;;jump otherwise
temp:
        ENDM

        ;CJEQ macro calls:

        CJEQ A, CHEETA, HERE
HERE:   CJEQ @R0, #13, THERE
        CJEQ R4, #DIFFER, HERE

; b.) The REPT meta instruction:

        ;repeat block: "seven NOPs"

        REPT 7
          NOP   ;;short pause
        ENDM

; c.) The EXITM meta instruction, recursive macro calls,
;     and the macro operators % and & :

        ;define macro DEFNSYM: "define n symbols"

        DEFNSYM MACRO symname, count
          IF count
            DEFNSYM symname, %count-1
            symname&count EQU count
          ELSE
            EXITM       ;;stop recursion if count=0
          ENDIF
        ENDM

; d.) The general controls $SAVE, $GENONLY, and $CONDONLY:

$SAVE                              ;save current $GEN/$COND/$LIST state
$GENONLY                           ;list only macro expansion lines
$CONDONLY                          ;list only true IFxx branches

        ;DEFNSYM macro calls:

        DEFNSYM SYMBOL, 5          ;define 5 symbols SYMBOLx
        DEFNSYM CONST, %DIFFER-7   ;define DIFFER-7 symbols CONSTx

; e.) The IFB and ELSEIFB meta instructions, and <...> literal brackets:

        ;define macro PATCH: "concatenate 3 literals"

        PATCH MACRO p1, p2, p3
          IFB <p1>
            PATCH 1_, <p2>, <p3>
          ELSEIFB <p2>
            PATCH <p1>, _2_, <p3>
          ELSEIFB <p3>
            PATCH <p1>, <p2>, _3
          ELSE
            DB '&p1&p2&p3'
          ENDIF
        ENDM

; f.) The general control $GEN:

$GEN                                    ;list macro calls and expansion lines

; g.) Omitting macro parameters, and the literal operator ! :

        ;PATCH macro calls:

        PATCH one, two, three           ;3 literal parameters specified
        PATCH ,two                      ;1st and 3rd parameter omitted
        PATCH one,,three                ;2nd parameter omitted
        PATCH                           ;all parameters omitted
        PATCH first, <, , >, last!;     ;special characters passed literally

; h.) The general control $RESTORE:

$RESTORE                                ;restore old $GEN/$COND/$LIST state


; 12. End of Program:
; -------------------

        END     ;end statement

        ;Only blank and commentary lines are allowed here!
