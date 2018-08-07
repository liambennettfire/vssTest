update subgentables
  set datadesc = (COALESCE (
    (select literal 
       from temp_sgt_bisaccodes_2014
       where temp_sgt_bisaccodes_2014.code=subgentables.bisacdatacode),
    subgentables.datadesc ) ),
	 lastuserid = 'FB-sql-V2014', 
    lastmaintdate = getdate()
  where tableid=339
go