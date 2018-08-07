if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_max_element_number') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_max_element_number
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_max_element_number
 (@i_key            integer,
  @i_datacode       integer,
  @i_datasubcode    integer,
  @o_maxelementnum  integer output,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qproject_get_max_element_number
**  Desc: This stored procedure returns the max taqelementnumber
**        taqprojectelement table for a datacode/datasubcode. 
**
**    Auth: Alan Katzen
**    Date: 25 August 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    6/27/2008   Alan Katzen     Elements can be for Titles or Projects
**                                so @i_key can be either a bookkey or projectkey
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_maxelementnum = 0
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @maxelementnum_var INT

  IF @i_datasubcode > 0 BEGIN
   -- element with sub element
    SELECT @maxelementnum_var = max(taqelementnumber) 
      FROM taqprojectelement e
     WHERE e.taqelementtypecode = @i_datacode and
           e.taqelementtypesubcode = @i_datasubcode and
           (e.taqprojectkey = @i_key OR e.bookkey = @i_key)
  END
  ELSE BEGIN
   -- element with no sub element
    SELECT @maxelementnum_var = max(taqelementnumber) 
      FROM taqprojectelement e
     WHERE e.taqelementtypecode = @i_datacode and
					 (e.taqelementtypesubcode = 0 OR e.taqelementtypesubcode IS NULL) and
           (e.taqprojectkey = @i_key OR e.bookkey = @i_key)
  END

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: key = ' + cast(@i_key AS VARCHAR) + 
                        ' / datacode = ' + cast(@i_datacode AS VARCHAR) +
                        ' / datasubcode = ' + cast(@i_datasubcode AS VARCHAR)
  END 

  IF @maxelementnum_var >= 0 BEGIN
    SET @o_maxelementnum = @maxelementnum_var
  END

GO
GRANT EXEC ON qproject_get_max_element_number TO PUBLIC
GO


