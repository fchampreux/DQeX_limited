# SIS Portal Help

Glossary describing the concepts used in statistical metadata management.

## Concepts

### Pluri-Annual Program

* Statistical theme     
* Information domain
* Statistical activity

Describe the structure of the FSO's activities as planned in the multi-annual programme

### Defined variables

The information domain is responsible for the defined variables, organized according to :

* Collections - containers for organizing the variables.		
* Defined variables - the concepts that serve as a model for the variables being used.
* Codes-lists - associated with a single variable, they define the only possible values.

### Used Variables

The hierarchy within the statistical activities describes their implementation according to :

* Statistical instances - iteration of the activity
* Data Structures - Description of a Data Set (DSD)
* Used variables - local implementation of defined variables

The used variables are copies of defined variables, of which some characteristics can be specified: technical name, role, confidentiality ...

## Defining variables

### Defined variables

| Field                   | Description                                                                                     |
|-------------------------|------------------------------------------------------------------------------------------------------|
| Short name | Unique name within a collection, for all languages |
| Name | Understandable name, translated into several languages |
| Description | Detailed description, translated into several languages |
| Organization | Organizational unit responsible for information |
| Responsible person | Person in charge
| Deputy | Alternate person in charge |
| Role | Role of the data in an analysis: measurement, analysis dimension, identification key, or attribute |
| Hierarchical code-list | Indicates that the list code (if any) is hierarchical.
| Type | Data type: characters, numeric, date |
| Length | Space required to store character type data |
| Accuracy | Number of decimal places of a numeric type data |
| Minimum | Minimum possible value |
| Maximum | Maximum possible value |

<br/>

### Used variables

| Field | Description |
|-------------------------|------------------------------------------------------------------------------------------------------|
| Technical name | Unique name corresponding to the name of the column in the data file or table |
| Name | Understandable name, translated into several languages |
| Description | Detailed description, translated into several languages |
| External description | Detailed description, translated into several languages, accompanying broadcast variables |
| Organization | Organizational unit responsible for information |
| Responsible person | Person in charge
| Deputy | Alternate person in charge |
| Role | Role of the data in an analysis: measurement, analysis dimension, identification key, or attribute |
| Hierarchical code-list | Indicates that the list code (if any) is hierarchical.
| Type | Data type: characters, numeric, date |
| Length | Space required to store character type data |
| Accuracy | Number of decimal places of a numeric type data |
| Minimum | Minimum possible value |
| Maximum | Maximum possible value |
| Null allowed | Value is not required |
| Unit of measurement | Unit of the measured death (m, km, kg etc.) |
| Privacy | Sensitive data requires encryption |
| Primary key | Unique identifier |
| Foreign key | Business identifier that can be used for matching |

<br/>

## Other concepts

* OGD: Open Governmental Data
* Period: Reference period of the instance
* Participants : Organizations participating in the activity
