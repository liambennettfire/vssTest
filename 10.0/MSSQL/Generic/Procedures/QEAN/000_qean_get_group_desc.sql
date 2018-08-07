IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_get_group_desc')
  BEGIN
    DROP PROCEDURE qean_get_group_desc
  END
GO

CREATE PROCEDURE dbo.qean_get_group_desc
 (@i_eanprefix          VARCHAR(3),
  @i_group_element      VARCHAR(5),
  @o_group_desc         VARCHAR(50) OUTPUT,
  @o_group_desc_detail  VARCHAR(255) OUTPUT,
  @o_error_code         INT OUTPUT,
  @o_error_desc         VARCHAR(2000) OUTPUT)
AS

/************************************************************************************
**  Name: qean_get_group_desc
**  Desc: Returns group description for passed group element.
**
**  Auth: Kate J. Wiewiora
**  Date: 10 July 2006
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
**  --------     --------    -------------------------------------------
**  11/04/2016   Colman      40804 - Support for 979 EAN prefix
*************************************************************************************/

DECLARE 
  @v_group_desc         VARCHAR(50),
  @v_group_desc_detail  VARCHAR(255),
  @v_group_int          INT,
  @v_error              INT,
  @v_rowcount           INT,
  @v_eanprefixcode      INT

BEGIN
  -- Default return values
  SET @o_group_desc = ''
  SET @o_group_desc_detail = ''
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_eanprefixcode = 0
  
  -- Convert the passed Group Element to integer
  SET @v_group_int = CONVERT(INT, @i_group_element)   
  SELECT @v_eanprefixcode = COALESCE(datacode, 0) FROM gentables WHERE tableid = 138 AND datadesc = @i_eanprefix
  
  -- Get group description from isbngroup table for this group
  SELECT @v_group_desc = groupdesc, @v_group_desc_detail = groupdescdetail
  FROM isbngroup
  WHERE isbngroup = @v_group_int
    AND (@v_eanprefixcode = 0 OR eanprefixcode = @v_eanprefixcode)
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access isbngroup table (isbngroup=' + @i_group_element + ').'
    RETURN
  END	
  
  IF @v_rowcount = 0
  BEGIN
    SET @o_error_code = -2
    SET @o_error_desc = 'Language/Country Group ' + @i_group_element + ' is not defined for EAN prefix ' + @i_eanprefix
    RETURN
  END     
  
  -- Set return values
  SET @o_group_desc = @v_group_desc
  SET @o_group_desc_detail = @v_group_desc_detail    

END
GO

GRANT EXEC ON dbo.qean_get_group_desc TO PUBLIC
GO
