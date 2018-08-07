update subgentables
  set datadesc = (COALESCE (
    (select literal 
       from temp_sgt_bisaccodes_2012
       where temp_sgt_bisaccodes_2012.code=subgentables.bisacdatacode),
    subgentables.datadesc ) ),
	 lastuserid = 'FB-sql-V2012', 
    lastmaintdate = getdate()
  where tableid=339
go