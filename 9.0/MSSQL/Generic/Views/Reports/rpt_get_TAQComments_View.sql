
GO

/****** Object:  View [dbo].[rpt_get_TAQComments_View]    Script Date: 08/25/2015 14:46:52 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_TAQComments_View]'))
DROP VIEW [dbo].[rpt_get_TAQComments_View]
GO


GO

/****** Object:  View [dbo].[rpt_get_TAQComments_View]    Script Date: 08/25/2015 14:46:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[rpt_get_TAQComments_View] As       
Select t.taqprojectkey,g2.sortorder,q.Commenttypecode,t.Commenttypesubcode,      
dbo.rpt_get_taq_comment(t.taqprojectkey,q.commenttypecode,q.commenttypesubcode,3) + '<br>' As comment,      
dbo.rpt_get_gentables_desc(284,q.commenttypecode,'long') as MainType,      
dbo.rpt_get_subgentables_desc(284,q.commenttypecode,q.commenttypesubcode,'long') as MainSubType    from gentables g 
inner join subgentables g2
on g.datacode=g2.datacode
and g.tableid=g2.tableid
inner join taqprojectcomments t
on g2.datacode=t.commenttypecode
and g2.datasubcode=t.commenttypesubcode
inner join qsicomments q
on t.commenttypecode=q.commenttypecode
and t.commenttypesubcode=q.commenttypesubcode
and t.commentkey=q.commentkey   
where g.tableid=284


group by  g2.sortorder,dbo.rpt_get_gentables_desc(284,q.commenttypecode,'long'),      
dbo.rpt_get_taq_comment(t.taqprojectkey,q.commenttypecode,q.commenttypesubcode,3),      
dbo.rpt_get_subgentables_desc(284,q.commenttypecode,q.commenttypesubcode,'long'),      
t.taqprojectkey,q.Commenttypecode,t.Commenttypesubcode 
--order by  g2.sortorder
GO

Grant all on rpt_get_TAQComments_View to public
