
GO

/****** Object:  View [dbo].[rpt_get_Marketing_Activity_Report_Comments_View]    Script Date: 08/09/2011 11:06:49 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_Marketing_Activity_Report_Comments_View]'))
DROP VIEW [dbo].[rpt_get_Marketing_Activity_Report_Comments_View]


/****** Object:  View [dbo].[rpt_get_Marketing_Activity_Report_Comments_View]    Script Date: 08/09/2011 11:06:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[rpt_get_Marketing_Activity_Report_Comments_View]
AS
Select b.bookkey,b.Commenttypecode,b.Commenttypesubcode,      
dbo.rpt_get_book_comment(b.bookkey,b.commenttypecode,b.commenttypesubcode,3) + '<br>' As comment,     
dbo.rpt_get_gentables_desc(284,b.commenttypecode,'long') as MainType,      
dbo.rpt_get_subgentables_desc(284,b.commenttypecode,b.commenttypesubcode,'long') as MainSubType      
 from bookcomments b 
where commenttypecode =1 and commenttypesubcode in(9,3,15,13,22,4,6,30,23,29)

union 
Select b.bookkey,b.Commenttypecode,b.Commenttypesubcode,      
dbo.rpt_get_book_comment(b.bookkey,b.commenttypecode,b.commenttypesubcode,3) + '<br>' As comment,     
dbo.rpt_get_gentables_desc(284,b.commenttypecode,'long') as MainType,      
dbo.rpt_get_subgentables_desc(284,b.commenttypecode,b.commenttypesubcode,'long') as MainSubType      
 from bookcomments b 
where commenttypecode =3 and commenttypesubcode in(7,51)

GO
GRANT ALL ON rpt_get_Marketing_Activity_Report_Comments_View TO PUBLIC