/* Glisser le jeu d'essais de 20 jours */
update dqm_app.dm_measures AS m 
set period_id = m.period_id+20,
period_day = p.period_day
from dqm_app.dim_time AS p
where p.period_id = m.period_id+20

/*                                    */

/* Générer des BR pour tous les processus */

select max(period_day) from dqm_app.dm_measures

insert into dqm_app.dim_rules (
select br.id, br.playground_id, br.code, br.name, br.description, br.hierarchy, ba.name, fl.name, bp.name,'Fred', 'Fred', br.created_at, br.updated_at,0
from dqm_app.business_rules br
inner join dqm_app.business_processes bp on bp.id = br.business_process_id
inner join dqm_app.business_flows fl on fl.id = bp.business_flow_id
inner join dqm_app.business_areas ba on ba.id = fl.business_area_id
where br.id >= 100 )

/*              */

/* Générer les measures pour tous les processus */

INSERT INTO "dqm_app"."dm_measures" (
select b.playground_id, b.id, 0, b.name, b.code, '/business_areas/' || ltrim(to_char(b.id::numeric(13,0),'9999999999999')), false, t.period_id, t.period_day, b.id*1000, 1000 + b.id * 100, 85, (15+b.id) * 20, (100+b.id) * 5, (15+b.id) * 20, 'Fred'::char(4), 'Fred'::char(4), b.created_at, b.updated_at,0
from business_areas b, dim_time t
where t.period_id between 2062 and 2081
and b.playground_id = 1001
and id not in (select dqm_object_id from dqm_app.dm_measures))




/*             */




update dqm_app.dm_measures AS m 
set period_id = m.period_id+20,
period_day = p.period_day
from dqm_app.dim_time AS p
where p.period_id = m.period_id+20

create table dqm_app.dummy_br (id integer, name varchar(5))

insert into dqm_app.dummy_br(id, name) values (3,'BR PO')

select bp.id, bp.hierarchy || '.' || to_char(br.id, '9') , bp.owner_id, 'Fred' as created_by, 'Fred' as updated_by, bp.created_at, bp.updated_at, 1301 as business_object_id, 10 as added_value, bp.code || '-' || to_char(br.id, '9')  as code, br.name
from dqm_app.business_processes bp, dqm_app.dummy_br br

insert into dqm_app.business_rules(business_process_id, hierarchy, owner_id, created_by, updated_by, created_at, updated_at, business_object_id, added_value, code, name) (
select bp.id, bp.hierarchy || '.' || to_char(br.id, '9') , bp.owner_id, 'Fred' as created_by, 'Fred' as updated_by, bp.created_at, bp.updated_at, 1301 as business_object_id, 10 as added_value, bp.code || '-' || to_char(br.id, '9')  as code, 'Business Rule' || br.name
from dqm_app.business_processes bp, dqm_app.dummy_br br )


select dqm_app.business_rules_id_seq.next_val from dqm_app.dummy_br

alter sequence dqm_app.business_rules_id_seq restart start with 100

/*     */


truncate table dm_measures;


select BR.playground_id, BR.id, BR.business_process_id parent_id, BR.name, BR.code, '/business_rules/'||BR.id url, to_char(current_date, 'YYYYMMDD') Period_day,  
count(distinct record_id) all_records, 
sum(case
    when  2^BR.id & error_mask <> 0 then 1
    else 0
    end) error_count,
case when count(record_id) <> 0 then
    (1-sum(case
        when  2^BR.id & error_mask <> 0 then 1
        else 0
        end)/count(distinct record_id))*100 
    else -1
    end score,
sum(case
    when  2^BR.id & error_mask <> 0 then BR.maintenance_duration
    else 0
    end) workload,
sum(case
    when  2^BR.id & error_mask  <> 0 then BR.added_value
    else 0
    end) added_value,
sum(case
    when  2^BR.id & error_mask <> 0 then BR.maintenance_cost
    else 0
    end) maintenance_cost
from business_rules BR 
left outer join dwh_records DWH on 2^BR.id & rule_mask <> 0
group by BR.playground_id, BR.id, BR.business_process_id, BR.name, BR.code, '/business_rules/'||BR.id,  to_char(current_date, 'YYYYMMDD') 



/* Full query with -1 assigned to rules with no record evaluated */
/* PG parent_id is assigned to 0 */
/* Based on id */
/* Simplified and including Playground */


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
select PG.id, PG.id, 0 parent_id, PG.name, PG.code, '/playgrounds/'||PG.id url, to_char(current_date, 'YYYYMMDD') Period_day,
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





