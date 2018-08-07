if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_max_element_number') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_max_element_number
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_max_element_number
 (@i_key            integer,
  @i_key2            integer,
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
**	  03/07/2016  Uday A. Khisty  Case 36706
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_maxelementnum = 0
  
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @maxelementnum_var INT,
          @v_sqlstring  NVARCHAR(max),
          @v_sqlselect  NVARCHAR(max),
          @v_sqlfrom  NVARCHAR(max),          
          @v_sqlwhere  NVARCHAR(max)
          
  SET @v_sqlselect = ' SELECT max(taqelementnumber)  '
  SET @v_sqlfrom = ' FROM taqprojectelement e '
  SET @v_sqlwhere = ' WHERE e.taqelementtypecode = '  + CONVERT(VARCHAR, @i_datacode) + ' and '
    
  IF @i_datasubcode > 0 BEGIN
	SET @v_sqlwhere = @v_sqlwhere +  ' e.taqelementtypecode = ' + CONVERT(VARCHAR, @i_datacode) + ' AND e.taqelementtypesubcode = ' + CONVERT(VARCHAR, @i_datasubcode) + ' and '
  END
  ELSE BEGIN
	SET @v_sqlwhere = @v_sqlwhere +  ' (e.taqelementtypesubcode = 0 OR e.taqelementtypesubcode IS NULL) and '
  END  
          
  IF @i_key > 0 AND @i_key2 > 0 BEGIN
	SET @v_sqlwhere = @v_sqlwhere +  ' (e.bookkey = ' + CONVERT(VARCHAR, @i_key) + ' AND e.printingkey = ' + CONVERT(VARCHAR, @i_key2)+ ') '
  END
  ELSE BEGIN
	SET @v_sqlwhere = @v_sqlwhere + ' (e.taqprojectkey = ' + CONVERT(VARCHAR, @i_key) + ' OR e.bookkey = ' + CONVERT(VARCHAR, @i_key) + ') '
  END        
  
  SET @v_sqlstring = @v_sqlselect + @v_sqlfrom + @v_sqlwhere
  
  EXEC execute_calcsql_integer @v_sqlstring, @maxelementnum_var OUTPUT

  IF @maxelementnum_var >= 0 BEGIN
    SET @o_maxelementnum = @maxelementnum_var
  END

GO
GRANT EXEC ON qproject_get_max_element_number TO PUBLIC
GO


