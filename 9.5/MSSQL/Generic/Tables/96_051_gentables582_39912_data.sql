update gentables
set alternatedesc1 = null
where tableid = 582
and alternatedesc1 = 'NULL'
 
update gentablesdesc
set refreshcacheind = 1
where tableid = 582