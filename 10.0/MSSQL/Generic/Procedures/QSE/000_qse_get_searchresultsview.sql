IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qse_get_searchresultsview]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qse_get_searchresultsview]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qse_get_searchresultsview]
 (@i_resultsviewkey     integer,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/******************************************************************************
**  Name: qse_get_searchresultsview
**  Desc: This stored procedure returns info for a specific result view from the 
**        qse_searchresultsview table.
**
**  Auth: Alan Katzen
**  Date: May 10, 2012
*******************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var                   INT,
          @rowcount_var                INT,
          @v_count                     INT
  
  SELECT * 
    FROM qse_searchresultsview srv
   WHERE srv.resultsviewkey = @i_resultsviewkey
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing qse_searchresultsview table (resultsviewkey = ' + cast(@i_resultsviewkey as varchar) + ')'
  END 

GO

GRANT EXEC on qse_get_searchresultsview TO PUBLIC
GO

