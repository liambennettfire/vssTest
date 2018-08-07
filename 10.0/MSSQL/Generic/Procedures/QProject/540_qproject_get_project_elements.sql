if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_project_elements') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_project_elements
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_project_elements
 (@i_projectkey     integer,
  @i_datacode       integer,
  @i_datasubcode    integer,
  @i_dropdownuse    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_project_elements
**  Desc: This stored procedure returns all elements from the
**        taqprojectelement table for a datacode/datasubcode. 
**
**  Auth: Alan Katzen
**  Date: 20 August 2004
*******************************************************************************/

  DECLARE 
    @v_quote      VARCHAR(2),
    @v_sqlselect  VARCHAR(2000),
    @v_sqlfrom    VARCHAR(2000),
    @v_sqlwhere   VARCHAR(2000),
    @v_sqlstring  NVARCHAR(4000),
    @error_var    INT,
    @rowcount_var INT
      
  SET @v_quote = ''''      
  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- ***** Build the dynamic SQL which will be used to retrieve elements ***** --
  IF @i_dropdownuse = 1
    BEGIN
      -- For drop-downs, get only key and description (and values needed for filtering)
      SET @v_sqlselect = 'SELECT taqelementkey,taqelementdesc,taqelementtypesubcode,' +  
      'CASE 
        WHEN taqelementtypecode > 0 THEN 
          (select COALESCE(gen1ind,0) from gentables where tableid=287 and datacode=taqelementtypecode)
        ELSE 0 ' +
      'END AS digitalassetind'
    END
  ELSE
    BEGIN
      -- If not drop-down, by default get all values needed for element pages
      SET @v_sqlselect = 'SELECT taqelementkey,taqelementtypecode,' +
        'taqelementtypesubcode,taqelementnumber,taqelementdesc,' +
        'elementstatus,sortorder,' +
        'CASE 
          WHEN taqelementtypecode > 0 THEN 
            (select COALESCE(gen1ind,0) from gentables where tableid=287 and datacode=taqelementtypecode)
          ELSE 0 ' +
        'END AS digitalassetind'            
    END
    
  SET @v_sqlfrom = ' FROM taqprojectelement'
  SET @v_sqlwhere = ' WHERE taqprojectkey = ' + CAST(@i_projectkey AS VARCHAR)
  
  IF @i_datasubcode > 0
    BEGIN
      -- element with sub element
      SET @v_sqlwhere = @v_sqlwhere + 
        ' AND taqelementtypecode = ' + CAST(@i_datacode AS VARCHAR) +
        ' AND taqelementtypesubcode = ' + CAST(@i_datasubcode AS VARCHAR)
    END
  ELSE IF @i_datacode > 0
    BEGIN
      -- element with no sub element
      SET @v_sqlwhere = @v_sqlwhere + 
        ' AND taqelementtypecode = ' + CAST(@i_datacode AS VARCHAR)
    END

  SET @v_sqlwhere = @v_sqlwhere + ' ORDER BY taqelementtypecode,taqelementtypesubcode,taqelementnumber'
  
  -- Set and execute the full sqlstring
  SET @v_sqlstring = @v_sqlselect + @v_sqlfrom + @v_sqlwhere    
  
  --print  @v_sqlstring
   
  EXECUTE sp_executesql @v_sqlstring
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: projectkey = ' + cast(@i_projectkey AS VARCHAR) + 
      ' / datacode = ' + cast(@i_datacode AS VARCHAR) +
      ' / datasubcode = ' + cast(@i_datasubcode AS VARCHAR)
  END
GO

GRANT EXEC ON qproject_get_project_elements TO PUBLIC
GO
