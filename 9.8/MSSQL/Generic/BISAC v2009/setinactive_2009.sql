update subgentables
  set deletestatus = 'Y',
      lastuserid = 'FB-sql-V2009',
      lastmaintdate = getdate()
  where tableid=339 
    and deletestatus = 'N'
    and bisacdatacode in
      (select distinct ltrim(temp_sgt_inactives_2009.code)
         from temp_sgt_inactives_2009 )
go