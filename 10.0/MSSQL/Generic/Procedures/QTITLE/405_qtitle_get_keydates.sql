if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_keydates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_keydates
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_keydates
 (@i_bookkey        integer,
  @i_printingkey    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qtitle_get_keydates
**  Desc: This stored procedure returns info from the bookdates 
**        table. 
**              
**
**    Auth: Alan Katzen
**    Date: 29 March 2004
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
  DECLARE @v_ExpectedShipDateTypeCode INT

  -- do not want to show expectedshipdate (qsicode = 9) as part of keydates
  SELECT @v_ExpectedShipDateTypeCode = COALESCE(datetypecode,0) 
    FROM datetype  
   WHERE qsicode = 9;
  
  IF @v_ExpectedShipDateTypeCode is null BEGIN
    SET @v_ExpectedShipDateTypeCode = 0
  END 

  SELECT d.description,d.datelabel,d.datelabelshort, 
         bd.*
    FROM bookdates bd, datetype d
   WHERE bd.datetypecode = d.datetypecode and
         bd.bookkey = @i_bookkey and
         bd.printingkey = @i_printingkey and
         bd.datetypecode NOT IN (387,@v_ExpectedShipDateTypeCode)        
ORDER BY bd.sortorder

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qtitle_get_keydates TO PUBLIC
GO


