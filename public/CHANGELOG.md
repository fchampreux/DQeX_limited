# Changelog
All notable changes to this project will be documented in this file. Details on upgrading are available [here](help/Release_notes).  

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

### Changes structure
* Version based on **Semantic Versioning**
* Release date in **yyyy-mm-dd** format
* **Changed** for changes in existing functionality
* **Deprecated** for once-stable features removed in upcoming releases
* **Removed** for deprecated features removed in this release
* **Fixed** for any bug fixes
* **Security** to invite users to upgrade in case of vulnerabilities

### Contributors
* Tests, translations, API - Laurent Kowalsky
* User eXperience, CSS, JavaScript - Pedro André da Silva Basilio
* Architecture and Rails development - Frédéric Champreux

## [Unreleased]
* **Changed**   Notifications visibility by tagged user icon when unread notifications are pending
* **Changed**   Variables interactive indexes (12084)

## [1.2.4] -
*  **Changed**  Business Process parameters are not propagated anymore to its children at update.
*  **Added**    Input and Output contracts are exchanged with the remote server to send and receive parameters
*  **Added**    Extra parameters can be extracted from the contract output
*  **Added**    Message trigger mode captures the message id

## [1.2.3] - 2022-04-11
*  **Changed**    GUI refactoring for production events
*  **Changed**    GUI refactoring for execution history
*  **Changed**    GUI refactoring for parameters management
*  **Changed**    Automated creation of Start and End steps for flows and subprocesses
*  **Changed**    Finalised instance creation and execution
*  **Changed**    Finalised schedule creation with parameters edition
*  **Added**      Batch process deployment script

## [1.2.2] - 2022-02-03
*  **Changed**    Global reorganisation of GUI structure into by-tab partial views
*  **Changed**    Business Processes views layout reorganised
*  **Changed**    Scheduler executions now have a tasks grouping level
*  **Changed**    Scheduler execution layout is expandable
*  **Added**      All services URLs and credentials are encrypted in credentials.yml.enc file
*  **Changed**    Environment configuration files are written and deployed from dev

## [1.2.1] - 2022-01-13
*  **Changed**    Route now defaults to Statistical activities index
*  **Changed**    Statistical activities index is filtered by user's statistical activities given by Keycloak token
*  **Changed**    Business Flows Controller's set_external_reference method now updates statistical activity code with SIS portal's identifier

## [1.2.0] - 2021-11-01
*  **Added**  User logging is now available through Keycloak

## [1.1.0] - 2021-11-01
*  **Added**  Scheduler tasks execution and monitoring
*  **Added**  Parameters upload, log-file download, document attachment

## [1.0.10] - 2021-10-06
* **Changed** Scheduler connections password is now encrypted
* **Changed** Take in consideration new migration web service field

## [1.0.9] - 2021-09-30
* **Changed** Scheduler tasks layout simplified

## [1.0.8] - 2021-09-28
* **Added**   Create defined variables collection from SDMX web services
* **Added**   Define Production flows (flow, activities and tasks) for a Statistical Activity

## [1.0.7] - 2021-09-03
* **Added**   Update code-list values from SDMX web services
* **Changed** Data validation scripts now include all types of constraints
* **Changed** Users authorisations are now limited to read access  

## [1.0.6] - 2021-08-18
* **Added**   Added var_update method for mass update of DSD's variables
* **Added**   Added Parent Code to values_list migration
* **Fixed**   Manage missing translation for skill.
* **Added**   Manage extra code-lists even through several DV
* **Added**   Test and link existing KdDSD
* **Changed** Enhanced error management in metadata migration  

## [1.0.5] - 2021-08-09
* **Fixed**   Pairing key, mandatory, regionality fields are migrated with relevant information
* **Fixed**   Used variable of type code-list can now be tagged as pairing key and mandatory

## [1.0.4] - 2021-07-27
* **Fixed**   Better manage empty filters in used variable
* **Fixed**   Add variable role and source to data migration

## [1.0.3] - 2021-07-21
* **Changed**   Exported variables can still be used in a structure
* **Changed**   Structure migration now includes extra ValuesLists and filters
* **Changed**   Associating an existing code-list to a defined variable returns success message when successful.

## [1.0.2] - 2021-07-06
* **Changed**   Valid_to field is no more exported through migration
* **Fixed**     Fixed bug at German translation of Variable description

## [1.0.1] - 2021-07-02
* **Changed**   Set is_pseudonymised default to false in variables
* **Changed**   Added Italian and Romanisch support for migration.
* **Changed**   Added message to business object migration.
* **Fixed**     Fixed bug at Organisation creation

## [1.0.0] - 2021-06-07
* **Added**     Metdata migration to SIS Portal API
* **Added**     Added uuid attribute to main objects

## [0.20.0] - 2021-04-30
* **Added**     User update API to retrieve indentifiers from SIS Portal
* **Fixed**     Hierarchical classification association of code-lists

## [0.19.0] - 2021-04-01
* **Changed**   Removed parent fetch from full-text search in translations
* **Changed**   Reject Edit request for finalised DSD.
* **Changed**   Updated SQL templates to load data from SAS to Oracle
* **Added**     Values-list data type, deployed objects' physical name
* **Changed**   Numerical / alphabetical sorting in object indexes
* **Added**     Specific export/import xlsx template to support deployed metadata translation by tier (limited to Data Steward role)
* **Added**     Metadata object completion assessment (limited to Data Steward role)
* **Changed**   Approval workflow extended DSD (deployed metadata structure)
* **Changed**   Approval workflow extended to support migration steps
* **Changed**   Translated annotations management applied to all metadata objects

## [0.18.0] - 2021-03-19
* **Added**     UUID field added on main objects for integration follow-up
* **Added**     Business Object physical name to trace existing objects from data services
* **Changed**   Annotations associated to used variable can now be translated
* **Changed**   SQL templates for SAS added

## [0.17.0] - 2021-03-15
* **Added**     ValuesList now supports tree list mode to build a self hierarchy within a values list
* **Added**     Structure's SQL scripts for table creation and table loading are generated and displayed

## [0.16.0] - 2021-02-19
* **Added**     New Release notes file
* **Added**     ValuesList object now has a type (Masterdata, Quality, Infrastructure, or Methodology)
* **Added**     Used variables can now have associated values lists to describe quality attributes
* **Added**     Used variables can now specify a filter when referencing a values list or a classification
* **Changed**   Skills indexes restructured

## [0.15.0] - 2021-02-05
* **Changed**   Bugs fixed: 18464, 18630, 17272, 17023, 16962, 18711
* **Changed**   Turned drop_downs into sortable and searchable lists
* **Changed**   Allow missing values for Unit field

## [0.14.0] - 2021-01-11
* **Changed**   Management of annotations, now including translations
* **Changed**   Notifications layout (15012)
* **Added**     Importation of not strict hierarchies (15775)
* **Added**     Import / export of parameters through structured Excel files, based on column names

## [0.13.0] - 2020-12-07
* **Changed**   Layout of most indexes now relies on interactive DataTables (12084)
* **Changed**   User friendly parameters management
* **Changed**   Defined variable technical name does not include timestamp, only counter
* **Changed**   Classification allows several values lists at level 0 to create a concatenation of lists
* **Changed**   Default responsible and organisation at object creation (15651)
* **Added**     User now has a main group, which allows distribution of notifications to this group
* **Added**     Index can be limited to current users objects
* **Added**     Values importation also import annotations (14999)
* **Added**     Parameters exportation now produces an XLSX file with 2 sheets
* **Fixed**     Classifications and variables can only be submitted if linked values-lists are approved
* **Fixed**     Message d'erreur au chargement d'une variable définie (15361)

## [0.12.0] - 2020-11-15
* **Added**     Classifications management provides value-sets to variables
* **Added**     Variables can now associate code-lists or classifications
* **Changed**   Validation of a variable can only be submitted if linked code-list is finalised
* **Fixed**     Navigations issues between defined variables and used variables

### [0.11.0] - 2020-09-21
* **Added**     Validation work-flow for Code-lists
* **Added**     Annotations added on Variables, Code-lists and Values (json in background)
* **Added**     Provide REST web services API on Code-lists for csv, file, xml, json formats
* **Changed**   Code-lists now exist as independent objects, and can be reused
* **Changed**   Several enhancements on index views
* **Fixed**     Authors can now delete objects

### [0.10.0] - 2020-08-31
* **Added**     Authorizations setup
* **Added**     Validation work-flow for variables
* **Added**     Internal notifications for work-flow follow-up
* **Added**     Monitoring queries, menu item and page
* **Added**     Support for Romansh
* **Changed**   Users, Groups and Roles management
* **Changed**   Values_lists maintenance is now based on Show view
* **Fixed**     Navigation menu now displays used variables

### [0.9.0] - 2020-06-20
* **Added**     Used variables creation with shopping cart
* **Changed**   Data import feature centralized
