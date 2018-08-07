if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_add_taqprojectreaderiteration') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_add_taqprojectreaderiteration
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_add_taqprojectreaderiteration
  (@i_projectkey  integer,
  @i_contactrolekey integer,
  @i_taqelementkey  integer,
  @i_userid varchar(30),
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS


/******************************************************************************
**  Name: qproject_add_taqprojectreaderiteration
**  Desc: This stored procedure adds a new row to taqprojectreaderiteration table.
**        If no contactrolekey is passed, it adds a new taqprojectreaderiteration
**        row for each active Reader.
**
**    Auth: Kate
**    Date: 9/28/04
*******************************************************************************/

  DECLARE
    @v_cnt  INT,
    @v_error  INT,
    @v_readerrolecode INT,
    @v_rowcount INT,
    @v_taqprojectcontactrolekey INT
  
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF @i_contactrolekey > 0
  BEGIN
    /***** ADD new row to TAQPROJECTREADERITERATION table ****/
    INSERT INTO taqprojectreaderiteration
      (taqprojectkey, taqprojectcontactrolekey, taqelementkey, lastuserid, lastmaintdate)
    VALUES
      (@i_projectkey, @i_contactrolekey, @i_taqelementkey, @i_userid, getdate())
      
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
      SET @o_error_desc = 'Error inserting to taqprojectreaderiteration table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) +
        ', taqprojectcontactkey=' + CAST(@i_contactrolekey AS VARCHAR) + ', taqelementkey=' + CAST(@i_taqelementkey AS VARCHAR) + ')'
      GOTO RETURN_ERROR
    END
  END
  ELSE
  BEGIN

    /* Check if records already exists for this element */
    SELECT @v_cnt = COUNT(*)
    FROM taqprojectreaderiteration
    WHERE taqprojectkey = @i_projectkey AND taqelementkey = @i_taqelementkey  
    
    IF @v_cnt = 0
    BEGIN
      
      /** Get the rolecode for 'Reader' (gentable 285, qsicode=3) **/
      SELECT @v_readerrolecode = datacode
      FROM gentables 
      WHERE tableid = 285 AND qsicode = 3
      
      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
        SET @o_error_desc = 'Error getting rolecode for Reader (gentables 285, qsicode=3).'
        GOTO RETURN_ERROR
      END
        
      /** Declare a cursor for all ACTIVE readers on this project **/
      DECLARE participant_iteration_cur CURSOR FOR
        SELECT taqprojectcontactrolekey 
        FROM taqprojectcontactrole 
        WHERE taqprojectkey = @i_projectkey AND
          rolecode = @v_readerrolecode AND
          activeind = 1
      
      OPEN participant_iteration_cur

      FETCH NEXT FROM participant_iteration_cur INTO @v_taqprojectcontactrolekey

      WHILE (@@FETCH_STATUS = 0) BEGIN
      
        /***** ADD new row to TAQPROJECTREADERITERATION table ****/
        INSERT INTO taqprojectreaderiteration
          (taqprojectkey, taqprojectcontactrolekey, taqelementkey, lastuserid, lastmaintdate)
        VALUES
          (@i_projectkey, @v_taqprojectcontactrolekey, @i_taqelementkey, @i_userid, getdate())
          
        SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
        IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
          SET @o_error_desc = 'Error inserting to taqprojectreaderiteration table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) +
            ', taqprojectcontactkey=' + CAST(@v_taqprojectcontactrolekey AS VARCHAR) + ', taqelementkey=' + CAST(@i_taqelementkey AS VARCHAR) + ')'
          BREAK --Exit participant cursor if occur occurs
        END
        
        FETCH NEXT FROM participant_iteration_cur INTO @v_taqprojectcontactrolekey
      END
      
      CLOSE participant_iteration_cur 
      DEALLOCATE participant_iteration_cur
      
      /* Exit if error occurred above */
      IF @o_error_code <> 0
        RETURN
      
    END /* IF @v_cnt = 0 */
  END

  RETURN  

RETURN_ERROR:  
  SET @o_error_code = -1
  RETURN
  
GO

GRANT EXEC ON qproject_add_taqprojectreaderiteration TO PUBLIC
GO
