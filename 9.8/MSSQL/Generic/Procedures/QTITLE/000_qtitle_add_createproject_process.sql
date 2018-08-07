IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.qtitle_add_createproject_process') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_add_createproject_process
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_add_createproject_process
 (
  @i_bookkey             integer,
  @i_project_templatekey integer,
  @i_project_itemtype    integer,
  @i_project_usageclass  integer,
  @i_project_name        VARCHAR(255),
  @i_userid              VARCHAR(30),
  @o_error_code          integer output,
  @o_error_desc          VARCHAR(2000) output)
AS

/*************************************************************************************************************
**  Name: qtitle_add_createproject_process
**  Desc: 
** 
**  Auth: Colman
**  Date: August 3, 2016
*************************************************************************************************************
**  Change History
*************************************************************************************************************
**  Date:       Author:     Description:
**  ----------  ------      ---------------------------------------------------------------------------------
**  07/10/2017  Colman      Case 41868
*************************************************************************************************************/

DECLARE
  @v_backgroundprocesskey INT,
  @v_stored_proc_name     VARCHAR(120),
  @v_jobtype              INT,
  @pos1                   INT, 
  @pos2                   INT, 
  @pos3                   INT, 
  @v_format               VARCHAR(100), 
  @v_sub1                 VARCHAR(100), 
  @v_sub2                 VARCHAR(100),
  @v_error                INT
  
BEGIN

  SET @v_stored_proc_name = 'qproject_create_project_from_title'
  IF @i_project_templatekey <= 0
    SET @i_project_templatekey = NULL
  
  SELECT @v_jobtype = datacode FROM gentables WHERE tableid = 543 AND qsicode = 19 --Create Projects FROM Title
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error getting Job Type FROM gentables 543.'
    RETURN 
  END

    -- Auto name generation can produce duplicate format sections.
  SELECT @pos1 = charindex(' (', @i_project_name)
  IF @pos1 > 0
  BEGIN
    SELECT @pos2 = charindex(')', @i_project_name, @pos1)
    IF @pos2 > 0
    BEGIN
      SELECT @v_format = substring(@i_project_name, @pos1 + 1, @pos2 - @pos1)
      SELECT @pos3 = charindex(@v_format, @i_project_name, @pos2 + 1)
      IF @pos3 > 0
      BEGIN
        SELECT @v_sub1 = substring(@i_project_name, 0, @pos1)
        SELECT @v_sub2 = substring(@i_project_name, @pos2 + 1, 255)
        SET @i_project_name = @v_sub1 + @v_sub2
      END
    END
  END
  
	EXEC get_next_key 'backgroundprocess', @v_backgroundprocesskey OUTPUT
	
	INSERT INTO backgroundprocess
  (backgroundprocesskey, jobtypecode, storedprocname, reqforgetprodind, key1, key2, 
   integervalue1, integervalue2, textvalue1, createdate, lastuserid, lastmaintdate)
	VALUES
  (@v_backgroundprocesskey, @v_jobtype, @v_stored_proc_name, 0, @i_bookkey, @i_project_templatekey,
   @i_project_itemtype, @i_project_usageclass, @i_project_name, GETDATE(), @i_userid, GETDATE())
  
END 
GO

GRANT EXEC ON qtitle_add_createproject_process TO PUBLIC
GO
