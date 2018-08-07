/****** Object:  View [dbo].[globalcontactrelationship_view]    Script Date: 02/06/2015 17:09:16 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[globalcontactrelationship_view]'))
DROP VIEW [dbo].[globalcontactrelationship_view]
GO

/****** Object:  View [dbo].[globalcontactrelationship_view]    Script Date: 02/06/2015 17:09:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE VIEW [dbo].[globalcontactrelationship_view] 
AS

  /********************************************************************************************************
  **  Change History
  *********************************************************************************************************
  **  Date:        Author:    Description:
  **  ----------   --------   -----------------------------------------------------------------------------
  **  06/22/2018   Colman     52137 Ship To Attention Names not displaying correctly on PO 
  *********************************************************************************************************/

  SELECT r.globalcontactrelationshipkey, 
	  r.globalcontactkey1, 
	  gc1.searchname contactname1,
	  r.globalcontactkey2,	
	  COALESCE(r.globalcontactname2, gc2.searchname, '') globalcontactname2, 
	  gc2.searchname contactname2,
	  r.contactrelationshipcode1, 
	  r.contactrelationshipcode2, 
	  r.contactrelationshipaddtldesc, 
	  r.keyind, 
	  r.lastuserid, 
	  r.lastmaintdate, 
	  r.sortorder
  FROM globalcontactrelationship r, globalcontact gc1, globalcontact gc2
  WHERE r.globalcontactkey1 = gc1.globalcontactkey AND 
	  r.globalcontactkey2 = gc2.globalcontactkey AND
	  r.globalcontactkey2 > 0
  UNION
  SELECT r.globalcontactrelationshipkey, 
	  r.globalcontactkey1, 
	  gc1.searchname contactname1,
	  r.globalcontactkey2,	
	  ISNULL(r.globalcontactname2, '') globalcontactname2, 
	  r.globalcontactname2 contactname2,
	  r.contactrelationshipcode1, 
	  r.contactrelationshipcode2, 
	  r.contactrelationshipaddtldesc, 
	  r.keyind, 
	  r.lastuserid, 
	  r.lastmaintdate, 
	  r.sortorder
  FROM globalcontactrelationship r, globalcontact gc1
  WHERE r.globalcontactkey1 = gc1.globalcontactkey AND 
	  (r.globalcontactkey2 IS NULL OR r.globalcontactkey2 = 0)

GO


