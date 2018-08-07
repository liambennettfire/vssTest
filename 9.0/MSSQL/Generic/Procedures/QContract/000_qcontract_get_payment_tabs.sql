if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_payment_tabs') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontract_get_payment_tabs
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_payment_tabs
 (@i_itemtype				integer,
	@i_usageclass			integer,
	@o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/************************************************************************************
**  Name: qcontract_get_payment_tabs
**  Desc: This stored procedure returns the tabs for the contract payments
**
**  Auth: Dustin Miller
**  Date: 7/16/12
*************************************************************************************/

BEGIN

  DECLARE
    @v_datacode INT,
    @v_error  INT,
    @v_rowcount INT,
    @v_title  VARCHAR(80)

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT s.*, e.gentext1
  FROM gentables_ext e, subgentables s, gentablesitemtype i
  WHERE s.tableid = 637
		AND e.tableid = s.tableid
		AND e.datacode = s.datacode
		AND i.tableid = s.tableid
		AND i.datacode = s.datacode
		AND i.datasubcode = s.datasubcode
		AND i.itemtypecode = @i_itemtype
		AND (i.itemtypesubcode = @i_usageclass OR @i_usageclass <= 0 OR i.itemtypesubcode <= 0)
  ORDER BY COALESCE(i.sortorder, 99999), COALESCE(s.sortorder, 99999) ASC

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not get contract payment tabs.'
  END
  
END
GO

GRANT EXEC ON qcontract_get_payment_tabs TO PUBLIC
GO
