update subgentables
  set deletestatus = 'Y',
      lastuserid = 'qsi-sql-V2.9',
      lastmaintdate = getdate()
  where tableid=339 
    and bisacdatacode in
      (select distinct temp_inactivecodes_29.code
         from temp_inactivecodes_29 )
go