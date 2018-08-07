if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_verify_projectstatus') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_verify_projectstatus
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_verify_projectstatus
 (@i_projectkey      INTEGER,
  @i_projectstatus   INTEGER,
  @i_userid          VARCHAR(30),
  @o_result_code     INTEGER OUTPUT,
  @o_result_desc     VARCHAR(MAX) OUTPUT,
  @o_error_code      INTEGER OUTPUT,
  @o_error_desc      VARCHAR(2000) OUTPUT)
AS


/******************************************************************************
**  Name: qproject_verify_projectstatus
**  Desc: This stored procedure returns verification info for a project status 
**        by itemtype/usageclass. 
**          
**    Auth: Colman
**    Date: 2/21/2017
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:         Author:       Description:
**    ----------    ----------    ---------------------------------------------
**    06/21/2017    Colman        45761 - Remove check for clientdefaults 85 status
*******************************************************************************/

  DECLARE @error_var INT,
          @v_storedprocname VARCHAR(100),
          @v_storedprocexists BIT,
          @v_proc_expects_output TINYINT,
          @v_verificationcode INT,
          @v_itemtype INT, 
          @v_usageclass INT,
          @v_projectstatus INT,
          @v_activestatus INT,
          @v_projectstatus_table INT,
          @v_projectverification_table INT,
          @v_sql NVARCHAR(max)
  
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_result_code = 1
  SET @o_result_desc = ''
  SET @v_projectstatus_table = 522
  SET @v_projectverification_table = 628

  SELECT @v_itemtype = searchitemcode, @v_usageclass = usageclasscode
  FROM taqproject
  WHERE taqprojectkey = @i_projectkey
  
  IF EXISTS (
    SELECT 1
      FROM gentablesitemtype gi
     WHERE gi.tableid = @v_projectstatus_table and
           gi.datacode = @i_projectstatus and
           gi.itemtypecode = @v_itemtype and
           (gi.itemtypesubcode = @v_usageclass OR gi.itemtypesubcode = 0) and
           ISNULL(gi.relateddatacode,0) > 0)
  BEGIN
    SELECT @v_storedprocname = g.alternatedesc1,
           @v_storedprocexists = CASE WHEN g.alternatedesc1 IS NULL OR LTRIM(RTRIM(g.alternatedesc1)) = '' THEN 0 ELSE 1 END,
           @v_proc_expects_output = ge.gen3ind
      FROM gentables g, gentables_ext ge, gentablesitemtype gi
     WHERE gi.tableid = @v_projectstatus_table and
           gi.itemtypecode = @v_itemtype and
           (gi.itemtypesubcode = @v_usageclass OR gi.itemtypesubcode = 0) and
           gi.datacode = @i_projectstatus and
           g.datacode = gi.relateddatacode and
           g.tableid = @v_projectverification_table and
           ge.datacode = gi.relateddatacode and
           ge.tableid = @v_projectverification_table

    IF @v_storedprocexists = 1
    BEGIN
      IF @v_proc_expects_output = 1
      BEGIN
        SET @v_sql = 'EXEC ' + @v_storedprocname + N' @i_projectkey, @v_verificationcode, @i_userid, @o_result_code OUTPUT, @o_result_desc OUTPUT'
        EXEC sp_executesql @v_sql, N'@i_projectkey INT, @v_verificationcode INT, @i_userid varchar(30), @o_result_code INT OUTPUT, @o_result_desc VARCHAR(2000) OUTPUT', 
          @i_projectkey, @v_verificationcode, @i_userid, @o_result_code OUTPUT, @o_result_desc OUTPUT
      END
      ELSE
      BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = @v_storedprocname + ' is not configured for output (gentables_ext 628, gen3ind).'
      END
    END
  END
  
  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'qproject_verify_projectstatus failed'
  END 

GO
GRANT EXEC ON qproject_verify_projectstatus TO PUBLIC
GO
