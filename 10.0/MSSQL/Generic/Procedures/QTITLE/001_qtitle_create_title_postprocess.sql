IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[qtitle_create_title_postprocess]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE [dbo].[qtitle_create_title_postprocess]
GO

/**************************************************************************************************
**  Name: qtitle_create_title_postprocess
**  Desc: Called after title creation to allow custom post processing
**  Case: 48528
**
**  Auth: Colman
**  Date: 30 November 2017
***************************************************************************************************
**	Change History
***************************************************************************************************
**  Date	    Author  Description
**	--------	------	-----------
**************************************************************************************************/

CREATE PROCEDURE dbo.qtitle_create_title_postprocess
  @i_bookkey      INT,
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT
AS

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  EXEC qtitle_create_title_postprocess_custom @i_bookkey, @o_error_code OUT, @o_error_desc OUT
END
GO

GRANT EXECUTE ON qtitle_create_title_postprocess TO PUBLIC
GO