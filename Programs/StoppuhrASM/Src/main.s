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

DEFAULT_BRIGHTNESS		DCW     800

STATE					DCB		5

PAST_CYCLES				DCD		0

CURRENT_TIME			DCB		"00:00:00", 0
NEW_TIME				DCB		"00:00:00", 0
INIT_TIME				DCB		"00:00:00", 0

TIME_UNITS				DCD		60000000, 6000000, 1000000, 100000, 10000, 1000

TIME_POSITIONS			DCB		0, 1, 3, 4, 6, 7



;********************************************	
; Code section, aligned on 8-byte boundery
;********************************************
	AREA |.text|, CODE, READONLY, ALIGN = 3



;--------------------------------------------
; init
;--------------------------------------------

initHW								PROC
									push		{r4, r5, r6, r7, r8, lr}

									BL			initITSboard
									ldr   		r1, =DEFAULT_BRIGHTNESS
									ldrh 		r0, [r1]
									bl   		GUI_init
									bl  		initTimer
									ldr 		R1,=TIM2_PSC   										; Set pre scaler such that 1 timer tick represents 10 us
									mov 		R0,#(90*10-1) 
									strh		R0,[R1]
									ldr 		R1,=TIM2_ERG   										; Restart timer	
									mov			R0,#0x01
									strh		R0,[R1]												; Set UG Bit
									MOV 		R0, #24
									bl  		lcdSetFont

									pop			{r4, r5, r6, r7, r8, lr}
									blx			lr
									ENDP


;----------------------------------------------------------------------------------------
; subroutines
;----------------------------------------------------------------------------------------


;----------------------------------------------|
; Ließt den Wert der gedrückten Tast aus.
; Übergabeparameter:
; 	-
; Rückgabewerte:
; 	r0: Dezimalwert der gedrückten Taste
;----------------------------------|-----------|
readButtons							PROC
									push		{r4, lr}

									ldr			r4, =GPIO_F_PIN
									ldrb		r4, [r4]
									eor			r4, #0xFF
									and			r4, #0xE0
									mov			r0, r4
									bl			bitmaskToNumber
									
									pop			{r4, lr}
									blx			lr
									ENDP


;----------------------------------------------|
; Schaltet eine angegebene LED ein.
; Übergabeparameter:
; 	r0: Dezimalwert der LED, welche angeschaltet werden soll
; Rückgabewerte:
; 	-
;----------------------------------|-----------|
switchLEDOn							PROC
									push		{r4, lr}

									ldr			r4, =GPIO_D_SET
									bl			numberToBitmask
									strb		r0, [r4]

									pop			{r4, lr}
									blx			lr
									ENDP


;----------------------------------------------|
; Schaltet eine angegebene LED aus.
; Übergabeparameter:
; 	r0: Dezimalwert der LED, welche ausgeschaltet werden soll
; Rückgabewerte:
; 	-
;----------------------------------|-----------|
switchLEDOff						PROC
									push		{r4, lr}

									ldr			r4, =GPIO_D_CLR
									bl			numberToBitmask
									strb		r0, [r4]

									pop			{r4, lr}
									blx			lr
									ENDP

;----------------------------------------------|
; Schaltet alle LEDs aus.
; Übergabeparameter:
; 	-
; Rückgabewerte:
; 	-
;----------------------------------|-----------|
switchLEDsOff						PROC
									push		{r4, r5, lr}

									ldr			r4, =GPIO_D_CLR
									mov			r5, #0xff
									strb		r5, [r4]

									pop			{r4, r5, lr}
									blx			lr
									ENDP


;----------------------------------------------|
; Wandelt eine Dezimalzahl in eine Bitmaske um.
; Übergabeparameter:
; 	r0: Dezimalwert
; Rückgabewerte:
; 	r0: Bitmaske des Dezimalwerts
;----------------------------------|-----------|
numberToBitmask						PROC
									push		{r4, lr}

									mov			r4, r0
									mov			r0, #1
while_numberToBitmask_01			
									cmp			r4, #0
									beq			end_while_numberToBitmask_01
do_numberToBitmask_01
									lsl			r0, #1
									sub			r4, #1
									b			while_numberToBitmask_01
end_while_numberToBitmask_01

									pop			{r4, lr}
									blx			lr
									ENDP


;----------------------------------------------|
; Wandelt eine Bitmaske in eine Dezimalzahl um.
; Übergabeparameter:
; 	r0: Bitmaske
; Rückgabewerte:
; 	r0: Dezimalzahl der Bitmaske
;----------------------------------|-----------|
bitmaskToNumber						PROC
									push		{r4, lr}

									mov			r4, #0							; Init Zähler
									mov			r5, r0
									bl			isOneBitSet
if_bitmaskToNumber_01		
									cmp			r0, #1							; Abbruchbedingung: not isOneBitSet
									bne			end_if_bitmaskToNumber_01
then_bitmaskToNumber_01
while_bitmaskToNumber_02
									cmp			r5, #1
									beq			end_while_bitmaskToNumber_02
do_bitmaskToNumber_02
									lsr			r5, #1
									add			r4, #1
									b			while_bitmaskToNumber_02
end_while_bitmaskToNumber_02
end_if_bitmaskToNumber_01
									mov			r0, r4

									pop			{r4, lr}
									blx			lr
									ENDP


;----------------------------------------------|
; Gibt zurück ob bei einer Bitmaske nur eine 1 enthalten ist.
; Übergabeparameter:
; 	r0: Bitmaske
; Rückgabewerte:
; 	r0: Wahrheitswert #0 oder #1
;----------------------------------|-----------|
isOneBitSet							PROC
									push		{r4, r5}

									mov			r4, r0
									mov			r0, #0
if_isOneBitSet_01
									cmp			r4, #0
									beq			end_if_isOneBitSet_01
then_isOneBitSet_01					
									sub			r5, r4, #1
									and			r5, r4
if_isOneBitSet_02
									cmp			r5, #0
									bne			end_if_isOneBitSet_02			
then_isOneBitSet_02		
									mov			r0, #1
end_if_isOneBitSet_02
end_if_isOneBitSet_01

									pop			{r4, r5}
									blx			lr
									ENDP


;----------------------------------------------|
; Vergleicht eine angegebene Zeit mit der aktuellen Zeit.
; Übergabeparameter:
; 	r0: Speicheradresse der Zeit.
; Rückgabewerte:
; 	r0: Wahrheitswert #0 oder #1 ob es die gleiche Zeit ist.
;----------------------------------|-----------|
isTimeEqual							PROC
									push		{r4, r5, r6, r7, lr}

									ldr			r4, =CURRENT_TIME
									mov			r5, r0
									mov			r0, #1
									ldrb		r6, [r4]
									ldrb		r7, [r5]							
while_isTimeEqual_01
									cmp			r6, #0
									beq			end_while_isTimeEqual_01
do_while_isTimeEqual_01
if_isTimeEqual_02
									cmp			r6, r7
									beq			end_if_isTimeEqual_02
then_isTimeEqual_02
									mov			r0, #0
									b			end_while_isTimeEqual_01
end_if_isTimeEqual_02
									ldrb		r6, [r4, #1]!
									ldrb		r7, [r5, #1]!
									b			while_isTimeEqual_01
end_while_isTimeEqual_01

									pop		{r4, r5, r6, r7, lr}
									blx		lr
									ENDP


;----------------------------------------------|
; Setzt die aktuelle Zeit auf eine angegebene Zeit.
; Übergabeparameter:
; 	r0: Speicheradresse zu einem Zeit-String
;	r1: Speicheradresse der Zeit die gesetzt werden soll.
; Rückgabewerte:
; 	-
;----------------------------------|-----------|
setTime								PROC
									push		{r4, r5, r6, lr}

									mov			r4, r0
									mov			r6, r1
									ldrb		r5, [r4]
while_setTime_01
									cmp			r5, #0
									beq			end_setTime_01
do_setTime_01
									strb		r5, [r6]
									ldrb		r5, [r4, #1]!
									add			r6, #1
									B			while_setTime_01
end_setTime_01

									pop			{r4, r5, r6, lr}
									blx			lr
									ENDP


;----------------------------------------------|
; Wandelt eine Dezimalzahl in eine Bitmaske um.
; Übergabeparameter:
; 	r0: Dezimalwert
; Rückgabewerte:
; 	r0: Bitmaske des Dezimalwerts
;----------------------------------|-----------|
displayTime							PROC
									push		{r4, r5, r6, r7, r8, lr}

									ldr			r5, =CURRENT_TIME
									ldr			r6, =NEW_TIME
for_displayTime_01
									mov			r4, #0
until_displayTime_01
									cmp			r4, #7
									bhi			end_for_displayTime_01
do_displayTime_01
									ldrb		r7, [r5, r4]
									ldrb		r8, [r6, r4]
if_displayTime_01
									cmp			r7, r8
									beq			end_if_displayTime_01
then_displayTime_01
									strb		r8, [r5, r4]
									mov			r0, r4
									mov			r1, #0
									bl			lcdGotoXY
									mov			r0, r8
									bl			lcdPrintC
end_if_displayTime_01
									add			r4, #1
									b			until_displayTime_01
end_for_displayTime_01				

									pop			{r4, r5, r6, r7, r8, lr}
									blx			lr
									ENDP


;----------------------------------------------|
; Fragt den aktuellen Timer-Wert ab und speichert ihn in der Variable.
; Übergabeparameter:
; 	-
; Rückgabewerte:
; 	-
;----------------------------------|-----------|
checkTimer							PROC
									push		{r4, r5, lr}

									ldr			r4, =TIMER
									ldr			r4, [r4]
									ldr			r5, =PAST_CYCLES
									str			r4, [r5]
									
									pop			{r4, r5, lr}
									blx			lr
									ENDP


;----------------------------------------------|
; Wandelt eine Dezimalzahl in ACII um.
; Übergabeparameter:
; 	r0: Dezimalwert
; Rückgabewerte:
; 	r0: ASCII-Wert der Dezimalzahl
;----------------------------------|-----------|
numberToASCII						PROC

									add			r0, r0, #0x30
									blx			lr

									ENDP


;----------------------------------------------|
; Berechnet die vergangene Zeit und speichert sie in der Variable der aktuellen Zeit.
; Übergabeparameter:
; 	-
; Rückgabewerte:
; 	-
;----------------------------------|-----------|
calculateTime						PROC
									push		{r4, r5, r6, r7, r8, r10, lr}

									ldr			r4, =TIME_UNITS
									ldr			r5, =NEW_TIME
									ldr			r10, =TIME_POSITIONS
									mov			r8, #4
for_calculateTime_01
									mov			r6, #0
until_calculateTime_01
									cmp			r6, #6
									bcs			end_for_calculateTime_01
do_calculateTime_01
									mul			r7, r6, r8
									ldr			r0, [r4, r7]
									bl			calculateTimeUnit
									bl			numberToASCII
									ldrb		r7, [r10, r6]
									strb		r0, [r5, r7]
									add			r6, #1
									b			until_calculateTime_01
end_for_calculateTime_01

									pop			{r4, r5, r6, r7, r8, r10, lr}
									blx			lr
									ENDP


;----------------------------------------------|
; Berechnet wie häufig die angegebene Zeiteinheit in die bishervergangene Zeit passt und zieht diese ab.
; Übergabeparameter:
; 	r0: Zeiteinheit
; Rückgabewerte:
; 	r0: Anzahl der Subtraktionen
;----------------------------------|-----------|
calculateTimeUnit					PROC
									push		{r4, r5, r6, lr}

									mov			r5, r0								
									ldr			r6, =PAST_CYCLES
									ldr			r4, [r6]
									mov			r0, #0
while_calculateTimeUnit_01
									cmp			r4, r5
									blo			end_if_calculateTimeUnit_01
do_calculateTimeUnit_01
									sub			r4, r4, r5
									add			r0, #1
									b			while_calculateTimeUnit_01
end_if_calculateTimeUnit_01
									str			r4, [r6]

									pop			{r4, r5, r6, lr}
									blx			lr
									ENDP



;----------------------------------------------|
; Repräsentiert den Zustand INIT. 
; Übergabeparameter:
; 	r0: Speicheradresse von dem Zustand
;	r1: Wert des Zustands
;	r2: Gedrückter Button
; Rückgabewerte:
; 	-
;----------------------------------|-----------|
stateINIT							PROC
									push		{lr}

									bl			stateSwitchINIT
if_stateINIT_01
									ldr			r0, =INIT_TIME
									bl			isTimeEqual
									cmp			r0, #1
									beq			end_if_stateINIT_01
then_stateINIT_01
									ldr			r0, =INIT_TIME
									ldr			r1, =NEW_TIME
									bl			setTime
									bl			displayTime
end_if_stateINIT_01

									pop			{lr}
									blx			lr
									ENDP


;---------------------------------------------|
; Repräsentiert den Zustand RUNNING. 
; Übergabeparameter:
; 	r0: Speicheradresse von dem Zustand
;	r1: Wert des Zustands
;	r2: Gedrückter Button
; Rückgabewerte:
; 	-
;----------------------------------|-----------|
stateRUNNING						PROC
									push		{lr}

									bl			stateSwitchRUNNING
									bl			checkTimer
									bl			calculateTime
									bl			displayTime

									pop			{lr}
									blx			lr
									ENDP


;---------------------------------------------|
; Repräsentiert den Zustand HOLD. 
; Übergabeparameter:
; 	r0: Speicheradresse von dem Zustand
;	r1: Wert des Zustands
;	r2: Gedrückter Button
; Rückgabewerte:
; 	-
;----------------------------------|-----------|
stateHOLD							PROC
									push		{lr}

									bl			stateSwitchHOLD

									pop			{lr}
									blx			lr
									ENDP


;---------------------------------------------|
; Repräsentiert den Zustandswechsel in INIT. 
; Übergabeparameter:
; 	r0: Speicheradresse von dem Zustand
;	r1: Wert des Zustands
;	r2: Gedrückter Button
; Rückgabewerte:
; 	-
;----------------------------------|-----------|
; r0: Speicheradresse STATE
; r1: Wert STATE
; r2: readButtons
stateSwitchINIT						PROC
									push		{r4, r5, r6, lr}

									mov			r4, #7
if_stateSwitchINIT_01
									cmp			r2, r4
									bne			end_if_stateSwitchINIT_01
then_stateSwitchINIT_01
									strb		r4, [r0]
									ldr			r5, =TIM2_ERG
									mov			r6, #1
									strh		r6, [r5]
									bl			switchLEDsOff
									mov			r0, r2
									bl			switchLEDOn
end_if_stateSwitchINIT_01

									pop			{r4, r5, r6, lr}
									blx			lr
									ENDP


;---------------------------------------------|
; Repräsentiert den Zustandswechsel in RUNNING. 
; Übergabeparameter:
; 	r0: Speicheradresse von dem Zustand
;	r1: Wert des Zustands
;	r2: Gedrückter Button
; Rückgabewerte:
; 	-
;----------------------------------|-----------|
stateSwitchRUNNING					PROC
									push		{r4, r5, r6, lr}

									mov			r4, #5
									mov			r5, #6
									mov			r6, r0
if_stateSwitchRUNNING_01
									cmp			r2, r4
									bne			else_if_stateSwitchRUNNING_01
then_stateSwitchRUNNING_01
									bl			switchLEDsOff
									mov			r0, r2
									bl			switchLEDOn
									strb		r4, [r6]
									b			end_if_stateSwitchRUNNING_01
else_if_stateSwitchRUNNING_01
									cmp			r2, r5
									bne			end_if_stateSwitchRUNNING_01
else_then_stateSwitchRUNNING_01
									bl			switchLEDsOff
									mov			r0, r2
									bl			switchLEDOn
									strb		r5, [r6]
end_if_stateSwitchRUNNING_01

									pop			{r4, r5, r6, lr}
									blx			lr
									ENDP



;---------------------------------------------|
; Repräsentiert den Zustandswechsel in HOLD. 
; Übergabeparameter:
; 	r0: Speicheradresse von dem Zustand
;	r1: Wert des Zustands
;	r2: Gedrückter Button
; Rückgabewerte:
; 	-
;----------------------------------|-----------|
stateSwitchHOLD						PROC
									push		{r4, r5, r6, lr}

									mov			r4, #5
									mov			r5, #7
									mov			r6, r0
if_stateSwitchHOLD_01
									cmp			r2, r4
									bne			else_if_stateSwitchHOLD_01
then_stateSwitchHOLD_01
									bl			switchLEDsOff
									mov			r0, r2
									bl			switchLEDOn
									strb		r4, [r6]
									b			end_if_stateSwitchHOLD_01
else_if_stateSwitchHOLD_01
									cmp			r2, r5
									bne			end_if_stateSwitchHOLD_01
else_then_stateSwitchHOLD_01
									bl			switchLEDsOff
									mov			r0, r2
									bl			switchLEDOn
									strb		r5, [r6]
end_if_stateSwitchHOLD_01

									pop			{r4, r5, r6, lr}
									blx			lr
									ENDP

;--------------------------------------------
; main subroutine
;--------------------------------------------
	EXPORT main [CODE]

main								PROC

									; Initialisierung der HW
									bl 			initHW

									; Initialisierung des Timers
									mov			r0, #0
									mov			r1, #0
									bl			lcdGotoXY
									ldr			r0, =CURRENT_TIME
									bl			lcdPrintS
									B 			superloop


superloop
									bl			readButtons
									mov			r2, r0
									ldr			r0, =STATE
									ldrb		r4, [r0]
									mov			r1, r4
									

if_superloop_01
									cmp			r4, #5
									bne			if_superloop_02
									bl			stateINIT
									b			end_if_superloop

if_superloop_02
									cmp			r4, #7
									bne			if_superloop_03
									bl			stateRUNNING
									b			end_if_superloop
if_superloop_03
									cmp			r4, #6
									bne			end_if_superloop
									bl			stateHOLD
									
end_if_superloop

									BAL			superloop				; End of superloop
									ENDP

									ALIGN
									END

