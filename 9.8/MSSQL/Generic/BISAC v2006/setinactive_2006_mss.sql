update subgentables
  set deletestatus = 'Y',
      lastuserid = 'qsi-sql-V2006',
      lastmaintdate = getdate()
  where tableid=339 
    and bisacdatacode in
      (select distinct temp_inactivecodes_29_2.code
         from temp_inactivecodes_29_2 )
go