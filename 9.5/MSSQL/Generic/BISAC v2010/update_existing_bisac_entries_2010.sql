update subgentables
  set datadesc = (COALESCE (
    (select literal 
       from temp_sgt_bisaccodes_2010
       where temp_sgt_bisaccodes_2010.code=subgentables.bisacdatacode),
    subgentables.datadesc ) ),
	 lastuserid = 'FB-sql-V2010', 
    lastmaintdate = getdate()
  where tableid=339
go
