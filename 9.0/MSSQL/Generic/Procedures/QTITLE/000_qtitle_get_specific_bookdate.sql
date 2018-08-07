if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_specific_bookdate') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_specific_bookdate
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_specific_bookdate
 (@i_bookkey         integer,
  @i_printingkey     integer,
  @i_datetypecode    integer,
  @i_datetypeqsicode integer,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qtitle_get_specific_bookdate
**  Desc: This stored procedure returns info from the bookdates 
**        table for a specific datetypecode or qsicode. 
**             
**        Will try qsicode first, then datetypecode 
**
**    Auth: Alan Katzen
**    Date: 20 November 2007
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  -- try qsicode first
  IF (@i_datetypeqsicode > 0) BEGIN
    SELECT d.description,d.datelabel,d.datelabelshort, 
           bd.*
      FROM bookdates bd, datetype d
     WHERE bd.datetypecode = d.datetypecode and
           bd.bookkey = @i_bookkey and
           bd.printingkey = @i_printingkey and
           d.qsicode = @i_datetypeqsicode
  END
  ELSE BEGIN
    SELECT d.description,d.datelabel,d.datelabelshort, 
           bd.*
      FROM bookdates bd, datetype d
     WHERE bd.datetypecode = d.datetypecode and
           bd.bookkey = @i_bookkey and
           bd.printingkey = @i_printingkey and
           bd.datetypecode = @i_datetypecode
  END

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
                      + ' and datetypecode = ' + cast(@i_datetypecode AS VARCHAR)
  END 

GO
GRANT EXEC ON qtitle_get_specific_bookdate TO PUBLIC
GO


