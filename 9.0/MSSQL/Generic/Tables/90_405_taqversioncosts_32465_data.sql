  
UPDATE taqversioncosts
   SET plcalccostcode = 1
 WHERE plcalccostcode is null
go

UPDATE taqversioncosts
   SET plcalccostsubcode = 1
 WHERE plcalccostsubcode is null
go

ALTER TABLE [dbo].taqversioncosts ADD CONSTRAINT DF_taqversioncosts_plcalccostcode DEFAULT (1) FOR plcalccostcode
go

ALTER TABLE [dbo].taqversioncosts ADD CONSTRAINT DF_taqversioncosts_plcalccostsubcode DEFAULT (1) FOR plcalccostsubcode
go




