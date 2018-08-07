UPDATE taqspecadmin SET culturecode = (SELECT datacode FROM gentables WHERE tableid = 670 AND qsicode = 1)
GO