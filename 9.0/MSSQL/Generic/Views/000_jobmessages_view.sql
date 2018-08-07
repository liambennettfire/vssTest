/****** Object:  View [dbo].[jobmessages_view]    Script Date: 03/15/2013 15:00:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[jobmessages_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
	drop view [dbo].[jobmessages_view]
GO

CREATE VIEW [dbo].[jobmessages_view] AS

SELECT m.qsijobmessagekey AS jobmessagekey, m.qsijobkey AS jobkey, j.jobtypecode,
COALESCE(i.itemtypesubcode, s.datasubcode) AS usageclasscode, m.messagecode,
CASE WHEN UPPER(COALESCE(e.gentext1, '')) = 'BOOK' THEN m.referencekey1
		 WHEN UPPER(COALESCE(e.gentext2, '')) = 'BOOK' THEN m.referencekey2
		 WHEN UPPER(COALESCE(e.gentext3, '')) = 'BOOK' THEN m.referencekey3
		 ELSE NULL END AS bookkey,
CASE WHEN UPPER(COALESCE(e.gentext1, '')) = 'PRTG' THEN m.referencekey1
		 WHEN UPPER(COALESCE(e.gentext2, '')) = 'PRTG' THEN m.referencekey2
		 WHEN UPPER(COALESCE(e.gentext3, '')) = 'PRTG' THEN m.referencekey3
		 ELSE 
		   CASE WHEN UPPER(COALESCE(e.gentext1, '')) = 'BOOK' THEN 1
		   WHEN UPPER(COALESCE(e.gentext2, '')) = 'BOOK' THEN 1
		   WHEN UPPER(COALESCE(e.gentext3, '')) = 'BOOK' THEN 1
		   ELSE NULL END
		 END AS printingkey,
CASE WHEN UPPER(COALESCE(e.gentext1, '')) = 'PROJ' THEN m.referencekey1
		 WHEN UPPER(COALESCE(e.gentext2, '')) = 'PROJ' THEN m.referencekey2
		 WHEN UPPER(COALESCE(e.gentext3, '')) = 'PROJ' THEN m.referencekey3
		 ELSE NULL END AS projectkey,
CASE WHEN UPPER(COALESCE(e.gentext1, '')) = 'ELEMENT' THEN m.referencekey1
		 WHEN UPPER(COALESCE(e.gentext2, '')) = 'ELEMENT' THEN m.referencekey2
		 WHEN UPPER(COALESCE(e.gentext3, '')) = 'ELEMENT' THEN m.referencekey3
		 ELSE NULL END AS elementkey,
CASE WHEN UPPER(COALESCE(e.gentext1, '')) = 'CONTACT' THEN m.referencekey1
		 WHEN UPPER(COALESCE(e.gentext2, '')) = 'CONTACT' THEN m.referencekey2
		 WHEN UPPER(COALESCE(e.gentext3, '')) = 'CONTACT' THEN m.referencekey3
		 ELSE NULL END AS contactkey,
CASE WHEN UPPER(COALESCE(e.gentext1, '')) = 'FOLDER' THEN m.referencekey1
		 WHEN UPPER(COALESCE(e.gentext2, '')) = 'FOLDER' THEN m.referencekey2
		 WHEN UPPER(COALESCE(e.gentext3, '')) = 'FOLDER' THEN m.referencekey3
		 ELSE NULL END AS cloudfolderkey,
CASE WHEN m.messagecode is not null THEN r.code2 ELSE m.messagetypecode END AS messagetypecode,
CASE WHEN m.messagecode is not null THEN e2.gentext1 ELSE m.messageshortdesc END AS messageshortdesc,
m.messagelongdesc, m.lastuserid, m.lastmaintdate
FROM qsijobmessages m
JOIN qsijob j ON (m.qsijobkey = j.qsijobkey)
JOIN gentables g ON (g.tableid=550 AND g.qsicode=13)
OUTER APPLY (select top 1 itemtypesubcode from gentablesitemtype it where it.tableid=543 AND it.itemtypecode = g.datacode AND it.datacode = j.jobtypecode) i --tableid=636?
JOIN gentables_ext e ON (e.datacode = j.jobtypecode)
LEFT JOIN gentablesrelationshipdetail r ON (r.code1 = m.messagecode AND r.gentablesrelationshipkey=26)
LEFT JOIN gentables_ext e2 ON (e2.datacode = m.messagecode AND e2.tableid=651)
LEFT JOIN subgentables s ON (s.tableid=550 AND s.qsicode=34)
WHERE e.tableid=543

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[jobmessages_view]  TO [public]
GO
