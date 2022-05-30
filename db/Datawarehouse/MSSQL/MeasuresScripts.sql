truncate table dm_measures;

/* Full query with -1 assigned to rules with no record evaluated */
/* Based on id */
/* Simplified and incliding Playground */


insert into dm_measures(PLAYGROUND_ID,dqm_OBJECT_ID,dqm_PARENT_ID,dqm_OBJECT_NAME, dqm_OBJECT_CODE, dqm_OBJECT_URL, PERIOD_DAY,ALL_RECORDS,ERROR_COUNT,SCORE,WORKLOAD,ADDED_VALUE,MAINTENANCE_COST,PERIOD_ID,CREATED_BY,UPDATED_BY,CREATED_AT,UPDATED_AT,PROCESS_ID) 
select DWH.PLAYGROUND_ID, DWH.ID, DWH.PARENT_ID, DWH.NAME, DWH.CODE, DWH.URL, DTIME.PERIOD_DAY, DWH.ALL_RECORDS, DWH.ERROR_COUNT, DWH.SCORE, DWH.WORKLOAD, DWH.ADDED_VALUE, DWH.MAINTENANCE_COST, DTIME.PERIOD_ID,'Rake','Rake',current_timestamp, current_timestamp,0 from (
select BR.playground_id, BR.id, BR.business_process_id parent_id, BR.name, BR.code, '/business_rules/'||BR.id url, to_char(current_date, 'YYYYMMDD') Period_day,  
count(distinct record_id) all_records, 
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then 1
    else 0
    end) error_count,
case when count(record_id) <> 0 then
    (1-sum(case
        when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then 1
        else 0
        end)/count(distinct record_id))*100 
    else -1
    end score,
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then BR.maintenance_duration
    else 0
    end) workload,
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then BR.added_value
    else 0
    end) added_value,
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then BR.maintenance_cost
    else 0
    end) maintenance_cost
from business_rules BR 
left outer join dwh_records DWH on bitand2(power(2,BR.id), rawtohex(rule_mask)) <> 0
group by BR.playground_id, BR.id, BR.business_process_id, BR.name, BR.code, '/business_rules/'||BR.id,  to_char(current_date, 'YYYYMMDD') 
UNION
select BP.playground_id, BP.id, BP.business_flow_id parent_id, BP.name, BP.code, '/business_processes/'||BP.id url, to_char(current_date, 'YYYYMMDD') Period_day, 
count(distinct record_id) all_records, 
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then 1
    else 0
    end) error_count,
case when count(record_id) <> 0 then 
    (1-sum(case
        when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then 1
        else 0
        end)/count(distinct record_id))*100 
    else -1
    end score,
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then BR.maintenance_duration
    else 0
    end) workload,
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then BR.added_value
    else 0
    end) added_value,
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then BR.maintenance_cost
    else 0
    end) maintenance_cost
from business_processes BP 
inner join business_rules BR on BR.business_process_id = BP.id
left outer join dwh_records DWH on bitand2(power(2,BR.id), rawtohex(rule_mask)) <> 0
group by BP.playground_id,  BP.id, BP.business_flow_id, BP.name, BP.code, '/business_processes/'||BP.id, to_char(current_date, 'YYYYMMDD')
UNION
select BF.playground_id, BF.id, BF.business_area_id parent_id, BF.name, BF.code, '/business_flows/'||BF.id url, to_char(current_date, 'YYYYMMDD') Period_day,  
count(distinct record_id) all_records, 
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then 1
    else 0
    end) error_count,
case when count(record_id) <> 0 then 
    (1-sum(case
        when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then 1
        else 0
        end)/count(distinct record_id))*100 
    else -1
    end score,
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then BR.maintenance_duration
    else 0
    end) workload,
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then BR.added_value
    else 0
    end) added_value,
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then BR.maintenance_cost
    else 0
    end) maintenance_cost
from business_flows BF 
inner join business_processes BP on BP.business_flow_id = BF.id
inner join business_rules BR on BR.business_process_id = BP.id
left outer join dwh_records DWH on bitand2(power(2,BR.id), rawtohex(rule_mask)) <> 0
group by BF.playground_id, BF.id, BF.business_area_id, BF.name, BF.code, '/business_flows/'||BF.id, to_char(current_date, 'YYYYMMDD')
UNION
select BA.playground_id, BA.id, BA.playground_id parent_id, BA.name, BA.code, '/business_areas/'||BA.id url, to_char(current_date, 'YYYYMMDD') Period_day,
count(distinct record_id) all_records, 
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then 1
    else 0
    end) error_count,
case when count(record_id) <> 0 then 
(1-sum(case
        when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then 1
        else 0
        end)/count(distinct record_id))*100 
    else -1
    end score,
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then BR.maintenance_duration
    else 0
    end) workload,
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then BR.added_value
    else 0
    end) added_value,
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then BR.maintenance_cost
    else 0
    end) maintenance_cost
from business_areas BA
inner join business_flows BF on BF.business_area_id = BA.id
inner join business_processes BP on BP.business_flow_id = BF.id
inner join business_rules BR on BR.business_process_id = BP.id
left outer join dwh_records DWH on bitand2(power(2,BR.id), rawtohex(rule_mask)) <> 0
group by BA.playground_id,  BA.id, BA.playground_id, BA.name, BA.code, '/business_areas/'||BA.id, to_char(current_date, 'YYYYMMDD')
UNION
select PG.id, PG.id, PG.id parent_id, PG.name, PG.code, '/playgrounds/'||PG.id url, to_char(current_date, 'YYYYMMDD') Period_day,
count(distinct record_id) all_records, 
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then 1
    else 0
    end) error_count,
case when count(record_id) <> 0 then 
(1-sum(case
        when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then 1
        else 0
        end)/count(distinct record_id))*100 
    else -1
    end score,
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then BR.maintenance_duration
    else 0
    end) workload,
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then BR.added_value
    else 0
    end) added_value,
sum(case
    when  bitand2(power(2,BR.id), rawtohex(error_mask)) <> 0 then BR.maintenance_cost
    else 0
    end) maintenance_cost
from playgrounds PG
inner join business_areas BA on BA.playground_id = PG.id
inner join business_flows BF on BF.business_area_id = BA.id
inner join business_processes BP on BP.business_flow_id = BF.id
inner join business_rules BR on BR.business_process_id = BP.id
left outer join dwh_records DWH on bitand2(power(2,BR.id), rawtohex(rule_mask)) <> 0
group by PG.id,  PG.id, PG.id, PG.name, PG.code, '/playgrounds/'||PG.id, to_char(current_date, 'YYYYMMDD')
)  DWH
inner join DIM_TIME DTIME on DTIME.PERIOD_DATE between current_date -10 and current_date ;

commit ;

update dm_measures 
set error_count = (all_records/10) * (dbms_random.value + 1) where error_count > 0;

commit ;

update dm_measures 
set score = (1- (error_count / all_records))*100
where error_count > 0;

commit ;





