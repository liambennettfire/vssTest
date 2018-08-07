update subgentables
  set deletestatus = 'Y',
      lastuserid = 'FB-sql-V2013',
      lastmaintdate = getdate()
  where tableid=339 
    and deletestatus = 'N'
    and bisacdatacode in
      (select distinct ltrim(temp_sgt_inactives_2013.code)
         from temp_sgt_inactives_2013 )
go