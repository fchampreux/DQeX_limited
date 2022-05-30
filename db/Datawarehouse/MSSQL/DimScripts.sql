/*Creating Organisations dimension*/

INSERT INTO DIM_ORGANISATIONS (
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
from organisations O1
inner join organisations O2 on O1.id = O2.parent_id
inner join organisations O3 on O2.id = O3.parent_id
where O3.organisation_level <= 3;


/*Creating Territories dimension*/

INSERT INTO DIM_TERRITORIES (
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
from territories O1
inner join territories O2 on O1.id = O2.parent_id
inner join territories O3 on O2.id = O3.parent_id
where O3.territory_level<=3;


/*Creating Scopes dimension */

INSERT INTO DIM_SCOPES (
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
from scopes S 
inner join landscapes L on L.id = S.landscape_id 
inner join business_objects B on B.id = S.business_object_id;

/*Creating Rules dimension */
INSERT INTO DIM_RULES (
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
from business_rules R 
inner join business_processes PROCESS on PROCESS.id = R.business_process_id
inner join business_flows FLOW on PROCESS.business_flow_id = FLOW.id
inner join business_areas AREA on FLOW.business_area_id = AREA.id
order by R.id;

