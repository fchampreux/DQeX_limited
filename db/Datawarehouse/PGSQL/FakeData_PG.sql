/* Full query with -1 assigned to rules with no record evaluated */
/* PG parent_id is assigned to 0 */
/* Based on id */
/* Simplified and including Playground */


insert into dqm_dwh.dm_processes(PLAYGROUND_ID,dqm_OBJECT_ID,dqm_PARENT_ID,dqm_OBJECT_NAME, dqm_OBJECT_CODE, dqm_OBJECT_URL, PERIOD_DAY, ALL_RECORDS,ERROR_COUNT,SCORE,WORKLOAD,ADDED_VALUE,MAINTENANCE_COST,PERIOD_ID,CREATED_BY,UPDATED_BY,CREATED_AT,UPDATED_AT, TERRITORY_ID, ORGANISATION_ID) 
select DWH.PLAYGROUND_ID, DWH.ID, DWH.PARENT_ID, DWH.NAME, DWH.CODE, DWH.URL, DTIME.PERIOD_DAY, DWH.ALL_RECORDS, DWH.ERROR_COUNT, DWH.SCORE, DWH.WORKLOAD, DWH.ADDED_VALUE, DWH.MAINTENANCE_COST, DTIME.PERIOD_ID,'Rake','Rake',current_timestamp, current_timestamp, 0, 0 from (
select BR.playground_id, BR.id, BR.business_process_id parent_id, BR.name, BR.code, '/business_rules/'||BR.id url, to_char(current_date, 'YYYYMMDD') Period_day,  
br.all_records, 
br.bad_records error_count,
0 score,
0 workload,
0 added_value,
0 maintenance_cost
from dqm_app.business_rules BR 
UNION
select BP.playground_id, BP.id, BP.business_flow_id parent_id, BP.name, BP.code, '/business_processes/'||BP.id url, to_char(current_date, 'YYYYMMDD') Period_day, 
bp.all_records, 
bp.bad_records  error_count,
0 score,
0 workload,
0 added_value,
0 maintenance_cost
from dqm_app.business_processes BP 
inner join dqm_app.business_rules BR on BR.business_process_id = BP.id
UNION
select BF.playground_id, BF.id, BF.business_area_id parent_id, BF.name, BF.code, '/business_flows/'||BF.id url, to_char(current_date, 'YYYYMMDD') Period_day,  
bf.all_records, 
bf.bad_records  error_count,
0 score,
0 workload,
0 added_value,
0 maintenance_cost
from dqm_app.business_flows BF 
inner join dqm_app.business_processes BP on BP.business_flow_id = BF.id
inner join dqm_app.business_rules BR on BR.business_process_id = BP.id
UNION
select BA.playground_id, BA.id, BA.playground_id parent_id, BA.name, BA.code, '/business_areas/'||BA.id url, to_char(current_date, 'YYYYMMDD') Period_day,
ba.all_records, 
ba.bad_records  error_count,
0 score,
0 workload,
0 added_value,
0 maintenance_cost
from dqm_app.business_areas BA
inner join dqm_app.business_flows BF on BF.business_area_id = BA.id
inner join dqm_app.business_processes BP on BP.business_flow_id = BF.id
inner join dqm_app.business_rules BR on BR.business_process_id = BP.id
UNION
select PG.id, PG.id, 0 parent_id, PG.name, PG.code, '/playgrounds/'||PG.id url, to_char(current_date, 'YYYYMMDD') Period_day,
pg.all_records, 
pg.bad_records  error_count,
0 score,
0 workload,
0 added_value,
0 maintenance_cost
from dqm_app.playgrounds PG
inner join dqm_app.business_areas BA on BA.playground_id = PG.id
inner join dqm_app.business_flows BF on BF.business_area_id = BA.id
inner join dqm_app.business_processes BP on BP.business_flow_id = BF.id
inner join dqm_app.business_rules BR on BR.business_process_id = BP.id
)  DWH
inner join dqm_dwh.DIM_TIME DTIME on DTIME.PERIOD_DATE between current_date -20 and current_date
where dwh.playground_id = 1;

commit ;

update dqm_dwh.dm_processes 
set all_records = 22000 where all_records = 0 ;

update dqm_dwh.dm_processes 
set error_count = 1+(all_records/10) * random() ;

commit ;

update dqm_dwh.dm_processes 
set score = (1.0- (1.0 * error_count) / (1.0 * all_records))*100.0 -5
where error_count > 0;

commit ;

/*Calculer l'impact des erreurs*/

update dqm_dwh.dm_processes D 
set workload = D.score * R.maintenance_duration,
added_value = D.score * R.added_value,
maintenance_cost = D.score * R.maintenance_cost
from dqm_app.business_rules R
where D.dqm_object_id = R.id ;

update dqm_dwh.dm_processes D 
set workload = R.workload,
added_value = R.added_value,
maintenance_cost = R.maintenance_cost
from ( select period_id, dqm_parent_id,
sum(workload) workload,
sum(added_value) added_value,
sum(maintenance_cost) maintenance_cost from dqm_dwh.dm_processes 
group by period_id, dqm_parent_id) R --Cumul par période des enfants de l'objet
where
D.dqm_object_id = R.dqm_parent_id and D.period_id = R.period_id;


/* Glisser le jeu d'essais de 20 jours */
update dqm_dwh.dm_processes AS m 
set period_id = m.period_id+20,
period_day = p.period_day
from dqm_dwh.dim_time AS p
where p.period_id = m.period_id+20 ;

/* Etendre le jeu d'essais de 10 jours */
insert into dqm_dwh.dm_processes(PLAYGROUND_ID,dqm_OBJECT_ID,dqm_PARENT_ID,dqm_OBJECT_NAME, dqm_OBJECT_CODE, dqm_OBJECT_URL, PERIOD_DAY,ALL_RECORDS,ERROR_COUNT,SCORE,WORKLOAD,ADDED_VALUE,MAINTENANCE_COST,PERIOD_ID,CREATED_BY,UPDATED_BY,CREATED_AT,UPDATED_AT,TERRITORY_ID,ORGANISATION_ID) 
select M.PLAYGROUND_ID,dqm_OBJECT_ID,dqm_PARENT_ID,dqm_OBJECT_NAME, dqm_OBJECT_CODE, dqm_OBJECT_URL, T.PERIOD_DAY,ALL_RECORDS,ERROR_COUNT,SCORE,WORKLOAD,ADDED_VALUE,MAINTENANCE_COST, T.PERIOD_ID,M.CREATED_BY,M.UPDATED_BY,M.CREATED_AT,M.UPDATED_AT,0,0
from dqm_dwh.dm_processes M inner join dqm_dwh.dim_time T on T.period_id = M.period_id + 10; 

