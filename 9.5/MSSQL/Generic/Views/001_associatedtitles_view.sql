if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[associatedtitles_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[associatedtitles_view]
GO

CREATE VIEW [dbo].[associatedtitles_view]  AS
  SELECT a.bookkey, a.associatetitlebookkey, a.associationtypecode AS associationtypecode, atv.datadesc AS associationtype, asv.datadesc AS associationsubtype,
    p.datadesc productidtype, a.isbn, a.title, a.authorname, a.authorkey, f.datadesc AS formatname, bv.datadesc AS status, 
    pub.datadesc AS publisher, a.pubdate, a.price, a.editiondescription AS edition, a.releasetoeloquenceind, a.sortorder, a.reportind,
    a.salesunitgross, a.salesunitnet, a.bookpos, a.lifetodatepointofsale, a.yeartodatepointofsale, a.previousyearpointofsale,
    a.pagecount, a.illustrations, a.quantity, a.volumenumber, 
    CONVERT(VARCHAR(4000), q1.commenttext) comment1, CONVERT(VARCHAR(4000), q2.commenttext) comment2
  FROM dbo.associatedtitles a 
    INNER JOIN dbo.associatedtitletypes_view atv ON a.associationtypecode = atv.datacode 
    LEFT OUTER JOIN dbo.associatedtitlesubtypes_view asv ON a.associationtypecode = asv.datacode AND a.associationtypesubcode = asv.datasubcode
    LEFT OUTER JOIN dbo.productidtypes_view p ON a.productidtype = p.datacode 
    LEFT OUTER JOIN dbo.origpubhouse_view pub ON a.origpubhousecode = pub.datacode 
    LEFT OUTER JOIN dbo.mediatypesub_view f ON a.mediatypecode = f.datacode AND a.mediatypesubcode = f.datasubcode 
    LEFT OUTER JOIN dbo.bisacstatus_view bv ON a.bisacstatus = bv.datacode
    LEFT OUTER JOIN dbo.qsicomments_view q1 ON a.commentkey1 = q1.commentkey
    LEFT OUTER JOIN dbo.qsicomments_view q2 ON a.commentkey2 = q2.commentkey
  WHERE (a.associatetitlebookkey = 0)
  UNION
  SELECT a.bookkey, a.associatetitlebookkey, a.associationtypecode, atv.datadesc, asv.datadesc,
    p.datadesc productidtype, c.isbn, c.title, c.authorname, a.authorkey, c.formatname, bisacstatusdesc,
    c.imprintname, c.bestpubdate, c.tmmprice, bd.editiondescription, a.releasetoeloquenceind, a.sortorder, a.reportind,
    a.salesunitgross, a.salesunitnet, a.bookpos, a.lifetodatepointofsale, a.yeartodatepointofsale, a.previousyearpointofsale,
    dbo.rpt_get_best_page_count(a.associatetitlebookkey, 1), dbo.rpt_get_best_insert_illus(a.associatetitlebookkey, 1), a.quantity, a.volumenumber, 
    CONVERT(VARCHAR(4000), q1.commenttext) comment1, CONVERT(VARCHAR(4000), q2.commenttext) comment2
  FROM associatedtitles a 
    INNER JOIN dbo.associatedtitletypes_view atv ON a.associationtypecode = atv.datacode
    LEFT OUTER JOIN dbo.associatedtitlesubtypes_view asv ON a.associationtypecode = asv.datacode AND a.associationtypesubcode = asv.datasubcode
    LEFT OUTER JOIN dbo.productidtypes_view p ON a.productidtype = p.datacode 
    INNER JOIN coretitleinfo c ON a.associatetitlebookkey = c.bookkey AND c.printingkey = 1
    INNER JOIN bookdetail bd ON a.associatetitlebookkey = bd.bookkey
    LEFT OUTER JOIN dbo.qsicomments_view q1 ON a.commentkey1 = q1.commentkey
    LEFT OUTER JOIN dbo.qsicomments_view q2 ON a.commentkey2 = q2.commentkey
  WHERE (a.associatetitlebookkey <> 0)
go

grant select on [dbo].[associatedtitles_view] to public
go