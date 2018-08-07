if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_otherprojectkey') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qproject_get_otherprojectkey
GO

CREATE FUNCTION qproject_get_otherprojectkey
    ( @i_thisprojectkey as integer,@i_thisrelqsicode as integer,@i_otherrelqsicode as integer) 

RETURNS int

/******************************************************************************
**  File: 
**  Name: qproject_get_otherprojectkey
**  Desc: This function returns the other taqprojectkey in a project 
**        relationship
**
**    Auth: Alan Katzen
**    Date: 4 March 2008
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @v_otherprojectkey   INT,
          @v_thisreldatacode INT,
          @v_otherreldatacode INT,
          @error_var    INT,
          @rowcount_var INT

  SET @v_otherprojectkey = 0
  
  SELECT @v_thisreldatacode = COALESCE(datacode,0)
    FROM gentables
   WHERE tableid = 582
     AND qsicode = @i_thisrelqsicode

  SELECT @v_otherreldatacode = COALESCE(datacode,0)
    FROM gentables
   WHERE tableid = 582
     AND qsicode = @i_otherrelqsicode
 
  IF (@v_thisreldatacode > 0 AND @v_otherreldatacode > 0) BEGIN
    -- check one direction (only need to find the relationship in one direction)
    SELECT @v_otherprojectkey = taqprojectkey2 
      FROM taqprojectrelationship r   
     WHERE r.taqprojectkey1 = @i_thisprojectkey 
       AND relationshipcode1 = @v_thisreldatacode
       AND relationshipcode2 = @v_otherreldatacode

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @v_otherprojectkey = -1
      --SET @o_error_desc = 'no data found: subjectcategories on gentablesdesc.'   
    END 
    
    IF (@v_otherprojectkey is null OR @v_otherprojectkey <= 0) BEGIN  
      -- check the other direction
      SELECT @v_otherprojectkey = taqprojectkey1
        FROM taqprojectrelationship r
       WHERE r.taqprojectkey2 = @i_thisprojectkey
         AND relationshipcode2 = @v_thisreldatacode
         AND relationshipcode1 = @v_otherreldatacode

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @v_otherprojectkey = -1
        --SET @o_error_desc = 'no data found: subjectcategories on gentablesdesc.'   
      END 
    END
  END
  
  IF @v_otherprojectkey > 0 BEGIN
    RETURN @v_otherprojectkey
  END

  RETURN 0
END
GO

GRANT EXEC ON dbo.qproject_get_otherprojectkey TO public
GO
