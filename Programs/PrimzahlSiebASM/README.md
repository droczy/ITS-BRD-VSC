# Konzept - Sieb des Eratosthenes

## Pseudocode (Python)

```python
from math import sqrt


def sieve_of_eratosthenes(end: int) -> list:
	
    is_prime = []
    for i in range(0, end + 1): is_prime.append(True)
    
    is_prime[0] = False
    is_prime[1] = False
    
    index_sieve = 2
	
	# --- Sieb des Eratosthenes ---
    while index_sieve <= sqrt(end):
        if not is_prime[index_sieve]:
            index_sieve += 1
            continue
            
        next_multiple = index_sieve * index_sieve
        
        for i in range(next_multiple, end + 1, index_sieve):
            is_prime[i] = False
        
        index_sieve += 1
        
    return is_prime
  
  
def write_numbers(numbers: list) -> list:
	
    prime_numbers = []
	
	# --- Speichern der Primzahlen ---
    for i in range(0, len(numbers)):
        if numbers[i]:
            prime_numbers.append(i)
	
    return prime_numbers  
  
  
if __name__ == "__main__":
    sieve = sieve_of_eratosthenes(1000)
    prime = write_numbers(sieve)
    print(prime)

```

---
## Struktogramm

Die Struktogramme für den Assembler-Code sind in dem Ordner `./struktogramme` abgelegt.

`sieb_des_eratosthenes_bausteine`
Dies zeigt die einzelnen Bausteine (Schleifen und Bedingungen), welche für den Algorithmus für das Sieb des Eratosthenes gebraucht werden.

`sieb_des_eratosthenes_gesamt`
Dies zeigt die als Algorithmus zusammengesetzten Bausteine, welche das Sieb des Eratosthenes ergeben.

`speichern_der_primzahlen_bausteine
Dies zeigt die einzelnen Bausteine, welche für das Abspeichern der wirklichen Primzahlen gebraucht werden.

`speichern_der_primzahlen_gesamt`
Dies zeigt die zusammengesetzten Bausteine, welche den Algorithmus für das Abspeichern ergeben.

---

## Assembler-Programm-Konzept

Hier sind einmal die begründeten begründeten Kommentare der Assembler-Skizze beschrieben.

### Deklaration
In diesem Abschnitt erfolgen für den gesamten Code die Zuweisungen.

```
; Anlegen eines Feld IstPrimzahl
```
Da im ersten Schritt nur bestimmt werden soll, ob es sich bei einer Zahl um eine Primzahl handelt, muss Speicher reserviert werden, wo wir diese Information speichern können.
Wir müssen uns als Speichergröße zwischen Byte, Halbwort und Wort entscheiden. Da wir nur zwei Zustände haben, würde uns eigentlich pro Zahl ein Bit reichen. Wir entscheiden uns also für die kleinste Einheit, Byte.
Die 1000 ist keine Primzahl, da sie neben sich selber und der 1, auch noch durch z.b. 10 teilbar ist. Um Klarheit zu behalten steht bei uns der Index 0 für die 0. Wir müssen dafür 1000 Bytes reservieren.
Wir wollen 0b00000000 und 0b00000001 als Markierung verwenden, ob es sich bei einer Zahl um eine Primzahl handelt oder nicht.
Beim Sieb des Eratosthenes werden standardmäßig alle Zahlen als Primzahlen angesehen. Durch das Errechnen der Vielfachen wird gezeigt, dass es sich bei einer Zahl nicht um eine Primzahl handelt, weshalb sie dann herausgestrichen wird.
Mit dem Reservieren des Feldes, ist die Standardbelegung der Bytes allerdings 0b00000000. Um den Aufwand zu vermeiden, in jedes Feld 0b00000001 zu schreiben, tauschen wir die Belegung. 0b0000000 steht also bei uns für `True`, 0b00000001 steht für `false`.


```
; Anlegen eines Feld Primzahlen
```
Hier sollen nun die wirklichen Primzahlen gespeichert werden. Also der Index der Bytes aus dem Feld `IstPrimzahl`, wenn dort der Inhalt gleich `0b00000000`ist.
In diesem Feld sollen die wirklichen Primzahlen gespeichert werden. Also alle Byte-Indizes des Feldes Sieb, welche `0b00000001` enthalten sollen hier abgelegt werden.
Pro Element müssen wir eine Zahl von 0 bis 999 darstellen können. Mit einem Byte ist es nur möglich maximal 255 darzustellen. Deshalb müssen wir hier als Größe ein Halbwort pro Zahl verwenden, da es damit möglich ist Zahlen bis 65535 darzustellen.
Uns ist die Anzahl der Primzahlen zwischen 0 und 999 unbekannt. Wir stehen daher auf der sicheren Seite 1000 Halbwörter also 2000 Bytes zu reservieren.

```
; Anlegen der Register-Variable IndexIstPrimzahl
```
Dieser Wert muss in einem Register abgelegt werden, er repräsentiert die Zahl bzw. den Index mit welchem wir bei dem Sieb anfangen. Damit ist `IndexIstPrimzahl = 0x2`.

```
; Anlegen der Register-Variable IndexPrimzahlen (= 0x0)
```
Dieser Wert muss in einem Register abgelegt werden, er repräsentiert den Index an welchen in das Feld `Primzahlen`geschrieben wird. Damit ist `IndexPrimzahlen = 0x0`.

```
; Anlegen der Register-Variable NaechstesVielfache (= 0x0)
```
Dieser Wert muss in einem Register abgelegt werden, er repräsentiert das nächste Vielfache das aktuell betrachteten Index. Da dieses im Verlaufe des Algorithmus berechnet wird, wird am Anfang `NaechstesVielfache = 0x0`gesetzt.


### Aendern der Vorbelegung
```
; Speichern von 0b00000001 an IstPrimzahl
; Speichern von 0b00000001 an IstPrimzahl + 1
```
In diesem Abschnitt werden die Vorbelegungen für die Zahlen 0 und 1 auf `0b00000001` geändert. Unser Algorithmus startet erst bei 2, würde also diese Zahlen übergehen. Die Standart-Belegung ist für diese `0b00000000`, das würde aber bedeuten, dass diese Primzahlen sind, da sie es aber per Definition nicht sind, muss die Belegung geändert werden.


### Sieb des Eratosthenes

Dieser gesamte Abschnitt umfasst den gesamten Algorithmus für das Sieb des Eratosthenes.

```
while_01
; Bedingung: IndexIstPrimzahl < 32
```
Da das Herausstreichen der Vielfachen beim Quadrat dieser beginnen kann, reicht es zu gucken, ob der aktuelle Index kleiner ist, als die Wurzel unserer Oberen Grenze 1000, was gerundet 32 ergibt. Ist die Zahl größer gleich 32 muss das Sieb nicht weiter gemacht werden.

```
do_01

if_02
; Bedingung: Inhalt an Speicheradresse IstPrimzahl + IndexIstPrimzahl == 0b00000001
	
then_02
; Erhöhe IndexIstPrimzahl um 1
; Springe zu while_01
```
Nun kann erst einmal überprüft werden, ob die aktuell betrachtete Zahl bereits gestrichen wurde, ist dies der Fall, wurden auch schon alle Vielfachen dieser Zahl gestrichen. Es kann also zur nächsten Zahl gegangen werden und zum Schleifen-Anfang gesprungen werden.

```
end_if_02
; Speichere Wert NaechstesVielfaches = IndexIstPrimzahl * IndexIstPrimzahl
```
Falls die Zahl noch nicht gestrichen wurde, kann nun das erste Vielfache dieser Zahl berechnet werde, da wir auch Wissen, dass dieses innerhalb unserer Grenze liegt.

```
while_03
; Bedingung: NaechstesVielfaches < 1000

do_03
; Speichere an Speicheradresse IstPrimzahl + NaechstesVielfaches = 0b00000001
; Erhöhe NaechstesVielfaches = NaechstesVielfaches + IndexIstPrimzahl
; Springe zu while_03
```
Nun können die Vielfachen dieser Zahl wirklich weggestrichen werden. Wir führen die Schleife solange aus, wie das Vielfache kleiner als 1000 ist.
Für jedes Vielfache Streichen wir dieses aus unserem Feld `IstPrimzahl`, berechnen das nächste Vielfache und prüfen für dieses die Bedingung erneut, indem wir zum Anfang der Schleife springen.

```
end_while_03
; Erhöhe IndexIstPrimzahl um 1
; Springe zu while_01
```
Wenn wir alle existierenden Vielfachen der Zahl gestrichen haben, können wir zur nächsten Zahl gehen und den gesamten Vorgang erneut durchführen.


### Speichern der Primzahlen

```
; Setze IndexIstPrimzahl = 0x2
```
Da wir erneut das Feld `IstPrimzahl` durchgehen müssen, setzen wir den Index zurück auf den Startwert unseres Siebs.

```
while_04
; Bedingung: IndexIstPrimzahl < 1000
```
Unsere Bedingung ist, dass wir uns noch innerhalb des Definierten Feldes befinden.

```
do_04

if_05
; Bedingung: Inhalt an Speicheradresse IstPrimzahl + IndexIstPrimzahl == 0b00000000
```
Da wir uns noch im Feld befinden, müssen wir nun überprüfen, ob es sich bei dem Index bzw. der Zahl von `IstPrimzahl`, um eine Primzahl handelt

```
then_05
; Speichere an Primzahlen + IndexPrimzahlen = IndexIstPrimzahl
; Erhöhe IndexIstPrimzahl = IndexIstPrimzahl + 1
; Erhöhe IndexPrimzahlen = IndexPrimzahlen + 2
; Springe zu while_04
```
Ist die betrachtete Zahl eine Primzahl, schreiben wir die Primzahl (also den Index `IndexIstPrimzahl`) an die nächste freie Stelle in unserem Feld `Primzahlen`. Wir erhöhen dann den Index, betrachten also die nächste Zahl, erhöhen auch den Index in unserem Feld `Primzahl`um Zugriff auf das nächste Freie Halbwort zu haben.

```
end_if_05
; Erhöhe IndexIstPrimzahl = IndexIstPrimzahl + 1
; Springe zu while_04
```
Ist die betrachtete Zahl keine Primzahl, erhöhen wir den Index von `IstPrimzahl` und springen wieder zum Schleifenanfang um die nächste Zahl zu untersuchen.