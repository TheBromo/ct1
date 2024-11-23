;* ------------------------------------------------------------------
;* --  _____       ______  _____                                    -
;* -- |_   _|     |  ____|/ ____|                                   -
;* --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
;* --   | | | '_ \|  __|  \___ \   Zurich University of             -
;* --  _| |_| | | | |____ ____) |  Applied Sciences                 -
;* -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
;* ------------------------------------------------------------------
;* --
;* -- Project     : CT1 - Lab 10
;* -- Description : Search Max
;* -- 
;* -- $Id: search_max.s 879 2014-10-24 09:00:00Z muln $
;* ------------------------------------------------------------------


; -------------------------------------------------------------------
; -- Constants
; -------------------------------------------------------------------
                AREA myCode, CODE, READONLY
                THUMB
                    
; STUDENTS: To be programmed




; END: To be programmed
; -------------------------------------------------------------------                    
; Searchmax
; - tableaddress in R0
; - table length in R1
; - result returned in R0
; -------------------------------------------------------------------   
search_max      PROC
                EXPORT search_max

                ; STUDENTS: To be programmed
				PUSH {R4-R7, LR}
				MOV R4, R0			; R4 = table address
				MOV R5, R1			; R5 = table length
				
				;setup for max search				
				LDR R0, =0x80000000	; standard return value
				LDR R1, =0 			; current table index
				
				
				CMP	R5, #0			; skip if table length = 0
				BEQ search_end
				
search_start
				LSLS R3, R1, #2		;convert index to memaddr = index * 4 = R3
				LDR R2,[R4, R3]		;load valuee to compare
				
				CMP  R2, R0			; compare max with r2 value
									
				BLE	increment		; if R2 bigger set max to r2
				MOVS R0, R2

increment
				ADDS R1, #1			; increment index
				CMP R1, R5			; compare index to table length
				BLT	search_start	; if index == table length go to search_max_end
				
search_end
				POP {R4-R7, PC}
                ; END: To be programmed
                ALIGN
                ENDP
; -------------------------------------------------------------------
; -- End of file
; -------------------------------------------------------------------                      
                END

