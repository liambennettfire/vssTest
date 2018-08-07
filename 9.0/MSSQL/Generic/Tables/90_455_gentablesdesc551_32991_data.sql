/* We are eliminating the following client options dealing with itemnumber generation:
29 - Generate Item # (instead we will check for presence of generating stored procedure call on the db)
60 - itemnumber auto-generation (gen1ind on gentable 551)
116 - Allow Duplicate Item Numbers (gen2ind) */
UPDATE gentablesdesc
SET gen1indlabel = 'Auto Generate w/EAN', gen2indlabel = 'Allow Duplicates',
  alternatedesc1label = 'Validating procedure call', alternatedesc2label = 'Generating procedure call'
WHERE tableid = 551
go
