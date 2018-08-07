update subgentables
  set datadesc = (COALESCE (
    (select literal 
       from temp_sgt_bisaccodes_2013
       where temp_sgt_bisaccodes_2013.code=subgentables.bisacdatacode),
    subgentables.datadesc ) ),
	 lastuserid = 'FB-sql-V2013', 
    lastmaintdate = getdate()
  where tableid=339
go