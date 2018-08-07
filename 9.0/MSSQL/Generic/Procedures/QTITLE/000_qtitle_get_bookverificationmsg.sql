if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_bookverificationmsg') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_bookverificationmsg
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_bookverificationmsg
 (@i_bookkey         integer,
  @i_verifytypecode  integer,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qtitle_get_bookverificationmsg
**  Desc: This stored procedure returns info from the bookverificationmessage 
**        table. 
**             
**    Auth: Alan Katzen
**    Date: 29 November 2007
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT m.*, messagetypecode severity
    FROM bookverificationmessage m
   WHERE m.bookkey = @i_bookkey and
         m.verificationtypecode = @i_verifytypecode

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR) 
  END 

GO
GRANT EXEC ON qtitle_get_bookverificationmsg TO PUBLIC
GO


