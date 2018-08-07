IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_filterorglevel_desc')
  BEGIN
    PRINT 'Dropping Procedure qutl_get_filterorglevel_desc'
    DROP  Procedure  qutl_get_filterorglevel_desc
  END

GO

PRINT 'Creating Procedure qutl_get_filterorglevel_desc'
GO

CREATE PROCEDURE qutl_get_filterorglevel_desc
 (@i_filterkey        integer,
  @i_descriptiontype  varchar(20),
  @o_filterorgleveldesc  varchar(100) output,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qutl_get_filterorglevel_desc
**  Desc: 
**
**              
**    Return values:
** 
**    Called by:   
**              
**    Parameters:
**    Input              Output
**    ----------              -----------
**
**    Auth: 
**    Date: 
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

  IF @i_descriptiontype = 'long' BEGIN
    SELECT @o_filterorgleveldesc = orgleveldesc
      FROM orglevel o, filterorglevel f
     WHERE o.orglevelkey = f.filterorglevelkey and
           f.filterkey = @i_filterkey;
  END
  ELSE BEGIN
    IF @i_descriptiontype = 'short' BEGIN
      SELECT @o_filterorgleveldesc = COALESCE(orglevelshortdesc,orgleveldesc)
 	      FROM orglevel o, filterorglevel f
       WHERE o.orglevelkey = f.filterorglevelkey and
             f.filterkey = @i_filterkey;
    END
  END	

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_filterorgleveldesc = ''
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: filtertype:  ' + @i_descriptiontype + ' orglevelfilterkey:  ' + cast(@i_filterkey AS VARCHAR) 
  END 
GO

GRANT EXEC ON qutl_get_filterorglevel_desc TO PUBLIC
GO
