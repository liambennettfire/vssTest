  if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpo_get_po_vendor') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qpo_get_po_vendor
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpo_get_po_vendor
 (@i_userkey integer,
  @i_projectkey  integer,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/*****************************************************************************************************************
**  Name: qpo_get_po_vendor
**  Desc: This stored procedure gets the Shipping Locations Information for PO reports.
**
**  Auth: Uday A. Khisty
**  Date: 17 February 2017
**
*********************************************************************************************************************
**  Change History
**********************************************************************************************************************
**  Date:      Author:   Description:
**  --------   ------    ---------------------------------------------------------------------------------
**  05/10/17   Uday      Case 42347 - Task 001
******************************************************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @v_error_var    INT,
		  @v_rowcount_var INT
		  		
  SELECT 
  g.gpokey,
  g.vendorname,
  COALESCE(g.vendoraddress1, '') + '<br />' + COALESCE(g.vendoraddress2, '') + '<br />' + COALESCE(g.vendorcity, '') + '<br />' + COALESCE(g.vendorstate, '')  + '<br />' + COALESCE(g.vendorzipcode, '') AS address,
  g.vendorattn,
  (SELECT c.email FROM corecontactinfo c WHERE c.contactkey = g.vendorkey) AS email,
  (SELECT c.phone FROM corecontactinfo c WHERE c.contactkey = g.vendorkey) AS phone,
  dbo.qcontact_is_contact_private(g.vendorkey, @i_userkey) AS isprivate		  
  FROM gpo g
  WHERE gpokey = @i_projectkey

  SELECT @v_error_var = @@ERROR, @v_rowcount_var = @@ROWCOUNT
  IF @v_error_var <> 0 or @v_rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing gpo: gpokey = ' + cast(@i_projectkey AS VARCHAR)
  END 

GO

GRANT EXEC ON qpo_get_po_vendor TO PUBLIC
GO


