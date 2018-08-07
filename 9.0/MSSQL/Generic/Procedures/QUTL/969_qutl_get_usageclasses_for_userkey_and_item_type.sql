if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_usageclasses_for_userkey_and_item_type') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_usageclasses_for_userkey_and_item_type
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_get_usageclasses_for_userkey_and_item_type
 (@i_userkey        integer,
  @i_itemtypecode   integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_usageclasses_for_userkey_and_item_type
**  Desc: This stored procedure returns all usage classes for a user.
**
**    Auth: marcus keyser
**    Date: 2012.01.23
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:        Description:
**    --------    --------       -------------------------------------------
**    2012.01.23  marcus         created for case # 12657 Usage Class Security
**
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @itemtypecode_var INT

	--if there are any usageclass=0 for this item type/user then list ALL usagetypes for the subgentable (this is the way the way menus used to work)
	declare  @i_SkipThis integer
	set @i_SkipThis= (select count(*) from qsiusersusageclass where itemtypecode=@i_itemtypecode and usageclasscode=0 and userkey=@i_userkey)
	
  IF @i_SkipThis=0
		SELECT 
			uuc.itemtypecode as datacode, uuc.usageclasscode as datasubcode, 
			gt.datadesc as itemtype, subgt.datadesc as usageclass, subgt.datadesc, subgt.subgen1ind 
		FROM 
			qsiusersusageclass uuc 
			inner join gentables gt on uuc.itemtypecode=gt.datacode and gt.tableid = 550
			inner join subgentables subgt on uuc.itemtypecode = subgt.datacode and uuc.usageclasscode = subgt.datasubcode and subgt.tableid = 550
		WHERE
			uuc.userkey=@i_userkey
			and uuc.itemtypecode=@i_itemtypecode		
			and (subgt.deletestatus in ('N','n') or subgt.deletestatus is null)
		ORDER BY subgt.datadesc
	ELSE
		SELECT subgt.datacode, subgt.datasubcode,
		  subgt.datadesc as usageclass, subgt.datadesc, subgt.subgen1ind 
		FROM subgentables subgt
		WHERE 
			subgt.tableid = 550 
			and subgt.datacode=@i_itemtypecode
			and (subgt.deletestatus in ('N','n') or subgt.deletestatus is null)
		ORDER BY subgt.datadesc 

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Database Error: Unable to access qsiusersusageclass (userkey = ' + cast(@i_userkey as varchar) + ').'   
  END 
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'No Data Found on qsiusersusageclass for userkey = ' + cast(@i_userkey as varchar) + '.'   
  END 

GO
GRANT EXEC ON qutl_get_usageclasses_for_userkey_and_item_type TO PUBLIC
GO


