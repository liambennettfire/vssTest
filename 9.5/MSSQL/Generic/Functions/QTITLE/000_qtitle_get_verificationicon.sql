if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_verificationicon') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qtitle_get_verificationicon
GO

CREATE FUNCTION dbo.qtitle_get_verificationicon
(
  @i_verificationtype as integer,
  @i_verificationstatus as integer
) 
RETURNS VARCHAR(100)

/******************************************************************************
**  Name: qtitle_get_verificationicon
**  Desc: This function returns the verification icon from verificationicons
**        based on the verification type and status
**
**  Auth: Alan Katzen
**  Date: 13 December 2007
*******************************************************************************/

BEGIN 
  DECLARE
    @v_count      INT,
    @v_iconname   VARCHAR(100)
    
  SELECT @v_count = COUNT(*)
    FROM verificationicons
   WHERE datacode = @i_verificationtype
     AND successcode = @i_verificationstatus
  
  IF @v_count = 0 BEGIN
    RETURN ''
  END

  SELECT @v_iconname = COALESCE(iconname,'')
    FROM verificationicons
   WHERE datacode = @i_verificationtype
     AND successcode = @i_verificationstatus
  
  RETURN @v_iconname
END
GO

GRANT EXEC ON dbo.qtitle_get_verificationicon TO public
GO
