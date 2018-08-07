if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_max_taskview_sortorder') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_max_taskview_sortorder
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qutl_get_max_taskview_sortorder]
 (@i_taskviewkey integer,
  @o_maxsortord  integer output,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/******************************************************************************
**  
**  Name: qutl_get_max_taskview_sortorder
**  Desc: This stored procedure returns the max sortnumber for a taskview 
**
**    Auth: Lisa Cormier
**    Date: 16 Jan 2009
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**                                
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_maxsortord = 0
  
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @maxelementnum_var INT

  SELECT @o_maxsortord = max(isNull(sortorder,0)) 
    FROM taskviewdatetype
   WHERE taskviewkey = @i_taskviewkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 
  BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: key = ' + cast(@i_taskviewkey AS VARCHAR)
  END 

GO


