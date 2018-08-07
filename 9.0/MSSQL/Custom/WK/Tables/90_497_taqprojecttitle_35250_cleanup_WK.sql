DELETE FROM taqprojecttitle where titlerolecode = (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 1) and projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 and qsicode = 1)
AND taqprojectkey > 0
AND bookkey IS NULL AND printingkey IS NULL

GO