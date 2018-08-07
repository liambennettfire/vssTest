SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_wh_get_short_briefdesc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_wh_get_short_briefdesc]
GO

CREATE FUNCTION dbo.qweb_wh_get_short_briefdesc 
  (@i_websitekey     INT,
   @i_bookkey        INT,
   @i_type           INT,
   @i_maxchars       INT)
    

/*        The parameters are for the book key and comment format type.  

  @i_type
    1 = Plain Text
    2 = HTML
    3 = HTML Lite

  @i_maxchars = total number of characters to return (add ... to end if more)
*/

RETURNS VARCHAR(8000)

AS  

BEGIN 

  DECLARE @i_commenttype           VARCHAR(40)
  DECLARE @i_commentsubtype_brief  VARCHAR(40)
  DECLARE @i_commentsubtype_desc   VARCHAR(40)
  DECLARE @v_text                  VARCHAR(8000)
  DECLARE @RETURN                  VARCHAR(8000)

/*  INITIALIZE Comment Types    */
  SELECT @i_commenttype = 'editorial'
  SELECT @i_commentsubtype_brief = 'brief description' 
  SELECT @i_commentsubtype_desc = 'description'
  SELECT @v_text = ''

/*  GET comment formats      */
  IF @i_type = 1
    BEGIN
      SELECT @v_text = CAST(commenttext AS VARCHAR(8000))
        FROM qweb_wh_titlecomments
       WHERE websitekey = @i_websitekey
         AND bookkey = @i_bookkey
         AND commenttype = @i_commenttype
         AND commentsubtype = @i_commentsubtype_brief

--      IF @v_text is null OR ltrim(rtrim(@v_text)) = '' BEGIN
--        -- use full description
--        SELECT @v_text = CAST(commenttext AS VARCHAR(8000))
--          FROM qweb_wh_titlecomments
--         WHERE websitekey = @i_websitekey
--           AND bookkey = @i_bookkey
--           AND commenttype = @i_commenttype
--           AND commentsubtype = @i_commentsubtype_desc
--      END 
    END

  IF @i_type = 2
    BEGIN
      SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
        FROM qweb_wh_titlecomments
       WHERE websitekey = @i_websitekey
         AND bookkey = @i_bookkey
         AND commenttype = @i_commenttype
         AND commentsubtype = @i_commentsubtype_brief

--      IF @v_text is null OR ltrim(rtrim(@v_text)) = '' BEGIN
--        -- use full description
--        SELECT @v_text = CAST(commenthtml AS VARCHAR(8000))
--          FROM qweb_wh_titlecomments
--         WHERE websitekey = @i_websitekey
--           AND bookkey = @i_bookkey
--           AND commenttype = @i_commenttype
--           AND commentsubtype = @i_commentsubtype_desc
--      END 
    END

  IF @i_type = 3
    BEGIN
      SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
        FROM qweb_wh_titlecomments
       WHERE websitekey = @i_websitekey
         AND bookkey = @i_bookkey
         AND commenttype = @i_commenttype
         AND commentsubtype = @i_commentsubtype_brief

--      IF @v_text is null OR ltrim(rtrim(@v_text)) = '' BEGIN
--        -- use full description
--        SELECT @v_text = CAST(commenthtmllite AS VARCHAR(8000))
--          FROM qweb_wh_titlecomments
--         WHERE websitekey = @i_websitekey
--           AND bookkey = @i_bookkey
--           AND commenttype = @i_commenttype
--           AND commentsubtype = @i_commentsubtype_desc
--      END 
    END


  IF @v_text is NOT NULL BEGIN
    IF @i_maxchars > 0 BEGIN
      IF datalength(ltrim(rtrim(@v_text))) > @i_maxchars BEGIN
        SELECT @v_text = left(ltrim(rtrim(@v_text)),@i_maxchars) + '...'
      END
    END

    SELECT @RETURN = LTRIM(RTRIM(@v_text))
  END
  ELSE BEGIN
    SELECT @RETURN = ''  
  END

  RETURN @RETURN

END

GO

GRANT EXEC ON dbo.qweb_wh_get_short_briefdesc TO public
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

