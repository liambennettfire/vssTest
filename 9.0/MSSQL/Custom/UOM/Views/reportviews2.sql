if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[contractbook_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[contractbook_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[works_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[works_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[workscontract_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[workscontract_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[clothtitles_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[clothtitles_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[contractstatus_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[contractstatus_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[papertitles_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[papertitles_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[relatedtitles_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[relatedtitles_view]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.clothtitles_view
AS
SELECT     dbo.book.workkey, dbo.whtitleinfo.bookkey, dbo.whtitleinfo.isbn, dbo.whtitleinfo.isbn10, dbo.whtitleinfo.title, dbo.whtitleinfo.quantityact, 
                      dbo.whtitleinfo.quantitybest, dbo.whtitleinfo.quantityest, dbo.whtitleinfo.seasonyearact, dbo.whtitleinfo.seasonyearbest, dbo.whtitleinfo.seasonyearest, 
                      dbo.whtitleinfo.uspriceact, dbo.whtitleinfo.uspricebest, dbo.whtitleinfo.uspriceest, dbo.whtitleclass.bisacstatus, dbo.whtitleclass.bisacstatusshort, 
                      dbo.whtitleclass.internalstatus, dbo.whtitleclass.internalstatusshort, dbo.whtitleinfo.format
FROM         dbo.whtitleinfo INNER JOIN
                      dbo.whtitleclass ON dbo.whtitleinfo.bookkey = dbo.whtitleclass.bookkey INNER JOIN
                      dbo.book ON dbo.whtitleinfo.bookkey = dbo.book.bookkey
WHERE     (dbo.whtitleinfo.format = 'Cloth Text')

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.contractstatus_view
AS
SELECT     dbo.gentables.*
FROM         dbo.gentables
WHERE     (tableid = 158)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.papertitles_view
AS
SELECT     dbo.book.workkey, dbo.whtitleinfo.bookkey, dbo.whtitleinfo.isbn, dbo.whtitleinfo.isbn10, dbo.whtitleinfo.title, dbo.whtitleinfo.quantityact, 
                      dbo.whtitleinfo.quantitybest, dbo.whtitleinfo.quantityest, dbo.whtitleinfo.seasonyearact, dbo.whtitleinfo.seasonyearbest, dbo.whtitleinfo.seasonyearest, 
                      dbo.whtitleinfo.uspriceact, dbo.whtitleinfo.uspricebest, dbo.whtitleinfo.uspriceest, dbo.whtitleclass.bisacstatus, dbo.whtitleclass.bisacstatusshort, 
                      dbo.whtitleclass.internalstatus, dbo.whtitleclass.internalstatusshort, dbo.whtitleinfo.format
FROM         dbo.whtitleinfo INNER JOIN
                      dbo.whtitleclass ON dbo.whtitleinfo.bookkey = dbo.whtitleclass.bookkey INNER JOIN
                      dbo.book ON dbo.whtitleinfo.bookkey = dbo.book.bookkey
WHERE     (dbo.whtitleinfo.format = 'Paper Text')

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE VIEW relatedtitles_view (bookkey,childbookkey,isbn,isbn10,title,format,seasonyearbest,edition,uspricebest,canadianpricebest,bisacstatus,bestdate1) AS select b.workkey as bookkey,b.bookkey as childbookkey,t.isbn,t.isbn10,t.title,t.format,t.seasonyearbest,
 c.edition,t.uspricebest, t.canadianpricebest,c.bisacstatus,d.bestdate1
from book b, whtitleinfo t, whtitleclass c, whtitledates d
where b.linklevelcode = 20
 and b.bookkey = t.bookkey
 and b.bookkey = c.bookkey
 and b.bookkey = d.bookkey
UNION
select b.bookkey as bookkey,b.workkey as childbookkey,t.isbn,t.isbn10,t.title,t.format,t.seasonyearbest,
 c.edition,t.uspricebest, t.canadianpricebest,c.bisacstatus,d.bestdate1
from book b, whtitleinfo t, whtitleclass c, whtitledates d
where b.linklevelcode = 20
 and b.workkey = t.bookkey
 and b.workkey= c.bookkey
 and b.workkey = d.bookkey


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.contractbook_view
AS
SELECT     dbo.book.bookkey, dbo.contract.contractkey, dbo.contract.contractnumber, dbo.contractstatus_view.datadesc AS contractstatus, 
                      dbo.ump_misccontract_contracttypes_view.contracttype
FROM         dbo.contract LEFT OUTER JOIN
                      dbo.ump_misccontract_contracttypes_view ON dbo.contract.contractkey = dbo.ump_misccontract_contracttypes_view.contractkey LEFT OUTER JOIN
                      dbo.contractstatus_view ON dbo.contract.contractstatuscode = dbo.contractstatus_view.datacode LEFT OUTER JOIN
                      dbo.contractbook ON dbo.contract.contractkey = dbo.contractbook.contractkey RIGHT OUTER JOIN
                      dbo.book ON dbo.contractbook.bookkey = dbo.book.bookkey

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.works_view
AS
SELECT DISTINCT 
                      TOP 100 PERCENT dbo.book.workkey, dbo.book.title, dbo.clothtitles_view.bookkey AS clothbookkey, dbo.clothtitles_view.isbn AS clothisbn, 
                      dbo.clothtitles_view.seasonyearbest AS clothseason, dbo.clothtitles_view.uspricebest AS clothprice, 
                      dbo.clothtitles_view.bisacstatus AS clothbisacstatus, dbo.clothtitles_view.internalstatus AS clothinternalstatus, 
                      dbo.clothtitles_view.quantitybest AS clothqty, dbo.papertitles_view.bookkey AS paperbookkey, dbo.papertitles_view.isbn AS paperisbn, 
                      dbo.papertitles_view.seasonyearbest AS paperseason, dbo.papertitles_view.uspricebest AS paperprice, 
                      dbo.papertitles_view.bisacstatus AS paperbisacstatus, dbo.papertitles_view.internalstatus AS paperinternalstatus, 
                      dbo.papertitles_view.quantitybest AS paperqty
FROM         dbo.book LEFT OUTER JOIN
                      dbo.papertitles_view ON dbo.book.workkey = dbo.papertitles_view.workkey LEFT OUTER JOIN
                      dbo.clothtitles_view ON dbo.book.workkey = dbo.clothtitles_view.workkey
ORDER BY dbo.book.title

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.workscontract_view
AS
SELECT     dbo.book.workkey, dbo.contractbook.contractkey, dbo.contract.contractnumber, dbo.contractstatus_view.datadesc AS contractstatus, 
                      dbo.ump_misccontract_contracttypes_view.contracttype, dbo.ump_misccontract_crc_view.crcind, dbo.ump_misccontract_cri_view.criind, 
                      dbo.ump_misccontract_maxpages_view.maxpages, dbo.ump_misccontract_maxwords_view.maxwords, 
                      dbo.ump_misccontract_includeoption_view.includeoption, dbo.ump_misccontract_paper_view.promisepaper
FROM         dbo.contract INNER JOIN
                      dbo.contractbook ON dbo.contract.contractkey = dbo.contractbook.contractkey INNER JOIN
                      dbo.contractstatus_view ON dbo.contract.contractstatuscode = dbo.contractstatus_view.datacode LEFT OUTER JOIN
                      dbo.ump_misccontract_maxpages_view ON dbo.contract.contractkey = dbo.ump_misccontract_maxpages_view.contractkey LEFT OUTER JOIN
                      dbo.ump_misccontract_includeoption_view ON dbo.contract.contractkey = dbo.ump_misccontract_includeoption_view.contractkey LEFT OUTER JOIN
                      dbo.ump_misccontract_paper_view ON dbo.contract.contractkey = dbo.ump_misccontract_paper_view.contractkey LEFT OUTER JOIN
                      dbo.ump_misccontract_maxwords_view ON dbo.contract.contractkey = dbo.ump_misccontract_maxwords_view.contractkey LEFT OUTER JOIN
                      dbo.ump_misccontract_cri_view ON dbo.contract.contractkey = dbo.ump_misccontract_cri_view.contractkey LEFT OUTER JOIN
                      dbo.ump_misccontract_contracttypes_view ON dbo.contract.contractkey = dbo.ump_misccontract_contracttypes_view.contractkey LEFT OUTER JOIN
                      dbo.ump_misccontract_crc_view ON dbo.contract.contractkey = dbo.ump_misccontract_crc_view.contractkey RIGHT OUTER JOIN
                      dbo.book ON dbo.contractbook.bookkey = dbo.book.bookkey
GROUP BY dbo.book.workkey, dbo.contractbook.contractkey, dbo.contract.contractnumber, dbo.contractstatus_view.datadesc, 
                      dbo.ump_misccontract_contracttypes_view.contracttype, dbo.ump_misccontract_crc_view.crcind, dbo.ump_misccontract_cri_view.criind, 
                      dbo.ump_misccontract_maxpages_view.maxpages, dbo.ump_misccontract_maxwords_view.maxwords, 
                      dbo.ump_misccontract_includeoption_view.includeoption, dbo.ump_misccontract_paper_view.promisepaper

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

