update subgentables
  set datadesc = (COALESCE (
    (select literal 
       from temp_sgt_bisaccodes_2009
       where temp_sgt_bisaccodes_2009.code=subgentables.bisacdatacode),
    subgentables.datadesc ) ),
	 lastuserid = 'FB-sql-V2009', 
    lastmaintdate = getdate()
  where tableid=339
go

