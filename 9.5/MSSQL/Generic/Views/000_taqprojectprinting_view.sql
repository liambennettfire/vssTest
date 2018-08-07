if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[taqprojectprinting_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[taqprojectprinting_view]
GO

CREATE VIEW taqprojectprinting_view AS
SELECT DISTINCT tpt.taqprojectkey, tpt.bookkey, tpt.printingkey,
       p.printingnum,p.trimsizewidth,p.trimsizelength,p.esttrimsizewidth,p.esttrimsizelength,
       p.tmmactualtrimwidth,p.tmmactualtrimlength,p.pubmonthcode, p.pubmonth,p.creationdate,
       p.seasonkey, p.lastuserid, p.lastmaintdate,tpt.projectrolecode,
       ct.mediatypecode, ct.mediatypesubcode, ct.productnumber, ct.title, ct.subtitle, p.jobnumberalpha         
  FROM taqprojecttitle tpt
       LEFT OUTER JOIN printing p ON (tpt.bookkey = p.bookkey AND tpt.printingkey = p.printingkey)         -- needs to be outer join because of add printing process  
       LEFT OUTER JOIN coretitleinfo ct ON (tpt.bookkey = ct.bookkey AND tpt.printingkey = ct.printingkey) -- in TMM Web
 WHERE tpt.taqprojectkey > 0
   and tpt.projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 and qsicode = 3)
   and tpt.titlerolecode = (SELECT datacode FROM gentables WHERE tableid = 605 and qsicode = 7)
   
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[taqprojectprinting_view]  TO [public]
GO