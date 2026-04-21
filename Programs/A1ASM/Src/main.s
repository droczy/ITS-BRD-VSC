;******************** (C) COPYRIGHT HAW-Hamburg ********************************
;* File Name          : main.s
;* Author             : Martin Becke
;* Version            : V1.0
;* Date               : 01.06.2021
;* Description        : This is a simple main to setup three LEDs
;                     :
;                     :
;
;*******************************************************************************
    EXTERN initITSboard ; Helper to organize the setup of the board

    EXPORT main         ; we need this for the linker
                        ;- In this context it set the entry point,too

; setup the peripherie - Mapping the GPIO
PERIPH_BASE         equ 0x40000000                      ;                           0x40000000
AHB1PERIPH_BASE     equ (PERIPH_BASE + 0x00020000)      ; 0x40000000 + 0x00020000 = 0x40020000
GPIOD_BASE          equ (AHB1PERIPH_BASE + 0x0C00)      ; 0x40020000 + 0x0C00     = 0x40020C00
    
GPIO_D_SET          equ (GPIOD_BASE + 0x18)             ; 0x40020C00 + 0x18       = 0x40020C18
GPIO_D_CLR          equ (GPIOD_BASE + 0x1A)             ; 0x40020C00 + 0x1A       = 0x40020C1A
    

;* We need minimal memory setup of InRootSection placed in Code Section
    AREA  |.text|, CODE, READONLY, ALIGN = 3
    ALIGN
main
    BL initITSboard             ; needed by the board to setup
    ; nop                         ; no operation
    LDR     R6, =GPIO_D_SET     ; get address of the GPIO data set register
    LDR     R7, =GPIO_D_CLR     ; get address of the GPIO data clear register
    ; MOV     R0, #0x01           ; load mask 0b00000001
    ; MOV     R1, #0x02           ; load mask 0b00000010
    ; MOV     R2, #0x40           ; load mask 0b01000000
    ; MOV     R3, #0x80           ; load mask 0b10000000
	; MOV     R4, #0xC3           ; load mask 0b11000011
	MOV      R8, #0xFF           ; load mask 0b11111111
	; MOV     R5, #0xFFFF         ; lead mask 0b1111111111111111

    ; Set LED
    ; STRB    R2, [R6]    ; switch on LED D14
    ; STRB    R3, [R6]    ; switch on LED D15
    ; STRB    R0, [R6]    ; switch on LED D08
    ; STRB    R0, [R7]    ; switch off LED D08
    ; STRB    R0, [R6]    ; switch on LED D08
    ; STRB    R1, [R6]    ; switch on LED D09
    ; STRB    R2, [R7]    ; switch off LED D14
    ; STRB    R3, [R7]    ; switch off LED D15

	; Switch on LED D08, D09, D14, D15 with masks R0, R1, R2, R3
	; STRB    R0, [R6]    ; switch on LED D08
	; STRB    R1, [R6]    ; switch on LED D09
	; STRB    R2, [R6]    ; switch on LED D14
	; STRB    R3, [R6]    ; switch on LED D15

	; Switch on LED D8, D9, D14, D15 with mask R4
	; STRB    R4, [R6]    ; switch on LEDs
	
	; Switch on all LED with mask R5
	; STRH    R5, [R6]    ; switch on LEDs

	; Switch on first 8 LED with mask R8
	STRB    R8, [R6]    ; switch on LEDs

    b .
    
    ALIGN
    END
