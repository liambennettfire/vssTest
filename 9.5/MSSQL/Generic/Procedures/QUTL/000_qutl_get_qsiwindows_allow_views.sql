IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qutl_get_qsiwindows_allow_views]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qutl_get_qsiwindows_allow_views]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qutl_get_qsiwindows_allow_views]
 (@o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_qsiwindows_allow_views
**  Desc: This stored procedure returns all qsiwindows for TMM Web with 
**        allowviewsind set to 1.
**
**  Parameters:
**
**  Auth: Alan Katzen
**  Date: May 26, 2010
*******************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT

  SELECT *, cast(windowid as varchar) + '|' + cast(COALESCE(itemtypecode,0) as varchar) windowiditemtype
    FROM qsiwindows 
   WHERE applicationind = 14
     AND upper(windowind) = 'Y'
     AND allowviewsind = 1

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing qsiwindows table from qutl_get_qsiwindows_allow_views stored proc'  
  END 

GO

GRANT EXEC on qutl_get_qsiwindows_allow_views TO PUBLIC
GO

