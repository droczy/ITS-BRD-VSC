;******************** (C) COPYRIGHT HAW-Hamburg ********************************
;* File Name          : main.s
;* Author             : Franz Korf	
;* Version            : V1.0
;* Date               : 11.05.2022
;* Description        : Rahmen zur Loesung von GTP Woche 7-9 (Stoppuhr).
;
;*******************************************************************************

; Define address of selected GPIO and Timer registers
PERIPH_BASE     	equ	0x40000000                 ;Peripheral base address
AHB1PERIPH_BASE 	equ	(PERIPH_BASE + 0x00020000)
APB1PERIPH_BASE     equ PERIPH_BASE

GPIOD_BASE			equ	(AHB1PERIPH_BASE + 0x0C00)
GPIOF_BASE			equ	(AHB1PERIPH_BASE + 0x1400)
TIM2_BASE           equ (APB1PERIPH_BASE + 0x0000)
	
GPIO_F_PIN        	equ	(GPIOF_BASE + 0x10)

GPIO_D_PIN			equ	(GPIOD_BASE + 0x10)
GPIO_D_SET			equ (GPIOD_BASE + 0x18)
GPIO_D_CLR			equ	(GPIOD_BASE + 0x1A)
	
TIMER				equ (TIM2_BASE + 0x24)   ; CNT : current time stamp (32 bit),  resolution
TIM2_PSC			equ (TIM2_BASE + 0x28)   ; Prescaler  resolution
TIM2_ERG			equ (TIM2_BASE + 0x14)   ; 16 Bit register, Bit 0 : 1 Restart Timer


    EXTERN initITSboard
    EXTERN GUI_init
	EXTERN TP_Init
	EXTERN initTimer
	EXTERN lcdSetFont
	EXTERN lcdGotoXY      		; TFT goto x y function
	EXTERN lcdPrintS			; TFT output function	
    EXTERN lcdPrintC            ; TFT output one character		
	EXTERN Delay				; Delay (ms) function


;********************************************
; Data section, aligned on 4-byte boundery
;********************************************
	AREA MyData, DATA, align = 2

DEFAULT_BRIGHTNESS	DCW     800
MY_TEXT				DCB		"00:00:00", 0

;********************************************
; Code section, aligned on 8-byte boundery
;********************************************
	AREA |.text|, CODE, READONLY, ALIGN = 3


;--------------------------------------------
; subroutines
;--------------------------------------------

readButtons				PROC
						ldr			r0, =GPIO_F_PIN
						ldrb		r0, [r0]
						BX			lr
						ENDP


switchLEDsOff			PROC
						ldr			r1, =GPIO_D_CLR
						strb		r0, [r1]
						BX			lr
						ENDP


switchLEDsOn			PROC
						PUSH		{}
						ldr			r1, =GPIO_D_SET
						eor			r0, r0, #0xFF
						strb		r0, [r1]
						POP			{}
						BX			lr
						ENDP


displayTime				PROC
						ENDP


checkTimer				PROC
						ENDP


betriebszustandINIT		PROC
						ENDP


betriebszustandRUNNING	PROC
						ENDP


betriebszustandHOLD		PROC
						ENDP



;--------------------------------------------
; main subroutine
;--------------------------------------------
	EXPORT main [CODE]

main					PROC

						; Initialisierung der HW

						BL		initITSboard
						ldr   	r1, =DEFAULT_BRIGHTNESS
						ldrh 	r0, [r1]
						bl   	GUI_init
						bl  	initTimer
						ldr 	R1,=TIM2_PSC   			; Set pre scaler such that 1 timer tick represents 10 us
						mov 	R0,#(90*10-1) 
						strh	R0,[R1]
						ldr 	R1,=TIM2_ERG   			; Restart timer	
						mov		R0,#0x01
						strh	R0,[R1]					; Set UG Bit
						MOV 	R0, #24
						bl  	lcdSetFont


						; Ihre Initialisierung
						; bl		betriebszustandINIT

						; Simple test code
						LDR 	R0,=MY_TEXT
						BL  	lcdPrintS
						B 		superloop

superloop
						bl		readButtons

						bl		switchLEDsOff
		
						bl		switchLEDsOn

						BAL		superloop				; End of superloop
						ENDP

						ALIGN
						END

