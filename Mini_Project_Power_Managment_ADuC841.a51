;********************************************************************
;
; Author : Moshe Peleg ID 203348040
;
; Date : 14 Junuary 2020
;
;
; File :Mini_Project_Power_Managment_ADuC841
;
; Hardware : Any 8052 based MicroConverter (ADuC8xx)
;
;Program descrieton: each time the user type "!" the main frequency clock devide itself by 2 (only one time!)
;each time the user type ")" the main frequency clock goes back to normal
;in both caes a constant baud rate of 57600 is aquired.
;
;*********************************************************************
                                                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                                 
#include <ADUC841.H >
CSEG AT 0000H
    JMP MAIN 
	
CSEG AT 000BH                            ;timer1 ISR - Create 20us rectangular wave to p3.4 (for later
	CPL P3.4                             ;to test the changes of frequency )
	RETI


CSEG AT 0023H                             ;UART ISR
	
	;Input check	
	PUSH ACC
	JBC TI,END_ISR
	CLR RI                               ;There is a reason why i put "CLR RI" *AFTER* JBC and not befor.
	MOV A,SBUF                           ;if "CLR RI" was before, in a sequense that both TI and RI are on
	CJNE A,#'!',NOT_SHIFT1               ;when i jump to 0023h i clear RI, and because TI is on i will go 
	JMP HALF_FREQUENCY                   ;to "END_ISR". when i finished deak with TI,and RETI from ISR 
	                                     ; i have lost the previus RI. -that why this way of algorithem
										 ;is more careful.
	NOT_SHIFT1: 
	CJNE A,#')',ECHO
	JMP FULL_FREQUENCY
	
	ECHO:
	MOV SBUF,A;
	JMP END_ISR;
	
	;HERE PART TO DEVIDE FREQUENCY TO 2 + CHANGE UART $ TIMER1 AS WELL.
	HALF_FREQUENCY:
	MOV PLLCON,#01H                     ;CD0=1 ->Divide by 2 Main clock frequency => 5529600 Hz      
    CLR TR1	
	MOV TL1,#0FDH                       ;253D to allow 3 "ticks" for apropriate O.F to new Frequency with SAME 57600 Baud rate
	MOV TH1,#0FDH
	SETB TR1
	JMP END_ISR
	
	FULL_FREQUENCY:                      ;This return the frequency back to normal
	CLR TR1	
	MOV PLLCON,#00H                     
	MOV TL1,#0FAH                        ;250D to allow 6 "ticks" for O.F (and for 57600 baud rate at nornal frequency)
	MOV TH1,#0FAH
	SETB TR1
	JMP END_ISR
	
	
	
	END_ISR:
	POP ACC
	RETI
	
	
	
;-------------	
	MAIN:	
	;Timer0 con                       for 20us rectangula wave to led,interrupts at 000BH.
	ANL TMOD,#11110000B
	ORL TMOD,#00000010B               ;Auto reload MODE2
	MOV TL0,#091H                    ;equal to 145D ,to allow O.F every 10us
	MOV TH0,#091H
	                                 ;FOR CHECHING IF UART WORKS WITH 40US PERIOD WAVE TO P3.4
	
	
    ;Timer1 con	                     (with MODE2 -Autoreload mood),NO INTERUPPTS.
									
	ANL TMOD,#00001111B              
	ORL TMOD,#00100000B              ;use Timer1 mode2
	MOV TL1,#0FAH                    ;equal to 250D to allow 6 "ticks" for O.F
	MOV TH1,#0FAH
	
	
	;UART con                        (57600 BR),8 BIT Transmittion.(interupts to 0023H)
                                   
	SETB REN                         ;this two line defined the UART in MODE1, and turns it on
    SETB SM1
	MOV PCON,#0H                     ;set SMOD=0 (the  MSB)
	
	;General ISR con
	SETB EA                          ;Enable all interrupts
	SETB ES                          ;Enable Serial Interrupts
	SETB ET0                         ;Enable interrupts from TIMER0
	SETB TR0                         ;now TIMER0 is TICKING!
	SETB TR1                         ;now TIMER1 is TICKING!
	;SETB ET1- Dont in use because it used for BaudRate.

JMP $
	
	
	END