if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_generate_work_name') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_generate_work_name
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_generate_work_name
 (@i_bookkey             integer,
  @o_worktitle           varchar(255)  output,
  @o_error_code          integer       output,
  @o_error_desc          varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_generate_work_name
**  Desc: This procedure will generate the work project title
**
**    Auth: Colman
**    Date: Sept 25 2015
*******************************************************************************/
BEGIN
  DECLARE
    @v_title VARCHAR(255)

    SELECT @v_title = title FROM book WHERE bookkey=@i_bookkey
    SET @o_worktitle = @v_title
    RETURN
END
  
GO
GRANT EXEC ON qproject_generate_work_name TO PUBLIC
GO


