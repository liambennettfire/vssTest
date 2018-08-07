update subgentables
  set datadesc = (COALESCE (
    (select literal 
       from temp_sgt_bisaccodes_2015
       where temp_sgt_bisaccodes_2015.code=subgentables.bisacdatacode),
    subgentables.datadesc ) ),
	 lastuserid = 'BISAC-sql-V2015', 
    lastmaintdate = getdate()
  where tableid=339
go