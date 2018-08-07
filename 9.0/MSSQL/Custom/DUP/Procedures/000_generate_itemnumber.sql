SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'generate_itemnumber')
  BEGIN
    DROP PROCEDURE generate_itemnumber
  END
GO

CREATE PROCEDURE dbo.generate_itemnumber
  @i_projectkey         INT,
  @i_elementkey         INT,
  @i_related_journalkey	INT,
  @i_productidcode      INT,
  @o_result             VARCHAR(50) OUTPUT,
  @o_error_code         INT OUTPUT,
  @o_error_desc         VARCHAR(2000) OUTPUT
AS

/*********************************************************************************************
Duke Project Detail enhancements
Case 5461 - Item #
******************************************************************************************/

BEGIN
 
  SET @o_error_code = 0
  SET @o_error_desc = ''  
  SET @o_result = ''
  
  IF @i_projectkey > 0
    SET @o_result = CONVERT(VARCHAR, @i_projectkey)
  ELSE IF @i_elementkey > 0
    SET @o_result = CONVERT(VARCHAR, @i_elementkey)
      
END
GO

GRANT EXEC ON dbo.generate_itemnumber TO PUBLIC
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO