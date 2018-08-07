IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[EODundistributedapprovedtitles]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[EODundistributedapprovedtitles]
GO

CREATE VIEW [dbo].[EODundistributedapprovedtitles] AS
SELECT b.*, bd.csapprovalcode, 1 AS existsind
FROM bookdetail bd
JOIN book b ON b.bookkey = bd.bookkey
WHERE (bd.csapprovalcode = 1 OR bd.csapprovalcode = 4)  -- title is approved FOR Elo 
AND bd.bookkey NOT IN (SELECT DISTINCT bookkey FROM csdistribution cs WHERE cs.statuscode = 1) -- No csdistribution record FOR asset

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT SELECT, UPDATE, INSERT, DELETE ON [dbo].[EODundistributedapprovedtitles]  TO [public]
GO

