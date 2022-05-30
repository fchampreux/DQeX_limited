**OBJECTS MANAGEMENT** - Describes objects creation and maintenance

**Classification framework**
The reference Classification Frameworks are provided by [APQC](https://apqc.org). They propose a structure to organise business processes in the overall organisation's activity.
Data Quality Manager's main objects adopt this hierarchy: Business Areas, Business Flows, Business Processes, Tasks and Activities.
Additional objects allow a smart project organsation among teams in large organisation: Playgrounds, Landscapes and Scopes.
More detailed elements of this knowledge base allow the organisation to express its expectations regarding the data feeding the business processes, and to assess the impact on business of data issues: Business Rules and Business Continuity Tasks

Objects belong to a hierarchy of which the highest element is the Playground. If the multitenancy is activated, each Playground defines a tenant.

**Version Management**
Following objects benefit from version management:
* The *Business Object* which provides the metadata information that describe items used in your business processes
* The *Business Rule* which defines the expectations regarding business objects
* The *Scope* which specifies a query to physically use (C.R.U.D.) business objects
* The *Activity* which describe a step in a business process
* The *Values List* which provides reference metadata
* The *Mappings List* which provides translation tables between reference metadata

Version number is based two elements:
* Major version: the highest digit is incremented on user's request to create a new version. New version is owned by the user who created it.
* Minor version: the lowest digit is incremented when a user - who is different from the user who did the last update - updates an object. The minor version increment does not change the owner of the object. The major version digit remains unchanged.
When created, the new version is assigned the status of **Current Version** by setting the **is_current** flag to *true* while other versions of the same objects have their **is_current** flag reset to *false*.

**Properties**
Properties are organised in tabs. The number of fields and tabs vary depending on the object, but some groups of fiels are always present:

* Description: name, code and description allow univoque identification of the object by the user. Hierarchy places the object in information's hierachy.
* Ownership: contains metadata about the record, such as owner's id, creation and update date and user, version number (if managed), statuses of the object.

**Methods**
The user can act on the objects through following features:  

* Index - returns the filtered list of objects. For versionned objects, only current & active or finalized objects are displayed
* Index_all - returns the full list of objects (including inactivated objects)
* New - creates a new object to be used by input form (internal use only)
* Edit - edits the selected object
* Show - displays the selected object
* Create - saves the newly created object
* Update - saves the selected object, and create a minor version if relevant
* Destroy - marks the object as deleted by setting **is_active** flag to *false*. This is applied to all versions of the object
* Activate - undeletes the object by setting **is_active** flag to *true* (opposite action to Destroy)
* Create new version - increments major version number by 1, and changes owner to current user
* Finalise - locks current version as read-only. A finalised object cannot be edited or update anymore.
* Make current - sets the selected version as **Current Version**, resets other versions of the same object

Back to: [Help index](help-index.md)
