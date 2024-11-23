			PRESERVE8
			THUMB
			
			AREA IOFuncCode, CODE, READONLY
in_word
			EXPORT in_word
			PUSH 	{R4-R7, LR}
			
			; copy input
			MOV		R4, R0
			; CODE
			LDR     R5, [R4]
			; store result
			MOV		R0, R5

			POP 	{R4-R7, PC}
			
out_word
			EXPORT out_word
			PUSH 	{R4-R7, LR}
			; allocate stack
			;SUB		SP, SP, #8
			
			; copy input
			MOV		R4, R0
			MOV		R5, R1
			
			; CODE
			STR     R5, [R4]
			
			; store result
			;empy on purpose
			
			; release stack
			;ADD		SP, SP, #8
			POP 	{R4-R7, PC}
			ALIGN
			END