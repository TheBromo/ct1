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
table	SPACE 32
ADDR_SEG7_BIN   			EQU		0x60000114
		

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
		LDR     R7, =BITMASK_LOWER_NIBBLE   ; load bitmask

        ; Task 3.2: Read Input Value and Input Index
        LDR     R0, =ADDR_DIP_SWITCH_7_0    ; Load Switch 7_0 Addr
        LDRB    R1, [R0, #0]                ; Load Value from Switch 7_0 (input value)
        LDR     R0, =ADDR_DIP_SWITCH_15_8   ; Load Switch 15_8 Addr
        LDRB    R2, [R0, #0]                ; Load Value from Switch 15_8 (input index)
        ANDS    R2, R2, R7                  ; Mask to get lower nibble (input index)	
		
		; display input value
		LDR		R0, =ADDR_LED_7_0 			; store led address
		STRB	R1, [R0] 					; display input_value
		; display input index
		LDR		R0, =ADDR_LED_15_8 			; store led address
		STRB	R2, [R0] 					; display array_index

	
        ; Task 3.3: Store Input Value and Index in the Table
        LDR     R0, =table                  ; Load address of reserved table
		MOV		R3, R2						; copy index
        LSLS    R2, R2, #1                  ; Calculate half-word offset (index * 2)
		LSLS	R3, R3, #8              	; index one byte in
		ADDS	R3, R3, R1					; add the value into it
        STRH    R3, [R0, R2]                ; Store half-word (index and value)

        ; Task 3.4: Read and Display the Output Index
        LDR     R0, =ADDR_DIP_SWITCH_31_24  ; Load Switch 31_24 Addr
        LDRB    R1, [R0]                	; Load Value from Switch 31_24 (output index)
        ANDS    R1, R1, R7                  ; Mask to get lower nibble (output index)
        LDR     R2, =ADDR_LED_31_24         ; Load LED 31_24 Addr
        STRB    R1, [R2]                ; Store index to LED 31_24
		

        ; Task 3.5: Display the Selected Table Value
        LDR     R0, =table                  ; Load address of table
        LSLS    R3, R1, #1                  ; Calculate half-word offset (index * 2)
        LDRH    R4, [R0, R3]                ; Load half-word from table
		
		;display
		LDR		R0, =ADDR_LED_23_16 		; store led address in R6
		STRB	R4, [R0] 					; display output value

		; SSD
		LDR     r0, =ADDR_SEG7_BIN			; Load SSD Address
		STRH    R4, [r0, #0]				; Store Index and Value to SSD
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
