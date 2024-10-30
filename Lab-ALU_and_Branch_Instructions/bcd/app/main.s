; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; --
; -- main.s
; --
; -- CT1 P06 "ALU und Sprungbefehle" mit MUL
; --
; -- $Id: main.s 4857 2019-09-10 17:30:17Z akdi $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Address Defines
; ------------------------------------------------------------------

ADDR_LED_15_0           EQU     0x60000100
ADDR_LED_31_16          EQU     0x60000102
ADDR_DIP_SWITCH_7_0     EQU     0x60000200
ADDR_DIP_SWITCH_15_8    EQU     0x60000201
ADDR_7_SEG_BIN_DS3_0    EQU     0x60000114
ADDR_BUTTONS            EQU     0x60000210

ADDR_LCD_RED            EQU     0x60000340
ADDR_LCD_GREEN          EQU     0x60000342
ADDR_LCD_BLUE           EQU     0x60000344
LCD_BACKLIGHT_FULL      EQU     0xffff
LCD_BACKLIGHT_OFF       EQU     0x0000

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA myCode, CODE, READONLY

        ENTRY

main    PROC
        export main
            
; STUDENTS: To be programmed
		B load_bcd ; R1 => BCD Ones, R2 => Bcd Tens

load_bcd
		; R1 => BCD Ones, R2 => Bcd Tens
		; load BCD Ones
		LDR R0,=ADDR_DIP_SWITCH_7_0
		LDRB R1,[R0] 					; R1 = BCD ONES
		LDR R3,=0xF0
		BICS R1, R1,R3					; clear 111110000
		
		; load BCD Tens 
		LDR R0,=ADDR_DIP_SWITCH_15_8
		LDR R2,[R0] 					; R2 = BCD Tens
		LDR R3,=0xF0
		BICS R2, R2,R3					; clear 111110000
		
		
		; R3 => binary 
		LDR		R0,=ADDR_BUTTONS
		LDR		R6,=0x01
		LDRB	R0,[R0]
		TST		R0, R6		; check if t0 is pressed
		BEQ		mult		; true
		B shift				; false

combine_bcd
		;R2 BCD Ten, R1 BCD One
		; combine and display bcd
		MOVS R4, R2						; R4 = 00000_BCDTen
		LSLS R4, R4, #4					; R4 = BCDTen_00000
		ORRS R4, R4, R1					; R4 = BCDTen_BCDOne
		
		; R1 Binary, R2 BCDTen_BCDOne
		MOVS R1, R3
		MOVS R2, R4
		B display
		

display
		; R1 Binary, R2 BCDTen_BCDOne
		LDR R0,=ADDR_LED_15_0
		STRB R1, [R0,#1]				; Display Binary (10*BCDTEN + BCDONES)
		
		LDR R0,=ADDR_LED_15_0
		STRB R2, [R0]					; Display BCDTen_BCDOne
	
		; display to seg 7
		LDR      R0, =ADDR_7_SEG_BIN_DS3_0
		STRB     R1, [R0, #1]  
		STRB     R2, [R0, #0]  
		
		B disco

display_blue
		; display blue background
		LDR      R0, =ADDR_LCD_RED
        LDR      R5, =0xffff
		LDR	  	 R6, =0x0000
        STRH     R5, [R0, #4]
		STRH     R6, [R0, #0]
		BX LR
		


display_red
		; display blue background
		LDR      R0, =ADDR_LCD_RED
        LDR      R5, =0xffff
		LDR	  	 R6, =0x0000
        STRH     R5, [R0, #0]
		STRH     R6, [R0, #4]
		BX LR

mult
		; calulate binary with muls => R3
		;R2 Tens, R1 Ones 
		MOVS R3, #10					; R3 = 10
		MULS R3, R2, R3					; R3 = R2 * 10
		ADDS R3, R1						; R3 = R3 + R1
		BL display_blue
		B combine_bcd

shift
		; calulate binary with muls => R3
		;R2 Tens, R1 Ones 
		MOVS R3, R2          ; Move R2 into R3
		LSLS R3, R3, #3      ; Shift R3 left by 3 bits to get R2 * 8
		LSLS R4, R2, #1      ; Shift R2 left by 1 to get R2 * 2
		ADDS R3, R4          ; Add R4 to R3
		ADDS R3, R1			 ; add Ones
		BL display_red
		B combine_bcd
		
; disco, counter and increment_counter can be replaced	
disco
		LDR 	R0,=ADDR_LED_15_0
		LDRB 	R0, [R0,#1]		;load binary
		
		LDR		R1,=0x0
		CMP		R0,	R1
		BEQ		main
		
		MOVS    R1, #0           ; R1 will hold the count of ones, start with 0
		MOVS    R2, #32          ; R2 will act as a loop counter, for 32 bits

count_ones_loop
		MOVS	R3, #1			; R3 =1
		TST     R0, R3           ; Test the least significant bit of R0
		BEQ     skip_increment   ; If the bit is 0, skip the increment
		ADDS   R1, R1, #1       ; If the least significant bit is 1, increment the count in R1
skip_increment
		LSRS     R0, R0, #1       ; Logical shift right R0 by 1 to check the next bit
		SUBS    R2, R2, #1       ; Decrement the loop counter in R2
		BNE     count_ones_loop  ; Repeat until all 32 bits are checked

; R1 contains the count
		MOVS     R0, #0           ; Clear R0 to start with zeroes
		MOVS     R2, R1           ; R2 will act as a counter for setting the initial bits

set_ones_loop
		MOVS	R3, #1
		ORRS     R0, R0, R3       ; Set the least significant bit in R0
		LSLS     R0, R0, #1       ; Shift R0 left to prepare for the next bit
		SUBS    R2, R2, #1       ; Decrement the counter R2
		BNE     set_ones_loop    ; Repeat until we set 'count' bits in R0
		MOV     R4, R0           ; Save the original pattern in R3 for comparison
		LSLS 	R0, R0, #16		 ;shift it back a halfword
		ORRS 	R0, R0, R4		 ; combine shifted plus old one
		MOV     R4, R0           ; Save the new original pattern in R3 for comparison
		
		


    ; At this point, R0 contains the specified number of ones in the most significant bits
    ; Now enter the rotation loop to continuously rotate R0 and call the pause function
	; now duplicate it do 
	

rotate_loop
		RORS    R0, R0, R3       ; Rotate R0 left by 1 with overspill from the MSB to LSB
		LDR		R1,=ADDR_LED_31_16
		STRH	R0,	[R1]
		BL   	pause            ; Call the pause subroutine
		CMP		R0, R4           ; Compare the current pattern in R0 with the original in R3
		BNE		rotate_loop      ; Repeat indefinitely or as per your loop condition
		B main
		

; END: To be programmed
        B       main
        ENDP
            
;----------------------------------------------------
; Subroutines
;----------------------------------------------------

;----------------------------------------------------
; pause for disco_lights
pause           PROC
        PUSH    {R0, R1}
        LDR     R1, =1
        LDR     R0, =0x000FFFFF
        
loop        
		SUBS    R0, R0, R1
        BCS     loop
    
        POP     {R0, R1}
        BX      LR
        ALIGN
        ENDP

; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        END
