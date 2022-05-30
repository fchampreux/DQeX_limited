/* Not allowed by Oracle */
update (
select BA.playground_id, BA.id, BA.playground_id parent_id, BA.name, BA.code, '/business_areas/'||BA.id url, to_char(current_date, 'YYYYMMDD') Period_day,
case when DMBA.error_count <> 0 then (1-(DMBA.error_count/DMBA.all_records))*100 else -1 end calc_score,
sum(BR.maintenance_duration * DM.error_count) workload,
sum(BR.added_value * DM.error_count) added_value,
sum(BR.maintenance_cost * DM.error_count) maintenance_cost,
DM.score NEW_SCORE
from dqm_app.business_areas BA
inner join dqm_app.business_flows BF on BF.business_area_id = BA.id
inner join dqm_app.business_processes BP on BP.business_flow_id = BF.id
inner join dqm_app.business_rules BR on BR.business_process_id = BP.id
inner join dqm_app.dm_measures DM on DM.dqm_object_id = BR.id
inner join dqm_app.dm_measures DMBA on DMBA.dqm_object_id = BA.id
group by BA.playground_id,  BA.id, BA.playground_id, BA.name, BA.code, '/business_areas/'||BA.id, to_char(current_date, 'YYYYMMDD'), case when DMBA.error_count <> 0 then (1-(DMBA.error_count/DMBA.all_records))*100 else -1 end, DM.score 
) T
set T.NEW_SCORE = T.calc_score 

