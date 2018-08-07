update subgentables
  set datadesc = (COALESCE (
    (select literal 
       from temp_sgt_bisaccodes_2011
       where temp_sgt_bisaccodes_2011.code=subgentables.bisacdatacode),
    subgentables.datadesc ) ),
	 lastuserid = 'FB-sql-V2011', 
    lastmaintdate = getdate()
  where tableid=339
go
