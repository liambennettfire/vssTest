SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_contributorlist]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_contributorlist]
GO

CREATE FUNCTION dbo.qweb_get_contributorlist 
      (@i_websitekey INT,
       @i_bookkey    INT,
       @i_roletype   VARCHAR(40),
       @i_delimiter  VARCHAR(5))

RETURNS  VARCHAR(4000)

/*  The purpose of the qweb_get_contributorlist function is to return a list of contributors */
/*  (by displayname) from the qweb_wh_titlecontributor table based upon the bookkey. */

/*  PARAMETER OPTIONS

    @i_roletype
      'ALL' Returns all contributors for the bookkey
      For role specific lists:
      'Author' would return contributors with a role type of Author
      'Editor' would return contributors with a role type of Editor
      etc.

    @i_delimiter = delimiter to put between contributors - defaults to '||'
      
*/
AS

BEGIN

  DECLARE @RETURN         VARCHAR(120)
  DECLARE @v_desc         VARCHAR(4000)
  DECLARE @i_count        INT    
  DECLARE @v_displayname  VARCHAR(150)
  DECLARE @v_delimiter    VARCHAR(5)
  DECLARE @v_websitekey   INT

  IF @i_bookkey is null BEGIN
    RETURN ''
  END

  IF @i_delimiter is null OR rtrim(ltrim(@i_delimiter)) = '' BEGIN
    SET @v_delimiter = '||'
  END
  ELSE BEGIN
    SET @v_delimiter = @i_delimiter
  END
   
  IF @i_websitekey is null BEGIN
    SET @v_websitekey = 1
  END
  ELSE BEGIN
    SET @v_websitekey = @i_websitekey
  END 

  SET @v_desc = ''

  IF lower(@i_roletype) = 'all' BEGIN
     DECLARE c_contributor CURSOR FOR
      SELECT displayname
        FROM qweb_wh_titlecontributors
       WHERE websitekey = @v_websitekey
         AND bookkey = @i_bookkey
    ORDER BY sortorder
    FOR READ ONLY
  END
  ELSE BEGIN 
     DECLARE c_contributor CURSOR FOR
      SELECT displayname
        FROM qweb_wh_titlecontributors
       WHERE websitekey = @v_websitekey
         AND bookkey = @i_bookkey
         AND lower(roletype) = lower(@i_roletype)
    ORDER BY sortorder
    FOR READ ONLY
  END

  OPEN c_contributor

  FETCH NEXT FROM c_contributor INTO @v_displayname

  WHILE (@@FETCH_STATUS = 0) BEGIN
    IF @v_displayname IS NOT NULL AND ltrim(rtrim(@v_displayname)) != '' BEGIN
      IF @v_desc = '' BEGIN
        SET @v_desc = ltrim(rtrim(@v_displayname))
      END
      ELSE BEGIN
        SET @v_desc = @v_desc + @v_delimiter + ltrim(rtrim(@v_displayname))
      END
    END

    FETCH NEXT FROM c_contributor INTO @v_displayname
  END

  CLOSE c_contributor
  DEALLOCATE c_contributor

  return @v_desc
END

GO

GRANT EXEC ON dbo.qweb_get_contributorlist TO public
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

