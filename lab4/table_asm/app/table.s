; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; --
; -- table.s
; --
; -- CT1 P04 Ein- und Ausgabe von Tabellenwerten
; --
; -- $Id: table.s 800 2014-10-06 13:19:25Z ruan $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB
; ------------------------------------------------------------------
; -- Symbolic Literals
; ------------------------------------------------------------------
ADDR_DIP_SWITCH_7_0         EQU     0x60000200
ADDR_DIP_SWITCH_15_8        EQU     0x60000201
ADDR_DIP_SWITCH_31_24       EQU     0x60000203
ADDR_LED_7_0                EQU     0x60000100
ADDR_LED_15_8               EQU     0x60000101
ADDR_LED_23_16              EQU     0x60000102
ADDR_LED_31_24              EQU     0x60000103
ADDR_BUTTONS                EQU     0x60000210

BITMASK_KEY_T0              EQU     0x01
BITMASK_LOWER_NIBBLE        EQU     0x0F

; ------------------------------------------------------------------
; -- Variables
; ------------------------------------------------------------------
        AREA MyAsmVar, DATA, READWRITE
; STUDENTS: To be programmed
table	SPACE 16

		

; END: To be programmed
        ALIGN

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA myCode, CODE, READONLY

main    PROC
        EXPORT main

readInput
        BL    waitForKey                    ; wait for key to be pressed and released
; STUDENTS: To be programmed
; 3.2 Read Input Index and Input Value 

		LDR 	R7, =BITMASK_LOWER_NIBBLE	; load bitmask

		;Task 3.2
		LDR		r0, =ADDR_DIP_SWITCH_7_0	; Load Switch 7_0 Addr
		LDRB    r1, [r0, #0]          		; Load Value from Switch 7_0
		LDR		r2, =ADDR_LED_7_0			; Load LED 7_0 Addr 
		STRB    r1, [r2, #0]          		; Store Value to LED 7_0
		
		LDR		r0, =ADDR_DIP_SWITCH_15_8	; Load Switch 15_8 Addr
		LDRB    r2, [r0, #0]          		; Load Value from Switch 15_8
		ANDS 	r2, r2, R7 					; cut off lower half 
		LDR		r0, =ADDR_LED_15_8			; Load LED 15_8 Addr 
		STRB    r2, [r0, #0]          		; Store Value to LED 15_8
		
		
		;Task 3.3
		LDR		R0, =table 					; load address of reserved table
		STRB	r1,	[r0,r2]					; store at index in table
		
		
		;Task 3.4 Read and Display the Output Index

		LDR		r0, =ADDR_DIP_SWITCH_31_24	; Load Switch 31_24 Addr
		LDRB    r1, [r0, #0]          		; Load Value from Switch 31_24
		ANDS 	R1, R1, R7					; cut off lower half
		LDR		r2, =ADDR_LED_31_24			; Load LED 31_24 Addr 
		STRB    r1, [r2, #0]          		; Store index to LED 31_24

		
		;Task 3.5 Display the Selected Table Value
		LDR		r0, =table					; Load Switch 23_16 Addr
		LDRB    r1, [r0, r1]          		; Load table value
		LDR 	r0, =ADDR_LED_23_16
		STRB    r1, [r0, #0]          		; Store Value to LED 23_16

				
; END: To be programmed
        B       readInput
        ALIGN

; ------------------------------------------------------------------
; Subroutines
; ------------------------------------------------------------------

; wait for key to be pressed and released
waitForKey
        PUSH    {R0, R1, R2}
        LDR     R1, =ADDR_BUTTONS           ; laod base address of keys
        LDR     R2, =BITMASK_KEY_T0         ; load key mask T0

waitForPress
        LDRB    R0, [R1]                    ; load key values
        TST     R0, R2                      ; check, if key T0 is pressed
        BEQ     waitForPress

waitForRelease
        LDRB    R0, [R1]                    ; load key values
        TST     R0, R2                      ; check, if key T0 is released
        BNE     waitForRelease
                
        POP     {R0, R1, R2}
        BX      LR
        ALIGN

; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        ENDP
        END
