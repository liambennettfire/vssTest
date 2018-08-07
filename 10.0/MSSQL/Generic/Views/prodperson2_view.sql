SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[prodperson2_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[prodperson2_view]
GO

CREATE VIEW dbo.prodperson2_view 
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
where filterroletype.filterkey = 2                                                                                                                                                


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



