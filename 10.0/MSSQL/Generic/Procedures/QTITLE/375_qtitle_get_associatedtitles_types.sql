if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_associatedtitles_types') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_associatedtitles_types
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_associatedtitles_types
 (@o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qtitle_get_associatedtitles_types
**  Desc: This stored procedure returns the associationcodes for associatedtitles
**  sections of Title Positioning page.
**  Codes are returned in the order client wants to see (gentable sortorder)
**
**    Auth: Kate
**    Date: 24 June 2004
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

  SELECT datacode, datadesc FROM gentables
  WHERE tableid = 440 AND 
	(deletestatus IS NULL OR deletestatus = 'N' OR deletestatus = 'n') 
  ORDER BY sortorder

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: gentables 440'
  END 

GO
GRANT EXEC ON qtitle_get_associatedtitles_types TO PUBLIC
GO


