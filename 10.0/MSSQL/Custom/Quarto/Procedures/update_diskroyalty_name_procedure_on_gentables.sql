update subgentables
set alternatedesc1 = 'EXEC qcontract_generate_diskroyalty_name @projectkey, @result1 OUTPUT, @errorcode OUTPUT, @errordesc OUTPUT' 
where tableid = 550 AND qsicode = 76

update gentablesdesc
set refreshcacheind = 1
where tableid = 550