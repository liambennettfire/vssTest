update gentables
  set datadesc = (COALESCE (
    (select Literal 
       from temp_gt_bisaccodes_2008
       where temp_gt_bisaccodes_2008.code=gentables.bisacdatacode),
    gentables.datadesc ) ),
    lastuserid = 'qsi-sql-V2008', 
    lastmaintdate = getdate()
  where tableid=339
go



update subgentables
  set datadesc = (COALESCE (
    (select literal 
       from temp_sgt_bisaccodes_2008
       where temp_sgt_bisaccodes_2008.code=subgentables.bisacdatacode),
    subgentables.datadesc ) ),
	 lastuserid = 'qsi-sql-V2008', 
    lastmaintdate = getdate()
  where tableid=339
go



