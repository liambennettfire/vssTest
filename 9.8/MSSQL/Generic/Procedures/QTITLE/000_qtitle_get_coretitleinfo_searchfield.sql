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
*******************************************************************************/

CREATE PROCEDURE [dbo].[qtitle_get_coretitleinfo_searchfield] (
	@bookkey INT,
	@searchfield VARCHAR(MAX) OUTPUT)
AS
BEGIN
	DECLARE @productnumber VARCHAR(50),
			@productnumberx VARCHAR(50),
			@title	VARCHAR(255),
			@subtitle VARCHAR(255),
			@authorname	VARCHAR(255),
			@linklevelcode INT,
			@prodnumlockey INT,
			@alt_prodnumlockey INT,
			@misckey INT,
			@misctext VARCHAR(4000),
			@elofieldid INT
    
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

	SET @misctext = NULL

	SELECT @elofieldid = datacode
	FROM gentables
	WHERE tableid = 560
	  AND eloquencefieldtag = 'DPIDXBIZKEYWORDS'

	SELECT @misckey = misckey
	FROM bookmiscitems
	WHERE eloquencefieldidcode = @elofieldid

	IF EXISTS(SELECT * FROM bookmisc WHERE bookkey = @bookkey AND misckey = @misckey)
	BEGIN
		SELECT @misctext = textvalue
		FROM bookmisc
		WHERE bookkey = @bookkey
		  AND misckey = @misckey
    END

	SELECT @title = b.title,
		   @subtitle = b.subtitle,
		   @authorname = bd.fullauthordisplayname
	FROM book b
	JOIN isbn i
		ON b.bookkey = i.bookkey
	JOIN bookdetail bd
		ON bd.bookkey = i.bookkey
	WHERE i.bookkey = @bookkey

	SET @searchfield = COALESCE(@productnumber, '') + '|' + COALESCE(@productnumberx, '') + '|' + COALESCE(@title, '') + '|' +
		COALESCE(@subtitle, '') + '|' + COALESCE(@authorname, '') + '|' + COALESCE(@misctext, '')

	IF LEN(@searchfield) > 900
	BEGIN
		SET @searchfield = SUBSTRING(@searchfield, 0, 900)
	END

END
GO

GRANT EXEC ON [dbo].[qtitle_get_coretitleinfo_searchfield] TO PUBLIC
GO

