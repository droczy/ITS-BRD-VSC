# Aufgaben

## Code-Anweisungen

**Beschreiben Sie in der Datei `Programs/A2/README.md` für jede Zeile den Effekt auf die Register `R0`, `R2` und `R3` und den Speicher (Memory) ab der Adresse der Variable `VariableA`.**


### Code-Abschnitt
```asm
ldr    R0,=VariableA     ; Anw01
ldrb   R2,[R0]           ; Anw02
ldrb   R3,[R0,#1]        ; Anw03
lsl    R2, #8            ; Anw04
orr    R2, R3            ; Anw05
strh   R2,[R0]           ; Anw06
```


### Anweisung 01
```
ldr R0,=VariableA ; Anw01
```
Die Speicher-Referenz von `VariableA` wird in `R0` gespeichert.


### Anweisung 02
```
ldrb R2,[R0] ; Anw02
```
Das Least-Significant-Byte, des Inhalts, welcher an der Speicheradresse `R0`  steht, wird in `R2` gespeichert (`0xef`).


### Anweisung 03
```
ldrb R3,[R0,#1] ; Anw03
```
Das zweite Byte, des Inhalts, welcher an der Speicheradresse `R0`  steht, wird in `R2` gespeichert (`0xbe`). `#1` gibt die Anzahl der Verschiebungen um die Größe der Lade-Operation an.


### Anweisung 04
```
lsl R2, #8 ; Anw04
```
Eine Left-Shift-Operation wird durchgeführt. Es werden alle Bits um `#8` Stellen nach links verschoben. Liegt das Zielbit außerhalb der Speichergröße, beginnt die Verschiebung wieder beim least significant bit. Das Ergebnis bleibt in `R2`.
Es gilt also: Zielposition = (Position + Verschiebung) % Speichergröße
`0x 0000 0000 0000 00ef` $\rightarrow$ `0x 0000 0000 0000 ef00`


### Anweisung 05
```asm
orr R2, R3 ; Anw05
```
Eine `XOR` Operation zwischen den beiden angegebenen Registern `R2` und `R3`, von welcher das Ergebnis in `R2` gespeichert wird.
```
0xEF00            = 0b1110 1111 0000 0000
0x00BE            = 0b0000 0000 1011 1110
0xEF00 XOR 0x00BE = 0b1110 1111 1011 1110 = 0xEFBE
```
Damit werden die Register `R2`und `R3`in `R2`zusammengeführt.


### Anweisung 06
```
strh R2,[R0] ; Anw06
```
Speichert das Least-Significant Halbwort in `R2`, an der Speicheradresse, welche in `R0` angegeben ist. ARM verwendet Little-Endian, im Speicher steht hintereinander `0xbeef`.