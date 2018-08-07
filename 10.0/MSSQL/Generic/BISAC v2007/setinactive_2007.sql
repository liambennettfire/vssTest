update subgentables
  set deletestatus = 'Y',
      lastuserid = 'qsi-sql-V2007',
      lastmaintdate = getdate()
  where tableid=339 
    and bisacdatacode in
      (select distinct ltrim(temp_inactivecodes_2007.code)
         from temp_inactivecodes_2007 )
go


update subgentables
   set deletestatus = 'N',
 lastuserid = 'qsi-sql-V2007',
      lastmaintdate = getdate()
  where tableid=339 
    and bisacdatacode = 'HUM001000'
go