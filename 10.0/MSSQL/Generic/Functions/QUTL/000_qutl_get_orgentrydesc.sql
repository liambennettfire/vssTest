SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qutl_get_orgentrydesc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qutl_get_orgentrydesc]
GO


CREATE FUNCTION dbo.qutl_get_orgentrydesc
    (@i_orglevelkey INT,
     @i_orgentrykey INT,
     @v_column  VARCHAR(1))

RETURNS VARCHAR(255)

/*  The purpose of the qutl_get_orgentrydesc function is to return a specific description column from orgentry 
    for a specific orgentry

  Parameter Options
    F = Group Level Description
    S = Group Level Short Description
    1 = Alternative Description 1
    2 = Alternative Deccription 2
*/  

AS

BEGIN

  DECLARE @RETURN      VARCHAR(255)
  DECLARE @v_desc      VARCHAR(255)

  IF @v_column = 'F' 
    BEGIN
      SELECT @v_desc = ltrim(rtrim(orgentrydesc))
        FROM orgentry
       WHERE orglevelkey = @i_orglevelkey
         AND orgentrykey = @i_orgentrykey
      
      IF datalength(@v_desc) > 0
        BEGIN
          SELECT @RETURN = @v_desc
        END
      ELSE
        BEGIN
          SELECT @RETURN = ''
        END
    END
  ELSE IF @v_column = 'S'
    BEGIN
      SELECT @v_desc = ltrim(rtrim(orgentryshortdesc))
        FROM orgentry
       WHERE orglevelkey = @i_orglevelkey
         AND orgentrykey = @i_orgentrykey
      
      IF datalength(@v_desc) > 0
        BEGIN
          SELECT @RETURN = @v_desc
        END
      ELSE
        BEGIN
          SELECT @RETURN = ''
        END
    END
  ELSE IF @v_column = '1'
    BEGIN
      SELECT @v_desc = ltrim(rtrim(altdesc1))
        FROM orgentry
       WHERE orglevelkey = @i_orglevelkey
         AND orgentrykey = @i_orgentrykey
      
      IF datalength(@v_desc) > 0
        BEGIN
          SELECT @RETURN = @v_desc
        END
      ELSE
        BEGIN
          SELECT @RETURN = ''
        END      
    END
  ELSE IF @v_column = '2'
    BEGIN
      SELECT @v_desc = ltrim(rtrim(altdesc2))
        FROM orgentry
       WHERE orglevelkey = @i_orglevelkey
         AND orgentrykey = @i_orgentrykey
      
      IF datalength(@v_desc) > 0
        BEGIN
          SELECT @RETURN = @v_desc
        END
      ELSE
        BEGIN
          SELECT @RETURN = ''
        END
    END

  RETURN @RETURN

END
GO

GRANT EXEC ON dbo.qutl_get_orgentrydesc TO public
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

