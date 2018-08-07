IF EXISTS (
	SELECT *
	FROM dbo.sysobjects
	WHERE id = Object_id('dbo.udf_StripDIVHTMLTags') AND type = 'FN'
	--AND OBJECTPROPERTY(id, N'IsProcedure') = 1 
	)
BEGIN
	DROP FUNCTION dbo.udf_StripDIVHTMLTags
END

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

CREATE  FUNCTION dbo.udf_StripDIVHTMLTags
	(@HTMLText NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @iPosStart INT
    DECLARE @iPosStart2 INT
    DECLARE	@iPosEnd INT
    
      
	IF	SUBSTRING(@HTMLText,1,len('<DIV>&#160;</DIV>')) = '<DIV>&#160;</DIV>' BEGIN
		SET @HTMLText = STUFF(@HTMLText, 1, len('<DIV>&#160;</DIV>'), '&#160;<BR>')
		IF	SUBSTRING(@HTMLText,len('&#160;<BR>')+ 1,len('<div>')) = '<div>'
			AND  SUBSTRING(@HTMLText,len(@HTMLText)-len('</div>')+1,len('</div>')) = '</div>' BEGIN
			SET @iPosStart=len('&#160;<BR>')+ 1
			IF @iPosStart> 0	BEGIN
				SET @HTMLText = STUFF(@HTMLText, @iPosStart, len('<div>'), '')
				SET @HTMLText = REVERSE(@HTMLText)
				SET @iPosStart2=CHARINDEX('>VID/<',@HTMLText,1)
				SET @HTMLText = STUFF(@HTMLText, @iPosStart2, len('>VID/<'), '>RB<')
				SET @HTMLText = REVERSE(@HTMLText)
			END
		END
	END
		    
		
	IF	SUBSTRING(@HTMLText,1,len('<div>')) = '<div>'
		AND  SUBSTRING(@HTMLText,len(@HTMLText)-len('</div>')+1,len('</div>')) = '</div>' BEGIN
		SET @iPosStart=1
		SET @iPosEnd=1	
		WHILE @iPosStart=1 	BEGIN
		    SET @iPosStart=CHARINDEX('<div>',@HTMLText,@iPosStart)
			IF @iPosStart=1	BEGIN
				SET @HTMLText = STUFF(@HTMLText, 1, len('<div>'), '')
				SET @HTMLText = REVERSE(@HTMLText)
				SET @iPosStart2=CHARINDEX('>VID/<',@HTMLText,1)
				SET @HTMLText = STUFF(@HTMLText, @iPosStart2, len('>VID/<'), '>RB<')
				SET @HTMLText = REVERSE(@HTMLText)
			END
		END
	END
	
	IF	SUBSTRING(@HTMLText,1,len('<div>')) = '<div>'
		AND  SUBSTRING(@HTMLText,len(@HTMLText)-len('&#160;</P>')+1,len('&#160;</P>')) = '&#160;</P>' BEGIN
			SET @HTMLText = STUFF(@HTMLText, 1, len('<div>'), '')
	END
	
	SET @iPosStart=CHARINDEX('</DIV><DIV>',@HTMLText,1)
	WHILE @iPosStart> 0 BEGIN
		SET @HTMLText = STUFF(@HTMLText, @iPosStart, len('</DIV><DIV>'), '<BR>')
		SET @iPosStart=CHARINDEX('</DIV><DIV>',@HTMLText,@iPosStart)
	END
	
	
	RETURN @HTMLText
END

GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXEC
	ON dbo.udf_StripDIVHTMLTags
	TO PUBLIC
GO