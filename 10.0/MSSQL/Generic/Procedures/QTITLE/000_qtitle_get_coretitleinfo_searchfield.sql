IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_coretitleinfo_searchfield]') AND type in (N'P', N'PC'))
  DROP PROCEDURE [dbo].[qcs_get_coretitleinfo_searchfield]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qtitle_get_coretitleinfo_searchfield]') AND type in (N'P', N'PC'))
  DROP PROCEDURE [dbo].[qtitle_get_coretitleinfo_searchfield]
GO

/******************************************************************************
**  Name: qtitle_get_coretitleinfo_searchfield
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  02/10/2016   UK		     Case 36206
**  08/09/2016   UK		     Case 39731
**  11/21/2017   JH			 V10 - TM-125 ( Removed keywords for performance sake )
*******************************************************************************/

CREATE PROCEDURE [dbo].[qtitle_get_coretitleinfo_searchfield] (
	@bookkey INT,
	@searchfield VARCHAR(MAX) OUTPUT)
AS
BEGIN
	DECLARE @productnumber VARCHAR(50),
			@productnumberx VARCHAR(50),
			@altproductnumber VARCHAR(50),
			@altproductnumberx VARCHAR(50),
			@title	VARCHAR(255),
			@subtitle VARCHAR(255),
			@authorname	VARCHAR(255),
			@linklevelcode INT,
			@prodnumlockey INT,
			@alt_prodnumlockey INT
    
	SET @searchfield = ''
	
  /*** Check if this is a set ***/
  SELECT @linklevelcode = linklevelcode
  FROM book
  WHERE bookkey = @bookkey

  IF @linklevelcode = 30
    BEGIN
      SET @prodnumlockey = 2 
      SET @alt_prodnumlockey = 4
    END
  ELSE
    BEGIN
      SET @prodnumlockey = 1
      SET @alt_prodnumlockey = 3
    END	
    
    SELECT @productnumber = dbo.qutl_get_productnumber(@prodnumlockey, @bookkey)
    SET @productnumberx = REPLACE(@productnumber, '-', '')

	SELECT @altproductnumber = altproductnumber,
		   @altproductnumberx = altproductnumberx
	FROM coretitleinfo
	WHERE bookkey = @bookkey

	SELECT @title = b.title,
		   @subtitle = b.subtitle,
		   @authorname = bd.fullauthordisplayname
	FROM book b
	JOIN isbn i
		ON b.bookkey = i.bookkey
	JOIN bookdetail bd
		ON bd.bookkey = i.bookkey
	WHERE i.bookkey = @bookkey

	SET @searchfield = COALESCE(@productnumber, '')
		+ '|' + COALESCE(@altproductnumber, '')
		+ '|' + COALESCE(@title, '')
		+ '|' + COALESCE(@subtitle, '')
		+ '|' + COALESCE(@authorname, '')
	IF COALESCE(@productnumber, '') <> COALESCE(@productnumberx, '')
	BEGIN
		SET @searchfield = @searchfield + '|' + COALESCE(@productnumberx, '')
	END
	IF COALESCE(@altproductnumber, '') <> COALESCE(@altproductnumberx, '')
	BEGIN
		SET @searchfield = @searchfield + '|' + COALESCE(@altproductnumberx, '')
	END

	IF LEN(@searchfield) > 900
	BEGIN
		SET @searchfield = SUBSTRING(@searchfield, 0, 900)
	END

END
GO

GRANT EXEC ON [dbo].[qtitle_get_coretitleinfo_searchfield] TO PUBLIC
GO

