;************************************************
;* Beginn der globalen Daten *
;************************************************
                   AREA MyData, DATA, align = 2

; --- Register Belegungen ---
; R0    Speicheradresse IndexIstPrimzahl
; R1                    IndexIstPrimzahl
; R2    Speicheradresse IndexPrimzahlen
; R3                    IndexPrimzahlen
; R4    Speicheradresse NaechstesVielfache
; R5                    NaechstesVielfache
; R6    Speicheradresse IstPrimzahl
; R10   Konstante       0b00000001
; R11



; --- Deklaration ---
; Anlegen der Register-Variable IndexIstPrimzahl (= 0x2)
IndexIstPrimzahl        DCW     0x2
; Anlegen der Register-Variable IndexPrimzahlen (= 0x0)
IndexPrimzahlen         DCW     0x0
; Anlegen der Register-Variable NaechstesVielfache (= 0x0)
NaechstesVielfache      DCW     0x0

; Anlegen eines Feld IstPrimzahl
IstPrimzahl             FILL 1000, 0x0

    
; Anlegen eines Feld Primzahlen



;***********************************************
;* Beginn des Programms *
;************************************************
    AREA |.text|, CODE, READONLY, ALIGN = 3

; ----- S t a r t des Hauptprogramms -----
                EXPORT main
                EXTERN initITSboard
main            PROC
                bl    initITSboard                 ; HW Initialisieren

; --- Laden der Variablen ---
	ldr                     r0, =IndexIstPrimzahl
	ldrh                    r1, [r0]
	ldr                     r2, =IndexPrimzahlen
	ldrh                    r3, [r2]
	ldr                     r4, =NaechstesVielfache
	ldrh                    r5, [r4]
	ldr                     r6, =IstPrimzahl



; --- Aendern der Vorbelegung ---
; Speichern von 0b00000001 an IstPrimzahl
	mov                     r10, #1
	strb                    r10, [r6]
; Speichern von 0b00000001 an IstPrimzahl + 1
	strb                    r10, [r6, #1]



; --- Sieb des Eratosthenes ---

while_01
; Bedingung: IndexIstPrimzahl < 32
	cmp                     r1, #32
; bcc                     do_01
; b                       end_while_01
	bcs                     end_while_01

do_01

if_02
; Bedingung: Inhalt an Speicheradresse IstPrimzahl + IndexIstPrimzahl == 0b00000001
	ldrb                    r11, [r6, r1]
	cmp                     r10, r11
; beq                     then_02
; b                       end_if_02
	beq                     end_if_02
	
then_02
	
; Speichere Wert NaechstesVielfache = IndexIstPrimzahl * IndexIstPrimzahl
	mul                     r5, r1, r1

while_03
; Bedingung: NaechstesVielfache < 1000
	cmp                     r5, #1000
	bcs                     end_while_03

do_03
; Speichere an Speicheradresse IstPrimzahl + NaechstesVielfache = 0b00000001
	strb                    r10, [r6, r5]
; Erhöhe NaechstesVielfache = NaechstesVielfache + IndexIstPrimzahl
	add                     r5, r1
; Springe zu while_03
	b                       while_03

end_while_03
end_if_02
; Erhöhe IndexIstPrimzahl um 1
	add                     r1, #1
; Springe zu while_01
	b                       while_01

end_while_01




; --- Speichern der Primzahlen ---

; Setze IndexIstPrimzahl = 0x2

; while_04
; Bedingung: IndexIstPrimzahl <= 1000

; do_04

; if_05
; Bedingung: Inhalt an Speicheradresse IstPrimzahl + IndexIstPrimzahl == 0b00000000

; then_05
; Speichere an Primzahlen + IndexPrimzahlen = IndexIstPrimzahl
; Erhöhe IndexIstPrimzahl = IndexIstPrimzahl + 1
; Erhöhe IndexPrimzahlen = IndexPrimzahlen + 2
; Springe zu while_04

; end_if_05
; Erhöhe IndexIstPrimzahl = IndexIstPrimzahl + 1
; Springe zu while_04

; end_while_04


forever         b   forever                         ; Anw-26
                ENDP
                END