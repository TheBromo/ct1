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
; -- CT1 P08 "Strukturierte Codierung" mit Assembler
; --
; -- $Id: struct_code.s 3787 2016-11-17 09:41:48Z kesr $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Address-Defines
; ------------------------------------------------------------------
; input
ADDR_DIP_SWITCH_7_0       EQU        0x60000200
ADDR_BUTTONS              EQU        0x60000210

; output
ADDR_LED_31_0             EQU        0x60000100
ADDR_7_SEG_BIN_DS3_0      EQU        0x60000114
ADDR_LCD_COLOUR           EQU        0x60000340
ADDR_LCD_ASCII            EQU        0x60000300
ADDR_LCD_ASCII_BIT_POS    EQU        0x60000302
ADDR_LCD_ASCII_2ND_LINE   EQU        0x60000314


; ------------------------------------------------------------------
; -- Program-Defines
; ------------------------------------------------------------------
; value for clearing lcd
ASCII_DIGIT_CLEAR        EQU         0x00000000
LCD_LAST_OFFSET          EQU         0x00000028

; offset for showing the digit in the lcd
ASCII_DIGIT_OFFSET        EQU        0x00000030

; lcd background colors to be written
DISPLAY_COLOUR_RED        EQU        0
DISPLAY_COLOUR_GREEN      EQU        2
DISPLAY_COLOUR_BLUE       EQU        4

; ------------------------------------------------------------------
; -- myConstants
; ------------------------------------------------------------------
        AREA myConstants, DATA, READONLY
; display defines for hex / dec
DISPLAY_BIT               DCB        "Bit "
DISPLAY_2_BIT             DCB        "2"
DISPLAY_4_BIT             DCB        "4"
DISPLAY_8_BIT             DCB        "8"
        ALIGN

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA myCode, CODE, READONLY
        ENTRY

        ; imports for calls
        import adc_init
        import adc_get_value

main    PROC
        export main
        ; 8 bit resolution, cont. sampling
        BL         adc_init 
        BL         clear_lcd

main_loop
; STUDENTS: To be programmed
		BL 		adc_get_value			; R0 = ADC
		MOVS 	R4, R0					; R4 = ADC
		
		;load t0 pressed
		LDR 	R0,=ADDR_BUTTONS		; T0 Addr
		LDRB    R0, [R0, #0]			; load all for buttons t0-t3
		MOVS	R1, #0xFE				; 0b11111110
		BICS	R0, R1					; clear t1-t3 
		
		;R0 if t0 pressed
		CMP 	R0, #0x01
		BNE		t0_else	
		
		;t0 pressed == true	
		LDR     r0, =DISPLAY_COLOUR_GREEN	;offset for green	
		BL 		set_background_to_offset	;set background green
		
		MOVS 	R0, R4						; set r0 adc
		BL 		display_7_seg				;display adc on 7 seg displ
		BL 		adc_bar						;display the bar
		B		t0_end_if
		
t0_else ;t0 pressed == false
		BL 		diff_proc	;diff procedure
t0_end_if

; END: To be programmed
        B          main_loop
        
clear_lcd
        PUSH       {R0, R1, R2}
        LDR        R2, =0x0
clear_lcd_loop
        LDR        R0, =ADDR_LCD_ASCII
        ADDS       R0, R0, R2                       ; add index to lcd offset
        LDR        R1, =ASCII_DIGIT_CLEAR
        STR        R1, [R0]
        ADDS       R2, R2, #4                       ; increas index by 4 (word step)
        CMP        R2, #LCD_LAST_OFFSET             ; until index reached last lcd point
        BMI        clear_lcd_loop
        POP        {R0, R1, R2}
        BX         LR

write_bit_ascii
        PUSH       {R0, R1}
        LDR        R0, =ADDR_LCD_ASCII_BIT_POS 
        LDR        R1, =DISPLAY_BIT
        LDR        R1, [R1]
        STR        R1, [R0]
        POP        {R0, R1}
        BX         LR

        ENDP
		
		
set_background_to_offset 	PROC 
		PUSH 	{R1-R2,LR} ;R0 = offset
		LDR     R1, =ADDR_LCD_COLOUR
		;clear collor
		LDR     R2, =0x0000
		STRH    R2,	[R1 ,#0]
		STRH    R2,	[R1 ,#2]
		STRH    R2,	[R1 ,#4]		
		
		LDR     R2, =0xffff
		STRH    R2,	[R1 , R0] 
		POP 	{R1-R2,PC}
		ENDP
		
			
display_7_seg PROC
		PUSH	{R1-R2,LR}	;R0 = display value in
		LDR     R1, =ADDR_7_SEG_BIN_DS3_0
		MOVS	R2,#0x00		
		STRB    R2, [R1, #1]	;write 00 at the beginning
		STRB    R0, [R1, #0]    ;write input  00xx
		POP		{R1-R2,PC}
		ENDP	
				
diff_proc PROC
		PUSH	{R0-R3,LR}				;r4 adc
		LDR 	R0,=ADDR_DIP_SWITCH_7_0
		LDRB 	R0, [R0,#0]				;load Dipval
		SUBS 	R0, R4, R0				;r0 = diff
		CMP		R0,	#0x0				;if diff >=0
		MOVS	R3, R0					;r3 =diff
		MOVS	R5, R0					;r3 =diff

		BLT		diff_false		
		;true 
		LDR     r0, =DISPLAY_COLOUR_BLUE	;offset for blue	
		BL 		set_background_to_offset	;set background blue
		BL		display_bit
		B		diff_end_if
diff_false
		;false
		LDR     r0, =DISPLAY_COLOUR_RED		;offset for red	
		BL 		set_background_to_offset	;set background red
		BL		display_zeros
diff_end_if		
		;display diff on 7 seg display
		MOVS 	R0,R3						;R0=diff
		BL 		display_7_seg				;display adc on 7 seg display
		POP{R0-R3,PC}
		ENDP

adc_bar PROC
		PUSH	{R0-R3,LR}				;r4 adc
		LSRS	R0,R4,#3				; R0= ADC>>3
		MOVS	R1, #1					; R1=led_count = 1
adc_while		
		CMP		R0,#0
		BEQ		adc_while_end			; while R0 != 0
		LSLS	R1,R1,#1				; 0001 << 1	= 0010
		ADDS	R1,R1,#0x1				; 0010 | 1  = 0011 
		SUBS	R0,R0, #1				; R0--
		B		adc_while
adc_while_end
		LDR 	R2,=ADDR_LED_31_0
		STR		R1,[R2,#0]				; display led_count
		POP{R0-R3,PC}
		ENDP
		

display_bit PROC
		PUSH	{R0-R3,LR}		;r5 diff
		BL 		clear_lcd
		MOVS	R1, R5
		BL		write_bit_ascii	; print "Bit "
		CMP     R1, #4          ; Check if diff < 4
		BLT     display_2bit    ; If r1 < 4, branch to display_2bit
		CMP     R1, #16         ; Check if diff < 16
		BLT     display_4bit    ; If r1 < 16, branch to display_4bit
		B       display_8bit    ; In all other cases, branch to display_8bit

display_2bit
        LDR        	R1, =DISPLAY_2_BIT
		B       end_display   

display_4bit
        LDR       	R1, =DISPLAY_4_BIT
		B       end_display    
			
display_8bit
        LDR        	R1, =DISPLAY_8_BIT

end_display
	    LDR        R1, [R1]
		LDR     	R0, =ADDR_LCD_ASCII 
        STRB       	R1, [R0,#8]
		POP			{R0-R3,PC}
		ENDP
			

display_zeros PROC
		PUSH	{R0-R4,LR}		;r5 diff
		BL 		clear_lcd
		MVNS     R4, R5          ; Invert diff and store it in r4
		MOVS     R3, #0          ; Initialize count to 0, store in r5
loop_disp
		CMP     R4, #0          ; Check if diff is 0
		BEQ     end_loop        ; Exit loop if diff is 0

		MOVS	R0, #1
		TST     R4, R0          ; Test if the least significant bit of diff is 1
		BEQ     shift_right     ; If not, skip incrementing count

		ADDS     R3, R3, #1      ; Increment count if the least significant bit is 1

shift_right
		LSRS     R4, R4, #1      ; Logical shift right by 1 to check the next bit
		B       loop_disp       ; Repeat the loop

end_loop
		LDR R0,=0x60000337
		STRB R3,[R0,#0]
		POP			{R0-R4,PC}
		endp



		ALIGN
; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        END
