SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[person]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[person]
GO

CREATE VIEW person AS
SELECT TOP 100 PERCENT 
  c.globalcontactkey contributorkey,
  c.displayname displayname,
  c.firstname firstname,
  c.lastname lastname,
  c.middlename middlename,
  (SELECT datadesc FROM gentables 
    WHERE tableid = 210 AND 
      datacode = c.accreditationcode) title,
  (SELECT TOP 1 rolecode FROM globalcontactrole r 
    WHERE r.globalcontactkey = c.globalcontactkey AND 
      r.keyind = 1) defaultroletypecode,
  (SELECT TOP 1 gr.code2 FROM gentablesrelationshipdetail gr, globalcontactrole r 
    WHERE r.globalcontactkey = c.globalcontactkey AND              
      r.rolecode = gr.code1 AND 
      r.keyind = 1 AND
      gr.gentablesrelationshipkey = 12 AND 
      gr.defaultind = 1) defaultdeptypecode,
  c.activeind activeind,
  c.individualind persontypecode,
  c.lastuserid lastuserid,
  c.lastmaintdate lastmaintdate,
  c.shortname shortname,
  340 tableid,
  c.lockbyqsiind lockbyqsiind,
  c.lockbyeloquenceind lockbyeloquenceind,
  cm.contactmethodvalue phone,
  c.externalcode1 externalcode  
FROM globalcontact c
  LEFT OUTER JOIN globalcontactmethod cm ON c.globalcontactkey = cm.globalcontactkey AND cm.contactmethodcode = 1 AND cm.primaryind = 1
WHERE c.personnelind = 1 
ORDER BY displayname

GO


SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[person]  TO [public]
GO




