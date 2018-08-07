if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qprinting_get_printing_detail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qprinting_get_printing_detail
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qprinting_get_printing_detail
 (@i_projectkey     integer,
  @o_error_code     integer       output,
  @o_error_desc     varchar(2000) output)
AS

/********************************************************************************************
**  Name: qprinting_get_printing_detail
**  Desc: This gets the detail information needed for the Printing Summary
**        screen and any other control which uses a subset of this information.
**
**    Auth: Uday A. Khisty
**    Date: 15 May 2014
*********************************************************************************************
**  Change History
*********************************************************************************************
**  Date:     Author:     Description:
**  --------  --------    -----------------------------------------------------
**  02/14/17  Colman      43021: Add link to printing details for related contract
**  09/27/17  Kate        47245: Add productnumber in front of title for Printing projects.
**  10/11/17  Colman      47248 - Currency on Purchase Orders
**	03/27/18  Colman      50550 - Return defaulttemplateind
*********************************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT c.projectheaderorg1key, c.projectheaderorg1desc,
      c.projectheaderorg2key, c.projectheaderorg2desc, 
      p.taqprojectkey, p.taqprojectownerkey, p.taqprojecttitleprefix, p.taqprojecttitle, 
      p.taqprojectsubtitle, p.taqprojecttype, p.taqprojectstatuscode,
      p.taqprojecteditionnumcode, p.taqprojecteditiontypecode, p.taqprojecteditiondesc, 
      p.taqprojectseriescode, p.taqprojectvolumenumber, p.termsofagreement, p.subsidyind, p.templateind,
      u.firstname, u.lastname, p.searchitemcode, p.usageclasscode, p.idnumber, p.additionaleditioninfo,
      p.plenteredcurrency, p.plapprovalcurrency, tp.bookkey, tp.printingkey, tp.printingnum, 
      (SELECT title from coretitleinfo ct where ct.bookkey = tp.bookkey and ct.printingkey = tp.printingkey) booktitle,
	  (SELECT productnumber from coretitleinfo ct where ct.bookkey = tp.bookkey AND ct.printingkey = tp.printingkey) bookproductnumber,
      p.autogeneratenameind, rp.taqprojectkey AS relatedcontractkey, rp.taqprojecttitle AS relatedcontractdesc,
      p.exchangerate, p.culturecode, p.defaulttemplateind
  FROM taqproject p
  join coreprojectinfo c on p.taqprojectkey = c.projectkey
  join taqprojectprinting_view tp on tp.taqprojectkey = c.projectkey
  left join qsiusers u on p.taqprojectownerkey = u.userkey  -- until we fix the cleanup of deleting qsiuser records, this will have to be an outer join
  LEFT JOIN taqprojectrights r ON r.taqprojectprintingkey = p.taqprojectkey
  LEFT JOIN taqproject rp ON rp.taqprojectkey = r.taqprojectkey
  WHERE p.taqprojectkey = @i_projectkey 

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qprinting_get_printing_detail TO PUBLIC
GO


