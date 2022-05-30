# Release notes
This file describes how to upgrade from previous version.

### Release note structure
* Version based on **Semantic Versioning**
* Updating procedure description

## 1.2.4
### Scheduler contracts integration
* Run migration
* Update Gem modules
  * bundle update
* Import parameters lists:
  * LIST_OF_STATUSES
  * LIST_OF_UNITS

## 1.2.3
### Scheduler enhancements
* Run migration
* Update Gem modules
  * bundle update
* Import parameters and infrastructure lists:
  * LIST_OF_PERIODS
  * LIST_OF_SCHEDULE_MODES
  * LIST_OF_NODE_TYPES
  * LIST_OF_STATUSES
  * CL_TECHNOLOGIES
  * LIST_OF_IT_LANGUAGES
  * LIST_OF_OBJECT_TYPES
  * LIST_OF_DATA_LIFECYLE_STEPS
  * CL_ENVIRONMENTS
  * LIST_OF_ANNOTATION_TYPES
  * LIST_OF_DATA_TYPES
  * CL_GSBPM

## 1.2.2
### Scheduler data architecture reviewed
* Run migration
* Update Gem modules
  * bundle update
  * bundle clean --force
* Build the credentials.yml.enc for each environment

## 1.2.1
### Login in with Keycloak and filtering activities
* Update ruby version to 2.7.5, update Passenger configuration in vhosts accordingly
* Run migration
* Update Gem modules
  * bundle update
  * bundle clean --force
* Upload Statistical Activities identifiers
  * copy the external_activities.json file in SIS-Portal directory
  * change to SIS-Portal directory and then run:
  curl --noproxy localhost -d @external_activities.json -H "Authorization:Basic QWRtaW46I1Byb3RvdHlwZTEzIQ==" -H "Content-type: application/json" http://localhost/API/external_activities
* Create an External Users group with External role

## 1.1.1
### CRON feature added
* Install Redis server and/or create new database and Redis instance

## 1.1.0
### Scheduler connections encrypted
* Run migration
* Bundle update
* Update values-lists and parameters_lists to support scheduler:
  * CL_TECHNOLOGIES
  * CL_ENVIRONMENTS
  * LIST_OF_DATA_LIFECYLE_STEPS
  * LIST_OF_IT_LANGUAGES
  * LIST_OF_STATUSES

## 1.0.10
### Scheduler connections encrypted
* Run migration

## 1.0.9
### More with Scheduler
* Update annotations types list to add 'Login'

## 1.0.8
### Scheduler prototype
* Create GSBPM values list
* Create node types parameters list
* Update data types
* bundle add graphviz
* install GraphViz

## 1.0.3
### Used variable migration now includes extra values and filters
* Requires Bundle install
* Requires rails db:migrate

## 1.0.0
### API prerequisites on list of data types
* Set the property field of data type to the target data type value [ CodeList, Date, Numeric, String ]
* Requires Bundle install
* Requires rails db:migrate
* Apply Curl queries to match existing data with prototype's data

## 0.20
### API required by SIS Portal migration
* User update API to invoke with cURL:
curl --noproxy localhost -d @external_users.json -H "Content-type: application/json" http://localhost/API/external_user_directory
* Reset of Gemfile.lock Ruby on Rails dependencies manifest
* Requires Bundle install
* Requires rails db:migrate

## 0.19
### Approval workflow ready for DSD migration
* Requires Bundle install
* Requires rails db:migrate
* Import parameters : List of Object Types

## 0.18
### ValuesList now supports tree list mode:
* No specific upgrade instruction

## 0.17
### ValuesList now supports tree list mode:
* No specific upgrade instruction

## 0.16
### ValuesList now has a type:
* Create a new list of parameters: LIST\_OF\_VALUES\_LISTS\_TYPES
* Import the list of associated parameters
* Check that values_lists table has a column named list_type_id (instead of type_id)
* Run Rails migration
* Update existing values lists with list_type_id corresponding to Metadata parmeter_id
* Make sure that all existing links from skills_values_lists table are copied into the skills.values_list_id field
