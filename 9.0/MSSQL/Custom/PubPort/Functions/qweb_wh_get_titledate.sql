SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_wh_get_titledate]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_wh_get_titledate]
GO

CREATE FUNCTION dbo.qweb_wh_get_titledate 
  (@i_websitekey     INT,
   @i_bookkey        INT,
   @i_datedesc       VARCHAR(100))
    
RETURNS datetime

AS  

BEGIN 

  DECLARE @RETURN                  datetime
  DECLARE @v_bestdate              datetime
  DECLARE @v_datedesc              varchar(100)

  SET @v_datedesc = @i_datedesc
  IF @v_datedesc is null BEGIN
    return null
  END  

  SELECT @v_bestdate = bestdate
    FROM qweb_wh_titledates
   WHERE websitekey = @i_websitekey
     AND bookkey = @i_bookkey
     AND datedesc = @v_datedesc

  IF COALESCE(@v_bestdate,0) <> 0 BEGIN
    return @v_bestdate
  END

  return null
END

GO

GRANT EXEC ON dbo.qweb_wh_get_titledate TO public
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

