SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[taq_associatedtitles_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[taq_associatedtitles_view]
GO


--select * from taqprojecttitle where titlerolecode in (5,6)
--select * from associatedtitletypes_view
--select * from productidtypes_view

CREATE VIEW [dbo].[taq_associatedtitles_view]  AS
  SELECT a.taqprojectkey, a.bookkey, a.titlerolecode AS associationtypecode, atv.datadesc AS associationtype, 
  '' AS associationsubtype,
    p.datadesc productidtype, a.isbn, a.title, a.authorname, 0 AS authorkey, f.datadesc AS formatname, 
    bv.datadesc AS status, 
    pub.datadesc AS publisher, a.pubdate, a.price, a.editiondescription AS edition, 
    0 releasetoeloquenceind, a.sortorder, a.reportind,
    a.salesunitgross, a.salesunitnet, a.bookpos, a.lifetodatepointofsale, a.yeartodatepointofsale, 
    a.previousyearpointofsale,
    a.pagecount, a.illustrations, a.quantity, a.volumenumber, 
    CONVERT(VARCHAR(max), q1.commenttext) comment1, CONVERT(VARCHAR(max), q2.commenttext) comment2
  FROM dbo.taqprojecttitle a 
    INNER JOIN dbo.gentables atv ON a.titlerolecode = atv.datacode and atv.tableid = 605
    --LEFT OUTER JOIN dbo.associatedtitlesubtypes_view asv ON a.associationtypecode = asv.datacode AND a.associationtypesubcode = asv.datasubcode
    LEFT OUTER JOIN dbo.productidtypes_view p ON a.productidtype = p.datacode 
    LEFT OUTER JOIN dbo.origpubhouse_view pub ON a.origpubhousecode = pub.datacode 
    LEFT OUTER JOIN dbo.mediatypesub_view f ON a.mediatypecode = f.datacode AND a.mediatypesubcode = f.datasubcode 
    LEFT OUTER JOIN dbo.bisacstatus_view bv ON a.bisacstatus = bv.datacode
    LEFT OUTER JOIN dbo.qsicomments_view q1 ON a.commentkey1 = q1.commentkey
    LEFT OUTER JOIN dbo.qsicomments_view q2 ON a.commentkey2 = q2.commentkey
  WHERE (a.bookkey = 0) and a.titlerolecode in (5,6) --and atv.tableid = 605
  UNION
  SELECT a.taqprojectkey, a.bookkey, a.titlerolecode AS associationtypecode, atv.datadesc, '' as associationsubtype,
    p.datadesc productidtype, c.isbn, c.title, c.authorname, 0 as authorkey, c.formatname, bisacstatusdesc,
    c.imprintname, c.bestpubdate, c.tmmprice, bd.editiondescription, 0 as releasetoeloquenceind, a.sortorder, 
    a.reportind,
    a.salesunitgross, a.salesunitnet, a.bookpos, a.lifetodatepointofsale, a.yeartodatepointofsale, 
    a.previousyearpointofsale,
    dbo.rpt_get_best_page_count(a.bookkey, 1), dbo.rpt_get_best_insert_illus(a.bookkey, 1), a.quantity, a.volumenumber, 
    CONVERT(VARCHAR(max), q1.commenttext) comment1, CONVERT(VARCHAR(max), q2.commenttext) comment2
  FROM taqprojecttitle a 
    INNER JOIN dbo.gentables atv ON a.titlerolecode = atv.datacode and atv.tableid = 605
    --LEFT OUTER JOIN dbo.associatedtitlesubtypes_view asv ON a.associationtypecode = asv.datacode AND a.associationtypesubcode = asv.datasubcode
    LEFT OUTER JOIN dbo.productidtypes_view p ON a.productidtype = p.datacode 
    INNER JOIN coretitleinfo c ON a.bookkey = c.bookkey AND c.printingkey = 1
    INNER JOIN bookdetail bd ON a.bookkey = bd.bookkey
    LEFT OUTER JOIN dbo.qsicomments_view q1 ON a.commentkey1 = q1.commentkey
    LEFT OUTER JOIN dbo.qsicomments_view q2 ON a.commentkey2 = q2.commentkey
  WHERE (a.bookkey <> 0) and a.titlerolecode in (5,6) --and atv.tableid = 605



GO

GRANT ALL ON dbo.taq_associatedtitles_view TO PUBLIC
GO

