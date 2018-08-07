IF EXISTS (    SELECT 2
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
**  04/13/18  Colman       9.9 change  
**  04/13/18  Colman       9.9 change #2
**  05/23/18  Colman       9.9 change #3
**  05/23/18  Colman       9.9 change #4
**  05/23/18  Colman       9.9 change #5
*******************************************************************************/
BEGIN
  DECLARE @v_count INT,
          @v_dummy2 INT
  
  -- Change in 9.9
  
  -- Check the change in length after replacing the searched character with '' to get the count
  SELECT @v_count = (len(@i_text) - len(replace(@i_text, '(', ''))) - (len(@i_text) - len(replace(@i_text, ')', '')))

  IF @v_count > 0
    RETURN @i_text + REPLICATE(')', @v_count)
    
  -- change 4
    
  -- Obvious
  RETURN @i_text
END
GO

GRANT EXEC ON dbo.qutl_close_parens TO PUBLIC
GO


