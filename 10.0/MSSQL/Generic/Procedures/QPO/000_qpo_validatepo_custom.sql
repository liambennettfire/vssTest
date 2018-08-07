IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[qpo_validatepo_custom]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE [dbo].[qpo_validatepo_custom]
GO

/**************************************************************************************************
**  Name: qpo_validatepo_custom
**  Desc: Stub procedure called when creating Final PO Report to enable custom validation.
**        Can be overriden by customer as needed.
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

CREATE PROCEDURE dbo.qpo_validatepo_custom
  @i_po_projectkey    INT,
  @i_po_createclass   INT,
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT
AS

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
END
GO

GRANT EXECUTE ON qpo_validatepo_custom TO PUBLIC
GO