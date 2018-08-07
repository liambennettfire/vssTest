SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[prodpoperson_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[prodpoperson_view]
GO

CREATE VIEW dbo.prodpoperson_view 
	(bookkey,printingkey,contributorkey,
	 roletypecode,depttypecode,resourcedesc,
	 lastuserid,lastmaintdate)
as 
select 	bookcontributor.bookkey,  	 			
bookcontributor.printingkey,  	 			
bookcontributor.contributorkey,  	 			
bookcontributor.roletypecode,  	 			
bookcontributor.depttypecode,  	 			
bookcontributor.resourcedesc,  	 			
bookcontributor.lastuserid,  	 			
bookcontributor.lastmaintdate       
FROM bookcontributor LEFT OUTER JOIN filterroletype ON bookcontributor.roletypecode = filterroletype.roletypecode   
where filterroletype.filterkey = 1                                                                                                                                               


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


