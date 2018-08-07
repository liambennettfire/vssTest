IF EXISTS (
    SELECT *
    FROM dbo.sysobjects
    WHERE id = object_id(N'dbo.qutl_close_parens')
      AND xtype IN (N'FN', N'IF', N'TF')
    )
  DROP FUNCTION dbo.qutl_close_parens
GO

CREATE FUNCTION qutl_close_parens (
  @i_text VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)

/******************************************************************************
**  Name: qutl_close_parens
**  Desc: Add any ')' characters to match the number of '('
**
**  Auth: Colman
**  Date: 3/23/2018
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:      Description:
**  --------  ----------   ----------------------------------------------------
**    
*******************************************************************************/
BEGIN
  DECLARE @v_count INT

  -- Check the change in length after replacing the searched character with '' to get the count
  SELECT @v_count = (len(@i_text) - len(replace(@i_text, '(', ''))) - (len(@i_text) - len(replace(@i_text, ')', '')))

  IF @v_count > 0
    RETURN @i_text + REPLICATE(')', @v_count)
    
  RETURN @i_text
END
GO

GRANT EXEC ON dbo.qutl_close_parens TO PUBLIC
GO


