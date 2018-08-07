if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[clientdefaults_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[clientdefaults_view]
GO

CREATE VIEW clientdefaults_view AS
SELECT d.clientdefaultid,d.clientdefaultname, d.clientdefaultcomment,d.clientdefaultvalue, 
  CASE d.clientdefaultid
    WHEN 1 THEN (SELECT customerlongname from customer where customerkey = d.clientdefaultvalue)
    WHEN 4 THEN (SELECT datadesc FROM gentables WHERE tableid = 312 and datacode = d.clientdefaultvalue)
    WHEN 43 THEN (SELECT datadesc FROM gentables WHERE tableid = 522 and datacode = d.clientdefaultvalue)
    WHEN 44 THEN (SELECT datadesc FROM gentables WHERE tableid = 390 and datacode = d.clientdefaultvalue)
    WHEN 45 THEN (SELECT datadesc FROM gentables WHERE tableid = 285 and datacode = d.clientdefaultvalue)
    WHEN 49 THEN (SELECT datadesc FROM gentables WHERE tableid = 613 and datacode = d.clientdefaultvalue)
    WHEN 50 THEN (SELECT datadesc FROM gentables WHERE tableid = 613 and datacode = d.clientdefaultvalue)
    WHEN 51 THEN (SELECT datadesc FROM gentables WHERE tableid = 613 and datacode = d.clientdefaultvalue)
    WHEN 55 THEN (SELECT datadesc FROM gentables WHERE tableid = 433 and datacode = d.clientdefaultvalue)
    WHEN 56 THEN (SELECT datadesc FROM gentables WHERE tableid = 565 and datacode = d.clientdefaultvalue)
    WHEN 61 THEN (SELECT datadesc FROM gentables WHERE tableid = 565 and datacode = d.clientdefaultvalue)
    ELSE NULL
  END AS clientdefaultdesc,
  CASE d.clientdefaultid
    WHEN 4 THEN (SELECT datadesc FROM subgentables WHERE tableid = 312 and datacode = d.clientdefaultvalue and datasubcode =d.clientdefaultsubvalue )
    ELSE NULL
  END AS clientdefaultsubdesc,  
  clientdefaultsubvalue, stringvalue
  FROM clientdefaults d

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[clientdefaults_view]  TO [public]
GO