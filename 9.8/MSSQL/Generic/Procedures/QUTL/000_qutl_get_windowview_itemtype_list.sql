IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qutl_get_windowview_itemtype_list]') AND type in (N'P', N'PC'))  
DROP PROCEDURE [dbo].[qutl_get_windowview_itemtype_list]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qutl_get_windowview_itemtype_list]
 (@o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_windowview_itemtype_list
**  Desc: This stored procedure returns all qsiwindows for TMM Web.
**
**  Parameters:
**
**  Auth: Alan Katzen
**  Date: May 24, 2010
*******************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT

  SELECT DISTINCT w.itemtypecode, g.datadesc, g.datacode
    FROM qsiwindows w, gentables g
   WHERE w.itemtypecode = g.datacode
     AND g.tableid = 550
     AND w.applicationind = 14
     AND upper(w.windowind) = 'Y'
     AND w.allowviewsind = 1
     AND w.itemtypecode > 0

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing qsiwindows table from qutl_get_windowview_itemtype_list stored proc'  
  END 

GO

GRANT EXEC on qutl_get_windowview_itemtype_list TO PUBLIC
GO

