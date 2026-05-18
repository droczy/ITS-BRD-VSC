;************************************************
;* Beginn der globalen Daten *
;************************************************
                   AREA MyData, DATA, align = 2
Base
VariableA          DCW 0x1234
VariableB          DCW 0x4711

VariableC          DCD  0

MeinHalbwortFeld   DCW 0x22 , 0x3e , -52, 78 , 0x27 , 0x45

MeinWortFeld       DCD 0x12345678 , 0x9dca5986
                   DCD -872415232 , 1308622848
                   DCD 0x27000000
                   DCD 0x45000000


                   EXPORT VariableA
                   EXPORT VariableB
                   EXPORT VariableC
                   EXPORT MeinHalbwortFeld
                   EXPORT MeinWortFeld
                   EXPORT MeinTextFeld

;***********************************************
;* Beginn des Programms *
;************************************************
    AREA |.text|, CODE, READONLY, ALIGN = 3
; ----- S t a r t des Hauptprogramms -----
                EXPORT main
                EXTERN initITSboard
main            PROC
                bl    initITSboard                 ; HW Initialisieren

; Laden von Konstanten in Register
				; Schreibe 0x12 in das Register R0
                mov   r0,#0x12                      ; Anw-01
				; Schreibe 128 im zweier Komplement in das Register R1
                mov   r1,#-128                      ; Anw-02
				; Schreibe 0x12345678 in das Register R2
                ldr   r2,=0x12345678                ; Anw-03

; Zugriff auf Variable
				; Schreibe die Speicheradresse von VariableA in das Register R0
                ldr   r0,=VariableA                 ; Anw-04
				; Schreibe das Halbwort von der Speicheradresse R0 in R1
                ldrh  r1,[r0]                       ; Anw-05
				; Schreibe das Wort von der Speicheradresse R0 in R2
                ldr   r2,[r0]                       ; Anw-0
				; Schreibe das Wort R2 an die Speicheradresse von R0 + (VariableC-VariableA * Bytes)
                str   r2,[r0,#VariableC-VariableA]  ; Anw-07

; Zugriff auf Felder (Speicherzellen)
				; Schreibe die Speicheradresse des Feldes MeinHalbwortFeld in R0
                ldr   r0,=MeinHalbwortFeld          ; Anw-08
				; Schreibe das Halbwort von der Speicheradresse R0 in R1
                ldrh  r1,[r0]                       ; Anw-09
				; Schreibe das Halbwort von der Speicheradresse R0 + 2 Bytes in R2
                ldrh  r2,[r0,#2]                    ; Anw-10
				; Schreibe 10 in R0
                mov   r3,#10                        ; Anw-11
				; Schreibe das Halbwort von der Speicheradresse R0 + (R3 * Bytes) in R4
                ldrh  r4,[r0,r3]                    ; Anw-12

				; Schreibe das Halbwort von der Speicheradresse R0 + 2 Bytes in R5 und erhöhe R0 um 2 Bytes
                ldrh  r5,[r0,#2]!                   ; Anw-13
				; Schreibe das Halbwort von der Speicheradresse R0 + 2 Bytes in R6 und erhöhe R0 um 2 Bytes	
                ldrh  r6,[r0,#2]!                   ; Anw-14
				; Schreibe das Halbwort aus R6 an der Speicheradresse R0 + 2 Bytes und erhöhe R0 um 2 Bytes
                strh  r6,[r0,#2]!                   ; Anw-15

; Addition und Subtraktion von unsigned / signed Integer-Werten
				; Schreine die Speicheradresse des Feldes MeinWortFeld in R0
                ldr  r0,=MeinWortFeld               ; Anw-16
				; Schreine das Wort von der Speicheradresse R0 in R1
                ldr  r1,[r0]                        ; Anw-17
				; Schreibe das Wort von der Speicheradresse R0 + 4 Bytes in R2
                ldr  r2,[r0,#4]                     ; Anw-18
				; Addiere die Werte aus R0 und R1 und schreibe das Ergebnis in R3
                adds r3,r1,r2                       ; Anw-19

				; Schreibe das Wort von der Speicheradresse R0 + 8 Bytes in R4
                ldr  r4,[r0,#8]                     ; Anw-20
				; Schreibe das Word von der Speicheradresse R0 + 12 Bytes in R5
                ldr  r5,[r0,#12]                    ; Anw-21
				; Addiere R4 mit dem Zweierkomplement von R5 und schreibe das Ergebnis in R6
                subs r6,r4,r5                       ; Anw-22

				; Schreibe das Wort von der Speicheradresse R0 + 16 Byte in R7
                ldr  r7,[r0,#16]                    ; Anw-23
				; Schreibe das Wort von der Speicheradresse R0 + 20 Byte in R8
                ldr  r8,[r0,#20]                    ; Anw-24
				; Addiere R7 mit dem Zweierkomplement von R8 und schreibe das Ergebnis in R9
                subs r9,r7,r8                       ; Anw-25

				; Beendet das Programm?
forever         b   forever                         ; Anw-26
                ENDP
                END