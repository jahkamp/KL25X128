	/* Author: Dylan Trafford
	   Date: 10/30/2014
	   Last Edit: 10/11/2015 */
	
	/* 	To Do: There are 7 functions that must be completed to get this code to work. 
		SDA (High and Low), SCLK (High and Low), Start Condition, Stop Condition, and Long Wait.

		There is a section labelled "restart", write your program there. */
	
	
	@ Port A (GPIOD) Registers
		.EQU	GPIOA_PDOR,	0xXXXXXXXX		@ Port A Data Output Register	
		.EQU	GPIOA_PSOR,	0xXXXXXXXX		@ Port A Set Output Register (writing 1 will set bit)
		.EQU	GPIOA_PCOR,	0xXXXXXXXX		@ Port A Clear Output Register (writing 1 will clear bit)
		.EQU	GPIOA_PTOR,	0xXXXXXXXX		@ Port A Toggle Output Register (writing 1 will toggle bit)
		.EQU	GPIOA_PDIR,	0xXXXXXXXX		@ Port A Data Input Register 
		.EQU	GPIOA_PDDR,	0xXXXXXXXX		@ Port A Data Direction Register (0=Input-default, 1=Output)

	@ Pin Control Register for Port A (These are top two, left pins vertically. Top = touchpad)
  		.EQU	PORTA_PCR1, 0xXXXXXXXX		@ Address of Port A pin 1 control Register
  		.EQU	PORTA_PCR2, 0xXXXXXXXX		@ Address of Port A pin 2 control Register
  	
  		.EQU	MUX_GPIO_Mask_SET, 0b00000000000000000000000100000000 @ used to set bit 8 using an ORR	
    	.EQU	MUX_GPIO_Mask_CLR, 0b11111111111111111111100111111111 @ used to clear bits 9 and 10 using and AND		

	@ System Clock Gating Control Register 5 (SIM_SCGC5)
  
  		.EQU 	SIM_SCGC5, 0x40048038		@ This is used to turn on the clocks to the Ports
  		.EQU	Port_Clock_Gate_Control, 0b11111000000000 @ used to turn on all Port clocks (bit 9-13)

	@ Generic bit masks
		.EQU	bit0_mask_SET, 0b1
  		.EQU	bit1_mask_SET, 0b10 
  		.EQU	bit2_mask_SET, 0b100
  		.EQU	bit3_mask_SET, 0b1000
  		.EQU	bit4_mask_SET, 0b10000
  		.EQU	bit5_mask_SET, 0b100000
  		.EQU	bit6_mask_SET, 0b1000000
  		.EQU	bit7_mask_SET, 0b10000000
  	
  		.EQU	bit18_mask_SET, 0b00000000000001000000000000000000
  		.EQU	bit19_mask_SET, 0b00000000000010000000000000000000
	
	.text
	.global	main
	
	
main:

@------ Turn on port clocks (mask for ports E through A)---------------------------------------------------------------------
		LDR r0, =SIM_SCGC5
		LDR r1, [r0]
		LDR r2, =Port_Clock_Gate_Control
		ORR r1, r1, r2
		STR r1, [r0]
@------ Pin Enable Setup------------------------------------------------------------------------------------------------------	
	@Turn on output pins to Alternative 1	
		LDR		r0, =PORTA_PCR1				@ load the address of of PORTA_PCR1 into r0
   		LDR		r1, [r0]					@ now load the contents of the PORTA_PCR1 into r1
   		LDR		r2, =MUX_GPIO_Mask_SET		@ now load the bit mask to SET bit 8 of the MUX field within the PCR to configure as GPIO
   		ORR		r1, r1, r2					@ OR the contents with the SET mask to set bit 8 of the PCR MUX field
   		LDR		r2, =MUX_GPIO_Mask_CLR		@ now load the bit mask to CLEAR bits 9 and 10 of the MUX field within the PCR to configure as GPIO
   		AND		r1, r1, r2					@ AND the contents with the CLEAR mask to clear bits 9 and 10 of the PCR MUX field
   		STR		r1, [r0]					@ Finally, store the new data back to the PORTA_PCR1
	
		LDR		r0, =PORTA_PCR2				@ load the address of of PORTA_PCR2 into r0
   		LDR		r1, [r0]					@ now load the contents of the PORTA_PCR2 into r1
   		LDR		r2, =MUX_GPIO_Mask_SET		@ now load the bit mask to SET bit 8 of the MUX field within the PCR to configure as GPIO
   		ORR		r1, r1, r2					@ OR the contents with the SET mask to set bit 8 of the PCR MUX field
   		LDR		r2, =MUX_GPIO_Mask_CLR		@ now load the bit mask to CLEAR bits 9 and 10 of the MUX field within the PCR to configure as GPIO
   		AND		r1, r1, r2					@ AND the contents with the CLEAR mask to clear bits 9 and 10 of the PCR MUX field
   		STR		r1, [r0]					@ Finally, store the new data back to the PORTA_PCR2
	
@------ Data Direction Setup----------------------------------------------------------------------------------------------------
	@Set data direction of port A bit 1 (out = 1)
   		LDR r0, =GPIOA_PDDR					@ Load the address of GPIOA_PDDR into r0
   		LDR r1, [r0]						@ Load the contents of GPIOA_PDDR into r1
   		LDR r2, =bit1_mask_SET				@ Isolate bit 1 using the generic bit mask
   		ORR r1, r1, r2						@ Set bit 1 to a 1 using OR logic command
   		STR r1, [r0]						@ Store the new contents back to GPIOA_PDDR
	@Set data direction of port A bit 2 (out = 1)
		LDR r0, =GPIOA_PDDR					@ Load the address of GPIOA_PDDR into r0
   		LDR r1, [r0]						@ Load the contents of GPIOA_PDDR into r1
   		LDR r2, =bit2_mask_SET				@ Isolate bit 2 using the generic bit mask
   		ORR r1, r1, r2						@ Set bit 2 to a 1 using OR logic command
   		STR r1, [r0]						@ Store the new contents back to GPIOA_PDDR
@------ Inital Conditions ------------------------------------------------------------------------------------------------------
		LDR r0, =GPIOA_PSOR					@SCLK Set Default High
		LDR r1, =bit1_mask_SET
		STR r1, [r0]
		
		LDR r0, =GPIOA_PSOR					@SDA Set Default High
		LDR r1, =bit2_mask_SET
		STR r1, [r0]
		LDR r7, =0
		BL sub_wait_long
		
restart:
		LDR r7, =0b10101010					@Part 1 this is your address 1010101 (0) = master out (write).
		@-------------------------------------------------------
		@Write your main program code here
		@Hint: Use BL to call various functions from here
		
		
		
		
		
		@-------------------------------------------------------
		BAL restart							@ Restart Send sequence
		
		
@ Call BL send_8bit to send the value currently in R7 over I2C
send_8bit:	

		PUSH {LR}
		PUSH {r0-r7}
		
		LDR r6, =bit7_mask_SET
		LDR r5, =8
send_8bit_loop:

	
		TST r7, r6							@ AND bitmask stored in r6 to the value in r7 (do not store results)
		BEQ send_bit_clear					@ If result is zero, branch to send_bit_clear
		BNE send_bit_set					@ If result is nonzero, branch to send_bit_set
		
	send_bit_set:
		BL SDA_High							@ Push SDA high to represent bit value being relayed
		BL SCLK_High						@ Push SCLK high to begin data sample
		BL sub_wait_i2c
		BL SCLK_Low							@ Pull SCLK low to end data sample
		BL SDA_Low							@ Pull SDA low (return to default)
		BL sub_wait_i2c
		BAL end_this
		
	send_bit_clear:
		BL SDA_Low							@ Pull SDA low to represent bit value being relayed
		BL SCLK_High						@ Push SCLK high to begin data sample 
		BL sub_wait_i2c
		BL SCLK_Low							@ Pull SCLK low to end data sample
		BL SDA_Low							@ Pull SDA low (return to default)
		BL sub_wait_i2c
		BAL end_this
		
	end_this:
		LSR r6, #1							@ Logical Shift Right to shift bit mask to sample next lowest bit
		SUB r5, #1							@ Subtract 1 from the end condition stored in r5
		BNE send_8bit_loop					@ If end condition has not been met, branch to main_loop
		
		
		BL sub_wait_i2c					@ wait a humanly noticable amount of time so the value can be read
			
		POP {r0-r7}
		POP {PC}
	
	
@--------------------------------------------------------------------------------------------------------------------------------	
Stop_Condition:

		PUSH {LR}
		PUSH {r0-r7}
		@----Stop I2C-----				@ Your stop code goes here
		
				@Write your stop condition code here
		
		
		@----------------
		POP {r0-r7}
		POP {PC}
Start_Condition:
		PUSH {LR}
		PUSH {r0-r7}
		@---Start I2C----				@ Your start code goes here
		
				@Write your start condition code here
		
		
		@----------------
		POP {r0-r7}
		POP {PC}
		
		
Handshake:									@Fake handshake for MSO (Normally this would be done by the device you're talking to) 
		PUSH {LR}
		PUSH {r0-r7}
		
		LDR r0, =GPIOA_PCOR					@Set SDA low (PORTA_2)
		LDR r1, =bit2_mask_SET
		STR r1, [r0]
		
		BL sub_wait_i2c
		
		LDR r0, =GPIOA_PSOR					@SET SCLK high (PORTA_1)
		LDR r1, =bit1_mask_SET
		STR r1, [r0]
		
		BL sub_wait_i2c
		
		LDR r0, =GPIOA_PCOR					@SET SCLK low (PORTA_2)
		LDR r1, =bit1_mask_SET
		STR r1, [r0]
		
		
		POP {r0-r7}
		POP {PC}

SDA_Low:
		PUSH {LR}
		PUSH {r0-r7}
		
		@-----------------------------------------------
		
		@Set SDA low (PORTA_2)
		
		@-----------------------------------------------
		
		POP {r0-r7}
		POP {PC}		
		
SDA_High:
		PUSH {LR}
		PUSH {r0-r7}
		
		@-----------------------------------------------
		
		@Set SDA high (PORTA_2)
		
		@-----------------------------------------------
		
		POP {r0-r7}
		POP {PC}
SCLK_Low:
		PUSH {LR}
		PUSH {r0-r7}
		
		@-----------------------------------------------
		
		@Set SCLK low (PORTA_1)
		
		@-----------------------------------------------

		POP {r0-r7}
		POP {PC}
		
SCLK_High:
		
		PUSH {LR}
		PUSH {r0-r7}
		
		@-----------------------------------------------
		
		@Set SCLK high (PORTA_1)
		
		@-----------------------------------------------
		
		POP {r0-r7}
		POP {PC}

@-------------------------------------------------------------------		
sub_wait_i2c:					@small wait (approx 1 ms)
		PUSH {LR}
		PUSH {r0-r7}
		
		LDR r0, =8000
	notdone:
		SUB r0, #1
		BPL notdone
		
		POP {r0-r7}
		POP {PC}
@-------------------------------------------------------------------
sub_wait_long:					@long wait for i2c (approx 100 ms)
		PUSH {LR}
		PUSH {r0-r7}
		@---Long wait----				@ Your delay goes here
		
		
				@Write your long wait code here
		
		
		@----------------
		
		
		POP {r0-r7}
		POP {PC}
		
@-------------------------------------------------------------------
sub_wait_500ms:					@long "human" wait (approx 500 ms)
		
		@Optional 500 ms long wait
