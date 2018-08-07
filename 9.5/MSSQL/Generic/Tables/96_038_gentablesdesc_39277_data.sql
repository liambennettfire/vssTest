ALTER TABLE gentablesdesc ADD itemtypenumericdesc1label VARCHAR(30) NULL
GO
ALTER TABLE gentablesitemtype ADD numericdesc1 FLOAT NULL
GO

UPDATE gentablesdesc SET itemtypenumericdesc1label = 'Column override'
WHERE tableid = 636
GO
