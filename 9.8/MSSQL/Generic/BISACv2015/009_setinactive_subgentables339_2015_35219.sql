update subgentables
  set deletestatus = 'Y',
      lastuserid = 'BISAC-sql-V2015',
      lastmaintdate = getdate()
  where tableid=339 
    and deletestatus = 'N'
    and bisacdatacode in
      (select distinct ltrim(temp_sgt_inactives_2015.code)
         from temp_sgt_inactives_2015 )
go