/* dqm_DWH for PostgreSQL technology */

/* Fact table stores all records captured*/
CREATE TABLE dwh_records
(
  playground_id integer,
  business_object_id integer,
  organisation_id integer,
  territory_id integer,
  scope_mask numeric(320,0),
  rule_mask numeric(320,0),
  error_mask numeric(320,0),
  whitelist_mask numeric(320,0),
  period_id integer,
  record_id character varying(255),
  record_created_by character varying(255),
  record_created_at timestamp without time zone,
  record_updated_by character varying(255),
  record_updated_at timestamp without time zone,
  first_time_right timestamp without time zone,
  first_user_right character varying(255),
  last_time_wrong timestamp without time zone,
  last_user_wrong character varying(255),
  data_values character varying(255),
  observation text,
  record_status character varying(255),
  created_by character varying(255),
  updated_by character varying(255),
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  process_id integer,
  CONSTRAINT dwh_records_pk PRIMARY KEY (playground_id, period_id, record_id)
);

/* DM stores basic measures for objects*/
CREATE TABLE dm_measures
(
  playground_id integer,
  dqm_object_id integer,
  dqm_parent_id integer,
  dqm_object_name character varying(255),
  dqm_object_code character varying(255),
  dqm_object_url character varying(255),
  is_project_hierarchy boolean,
  period_id integer,
  period_day char(8),
  all_records integer,
  error_count integer,
  score numeric(5,2),
  workload numeric(10,2),
  added_value numeric(10,2),
  maintenance_cost numeric(10,2),
  created_by character varying(255),
  updated_by character varying(255),
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  process_id integer,
  CONSTRAINT dm_measures_pk PRIMARY KEY (dqm_object_id, period_id )
);

/*Territories dimension table*/
CREATE TABLE dim_territories
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
CREATE TABLE dim_organisations
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
CREATE TABLE dim_rules
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
CREATE TABLE dim_scopes
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

