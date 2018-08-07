UPDATE subgentables
SET alternatedesc1 = 'EXEC qprinting_generate_printing_name 0, @bookkey, @printingnum, @result1 OUTPUT, @errorcode OUTPUT, @errordesc OUTPUT'
WHERE tableid = 550 AND qsicode = 40
go
