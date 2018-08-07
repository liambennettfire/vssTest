update subgentables
  set datadesc = (COALESCE (
    (select literal 
       from temp_sgt_bisaccodes_29
       where temp_sgt_bisaccodes_29.code=subgentables.bisacdatacode),
    subgentables.datadesc ) ),
	 lastuserid = 'qsi-sql-V2006', 
    lastmaintdate = getdate()
  where tableid=339
go