SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[publisher_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[publisher_view]
GO


/****** Object:  View dbo.publisher_view    Script Date: 5/22/2000 4:22:19 PM ******/
CREATE VIEW dbo.publisher_view 
	(orgentrykey,orglevelkey,orgentrydesc,
	 orgentryparentkey,orgentryshortdesc,deletestatus,
	 lastuserid,lastmaintdate)
as
select orgentry.orgentrykey,orgentry.orglevelkey,
orgentry.orgentrydesc,orgentry.orgentryparentkey,
orgentry.orgentryshortdesc,orgentry.deletestatus,
orgentry.lastuserid,orgentry.lastmaintdate
from orgentry, filterorglevel where orgentry.orglevelkey=
filterorglevel.filterorglevelkey and filterorglevel.filterkey=18

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[publisher_view]  TO [public]
GO

