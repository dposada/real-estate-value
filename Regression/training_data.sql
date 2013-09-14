select
  p.mlsnum,
  c.latitude,
  c.longitude,
  m.lotsize,
  m.sqftbldg,
  r.land_value,
  r.land_value / m.lotsize,
  r.improvement_value,
  r.improvement_value / m.sqftbldg,
  r.total_appraised_value_num,
  case when instr(m.defects,'KNOWN')>0 THEN 1 else 0 end as known_defects,
  case WHEN INSTR(M.DEFECTS,'REPRT')>0 THEN 1 else 0 end as defects_report,
  case WHEN INSTR(M.DEFECTS,'FNDRP')>0 THEN 1 else 0 end as foundation_repair,
  case WHEN INSTR(M.DEFECTS,'DEFRP')>0 THEN 1 else 0 end as defects_repaired,
  case WHEN INSTR(M.DEFECTS,'TREAT')>0 THEN 1 else 0 end as treated,
  m.yearbuilt,
  case r.protested when 'Y' then 1 else 0 end as appraisal_protested,
  case area when 4  then 1 else 0 end as area_4,
  case area
    when 9 then
      case when latitude < 29.815038208917482 then 1 else 0 end
    else 0 end as area_9_inside,
  case area
    when 9 then
      case when latitude >= 29.815038208917482 then 1 else 0 end
    else 0 end as area_9_outside,
  case area when 16 then 1 else 0 end as area_16,
  case area when 17 then 1 else 0 end as area_17,
  case area when 20 then 1 else 0 end as area_20,
  case area when 21 then 1 else 0 end as area_21,
  case area when 22 then 1 else 0 end as area_22,
  sqrt(pow((c.latitude-29.760828),2) + pow((c.longitude-(-95.369416)),2)) as dist_from_downtown,
  case when instr(e.disclosures,'FORCL')>0 OR INSTR(E.PROPERTY_DESCRIPTION,'FORECLOS')>0 THEN 1 ELSE 0 END AS FORECLOSURE,
  case when
    instr(e.property_description, 'quick sale')>0
    or instr(e.property_description, 'below market')>0
    or instr(e.property_description, 'priced to sell')>0
  then 1 else 0 end as quick_sale,
  case when
    instr(e.property_description, 'needs repair')>0
    or instr(e.property_description, 'needs some repair')>0
    or instr(e.property_description, 'needs many repair')>0
    or instr(e.property_description, 'as is')>0
    or instr(e.property_description, 'tlc')>0
    or instr(e.property_description, 'handyman')>0
  then 1 else 0 end as needs_repairs,
  m.salesprice
from
  property_map p
  join mls m on m.mlsnum=p.mlsnum
  join real_acct r on r.account_number=p.account_number
  join coords c on c.property_map_id=p.property_map_id
  join mls_extra e on e.mlsnum=m.mlsnum
where
  m.lotsize is not null
  and m.yearbuilt<>'None'
  and m.sqftbldg>0
  and m.lotsize>0
  and r.total_appraised_value_num is not null
group by
  p.mlsnum
order by
  rand();
