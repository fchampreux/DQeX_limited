/* dqm_DWH for Oracle technology */

/* Fact table stores all records captured*/
CREATE TABLE dwh_records
(
  playground_id integer,
  business_object_id integer,
  organisation_id integer,
  territory_id integer,
  scope_mask raw(1000),
  rule_mask raw(1000),
  error_mask raw(1000),
  whitelist_mask raw(1000),
  period_id integer,
  record_id varchar2(255),
  record_created_by varchar2(255),
  record_created_at timestamp ,
  record_updated_by varchar2(255),
  record_updated_at timestamp ,
  first_time_right timestamp ,
  first_user_right varchar2(255),
  last_time_wrong timestamp ,
  last_user_wrong varchar2(255),
  data_values varchar2(1000),
  observation clob,
  record_status varchar2(255),
  created_by varchar2(255),
  updated_by varchar2(255),
  created_at timestamp ,
  updated_at timestamp ,
  process_id integer,
  CONSTRAINT dwh_records_pk PRIMARY KEY (playground_id, period_id, record_id)
);

/* DM stores basic measures for objects*/
CREATE TABLE dm_measures
(
  playground_id integer,
  dqm_object_id integer,
  dqm_parent_id integer,
  dqm_object_name varchar2(255),
  dqm_object_code varchar2(255),
  dqm_object_url varchar2(255),
  is_project_hierarchy char(1),
  period_id integer,
  period_day char(8),
  all_records number(12,2),
  error_count number(12,2),
  score number(5,2),
  workload number(10,2),
  added_value number(10,2),
  maintenance_cost number(10,2),
  created_by varchar2(255),
  updated_by varchar2(255),
  created_at timestamp ,
  updated_at timestamp ,
  process_id integer,
  CONSTRAINT dm_measures_pk PRIMARY KEY (dqm_object_id, period_id )
);

/*Territories dimension table*/
CREATE TABLE dim_territories
(
  id integer NOT NULL,
  playground_id integer,
  code varchar2(255),
  name varchar2(255),
  description clob,
  territory_level integer,
  hierarchy varchar2(255),
  level_0 varchar2(255),
  level_1 varchar2(255),
  level_2 varchar2(255),
  level_3 varchar2(255),
  level_4 varchar2(255),
  level_5 varchar2(255),
  created_by varchar2(255),
  updated_by varchar2(255),
  created_at timestamp  NOT NULL,
  updated_at timestamp  NOT NULL,
  process_id integer,
  CONSTRAINT dim_territories_pk PRIMARY KEY (id )
)
;

/*Organisations dimension table*/
CREATE TABLE dim_organisations
(
  id integer NOT NULL,
  playground_id integer,
  code varchar2(255),
  name varchar2(255),
  description clob,
  organisation_level integer,
  hierarchy varchar2(255),
  level_0 varchar2(255),
  level_1 varchar2(255),
  level_2 varchar2(255),
  level_3 varchar2(255),
  level_4 varchar2(255),
  level_5 varchar2(255),
  created_by varchar2(255),
  updated_by varchar2(255),
  created_at timestamp  NOT NULL,
  updated_at timestamp  NOT NULL,
  process_id integer,
  CONSTRAINT dim_organisations_pk PRIMARY KEY (id )
)
;

/*Time dimension table*/
CREATE TABLE dim_time
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
  month_name varchar(20),
  month_number integer,
  trimester_of_year integer,
  trimester_number integer,
  semester_of_year integer,
  semester_number integer,
  year integer,
  year_number integer,
  created_by varchar2(255),
  updated_by varchar2(255),
  created_at timestamp  NOT NULL,
  updated_at timestamp  NOT NULL,
  process_id integer,
  CONSTRAINT dim_time_pk PRIMARY KEY (period_id )
)
;

/*Business Rules dimension table*/
CREATE TABLE dim_rules
(
  id integer NOT NULL,
  playground_id integer,
  code varchar2(255),
  name varchar2(255),
  description clob,
  hierarchy varchar2(255),
  business_area varchar2(255),
  business_flow varchar2(255),
  business_process varchar2(255),
  created_by varchar2(255),
  updated_by varchar2(255),
  created_at timestamp  NOT NULL,
  updated_at timestamp  NOT NULL,
  process_id integer,
  CONSTRAINT dim_rules_pk PRIMARY KEY (id )
)
;


/*Scopes dimension table*/
CREATE TABLE dim_scopes
(
  id integer NOT NULL,
  playground_id integer,
  code varchar2(255),
  name varchar2(255),
  description clob,
  hierarchy varchar2(255),
  landscape varchar2(255),
  business_object varchar2(255),
  business_object_id integer,
  created_by varchar2(255),
  updated_by varchar2(255),
  created_at timestamp  NOT NULL,
  updated_at timestamp  NOT NULL,
  process_id integer,
  CONSTRAINT dim_scopes_pk PRIMARY KEY (id )
)
;

