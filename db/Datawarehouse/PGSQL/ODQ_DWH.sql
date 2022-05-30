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

