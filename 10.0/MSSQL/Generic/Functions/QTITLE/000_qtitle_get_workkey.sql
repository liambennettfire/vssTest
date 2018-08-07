SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.qtitle_get_workkey') AND xtype IN (N'FN', N'IF', N'TF'))
  DROP FUNCTION dbo.qtitle_get_workkey
GO

CREATE FUNCTION [dbo].[qtitle_get_workkey]
		(@i_bookkey	INT)
RETURNS INT

AS

BEGIN
  DECLARE @v_work_projectkey int,
          @v_title_title_role int,
          @v_work_project_role int

  SET @v_work_projectkey = 0
  
  SELECT @v_work_project_role = datacode
    FROM gentables
   WHERE tableid = 604
     and qsicode = 1

  SELECT @v_title_title_role = datacode
    FROM gentables
   WHERE tableid = 605
     and qsicode = 1

  SELECT @v_work_projectkey = tpt.taqprojectkey
    FROM taqprojecttitle tpt, coreprojectinfo c
   WHERE tpt.taqprojectkey = c.projectkey
     AND tpt.bookkey = @i_bookkey
     AND tpt.printingkey = 1
     AND tpt.titlerolecode = @v_title_title_role
     AND tpt.projectrolecode = @v_work_project_role
	
  RETURN @v_work_projectkey
END
GO

GRANT EXEC ON dbo.qtitle_get_workkey TO PUBLIC
GO