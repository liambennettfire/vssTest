update subgentables
  set deletestatus = 'Y'
  where tableid=339 
    and bisacdatacode in
      (select distinct temp_inactivecodes_27.code
         from temp_inactivecodes_27 )
go
