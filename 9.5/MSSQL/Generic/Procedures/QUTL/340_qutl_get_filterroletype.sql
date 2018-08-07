if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_filterroletype') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_filterroletype
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qutl_get_filterroletype
 (@i_filterkey      integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qutl_get_filterroletype
**  Desc: This stored procedure returns the roletypecode and description
**        for the filter roletype.
**              
**
**    Auth: Alan Katzen
**    Date: 18 April 2005
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT

  select COALESCE(f.roletypecode,0) rolecode, COALESCE(g.datadesc, '') rolelabel
    from filterroletype f, gentables g
   where f.roletypecode = g.datacode
     and f.filterkey = @i_filterkey
     and g.tableid = 285

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error: unable to access filterroletype table for filterkey = ' + cast(@i_filterkey AS VARCHAR)
    return
  END 

  IF @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error: unable to find filterkey = ' + cast(@i_filterkey AS VARCHAR) + ' on filterroletype table.'
    return
  END

GO
GRANT EXEC ON qutl_get_filterroletype TO PUBLIC
GO


