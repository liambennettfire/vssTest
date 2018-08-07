-- Expand Titles tab to accommodate about 20 rows

UPDATE taqrelationshiptabconfig
SET scrollbarheight = 460
WHERE relationshiptabcode in (select datacode from gentables where tableid = 583 and qsicode = 15)
GO
