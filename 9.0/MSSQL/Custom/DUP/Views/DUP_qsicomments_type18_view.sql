 
/****** Object:  View [dbo].[DUP_qsicomments_type18_view]    Script Date: 08/06/2015 13:54:27 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[DUP_qsicomments_type18_view]'))
DROP VIEW [dbo].[DUP_qsicomments_type18_view]
GO
 

/****** Object:  View [dbo].[DUP_qsicomments_type18_view]    Script Date: 08/06/2015 13:54:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[DUP_qsicomments_type18_view] 
	(commentkey, commenttypecode, commenttypesubcode, commenttext, releasetoeloquenceind)
AS 
SELECT commentkey, commenttypecode, commenttypesubcode, commenttext, releasetoeloquenceind
FROM qsicomments
where commenttypecode=18



GO


