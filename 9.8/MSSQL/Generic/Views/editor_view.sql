SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[editor_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[editor_view]
GO


/****** Object:  View dbo.editor_view    Script Date: 5/22/2000 4:22:19 PM ******/
CREATE VIEW dbo.editor_view 
	(bookkey,printingkey,contributorkey,
	 roletypecode,depttypecode,resourcedesc,
	 lastuserid,lastmaintdate,displayname)
as 
select bookcontributor.bookkey,bookcontributor.printingkey,
bookcontributor.contributorkey,bookcontributor.roletypecode,
bookcontributor.depttypecode,bookcontributor.resourcedesc,
bookcontributor.lastuserid,bookcontributor.lastmaintdate,
person.displayname from bookcontributor, person where
roletypecode=7 and person.contributorkey=bookcontributor.
contributorkey

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[editor_view]  TO [public]
GO

