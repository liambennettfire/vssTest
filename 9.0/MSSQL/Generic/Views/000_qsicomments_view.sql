SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qsicomments_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[qsicomments_view]
GO

CREATE VIEW dbo.qsicomments_view 
	(commentkey, commenttypecode, commenttypesubcode, commenttext, releasetoeloquenceind)
AS 
SELECT commentkey, commenttypecode, commenttypesubcode, commenttext, releasetoeloquenceind
FROM qsicomments

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT SELECT, UPDATE, INSERT, DELETE ON [dbo].[qsicomments_view]  TO [public]
GO

