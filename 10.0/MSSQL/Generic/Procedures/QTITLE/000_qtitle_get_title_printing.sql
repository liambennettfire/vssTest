if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_title_printing') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_title_printing
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_title_printing
 (@i_bookkey            integer,
  @i_bookkeylist        varchar(max),
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/********************************************************************************
**  Name: qtitle_get_title_printing
**  Desc: This stored procedure gets printing info for given titles.
**        Right now used to populate Prtg # drop-downs.
**
**  Auth: Kate W.
**  Date: 6 May 2011
*********************************************************************************/

DECLARE
  @v_error  INT,
  @v_quote    VARCHAR(2),  
  @v_sqlstring  NVARCHAR(max)

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF @i_bookkey > 0 
  BEGIN
    SELECT DISTINCT printingkey, CONVERT(VARCHAR,printingnum) printingnumdesc
    FROM printing
    WHERE bookkey = @i_bookkey
  END
  ELSE
  BEGIN
    IF (@i_bookkeylist is null OR ltrim(rtrim(@i_bookkeylist)) = '') BEGIN
      RETURN
    END
       
    SET @v_sqlstring = 'SELECT DISTINCT printingnum, CONVERT(VARCHAR,printingnum) printingnumdesc
    FROM printing
    WHERE bookkey IN (' + @i_bookkeylist + ')'
    
    EXECUTE sp_executesql @v_sqlstring

    PRINT @v_sqlstring
    
  END  
  
  SELECT @v_error = @@ERROR 
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access printing table.'
    RETURN
  END

END
GO

GRANT EXEC ON qtitle_get_title_printing TO PUBLIC
GO


