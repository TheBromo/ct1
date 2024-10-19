; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; --
; -- sumdiff.s
; --
; -- CT1 P05 Summe und Differenz
; --
; -- $Id: sumdiff.s 705 2014-09-16 11:44:22Z muln $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Symbolic Literals
; ------------------------------------------------------------------
ADDR_DIP_SWITCH_7_0     EQU     0x60000200
ADDR_DIP_SWITCH_15_8    EQU     0x60000201
ADDR_LED_7_0            EQU     0x60000100
ADDR_LED_15_8           EQU     0x60000101
ADDR_LED_23_16          EQU     0x60000102
ADDR_LED_31_24          EQU     0x60000103

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA MyCode, CODE, READONLY

main    PROC
        EXPORT main

user_prog
        ; STUDENTS: To be programmed
		
		LDR R0, =ADDR_DIP_SWITCH_15_8
		LDRB R1,[R0]; R1 = A
		LDR R0, =ADDR_DIP_SWITCH_7_0
		LDRB R2,[R0]; R2 = B
		
		LSLS R1, R1, #24 ;expand A
		LSLS R2, R2, #24 ;expand B
		
		ADDS R3, R1, R2 ;R3 = A + B
		MRS R5, APSR ; R5 = flags
		SUBS R4, R1, R2 ;R4 = A - B
		MRS R6, APSR ; R6 = flags
		
		LSRS R3, R3, #24 ;most significant byte R3 A
		LSRS R4, R4, #24 ;most significant byte R4 B
		
		LDR R0, =ADDR_LED_7_0
		STRB R3, [R0] ;display most significant byte R3
		
		LDR R0, =ADDR_LED_23_16
		STRB R4, [R0] ;display most significant byte R4
		
		LSRS R5, R5, #24 ;most significant byte Flag add
		LSRS R6, R6, #24 ;most significant byte Flab sub
		
		
		LDR R0, =ADDR_LED_15_8
		STRB R5, [R0] ;display addition flags
		
		LDR R0, =ADDR_LED_31_24
		STRB R6, [R0] ;display substraction flags
		


        ; END: To be programmed
        B       user_prog
        ALIGN
; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        ENDP
        END
