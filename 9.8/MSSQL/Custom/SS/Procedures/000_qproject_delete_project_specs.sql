IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = object_id(N'dbo.qproject_delete_project_specs') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qproject_delete_project_specs
GO

CREATE PROCEDURE dbo.qproject_delete_project_specs
 (@i_projectkey         integer,
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

SET NOCOUNT ON

/******************************************************************************
**  Name: qproject_delete_project_specs
**  Desc: Deletes spec categories and items from the specified project
**              
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:     Author:         Description:
**    --------  --------        -------------------------------------------
*******************************************************************************/
  
  -- verify projectkey is filled in
  IF ISNULL(@i_projectkey,0) <= 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'projectkey is empty.'
    RETURN
  END 

  DECLARE @error_var    INT,
          @rowcount_var INT,
          @errormsg_var varchar(2000),
          @is_error_var TINYINT,
          @count_var INT,
          @v_categorykey INT,
          @v_searchitemcode INT,
          @v_usageclasscode INT,
          @v_printing_searchitemcode INT,
          @v_printing_usageclasscode INT,
          @v_bookkey INT,
          @v_printingkey INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_searchitemcode = searchitemcode, 
         @v_usageclasscode = usageclasscode 
  FROM taqproject 
  WHERE taqprojectkey = @i_projectkey
   
  SELECT @v_printing_searchitemcode = datacode, @v_printing_usageclasscode = datasubcode 
  FROM subgentables 
  WHERE tableid = 550 and qsicode = 40  --Printing
  
  -- Is this a Printing Project?
  IF @v_searchitemcode = @v_printing_searchitemcode AND @v_usageclasscode = @v_printing_usageclasscode 
  BEGIN  
    SELECT @v_bookkey = bookkey, @v_printingkey = printingkey FROM taqprojecttitle WHERE taqprojectkey = @i_projectkey
  
    IF @v_printingkey = 1 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to delete specs from printing project with printingkey =  1.'
      RETURN
    END

    IF NOT EXISTS (SELECT 1 
      FROM taqProjectTitle
      WHERE bookkey = @v_bookkey and printingkey > @v_printingkey)
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to delete specs from last printing project.'
      RETURN
    END
  END
  ELSE
  BEGIN
    -- Don't delete if projectstatus is considered "locked"
    IF EXISTS (
      SELECT 1
        FROM gentables g, taqproject p
       WHERE p.taqprojectstatuscode = g.datacode and
             g.tableid = 522 and 
             (g.qsicode in (1) or g.gen2ind = 1) and
             p.taqprojectkey = @i_projectkey )
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to Delete Project due to the Project Status.'
      RETURN
    END 
  END

  BEGIN TRANSACTION
  
  DECLARE speccategory_cursor CURSOR FOR
    SELECT taqversionspecategorykey
    FROM taqversionspeccategory
    WHERE taqprojectkey = @i_projectkey 

  OPEN speccategory_cursor

  FETCH speccategory_cursor
  INTO @v_categorykey

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    -- Delete cost messages associated with this component as well as any components related to this one
    DELETE FROM taqversioncostmessages
    WHERE taqversionformatyearkey IN (
        SELECT DISTINCT taqversionformatyearkey FROM taqversioncosts
        WHERE taqversionspeccategorykey = @v_categorykey
          OR taqversionspeccategorykey  IN (
            SELECT taqversionspecategorykey 
            FROM taqversionspeccategory 
            WHERE relatedspeccategorykey = @v_categorykey
          )
      )
      
    SELECT @error_var = @@ERROR
    IF @error_var <> 0 BEGIN
      SET @errormsg_var = 'Error deleting from taqversioncostmessages table (Error ' + cast(@error_var AS VARCHAR) + ').'
      GOTO ErrorHandler
    END  

    -- Delete costs associated with this component as well as any components related to this one
    DELETE FROM taqversioncosts
    WHERE taqversionspeccategorykey = @v_categorykey
      OR taqversionspeccategorykey  IN (
        SELECT taqversionspecategorykey 
        FROM taqversionspeccategory 
        WHERE relatedspeccategorykey = @v_categorykey
      )

    SELECT @error_var = @@ERROR
    IF @error_var <> 0 BEGIN
      SET @errormsg_var = 'Error deleting from taqversioncosts table (Error ' + cast(@error_var AS VARCHAR) + ').'
      GOTO ErrorHandler
    END  

    DELETE FROM taqversionspecitems
    WHERE taqversionspecategorykey = @v_categorykey
    
    SELECT @error_var = @@ERROR
    IF @error_var <> 0 BEGIN
      SET @errormsg_var = 'Error deleting from taqversionspecitems table (Error ' + cast(@error_var AS VARCHAR) + ').'
      GOTO ErrorHandler
    END  
    
    -- Delete this component as well as any components related to this one
    DELETE FROM taqversionspeccategory
    WHERE taqversionspecategorykey = @v_categorykey
      OR taqversionspecategorykey  IN (
        SELECT taqversionspecategorykey 
        FROM taqversionspeccategory 
        WHERE relatedspeccategorykey = @v_categorykey
      )
    
    SELECT @error_var = @@ERROR
    IF @error_var <> 0 BEGIN
      SET @errormsg_var = 'Error deleting from taqversionspeccategory table (Error ' + cast(@error_var AS VARCHAR) + ').'
      GOTO ErrorHandler
    END  
    
    FETCH speccategory_cursor
    INTO @v_categorykey
  END

  CLOSE speccategory_cursor
  DEALLOCATE speccategory_cursor 

  COMMIT
  RETURN

ErrorHandler:
  ROLLBACK
  SET @o_error_desc = @errormsg_var
  RETURN
  GO

GRANT EXEC ON dbo.qproject_delete_project_specs TO PUBLIC
GO
