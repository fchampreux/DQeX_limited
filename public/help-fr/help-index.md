# Aide SIS Portal

Lexique décrivant les concepts utilisés dans la gestion des métadonnées statistiques.

## Concepts

### Programme Pluri-Annuel

* Thème statistique     
* Domaine d'information
* Activité statistique

Décrivent la structure des activités de l'OFS tel que plannifiées dans le programme pluri-annuel

### Variables définies

Le domaine d’information est responsable des variables définies, organisées selon :

* Les collections – des containers permettant d’organiser les variables		
* Les variables définies – les concepts servant de modèle aux variables utilisées
* Les codes-listes – associées à une variable unique, elles en définissent les seules valeurs possibles.

### Variables utilisées

La hiérarchie au sein des activités statistiques décrit leur implémentation selon :

* Les instances statistiques – itération de l’activité
* Les structures de données – description d’un jeu de données (DSD)
* Les variables utilisées – implémentation locale de variables définies

Les variables utilisées sont des copies de variables définies, dont certaines caractéristiques peuvent être précisées : le nom technique, le rôle, la confidentialité …

## Définition des variables

### Variables définies

| Champ                   | Description                                                                                          |
|-------------------------|------------------------------------------------------------------------------------------------------|
| Nom court               | Nom unique au sein d'une collection, pour toutes les langues                                         |
| Nom                     | Nom compréhensible, traduit en plusieurs langues                                                     |
| Description             | Description détaillée, traduit en plusieurs langues                                                  |
| Organisation            | Unité organistionnelle responsable de l'information                                                  |
| Responsable             | Personne responsable de l'information                                                                |
| Suppléant               | Suppléant du responsable de l'information                                                            |
| Rôle                    | Rôle de la donnée dans une analyse : mesure, dimension d'analyse, clef d'identification, ou attribut |
| Code-list hiérarchique  | Indique que la code-liste (éventuelle) est hiérarchique                                              |
| Type                    | Type de données : caractères, numérique, date                                                        |
| Longueur                | Espace nécessaire au stockage des données de type caractère                                          |
| Précision               | Nombre de décimales d'une données de type numérique                                                  |
| Minimum                 | Valeur minimale possible                                                                             |
| Maximum                 | Valeur maximale possible                                                                             |

<br/>

### Variables utilisées

| Champ                   | Description                                                                                          |
|-------------------------|------------------------------------------------------------------------------------------------------|
| Nom technique           | Nom unique correspondant au nom de la colonne dans le fichier ou la table de données                 |
| Nom                     | Nom compréhensible, traduit en plusieurs langues                                                     |
| Description             | Description détaillée, traduit en plusieurs langues                                                  |
| Description externe     | Description détaillée, traduit en plusieurs langues, accompagnant des variables diffusées            |
| Organisation            | Unité organistionnelle responsable de l'information                                                  |
| Responsable             | Personne responsable de l'information                                                                |
| Suppléant               | Suppléant du responsable de l'information                                                            |
| Rôle                    | Rôle de la donnée dans une analyse : mesure, dimension d'analyse, clef d'identification, ou attribut |
| Code-list hiérarchique  | Indique que la code-liste (éventuelle) est hiérarchique                                              |
| Type                    | Type de données : caractères, numérique, date                                                        |
| Longueur                | Espace nécessaire au stockage des données de type caractère                                          |
| Précision               | Nombre de décimales d'une données de type numérique                                                  |
| Minimum                 | Valeur minimale possible                                                                             |
| Maximum                 | Valeur maximale possible                                                                             |
| Null autorisé           | La valeur n'est pas obligatoire                                                                      |
| Unité de mesure         | Unité de la meeure relevée (m, km, kg etc.)                                                          |
| Confidentialité         | Une données sensible requiert un chiffrement                                                         |
| Clef primaire           | Identifiant unique                                                                                   |
| Clef étrangère          | Identifiant métier utilisable pour l'appariement                                                     |

<br/>

## Autres concepts

* OGD : Open Governmental Data
* Période : Période de référence de l'instances
* Participants : Organisations participant à l'activités
