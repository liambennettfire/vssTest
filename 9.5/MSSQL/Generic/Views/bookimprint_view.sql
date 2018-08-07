SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[bookimprint_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[bookimprint_view]
GO


/****** Object:  View dbo.bookimprint_view    Script Date: 5/22/2000 4:22:18 PM ******/
CREATE VIEW dbo.bookimprint_view 
	(orgentrykey,orglevelkey,orgentrydesc,
	 orgentryparentkey,orgentryshortdesc,deletestatus,
	 lastuserid,lastmaintdate,bookkey)
as
select orgentry.orgentrykey,orgentry.orglevelkey,
orgentry.orgentrydesc,orgentry.orgentryparentkey,
orgentry.orgentryshortdesc,orgentry.deletestatus,
orgentry.lastuserid,orgentry.lastmaintdate, 
bookorgentry.bookkey
from orgentry, bookorgentry, filterorglevel
where filterorglevel.filterkey=19 and
orgentry.orglevelkey=filterorglevel.filterorglevelkey
and bookorgentry.orgentrykey=orgentry.orgentrykey

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[bookimprint_view]  TO [public]
GO

