IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.qcontract_get_related_works') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qcontract_get_related_works
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_related_works
 (@i_contractprojectkey   INTEGER,
  @i_only_if_rights_exist INTEGER,
  @o_error_code           INTEGER OUTPUT,
  @o_error_desc           VARCHAR(2000) OUTPUT)
AS

/******************************************************************************
**  Name: qcontract_get_related_works
**  Desc: This procedure returns all works related to the passed contract
**
**  Auth: Colman
**  Date: July 7, 2017
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
**  --------     --------    --------------------------------------------------
**  07/12/17     Colman      46209 - Flag to return all related works or only those with rights defined
*******************************************************************************/

  DECLARE @v_worktype          INT,
          @v_error             INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SET @v_worktype = (SELECT dataCode from gentables where tableId = 550 AND qsiCode = 9) --Work Item Type

  SELECT 
    taq.taqprojectkey AS workkey,
    taq.taqprojecttitle AS worktitle
  FROM 
    taqprojectrelationship rel
  INNER JOIN taqProject taq
    ON rel.taqprojectkey1 = taq.taqprojectkey
  WHERE 
      taq.searchitemcode = @v_worktype
  AND rel.taqprojectkey2 = @i_contractprojectkey
  AND (@i_only_if_rights_exist = 0 OR (EXISTS(SELECT 1 FROM taqProjectRights tpr
        WHERE tpr.taqprojectkey = rel.taqprojectkey2
      AND (CASE WHEN ISNULL(tpr.workkey,0) = 0 THEN rel.taqprojectkey1 ELSE tpr.workkey END) = rel.taqprojectkey1)))
  UNION
  SELECT 
    taq.taqprojectkey AS workkey,
    taq.taqprojecttitle AS worktitle
  FROM 
    taqprojectrelationship rel
  INNER JOIN taqProject taq
    ON rel.taqprojectkey2 = taq.taqprojectkey
  WHERE 
      taq.searchitemcode = @v_worktype
  AND rel.taqprojectkey1 = @i_contractprojectkey
  AND (@i_only_if_rights_exist = 0 OR (EXISTS(SELECT 1 FROM taqProjectRights tpr
        WHERE tpr.taqprojectkey = rel.taqprojectkey1
      AND (CASE WHEN ISNULL(tpr.workkey,0) = 0 THEN rel.taqprojectkey2 ELSE tpr.workkey END) = rel.taqprojectkey2)))

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning related works (projectkey=' + CAST(@i_contractprojectkey AS VARCHAR) + ')'
    RETURN
  END   
GO

GRANT EXEC ON qcontract_get_related_works TO PUBLIC
GO