update subgentables
  set deletestatus = 'Y',
      lastuserid = 'qsi-sql-V2008',
      lastmaintdate = getdate()
  where tableid=339 
    and bisacdatacode in
      (select distinct ltrim(temp_inactivecodes_2008.code)
         from temp_inactivecodes_2008 )
go


