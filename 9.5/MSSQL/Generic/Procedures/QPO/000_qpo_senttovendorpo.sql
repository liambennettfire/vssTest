if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpo_senttovendorpo') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qpo_senttovendorpo
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpo_senttovendorpo
 (@i_projectkey           integer,
  @i_lastuserid           varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qpo_senttovendorpo
**  Desc: This procedure will be called when the Print & Mark Sent button is clicked on PO Report.  
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
/*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   --------------------------------------
**   04/06/2016   Kusum        36178     Keys Table at S&S Getting Close to Max Value   
**   06/29/2016   Uday		   38904     historychanges not updating lastmaintdate when po amended 
*******************************************************************************/
BEGIN
  DECLARE @v_error	INT,
          @v_rowcount INT,
          @v_count_task INT,
          @lastuserid_var   VARCHAR(30),   
          @v_newtaqtaskkey INT,       
          @v_SentToVendor_status INT,
		  @v_proforma_SentToVendor_status INT,
		  @v_final_SentToVendor_status INT,
          @v_datetypecode_SentToVendor INT,
          @v_datacode INT,
          @v_datasubcode INT,
          @v_qsicode_project INT,
          @v_projectkey_POSummary INT

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
  
  IF @v_qsicode_project NOT IN (42, 43) BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'The project passed in is not a Proforma PO Report or Final PO Report (projectkey = ' + cast(@i_projectkey as varchar) + ')'
    RETURN  	
  END   
          
  SELECT @v_datetypecode_SentToVendor = datetypecode 
  FROM datetype 
  WHERE qsicode = 31
         
  SELECT @v_SentToVendor_status = datacode 
  FROM gentables 
  WHERE tableid = 522 and qsicode = 13       
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning Sent to Vendor status from gentable 522 qsicode 13'
    RETURN  
  END   
  
  SELECT @v_proforma_SentToVendor_status = datacode 
  FROM gentables 
  WHERE tableid = 522 and qsicode = 7       
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning Proforma Sent to Vendor status from gentable 522 qsicode 7'
    RETURN  
  END   
  
  SELECT @v_final_SentToVendor_status = datacode 
  FROM gentables 
  WHERE tableid = 522 and qsicode = 9       
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning Final Sent to Vendor status from gentable 522 qsicode 9'
    RETURN  
  END       
  
  -- Existing PO Report project status set to 'Sent to Vendor'  
  UPDATE taqproject 
  SET taqprojectstatuscode = @v_SentToVendor_status, lastuserid = @lastuserid_var, lastmaintdate = GETDATE()
  WHERE taqprojectkey = @i_projectkey
  
  SELECT @v_count_task = COUNT (*) 
  FROM taqprojecttask 
  WHERE datetypecode = @v_datetypecode_SentToVendor AND 
	  taqprojectkey = @i_projectkey AND
	  COALESCE(bookkey,0) <= 0 AND
	  COALESCE(taqelementkey, 0) = 0  
	  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Error accessing taqprojecttask table (' + cast(@v_error AS VARCHAR) + ').'
	  RETURN
  END 	  
	  
 --Auto generate ‘Sent to Vendor’ date on the PO Report   	  
  IF @v_count_task = 0 BEGIN
	 exec get_next_key 'taqprojecttask', @v_newtaqtaskkey output
	 
	 insert into taqprojecttask
			(taqtaskkey, taqprojectkey, 
			datetypecode, 
			activedate, 
			keyind, 
			originaldate, 		
			lastuserid, lastmaintdate)	
	  VALUES (@v_newtaqtaskkey, @i_projectkey, @v_datetypecode_SentToVendor, GETDATE(), 1, GETDATE(), @lastuserid_var, GETDATE())   
  END 
  ELSE BEGIN
	 UPDATE taqprojecttask 
	 SET activedate = GETDATE(), lastuserid = @lastuserid_var, lastmaintdate = GETDATE()
	 WHERE datetypecode = @v_datetypecode_SentToVendor AND 
	  taqprojectkey = @i_projectkey AND
	  COALESCE(bookkey,0) <= 0 AND
	  COALESCE(taqelementkey, 0) = 0  
  END
  
 -- Set PO Summary Status = 'Proforma Sent to Vendor' if proforma; ‘Final Sent to Vendor’ if final   
  SELECT TOP(1) @v_projectkey_POSummary = v.relatedprojectkey
  FROM projectrelationshipview v, taqproject p, coreprojectinfo c
  WHERE v.relatedprojectkey = p.taqprojectkey	
    AND v.taqprojectkey = c.projectkey
    AND p.searchitemcode = c.searchitemcode	
	AND v.taqprojectkey = @i_projectkey
       
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning related PO Projectkey for project report (projectkey = ' + cast(@i_projectkey as varchar) + ')'
    RETURN  
  END       
       
  IF @v_qsicode_project = 42 BEGIN  -- Proforma PO Report
	  UPDATE taqproject 
	  SET taqprojectstatuscode = @v_proforma_SentToVendor_status, lastuserid = @lastuserid_var, lastmaintdate = GETDATE()
	  WHERE taqprojectkey = @v_projectkey_POSummary  
  END
  ELSE IF @v_qsicode_project = 43 BEGIN  -- Final PO Report
	  UPDATE taqproject 
	  SET taqprojectstatuscode = @v_final_SentToVendor_status, lastuserid = @lastuserid_var, lastmaintdate = GETDATE()
	  WHERE taqprojectkey = @v_projectkey_POSummary  
  END      
  
  -- Auto generate/Update ‘Sent to Vendor’ date on the Purchase Order     
  SELECT @v_count_task = COUNT (*) 
  FROM taqprojecttask 
  WHERE datetypecode = @v_datetypecode_SentToVendor AND 
	  taqprojectkey = @v_projectkey_POSummary AND
	  COALESCE(bookkey,0) <= 0 AND
	  COALESCE(taqelementkey, 0) = 0  
	  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Error accessing taqprojecttask table (' + cast(@v_error AS VARCHAR) + ').'
	  RETURN
  END 	  
	  
  IF @v_count_task = 0 BEGIN
	 exec get_next_key @lastuserid_var, @v_newtaqtaskkey output
	 insert into taqprojecttask
			(taqtaskkey, taqprojectkey, 
			datetypecode, 
			activedate, 
			keyind, 
			originaldate, 		
			lastuserid, lastmaintdate)	
	  VALUES (@v_newtaqtaskkey, @v_projectkey_POSummary, @v_datetypecode_SentToVendor, GETDATE(), 1, GETDATE(), @lastuserid_var, GETDATE())   
  END 
  ELSE BEGIN
	 UPDATE taqprojecttask 
	 SET activedate = GETDATE(), lastuserid = @lastuserid_var, lastmaintdate = GETDATE()
	 WHERE datetypecode = @v_datetypecode_SentToVendor AND 
	  taqprojectkey = @v_projectkey_POSummary AND
	  COALESCE(bookkey,0) <= 0 AND
	  COALESCE(taqelementkey, 0) = 0  
  END  
   
END  
GO

GRANT EXEC ON qpo_senttovendorpo TO PUBLIC
GO


