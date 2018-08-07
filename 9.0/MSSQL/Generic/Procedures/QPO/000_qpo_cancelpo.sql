if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpo_cancelpo') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qpo_cancelpo
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpo_cancelpo
 (@i_projectkey           integer,
  @i_lastuserid           varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qpo_cancelpo
**  Desc: This procedure will be called when the Cancelled button is clicked on Purchase Order.  
**
**	Auth: Uday
**	Date: 20 November 2014
*******************************************************************************
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   --------------------------------------
**   
*******************************************************************************/
BEGIN
  DECLARE @v_error	INT,
          @v_rowcount INT,
          @v_count_task INT,
          @lastuserid_var   VARCHAR(30),   
          @v_newtaqtaskkey INT,       
          @v_project_type INT,
          @v_cancelled_status INT,
          @v_pending_status INT,
          @v_datetypecode_Cancelled INT,
          @v_datacode INT,
          @v_datasubcode INT,
          @v_qsicode_project INT,
          @v_projectkey_POSummary INT,
          @v_po_itemtypecode INT,
          @v_po_usageclasscode INT,
          @v_taqprojectkey INT

  SET @o_error_code = 0
  SET @o_error_desc = '' 
  SET @v_count_task = 0
       
  IF @i_lastuserid IS NULL BEGIN
	SELECT @lastuserid_var = 'QSIADMIN'
  END
  ELSE BEGIN
    SET @lastuserid_var = @i_lastuserid
  END
         
  SELECT @v_datacode = COALESCE(searchitemcode, 0), @v_datasubcode = COALESCE(usageclasscode, 0) 
  FROM coreprojectinfo 
  WHERE projectkey = @i_projectkey
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning coreprojectinfo row for project (projectkey = ' + cast(@i_projectkey as varchar) + ')'
    RETURN  
  END       
  
  SELECT @v_qsicode_project = qsicode
  FROM subgentables 
  WHERE tableid = 550 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
   
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning finding subgentable 550 entry for ItemType/UsageClass for project (projectkey = ' + cast(@i_projectkey as varchar) + ')'
    RETURN  
  END        
  
  IF @v_qsicode_project <> 41 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'The project passed in is not a PO Project (projectkey = ' + cast(@i_projectkey as varchar) + ')'
    RETURN  	
  END  
  
  SELECT @v_po_itemtypecode = datacode, @v_po_usageclasscode= datasubcode
  FROM subgentables 
  WHERE tableid = 550 AND qsicode = 41
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning row qsicode 41 from subgentable 550'
    RETURN  
  END     
          
  SELECT @v_datetypecode_Cancelled = datetypecode 
  FROM datetype 
  WHERE qsicode = 32
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning datetypecode of Cancelled, qsicode 32'
    RETURN  
  END     
         
  SELECT @v_cancelled_status = datacode 
  FROM gentables 
  WHERE tableid = 522 and qsicode = 12       
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning Cancelled status from gentable 522 qsicode 2'
    RETURN  
  END   
  
  SELECT @v_pending_status = datacode 
  FROM gentables 
  WHERE tableid = 522 and qsicode = 4       
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning pending status from gentable 522 qsicode 4'
    RETURN  
  END   
        
  SELECT @v_count_task = COUNT (*) 
  FROM taqprojecttask 
  WHERE datetypecode = @v_datetypecode_Cancelled AND 
	  taqprojectkey = @i_projectkey AND
	  COALESCE(bookkey,0) <= 0 AND
	  COALESCE(taqelementkey, 0) = 0  
	  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Error accessing taqprojecttask table (' + cast(@v_error AS VARCHAR) + ').'
	  RETURN
  END 	    
  -- Auto generate 'Cancelled' date on PO summary
 	  
  IF @v_count_task = 0 BEGIN
	 exec get_next_key @lastuserid_var, @v_newtaqtaskkey output
	 insert into taqprojecttask
			(taqtaskkey, taqprojectkey, 
			datetypecode, 
			activedate, 
			keyind, 
			originaldate, 		
			lastuserid, lastmaintdate)	
	  VALUES (@v_newtaqtaskkey, @i_projectkey, @v_datetypecode_Cancelled, GETDATE(), 1, GETDATE(), @lastuserid_var, GETDATE())   
  END 
  ELSE BEGIN
	 UPDATE taqprojecttask 
	 SET activedate = GETDATE(), lastuserid = @lastuserid_var, lastmaintdate = GETDATE()
	 WHERE datetypecode = @v_datetypecode_Cancelled AND 
	  taqprojectkey = @i_projectkey AND
	  COALESCE(bookkey,0) <= 0 AND
	  COALESCE(taqelementkey, 0) = 0  
  END
    
  -- Change status on every ‘Pending’ PO report to ‘Cancelled’
  
	DECLARE taqproject_cur CURSOR FOR
		SELECT v.taqprojectkey
		FROM projectrelationshipview v
			,taqproject p
		WHERE v.taqprojectkey = p.taqprojectkey
			AND v.relatedprojectkey = @i_projectkey
			AND p.searchitemcode = @v_datacode
			AND p.usageclasscode <> @v_datasubcode		
			AND p.taqprojectstatuscode = @v_pending_status
			
	OPEN taqproject_cur
	
	FETCH taqproject_cur INTO @v_taqprojectkey

    WHILE @@fetch_status = 0 BEGIN
		UPDATE taqproject 
		SET taqprojectstatuscode = @v_cancelled_status
		WHERE taqprojectkey = @v_taqprojectkey
		
		FETCH taqproject_cur INTO @v_taqprojectkey
    END
    
    CLOSE taqproject_cur
    DEALLOCATE taqproject_cur      
   
END  
GO

GRANT EXEC ON qpo_cancelpo TO PUBLIC
GO


