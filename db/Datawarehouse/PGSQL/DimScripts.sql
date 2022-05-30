/*Create dimensions tables */

/*Territories dimension table*/
CREATE TABLE dqm_dwh.dim_territories
(
  id integer NOT NULL,
  playground_id integer,
  code character varying(255),
  name character varying(255),
  description text,
  territory_level integer,
  hierarchy character varying(255),
  level_0 character varying(255),
  level_1 character varying(255),
  level_2 character varying(255),
  level_3 character varying(255),
  level_4 character varying(255),
  level_5 character varying(255),
  created_by character varying(255),
  updated_by character varying(255),
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  process_id integer,
  CONSTRAINT dim_territories_pk PRIMARY KEY (id)
)
;

/*Organisations dimension table*/
CREATE TABLE dqm_dwh.dim_organisations
(
  id integer NOT NULL,
  playground_id integer,
  code character varying(255),
  name character varying(255),
  description text,
  organisation_level integer,
  hierarchy character varying(255),
  level_0 character varying(255),
  level_1 character varying(255),
  level_2 character varying(255),
  level_3 character varying(255),
  level_4 character varying(255),
  level_5 character varying(255),
  created_by character varying(255),
  updated_by character varying(255),
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  process_id integer,
  CONSTRAINT dim_organisations_pk PRIMARY KEY (id)
)
;

/*Time dimension table*/
CREATE TABLE dqm_dwh.dim_time
(
  period_id integer NOT NULL,
  playground_id integer NOT NULL,
  period char(6),
  period_day char(8),
  period_date date,
  period_timestamp timestamp,
  day_of_month integer,
  day_of_year integer,
  day_number integer,
  week_of_month integer,
  week_of_year integer,
  week_number integer,
  month integer,
  month_name character varying(20),
  month_number integer,
  trimester_of_year integer,
  trimester_number integer,
  semester_of_year integer,
  semester_number integer,
  year integer,
  year_number integer,
  created_by character varying(255),
  updated_by character varying(255),
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  process_id integer,
  CONSTRAINT dim_time_pk PRIMARY KEY (period_id )
)
;

/*Business Rules dimension table*/
CREATE TABLE dqm_dwh.dim_rules
(
  id integer NOT NULL,
  playground_id integer,
  code character varying(255),
  name character varying(255),
  description text,
  hierarchy character varying(255),
  business_area character varying(255),
  business_flow character varying(255),
  business_process character varying(255),
  created_by character varying(255),
  updated_by character varying(255),
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  process_id integer,
  CONSTRAINT dim_rules_pk PRIMARY KEY (id)
)
;


/*Scopes dimension table*/
CREATE TABLE dqm_dwh.dim_scopes
(
  id integer NOT NULL,
  playground_id integer,
  code character varying(255),
  name character varying(255),
  description text,
  hierarchy character varying(255),
  landscape character varying(255),
  business_object character varying(255),
  business_object_id integer,
  created_by character varying(255),
  updated_by character varying(255),
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  process_id integer,
  CONSTRAINT dim_scopes_pk PRIMARY KEY (id)
)
;

/* Generating dimensions */

/*Creating Organisations dimension*/

INSERT INTO dqm_dwh.DIM_ORGANISATIONS (
ID,
PLAYGROUND_ID,
CODE,
NAME,
DESCRIPTION,
ORGANISATION_LEVEL,
HIERARCHY,
LEVEL_0,
LEVEL_1,
LEVEL_2,
LEVEL_3,
/*LEVEL_4,
LEVEL_5,*/
CREATED_BY,
UPDATED_BY,
CREATED_AT,
UPDATED_AT,
PROCESS_ID
) 
select O3.id, O3.playground_id, O3.code, O3.name, O3.description, O3.organisation_level, O3.hierarchy, 'World' Level0, O1.name Level1, O2.name Level2, O3.name Level3, 'Rake' created_by, 'Rake' updated_by, current_timestamp created_at, current_timestamp updated_at, 0 process_id
from dqm_app.organisations O1
inner join dqm_app.organisations O2 on O1.id = O2.parent_id
inner join dqm_app.organisations O3 on O2.id = O3.parent_id
where O3.organisation_level <= 3;


/*Creating Territories dimension*/

INSERT INTO dqm_dwh.DIM_TERRITORIES (
ID,
PLAYGROUND_ID,
CODE,
NAME,
DESCRIPTION,
TERRITORY_LEVEL,
HIERARCHY,
LEVEL_0,
LEVEL_1,
LEVEL_2,
LEVEL_3,
/*LEVEL_4,
LEVEL_5,*/
CREATED_BY,
UPDATED_BY,
CREATED_AT,
UPDATED_AT,
PROCESS_ID
) 
select O3.id, O3.playground_id, O3.code, O3.name, O3.description, O3.territory_level, O3.hierarchy, 'World' Level0, O1.name Level1, O2.name Level2, O3.name Level3, 'Rake' created_by, 'Rake' updated_by, current_timestamp created_at, current_timestamp updated_at, 0 process_id
from dqm_app.territories O1
inner join dqm_app.territories O2 on O1.id = O2.parent_id
inner join dqm_app.territories O3 on O2.id = O3.parent_id
where O3.territory_level<=3;


/*Creating Scopes dimension */

INSERT INTO dqm_dwh.DIM_SCOPES (
ID,
PLAYGROUND_ID,
BUSINESS_OBJECT,
BUSINESS_OBJECT_ID,
CODE,
NAME,
DESCRIPTION,
HIERARCHY,
LANDSCAPE,
CREATED_BY,
UPDATED_BY,
CREATED_AT,
UPDATED_AT,
PROCESS_ID
)
select S.id, S.playground_id, B.name, B.id, S.code, S.name, S.description, S.hierarchy, L.name,  'Rake' created_by, 'Rake' updated_by, current_timestamp created_at, current_timestamp updated_at, 0 process_id
from dqm_app.scopes S 
inner join dqm_app.landscapes L on L.id = S.landscape_id 
inner join dqm_app.business_objects B on B.id = S.business_object_id;

/*Creating Rules dimension */

INSERT INTO dqm_dwh.DIM_RULES (
ID,
PLAYGROUND_ID,
CODE,
NAME,
DESCRIPTION,
HIERARCHY,
BUSINESS_AREA,
BUSINESS_FLOW,
BUSINESS_PROCESS,
CREATED_BY,
UPDATED_BY,
CREATED_AT,
UPDATED_AT,
PROCESS_ID
) 
select R.id, R.playground_id, R.code, R.name, R.description, R.hierarchy, AREA.name BA, FLOW.name BF, PROCESS.name BP, 'Rake' created_by, 'Rake' updated_by, current_timestamp created_at, current_timestamp updated_at, 0 process_id
from dqm_app.business_rules R 
inner join dqm_app.business_processes PROCESS on PROCESS.id = R.business_process_id
inner join dqm_app.business_flows FLOW on PROCESS.business_flow_id = FLOW.id
inner join dqm_app.business_areas AREA on FLOW.business_area_id = AREA.id
order by R.id;

/*Creating Time dimension */

INSERT INTO "dqm_dwh"."dim_time" (period_id,playground_id,period_day,period_date,period_timestamp,day_of_month,day_of_year,week_of_year,year,created_by,updated_by,created_at,updated_at) 
SELECT period_id,playground_id,period_day,period_date,period_timestamp,day_of_month,day_of_year,week_of_year,year,created_by,updated_by,created_at,updated_at
from dqm_app.time_scales 
