# SIS-Portal-Hilfe

Lexikon zur Beschreibung der Konzepte, die bei der Verwaltung statistischer Metadaten verwendet werden.

## Konzepte

### Mehrjahresprogramm

* Themenfeld    
* Informationsfeld
* Statistische Aktivität

Beschreiben Sie die Struktur der Aktivitäten des BFS wie im Mehrjahresprogramm geplant

### Definierte Variablen

Die Informationsfeld ist für die definierten Variablen verantwortlich, die nach :

* Sammlungen - Behälter für die Organisation der Variablen.		
* Definierte Variablen - die Konzepte, die als Modell für die verwendeten Variablen dienen.
* Codelisten - verbunden mit einer einzelnen Variable, definieren sie die einzig möglichen Werte.

### Verwendete Variablen

Die Hierarchie innerhalb der statistischen Aktivitäten beschreibt deren Umsetzung nach :

* Statistische Instanzen - Iteration der Aktivität
* Datenstrukturen - Beschreibung eines Datensatzes (DSD)
* Verwendete Variablen - lokale Implementierung von definierten Variablen

Die verwendeten Variablen sind Kopien von definierten Variablen, von denen einige Merkmale spezifiziert werden können: technischer Name, Rolle, Vertraulichkeit ...

## Definierende Variablen

### Definierte Variablen

| Feld | Beschreibung |
|-------------------------|------------------------------------------------------------------------------------------------------|
| Kurzname | Eindeutiger Name innerhalb einer Sammlung, für alle Sprachen |
| Name | Verständlicher Name, übersetzt in mehrere Sprachen |
| Beschreibung | Detaillierte Beschreibung, übersetzt in mehrere Sprachen |
| Organisation | Für Informationen zuständige Organisationseinheit |
| Verantwortliche Person | Verantwortliche Person
| Stellvertreter | Stellvertretende verantwortliche Person |
| Rolle | Rolle der Daten in einer Analyse: Messung, Analysedimension, Identifikationsschlüssel oder Attribut |
| Hierarchische Codeliste | Zeigt an, dass der Listencode (falls vorhanden) hierarchisch ist.
| Typ | Datentyp: Zeichen, numerisch, Datum |
| Länge | Zum Speichern von zeichenartigen Daten benötigter Platz |
| Genauigkeit | Anzahl der Dezimalstellen eines numerischen Datentyps |
| Minimal | Minimal möglicher Wert |
| Maximal | Maximal möglicher Wert |

<br/>

### Verwendete Variablen

| Feld | Beschreibung |
|-------------------------|------------------------------------------------------------------------------------------------------|
| Technischer Name | Eindeutiger Name, der dem Namen der Spalte in der Datendatei oder Tabelle entspricht |
| Name | Verständlicher Name, übersetzt in mehrere Sprachen |
| Beschreibung | Detaillierte Beschreibung, übersetzt in mehrere Sprachen |
| Externe Beschreibung | Detaillierte Beschreibung, übersetzt in mehrere Sprachen, begleitende Sendevariablen |
| Organisation | Für Informationen zuständige Organisationseinheit |
| Verantwortliche Person | Verantwortliche Person
| Stellvertreter | Stellvertretende verantwortliche Person |
| Rolle | Rolle der Daten in einer Analyse: Messung, Analysedimension, Identifikationsschlüssel oder Attribut |
| Hierarchische Codeliste | Zeigt an, dass der Listencode (falls vorhanden) hierarchisch ist.
| Typ | Datentyp: Zeichen, numerisch, Datum |
| Länge | Zum Speichern von zeichenartigen Daten benötigter Platz |
| Genauigkeit | Anzahl der Dezimalstellen eines numerischen Datentyps |
| Minimal | Minimal möglicher Wert |
| Maximal | Maximal möglicher Wert |
| Null erlaubt | Wert ist nicht erforderlich |
| Maßeinheit | Einheit des gemessenen Todes (m, km, kg usw.) |
| Datenschutz | Sensible Daten erfordern Verschlüsselung |
| Primärschlüssel | Eindeutiger Bezeichner |
| Fremdschlüssel | Geschäftsidentifikator, der für den Abgleich verwendet werden kann |

<br/>

## Andere Konzepte

* OGD: Offene Regierungsdaten
* Zeitraum: Bezugszeitraum der Instanz
* Teilnehmer : An der Aktivität teilnehmende Organisationen
