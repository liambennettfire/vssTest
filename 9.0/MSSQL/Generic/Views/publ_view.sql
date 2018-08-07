SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[publ_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[publ_view]
GO


/****** Object:  View dbo.publ_view    Script Date: 5/22/2000 4:22:19 PM ******/
CREATE VIEW dbo.publ_view 
	(orgentrykey,orglevelkey,orgentrydesc,
	 orgentryparentkey,orgentryshortdesc,deletestatus,
	 lastuserid,lastmaintdate)
as 
select orgentry.orgentrykey,orgentry.orglevelkey,  orgentry.orgentrydesc,orgentry.orgentryparentkey,  orgentry.orgentryshortdesc,orgentry.deletestatus,  orgentry.lastuserid,orgentry.lastmaintdate from orgentry  where orglevelkey=2

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[publ_view]  TO [public]
GO

