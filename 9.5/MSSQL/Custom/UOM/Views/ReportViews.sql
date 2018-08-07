if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_simulestcloth_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_simulestcloth_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_simulestpaper_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_simulestpaper_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[estversion_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[estversion_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_estcompspec_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_estcompspec_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_estimate_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_estimate_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_estspec_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_estspec_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[estcost_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[estcost_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_compcopies_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_compcopies_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_esttotalcost_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_esttotalcost_view]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_subventioncost_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ump_subventioncost_view]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE VIEW dbo.estcost_view
AS
SELECT     TOP 100 PERCENT dbo.estcost.estkey, dbo.estcost.versionkey, dbo.comptype.compdesc, dbo.cdlist.externaldesc, dbo.cdlist.externalcode, 
                      dbo.cdlist.costtype, dbo.estcost.potag1, dbo.estcost.potag2, dbo.estcost.unitcost, dbo.estcost.totalcost, dbo.estcost.poind
FROM         dbo.estcost LEFT OUTER JOIN
                      dbo.comptype ON dbo.estcost.compkey = dbo.comptype.compkey LEFT OUTER JOIN
                      dbo.cdlist ON dbo.estcost.chgcodecode = dbo.cdlist.internalcode
ORDER BY dbo.estcost.estkey, dbo.estcost.versionkey



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[estcost_view]  TO [public]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE VIEW dbo.ump_compcopies_view
AS
SELECT     *
FROM         dbo.gentables
WHERE      (datadesc LIKE '%comp copies%')




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[ump_compcopies_view]  TO [public]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE VIEW dbo.ump_esttotalcost_view
AS
SELECT     estkey, versionkey, SUM(totalcost) AS totalcost
FROM         dbo.estcost
GROUP BY estkey, versionkey



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[ump_esttotalcost_view]  TO [public]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.ump_subventioncost_view
AS
SELECT     dbo.estmiscspecs.*
FROM         dbo.estmiscspecs
WHERE     (datacode = 7)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[ump_subventioncost_view]  TO [public]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE VIEW dbo.estversion_view
AS
SELECT     TOP 100 PERCENT dbo.estbook.estkey, dbo.estbook.bookkey, dbo.estbook.printingkey, dbo.estbook.estimatename, dbo.estversion.versionkey, 
                      dbo.estversion.description, dbo.estbook.estimatorcode, dbo.estbook.authorillustrator, dbo.person.displayname AS editor, 
                      dbo.person.shortname AS editorshort, person_1.displayname AS estimator, person_1.shortname AS estimatorshort, dbo.estversion.finishedgoodqty, 
                      dbo.estspecs.trimsizewidth + ' x ' + dbo.estspecs.trimsizelength AS trimsize, dbo.estspecs.pagecount, 
                      dbo.mediatypesub_view.datadesc AS estimateformat, mediatypesub_view_1.datadesc AS versionformat, dbo.estversion.versiontypecode, 
                      dbo.estbook.pubdate
FROM         dbo.estbook INNER JOIN
                      dbo.estversion ON dbo.estbook.estkey = dbo.estversion.estkey INNER JOIN
                      dbo.estspecs ON dbo.estversion.estkey = dbo.estspecs.estkey AND dbo.estversion.versionkey = dbo.estspecs.versionkey LEFT OUTER JOIN
                      dbo.person person_1 ON dbo.estbook.estimatorcode = person_1.contributorkey LEFT OUTER JOIN
                      dbo.person ON dbo.estbook.editorcode = dbo.person.contributorkey LEFT OUTER JOIN
                      dbo.mediatypesub_view mediatypesub_view_1 ON dbo.estspecs.mediatypecode = mediatypesub_view_1.datacode AND 
                      dbo.estspecs.mediatypesubcode = mediatypesub_view_1.datasubcode LEFT OUTER JOIN
                      dbo.mediatypesub_view ON dbo.estbook.mediatypecode = dbo.mediatypesub_view.datacode AND 
                      dbo.estbook.mediatypesubcode = dbo.mediatypesub_view.datasubcode
ORDER BY dbo.estbook.estkey


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[estversion_view]  TO [public]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.ump_estcompspec_view
AS
SELECT     TOP 100 PERCENT estspecs.estkey, estspecs.versionkey, estversion.description AS versiondesc, estversion.finishedgoodqty AS quantity, 
                      trimsize_view.datadesc AS trimsize, estspecs.pagecount, estspecs.alternatebindpagecount AS insertpages, estversion.approvedind, 
                      estversion.versiontypecode, dbo.mediatypesub_view.datadesc AS versionformat, estversion.lastuserid, estversion.lastmaintdate, 
                      dbo.ink.inkdesc AS textink
FROM         dbo.estversion estversion LEFT OUTER JOIN
                      dbo.estcomp ON estversion.estkey = dbo.estcomp.estkey AND estversion.versionkey = dbo.estcomp.versionkey LEFT OUTER JOIN
                      dbo.estspecs estspecs ON estversion.estkey = estspecs.estkey AND estversion.versionkey = estspecs.versionkey LEFT OUTER JOIN
                      dbo.trimsize_view trimsize_view ON estspecs.trimfamilycode = trimsize_view.datacode LEFT OUTER JOIN
                      dbo.ink ON dbo.estcomp.inks = dbo.ink.inkkey FULL OUTER JOIN
                      dbo.mediatypesub_view ON estspecs.mediatypecode = dbo.mediatypesub_view.datacode AND 
                      estspecs.mediatypesubcode = dbo.mediatypesub_view.datasubcode
GROUP BY estspecs.estkey, estspecs.versionkey, estversion.description, estversion.finishedgoodqty, trimsize_view.datadesc, estspecs.pagecount, 
                      estspecs.alternatebindpagecount, estversion.approvedind, estversion.versiontypecode, dbo.mediatypesub_view.datadesc, estversion.lastuserid, 
                      estversion.lastmaintdate, dbo.ink.inkdesc, dbo.estcomp.compkey
HAVING      (dbo.estcomp.compkey IN (4, 5))
ORDER BY estspecs.estkey, estspecs.versionkey

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  REFERENCES ,  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[ump_estcompspec_view]  TO [public]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE VIEW dbo.ump_estimate_view
AS
SELECT     estbook.estkey, estbook.estimatename, estbook.authorillustrator, person.displayname AS estimator, estbook.pubdate, 
                      mediatypesub_view.datadesc AS format
FROM         dbo.estbook estbook INNER JOIN
                      dbo.mediatypesub_view mediatypesub_view ON estbook.mediatypecode = mediatypesub_view.datacode AND 
                      estbook.mediatypesubcode = mediatypesub_view.datasubcode LEFT OUTER JOIN
                      dbo.person person ON estbook.editorcode = person.contributorkey


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[ump_estimate_view]  TO [public]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE VIEW dbo.ump_estspec_view
AS
SELECT     TOP 100 PERCENT estspecs.estkey, estspecs.versionkey, estversion.description AS versiondesc, estversion.finishedgoodqty AS quantity, 
                      estspecs.trimsizewidth + ' x ' + estspecs.trimsizelength AS trimsize, estspecs.pagecount, estspecs.alternatebindpagecount AS insertpages, 
                      estversion.approvedind, estversion.versiontypecode, dbo.mediatypesub_view.datadesc AS versionformat, estversion.lastuserid, 
                      estversion.lastmaintdate, dbo.ink.inkdesc AS textink
FROM         dbo.estversion estversion LEFT OUTER JOIN
                      dbo.estcomp ON estversion.estkey = dbo.estcomp.estkey AND estversion.versionkey = dbo.estcomp.versionkey LEFT OUTER JOIN
                      dbo.estspecs estspecs ON estversion.estkey = estspecs.estkey AND estversion.versionkey = estspecs.versionkey LEFT OUTER JOIN
                      dbo.mediatypesub_view ON estspecs.mediatypecode = dbo.mediatypesub_view.datacode AND 
                      estspecs.mediatypesubcode = dbo.mediatypesub_view.datasubcode LEFT OUTER JOIN
                      dbo.ink ON dbo.estcomp.inks = dbo.ink.inkkey
GROUP BY estspecs.estkey, estspecs.versionkey, estversion.description, estversion.finishedgoodqty, estspecs.trimsizewidth + ' x ' + estspecs.trimsizelength, 
                      estspecs.pagecount, estspecs.alternatebindpagecount, estversion.approvedind, estversion.versiontypecode, dbo.mediatypesub_view.datadesc, 
                      estversion.lastuserid, estversion.lastmaintdate, dbo.ink.inkdesc, dbo.estcomp.compkey
HAVING      (dbo.estcomp.compkey = 3)
ORDER BY estspecs.estkey, estspecs.versionkey


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[ump_estspec_view]  TO [public]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.ump_simulestcloth_view
AS
SELECT     dbo.estbook.estkey, dbo.estversion.versionkey, dbo.estbook.estimatename, dbo.estversion.description, dbo.estbook.estimatetypecode, 
                      dbo.estversion.versiontypecode, dbo.estversion_view.versionformat, dbo.estplspecs.listprice, dbo.estplspecs.discountpercent, 
                      dbo.estplspecs.totalroyalty, dbo.estversion.finishedgoodqty, dbo.estmiscspecs.quantity AS frees
FROM         dbo.ump_compcopies_view INNER JOIN
                      dbo.estmiscspecs ON dbo.ump_compcopies_view.datacode = dbo.estmiscspecs.datacode RIGHT OUTER JOIN
                      dbo.estplspecs RIGHT OUTER JOIN
                      dbo.estversion_view ON dbo.estplspecs.estkey = dbo.estversion_view.estkey AND dbo.estplspecs.versionkey = dbo.estversion_view.versionkey ON 
                      dbo.estmiscspecs.estkey = dbo.estplspecs.estkey AND dbo.estmiscspecs.versionkey = dbo.estplspecs.versionkey RIGHT OUTER JOIN
                      dbo.estbook INNER JOIN
                      dbo.estversion ON dbo.estbook.estkey = dbo.estversion.estkey ON dbo.estversion_view.estkey = dbo.estversion.estkey AND 
                      dbo.estversion_view.versionkey = dbo.estversion.versionkey
WHERE     (dbo.estbook.estimatetypecode = 1) AND (dbo.estversion.versiontypecode = 1) AND (dbo.estversion_view.versionformat = 'Cloth Text')

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[ump_simulestcloth_view]  TO [public]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.ump_simulestpaper_view
AS
SELECT     dbo.estbook.estkey, dbo.estversion.versionkey, dbo.estbook.estimatename, dbo.estversion.description, dbo.estbook.estimatetypecode, 
                      dbo.estversion.versiontypecode, dbo.estversion_view.versionformat, dbo.estplspecs.listprice, dbo.estplspecs.discountpercent, 
                      dbo.estplspecs.totalroyalty, dbo.estversion.finishedgoodqty, dbo.estmiscspecs.quantity AS frees
FROM         dbo.ump_compcopies_view INNER JOIN
                      dbo.estmiscspecs ON dbo.ump_compcopies_view.datacode = dbo.estmiscspecs.datacode RIGHT OUTER JOIN
                      dbo.estplspecs RIGHT OUTER JOIN
                      dbo.estversion_view ON dbo.estplspecs.estkey = dbo.estversion_view.estkey AND dbo.estplspecs.versionkey = dbo.estversion_view.versionkey ON 
                      dbo.estmiscspecs.estkey = dbo.estplspecs.estkey AND dbo.estmiscspecs.versionkey = dbo.estplspecs.versionkey RIGHT OUTER JOIN
                      dbo.estbook INNER JOIN
                      dbo.estversion ON dbo.estbook.estkey = dbo.estversion.estkey ON dbo.estversion_view.estkey = dbo.estversion.estkey AND 
                      dbo.estversion_view.versionkey = dbo.estversion.versionkey
WHERE     (dbo.estbook.estimatetypecode = 1) AND (dbo.estversion.versiontypecode = 1) AND (dbo.estversion_view.versionformat = 'Paper Text')

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[ump_simulestpaper_view]  TO [public]
GO

