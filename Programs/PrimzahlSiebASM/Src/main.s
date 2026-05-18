; --- Deklaration ---
; Anlegen eines Feld IstPrimzahl
; Anlegen eines Feld Primzahlen

; Anlegen der Register-Variable IndexIstPrimzahl (= 0x2)
; Anlegen der Register-Variable IndexPrimzahlen (= 0x0)
; Anlegen der Register-Variable NaechstesVielfache (= 0x0)


; --- Aendern der Vorbelegung ---
; Speichern von 0b00000001 an IstPrimzahl
; Speichern von 0b00000001 an IstPrimzahl + 1



; --- Sieb des Eratosthenes ---

while_01
; Bedingung: IndexIstPrimzahl < 32

do_01

if_02
; Bedingung: Inhalt an Speicheradresse IstPrimzahl + IndexIstPrimzahl == 0b00000001
	
then_02
; Erhöhe IndexIstPrimzahl um 1
; Springe zu while_01
	
end_if_02
; Speichere Wert NaechstesVielfaches = IndexIstPrimzahl * IndexIstPrimzahl

while_03
; Bedingung: NaechstesVielfaches < 1000

do_03
; Speichere an Speicheradresse IstPrimzahl + NaechstesVielfaches = 0b00000001
; Erhöhe NaechstesVielfaches = NaechstesVielfaches + IndexIstPrimzahl
; Springe zu while_03

end_while_03
; Erhöhe IndexIstPrimzahl um 1
; Springe zu while_01

end_while_01




; --- Speichern der Primzahlen ---

; Setze IndexIstPrimzahl = 0x2

while_04
; Bedingung: IndexIstPrimzahl <= 1000

do_04

if_05
; Bedingung: Inhalt an Speicheradresse IstPrimzahl + IndexIstPrimzahl == 0b00000000

then_05
; Speichere an Primzahlen + IndexPrimzahlen = IndexIstPrimzahl
; Erhöhe IndexIstPrimzahl = IndexIstPrimzahl + 1
; Erhöhe IndexPrimzahlen = IndexPrimzahlen + 2
; Springe zu while_04

end_if_05
; Erhöhe IndexIstPrimzahl = IndexIstPrimzahl + 1
; Springe zu while_04

end_while_04