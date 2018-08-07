update subgentables
   set deletestatus = 'N'
 where tableid = 339
   and datadesc = ltrim(rtrim('Automotive/Driver Education'))
   and bisacdatacode = 'TRA001080'
   and deletestatus = 'Y'
go