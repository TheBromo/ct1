;* ------------------------------------------------------------------
;* --  _____       ______  _____                                    -
;* -- |_   _|     |  ____|/ ____|                                   -
;* --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
;* --   | | | '_ \|  __|  \___ \   Zurich University of             -
;* --  _| |_| | | | |____ ____) |  Applied Sciences                 -
;* -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
;* ------------------------------------------------------------------
;* --
;* -- Project     : CT1 - Lab 7
;* -- Description : Control structures
;* -- 
;* -- $Id: main.s 3748 2016-10-31 13:26:44Z kesr $
;* ------------------------------------------------------------------


; -------------------------------------------------------------------
; -- Constants
; -------------------------------------------------------------------
    
                AREA myCode, CODE, READONLY
                    
                THUMB

ADDR_LED_15_0           EQU     0x60000100
ADDR_LED_31_16          EQU     0x60000102
ADDR_7_SEG_BIN_DS1_0    EQU     0x60000114
ADDR_DIP_SWITCH_15_0    EQU     0x60000200
ADDR_HEX_SWITCH         EQU     0x60000211

NR_CASES                EQU     0xB

jump_table      ; ordered table containing the labels of all cases
                ; STUDENTS: To be programmed 
				DCD 	case_dark		;0x00
				DCD		case_add		;0x01
				DCD		case_sub		;0x02
				DCD		case_umult		;0x03
				DCD		case_and		;0x04
				DCD		case_or			;0x05
				DCD		case_xor		;0x06
				DCD		case_not		;0x07
				DCD		case_nand		;0x08
				DCD		case_nor		;0x09
				DCD		case_xnor		;0x0A


                ; END: To be programmed
    

; -------------------------------------------------------------------
; -- Main
; -------------------------------------------------------------------   
                        
main            PROC
                EXPORT main
                
read_dipsw      ; Read operands into R0 and R1 and display on LEDs
                ; STUDENTS: To be programmed
				LDR 	R0, =ADDR_DIP_SWITCH_15_0 ;load op1
				LDRB 	R0, [R0,#1]
				LDR 	R3, =ADDR_LED_15_0 ;Display op1
				STRB	R0, [R3,#1]

				LDR 	R1, =ADDR_DIP_SWITCH_15_0 ;load op2
				LDRB 	R1, [R1]
				LDR 	R3, =ADDR_LED_15_0 ;Display op2
				STRB	R1, [R3]
				
				;extend to 32 bit
				UXTB 	R0,R0
				UXTB 	R1,R1

                ; END: To be programmed
                    
read_hexsw      ; Read operation into R2 and display on 7seg.
                ; STUDENTS: To be programmed
				LDR 	R2, =ADDR_HEX_SWITCH
				LDRB	R2, [R2,#0]
				LDR 	R3, =0x0F
				ANDS	R2, R2, R3
				LDR 	R3, =ADDR_7_SEG_BIN_DS1_0
				STRB	R2, [R3]

                ; END: To be programmed
NR_Cases		EQU 	11
case_switch     ; Implement switch statement as shown on lecture slide
                ; STUDENTS: To be programmed
				CMP 	R2, #NR_Cases
				BHS 	case_default
				LSLS	R2, #2			;*4
				LDR		R7, =jump_table
				LDR		R7,[R7,R2]
				BX		R7
                ; END: To be programmed


; Add the code for the individual cases below
; - operand 1 in R0
; - operand 2 in R1
; - result in R0

case_dark       
                LDR  R0, =0
                B    display_result  

case_add        
                ADDS R0, R0, R1
                B    display_result

; STUDENTS: To be programmed
case_default	
				LDR		R0, =0
				UXTB 	R0,R0
				MVNS	R0, R0
				B    	display_result

case_sub		SUBS 	R0, R0, R1
				B		display_result
						

case_umult		MULS	R0, R1, R0
				B		display_result

case_and		ANDS	R0,	R0,	R1
				B		display_result

case_or			ORRS	R0,	R0,	R1
				B		display_result

case_xor		EORS	R0,	R0,	R1
				B		display_result

case_not		MVNS	R0,	R0
				B		display_result

case_nand		ANDS	R0,	R0,	R1
				MVNS	R0,	R0
				B		display_result

case_nor		ORRS	R0,	R0,	R1
				MVNS	R0,	R0
				B		display_result

case_xnor		EORS	R0,	R0,	R1
				MVNS	R0,	R0
				B		display_result
				

; END: To be programmed


display_result  ; Display result on LEDs
                ; STUDENTS: To be programmed
				LDR R1,=ADDR_LED_31_16
				STR	R0, [R1]
                ; END: To be programmed

                B    read_dipsw
                
                ALIGN
                ENDP

; -------------------------------------------------------------------
; -- End of file
; -------------------------------------------------------------------                      
                END

