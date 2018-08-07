update subgentables
  set datadesc = (COALESCE (
    (select literal 
       from temp_sgt_merchcodes_2007
       where temp_sgt_merchcodes_2007.code=subgentables.bisacdatacode),
    subgentables.datadesc ) ),
	 lastuserid = 'qsi-sql-V2007', 
    lastmaintdate = getdate()
  where tableid=558
go