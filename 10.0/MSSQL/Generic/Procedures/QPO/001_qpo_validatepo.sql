IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[qpo_validatepo]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE [dbo].[qpo_validatepo]
GO

/**************************************************************************************************
**  Name: qpo_validatepo
**  Desc: Called when creating a PO Report to enable custom validation.
**  Case: 50569
**
**  Auth: Colman
**  Date: 04/13/2018
***************************************************************************************************
**	Change History
***************************************************************************************************
**  Date	    Author    Description
**	--------	--------	---------------------------------------------------------------------------
***************************************************************************************************/

CREATE PROCEDURE dbo.qpo_validatepo
  @i_po_projectkey    INT,
  @i_po_createclass   INT,
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT
AS

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  EXEC qpo_validatepo_custom @i_po_projectkey, @i_po_createclass, @o_error_code OUT, @o_error_desc OUT
END
GO

GRANT EXECUTE ON qpo_validatepo TO PUBLIC
GO