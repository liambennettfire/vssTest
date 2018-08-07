update subgentables
   set deletestatus = 'N'
 where tableid = 339
   and datadesc = ltrim(rtrim('Ecosystems & Habitats/Forests & Rainforests'))
   and bisacdatacode = 'NAT014000' 