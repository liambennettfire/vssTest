if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_misccontract_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_misccontract_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[up_dwocontact_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[up_dwocontact_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[up_lastnexttask_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[up_lastnexttask_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[clothtitles_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[clothtitles_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[copyrightinname_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[copyrightinname_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[papertitles_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[papertitles_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[shipcode_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[shipcode_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_misccontract_contracttypes_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_misccontract_contracttypes_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_misccontract_crc_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_misccontract_crc_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_misccontract_cri_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_misccontract_cri_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_misccontract_includeoption_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_misccontract_includeoption_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_misccontract_maxpages_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_misccontract_maxpages_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_misccontract_maxwords_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_misccontract_maxwords_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_misccontract_paper_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_misccontract_paper_view]
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

CREATE VIEW dbo.copyrightinname_view
AS
SELECT     *
FROM         dbo.gentables
WHERE     (tableid = 475)

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

CREATE VIEW dbo.shipcode_view
AS
SELECT     dbo.gentables.*
FROM         dbo.gentables
WHERE     (tableid = 387)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.ump_misccontract_contracttypes_view
AS
SELECT     dbo.contractmisc.contractkey, dbo.subgentables.datadesc AS contracttype
FROM         dbo.subgentables INNER JOIN
                      dbo.contractmisc ON dbo.subgentables.datasubcode = dbo.contractmisc.longvalue
WHERE     (dbo.subgentables.tableid = 465) AND (dbo.subgentables.datacode = 1) AND (dbo.contractmisc.misckey = 1)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.ump_misccontract_crc_view
AS
SELECT     contractkey, longvalue AS crcind
FROM         dbo.contractmisc
WHERE     (misckey = 2)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.ump_misccontract_cri_view
AS
SELECT     contractkey, longvalue AS criind
FROM         dbo.contractmisc
WHERE     (misckey = 3)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.ump_misccontract_includeoption_view
AS
SELECT     dbo.contractmisc.contractkey, dbo.subgentables.datadesc AS includeoption
FROM         dbo.contractmisc LEFT OUTER JOIN
                      dbo.subgentables ON dbo.contractmisc.longvalue = dbo.subgentables.datasubcode
WHERE     (dbo.contractmisc.misckey = 4) AND (dbo.subgentables.tableid = 465) AND (dbo.subgentables.datacode = 2)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.ump_misccontract_maxpages_view
AS
SELECT     contractkey, longvalue AS maxpages
FROM         dbo.contractmisc
WHERE     (misckey = 6)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.ump_misccontract_maxwords_view
AS
SELECT     contractkey, longvalue AS maxwords
FROM         dbo.contractmisc
WHERE     (misckey = 5)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.ump_misccontract_paper_view
AS
SELECT     dbo.contractmisc.contractkey, dbo.subgentables.datadesc AS promisepaper
FROM         dbo.contractmisc LEFT OUTER JOIN
                      dbo.subgentables ON dbo.contractmisc.longvalue = dbo.subgentables.datasubcode
WHERE     (dbo.contractmisc.misckey = 8) AND (dbo.subgentables.tableid = 465) AND (dbo.subgentables.datacode = 2)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.ump_misccontract_view
AS
SELECT     dbo.contract.contractkey, dbo.contract.primarybookkey, dbo.contract.contractnumber, dbo.ump_misccontract_contracttypes_view.contracttype, 
                      dbo.ump_misccontract_cri_view.criind, dbo.ump_misccontract_crc_view.crcind, dbo.ump_misccontract_maxwords_view.maxwords, 
                      dbo.ump_misccontract_maxpages_view.maxpages, dbo.ump_misccontract_includeoption_view.includeoption, 
                      dbo.ump_misccontract_paper_view.promisepaper
FROM         dbo.contract LEFT OUTER JOIN
                      dbo.ump_misccontract_paper_view ON dbo.contract.contractkey = dbo.ump_misccontract_paper_view.contractkey LEFT OUTER JOIN
                      dbo.ump_misccontract_includeoption_view ON dbo.contract.contractkey = dbo.ump_misccontract_includeoption_view.contractkey LEFT OUTER JOIN
                      dbo.ump_misccontract_maxpages_view ON dbo.contract.contractkey = dbo.ump_misccontract_maxpages_view.contractkey LEFT OUTER JOIN
                      dbo.ump_misccontract_maxwords_view ON dbo.contract.contractkey = dbo.ump_misccontract_maxwords_view.contractkey LEFT OUTER JOIN
                      dbo.ump_misccontract_contracttypes_view ON dbo.contract.contractkey = dbo.ump_misccontract_contracttypes_view.contractkey LEFT OUTER JOIN
                      dbo.ump_misccontract_crc_view ON dbo.contract.contractkey = dbo.ump_misccontract_crc_view.contractkey LEFT OUTER JOIN
                      dbo.ump_misccontract_cri_view ON dbo.contract.contractkey = dbo.ump_misccontract_cri_view.contractkey

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.up_dwocontact_view
AS
SELECT     dbo.dwolist.dwokey, dbo.dwolist.dwoponumber, dbo.shipcode_view.datadesc AS shipcode, dbo.dwolist.publicist, dbo.dwolist.acctnumber, 
                      dbo.dwocontact.contactkey, dbo.nameabbr_view.datadesc AS salutation, dbo.dwocontact.contact_first, dbo.dwocontact.contact_middle, 
                      dbo.dwocontact.contact_last, dbo.dwocontact.title, dbo.dwocontact.address1, dbo.dwocontact.address2, dbo.dwocontact.address3, 
                      dbo.dwocontact.suite, dbo.dwocontact.city, dbo.stateabb_view.datadesc AS state, dbo.dwocontact.zip, dbo.country_view.datadesc AS country, 
                      dbo.dwocontact.companydesc
FROM         dbo.dwolist LEFT OUTER JOIN
                      dbo.dwocontact ON dbo.dwolist.dwokey = dbo.dwocontact.dwokey LEFT OUTER JOIN
                      dbo.country_view ON dbo.dwocontact.countrycode = dbo.country_view.datacode LEFT OUTER JOIN
                      dbo.nameabbr_view ON dbo.dwocontact.nameabbrcode = dbo.nameabbr_view.datacode LEFT OUTER JOIN
                      dbo.shipcode_view ON dbo.dwolist.shippingcode = dbo.shipcode_view.datacode LEFT OUTER JOIN
                      dbo.stateabb_view ON dbo.dwocontact.statecode = dbo.stateabb_view.datacode

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.up_lastnexttask_view
AS
SELECT     dbo.book.bookkey, dbo.book.title, dbo.elementtype_view.datadesc AS scheduletype, dbo.element.elementname, dbo.element.elementdesc, 
                      dbo.datetype.description AS nexttask, dbo.element.startdate, datetype_1.description AS lasttask, dbo.element.completiondate
FROM         dbo.element INNER JOIN
                      dbo.bookelement ON dbo.element.elementkey = dbo.bookelement.elementkey INNER JOIN
                      dbo.datetype ON dbo.element.nexttaskduecode = dbo.datetype.datetypecode INNER JOIN
                      dbo.datetype datetype_1 ON dbo.element.lasttaskdonecode = datetype_1.datetypecode INNER JOIN
                      dbo.elementtype_view ON dbo.element.elementtypecode = dbo.elementtype_view.datacode RIGHT OUTER JOIN
                      dbo.book ON dbo.bookelement.bookkey = dbo.book.bookkey

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

