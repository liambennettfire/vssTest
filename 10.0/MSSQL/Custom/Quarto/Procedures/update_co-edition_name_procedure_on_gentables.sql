update subgentables
set alternatedesc1 = 'EXEC qcontract_generate_coedition_name @projectkey, @result1 OUTPUT, @errorcode OUTPUT, @errordesc OUTPUT' 
where tableid = 550 AND qsicode = 63

update gentablesdesc
set refreshcacheind = 1
where tableid = 550