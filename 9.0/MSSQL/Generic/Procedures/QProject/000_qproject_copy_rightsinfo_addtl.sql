if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_copy_rightsinfo_addtl') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_copy_rightsinfo_addtl
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_copy_rightsinfo_addtl
  (@i_from_projectkey integer,
  @i_new_projectkey   integer,
  @i_approved_status  integer,
  @i_userid           varchar(30),
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/***************************************************************************************
**  Name: qproject_copy_rightsinfo_addtl
**  Desc: This stored procedure is called from qproject_copy_project_contract_rights
**        after contract rights and territories are copied, and it updates the
**        author subright percentages from the approved p&l.
**
**  If you call this procedure from anyplace other than qproject_copy_project,
**  you must do your own transaction/commit/rollbacks on return from this procedure.
**
**  Auth: Kate W.
**  Date: 10 May 2012
****************************************************************************************/

DECLARE
  @v_authorpercent  INT,
  @v_copy_plstage INT,
  @v_copy_plversion INT,
  @v_count  INT,
  @v_error  INT,
  @v_rightscode INT
	
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
    
  -- Get the plstagecode and taqversionkey of the approved version for the most recent stage for this project
  SELECT TOP 1 @v_copy_plstage = v.plstagecode, @v_copy_plversion = v.taqversionkey
  FROM taqversion v, gentables g
  WHERE v.plstagecode = g.datacode AND
    g.tableid = 562 AND 
    v.taqprojectkey = @i_from_projectkey AND
    v.plstatuscode = @i_approved_status
  ORDER BY g.sortorder DESC
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error getting approved version for the most recent P&L stage (taqprojectkey=' + CONVERT(VARCHAR, @i_from_projectkey) + ').'
    RETURN
  END  
  
  /* 5/10/12 - KW - From case 17842:
  Contract Rights and Territory: (After rights and territories have been copied from i_copy_projectkey or i_copy2_projectkey,)
  if there is an approved P&L for the passed projectkey, for every taqversionsubrights.rightscode for that version, find all taqprojectrights 
  for that rightstypecode and update the authorsubrightspercent for those rights. */
    
  -- Loop through all rights on the approved p&l version and update author percentages on taqprojectrights table
  DECLARE subrights_cur CURSOR FOR
    SELECT rightscode, authorpercent
    FROM taqversionsubrights
    WHERE taqprojectkey = @i_from_projectkey AND
      plstagecode = @v_copy_plstage AND
      taqversionkey = @v_copy_plversion

  OPEN subrights_cur 	

  FETCH NEXT FROM subrights_cur INTO @v_rightscode, @v_authorpercent

  WHILE (@@FETCH_STATUS = 0)
  BEGIN    
    
    SELECT @v_count = COUNT(*)
    FROM taqprojectrights
    WHERE taqprojectkey = @i_new_projectkey AND
      rightstypecode = @v_rightscode
    
    IF @v_count > 0
    BEGIN
      UPDATE taqprojectrights
      SET authorsubrightspercent = @v_authorpercent
      WHERE taqprojectkey = @i_new_projectkey AND
        rightstypecode = @v_rightscode
        
      SELECT @v_error = @@ERROR
      IF @v_error <> 0
      BEGIN
        CLOSE subrights_cur 
        DEALLOCATE subrights_cur      
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not update Author Subrights Percent on taqprojectsubrights from approved p&l for the new project (Error ' + CONVERT(VARCHAR, @v_error) + ').'
        RETURN
      END
    END
      
    FETCH NEXT FROM subrights_cur INTO @v_rightscode, @v_authorpercent
  END

  CLOSE subrights_cur 
  DEALLOCATE subrights_cur
  
END
GO

GRANT EXEC ON qproject_copy_rightsinfo_addtl TO PUBLIC
GO
