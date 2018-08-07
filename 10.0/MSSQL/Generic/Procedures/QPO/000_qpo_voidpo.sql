if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpo_voidpo') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qpo_voidpo
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpo_voidpo
 (@i_projectkey           integer,
  @i_lastuserid           varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/***********************************************************************************************************
**  Name: qpo_voidpo
**  Desc: This procedure will void a PO 
**        Taqprojectkey of the PO Report to be voided and
**        Lastuserid of user voiding PO will be passed in
**	Auth: Kusum
**	Date: 20th November 2014
************************************************************************************************************
************************************************************************************************************
**    Change History
************************************************************************************************************
**    Date:         Author:      Case #:        Description:
**    ----------    --------     ----------     ------------------------------------------------------------
**    01/22/2016    UK		     35983     gpo status not being updated when Po Report is amended 
************************************************************************************************************
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:      Case #:   Description:
**   ---------    --------     -------   --------------------------------------
**   03/29/2016   Kusum        36178     Keys Table at S&S Getting Close to Max Value     
**   07/02/2018   Colman		   TM-570
*******************************************************************************/
BEGIN 
  DECLARE 
	@v_proforma_pending INT,
	@v_proforma_approved INT,
	@v_final_pending INT,
	@v_final_approved INT,
	@v_taqprojectstatuscode INT,
	@v_taqprojectstatusdesc VARCHAR(40),
	@v_taqprojecttitle VARCHAR(100),
	@v_count INT,
	@v_purchaseorders_for_poreports INT,
	@v_poreports_for_purchaseorders INT,
	@v_taqtaskkey  INT,
	@v_datetypecode INT,
	@v_lastuserid VARCHAR(30),
	@v_related_projectkey INT,
	@v_void INT,
	@v_po_number	INT,
	@v_poamendment_number INT,
	@v_amendment_numberkey INT,
	@v_amendentnumber VARCHAR(50),
	@v_po_numberkey INT,
	@v_ponumber VARCHAR(50),
	@v_po_numberkey2 INT,
	@v_ponumber2 VARCHAR(50),
	@v_amendment_numberkey2 INT,
	@v_amendentnumber2 VARCHAR(50),
	@v_saved_related_projectkey INT,
	@v_saved_related_projectkey2 INT,
	@v_pending INT,
	@error_var INT,
    @rowcount_var INT,
    @v_po_taqprojectkey INT,
    @v_amended	INT,
    @v_cancelled INT
   

	SET @o_error_code = 0
	SET @o_error_desc = '' 
	IF @i_lastuserid IS NOT NULL and @i_lastuserid <> '' 
		SET @v_lastuserid = @i_lastuserid 
	ELSE
		SET @v_lastuserid = 'QSIADMIN' 
	
	--Project Status
	--SELECT @v_proforma_pending = datacode FROM gentables WHERE tableid = 522 AND qsicode = 6  --Proforma Pending
	--SELECT @v_proforma_approved = datacode FROM gentables WHERE tableid = 522 AND qsicode = 7  --Proforma Approved
	--SELECT @v_final_pending = datacode FROM gentables WHERE tableid = 522 AND qsicode = 8  --Final Pending
	--SELECT @v_final_approved = datacode FROM gentables WHERE tableid = 522 AND qsicode = 9  --Final Approved
	SELECT @v_void = datacode FROM gentables WHERE tableid = 522 AND qsicode = 10  --Void
	SELECT @v_pending = datacode FROM gentables WHERE tableid = 522 AND qsicode = 4  --Pending
	
	SELECT @v_amended = datacode FROM gentables WHERE tableid = 522 AND qsicode = 11  --Amended
	SELECT @v_cancelled = datacode FROM gentables WHERE tableid = 522 AND qsicode = 2  --Cancelled
	
	-- Project Relationship Tab
	SELECT @v_purchaseorders_for_poreports = datacode FROM gentables WHERE tableid = 582 AND qsicode = 27  --Purchase Orders (for PO Reports)
	SELECT @v_poreports_for_purchaseorders = datacode FROM gentables WHERE tableid = 582 AND qsicode = 28  --PO Reports (for Purchase Orders)
	
	-- Date Type
	select @v_datetypecode = datetypecode FROM datetype where qsicode = 30 -- PO Voided
	
	--ProjectElement/ID Type
	select @v_poamendment_number = datacode FROM gentables WHERE tableid = 594 and qsicode = 13  --PO Amendment #
	select @v_po_number = datacode FROM gentables WHERE tableid = 594 and qsicode = 7  --PO #
	
	SELECT @v_taqprojectstatuscode = taqprojectstatuscode, @v_taqprojecttitle = taqprojecttitle 
	  FROM taqproject WHERE taqprojectkey = @i_projectkey
	
	IF @v_taqprojectstatuscode IN (@v_void,@v_amended,@v_cancelled) BEGIN
	  SELECT @v_taqprojectstatusdesc = datadesc FROM gentables WHERE tableid = 522 and datacode = @v_taqprojectstatuscode
		SET @o_error_code = -99
		SET @o_error_desc = 'PO Report ' + CONVERT(varchar,@v_taqprojecttitle) + ' with a status of ' +
			CONVERT(varchar,@v_taqprojectstatusdesc) + ' can not be voided'
		RETURN
	END
	
	-- Get the taqprojectkey of the PO Summary project
	SELECT @v_count = 0
	
	SELECT @v_count = COUNT(*)
	  FROM projectrelationshipview
	 WHERE taqprojectkey = @i_projectkey
	   AND relationshipcode = @v_purchaseorders_for_poreports
	   
	IF @v_count = 1 BEGIN
		SELECT @v_po_taqprojectkey = relatedprojectkey
		  FROM projectrelationshipview
	     WHERE taqprojectkey = @i_projectkey
	       AND relationshipcode = @v_purchaseorders_for_poreports
	END
	
	-- Check the number of PO Reports projects that are on the PO Summary project
	SELECT @v_count = 0
	
	SELECT @v_count = COUNT(*)
	  FROM projectrelationshipview
	 WHERE taqprojectkey = @v_po_taqprojectkey
	   AND relationshipcode = @v_poreports_for_purchaseorders
	   		   
	IF @v_count = 1 BEGIN  
	  -- we are voiding the only PO Report project on PO Summary Report project	  
	  UPDATE taqproject
	     SET taqprojectstatuscode = @v_void,
		     lastuserid = @v_lastuserid,
			 lastmaintdate = getdate()
	   WHERE taqprojectkey = @i_projectkey
	     
	  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Unable to set taqprojectstatuscode on taqproject (' + cast(@error_var AS VARCHAR) + ').'
		  RETURN 
		END 
		
	  UPDATE gpo
	     SET gpostatus = 'V',
		     lastuserid = @v_lastuserid,
			 lastmaintdate = getdate()
	   WHERE gpokey = @i_projectkey	
	   
	  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Unable to set gpostatus on gpo (' + cast(@error_var AS VARCHAR) + ').'
		  RETURN 
		END			
		
	  UPDATE taqproject
	     SET taqprojectstatuscode = @v_void,
		     lastuserid = @v_lastuserid,
			 lastmaintdate = getdate()
	   WHERE taqprojectkey = @v_po_taqprojectkey
	     
	  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Unable to set taqprojectstatuscode on taqproject (' + cast(@error_var AS VARCHAR) + ').'
		  RETURN 
		END 
		
	  UPDATE gpo
	     SET gpostatus = 'V',
		     lastuserid = @v_lastuserid,
			 lastmaintdate = getdate()
	   WHERE gpokey = @v_po_taqprojectkey	
	   
	  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Unable to set gpostatus on gpo (' + cast(@error_var AS VARCHAR) + ').'
		  RETURN 
		END	
	    
	  -- Auto generate 'PO Voided' datetype on PO Report
		EXEC dbo.get_next_key 'taqprojecttask', @v_taqtaskkey OUT
			
		--print 'PO Voided'
		--print '@v_datetypecode'
		--print @v_datetypecode
        
		INSERT INTO taqprojecttask(taqtaskkey,taqprojectkey,datetypecode,keyind,activedate,actualind,lastuserid,lastmaintdate)
			 VALUES (@v_taqtaskkey,@i_projectkey,@v_datetypecode,1,getdate(),1,@v_lastuserid, getdate())
	          
		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			IF @error_var <> 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'Unable to insert row into taqprojecttask for PO Voided (' + cast(@error_var AS VARCHAR) + ').'
			  RETURN 
		END              
	END 
	ELSE IF @v_count > 1 BEGIN  
	  -- Multiple PO Report projects on PO Summary Report project
	  SELECT @v_amendment_numberkey = productnumberkey, @v_amendentnumber = COALESCE(productnumber,0)
	    FROM taqproductnumbers
	   WHERE taqprojectkey = @i_projectkey
	     AND productidcode = @v_poamendment_number
	       
	       
	  SELECT @v_po_numberkey = productnumberkey, @v_ponumber = productnumber
	    FROM taqproductnumbers
	   WHERE taqprojectkey = @i_projectkey
	     AND productidcode = @v_po_number
	       
	  SET @v_saved_related_projectkey = 0
	  SET @v_saved_related_projectkey2 = 0
	       
	  DECLARE taqproductnumbers_cur CURSOR FOR
		 SELECT productnumberkey,productnumber, taqprojectkey
		   FROM taqproductnumbers 
		  WHERE productnumber = @v_ponumber
		    AND productidcode = @v_po_number
		    AND taqprojectkey < @i_projectkey
		ORDER BY taqprojectkey DESC
			   
	  OPEN taqproductnumbers_cur
		
	  FETCH taqproductnumbers_cur INTO @v_po_numberkey2,@v_ponumber2,@v_related_projectkey 
    
      WHILE @@fetch_status = 0 BEGIN
		SELECT @v_amendment_numberkey2 = productnumberkey, @v_amendentnumber2 = COALESCE(productnumber,0)
		  FROM taqproductnumbers
	     WHERE taqprojectkey = @v_related_projectkey
	       AND productidcode = @v_poamendment_number
	          
                 
		SET @v_saved_related_projectkey = @v_po_taqprojectkey
          
        IF @v_saved_related_projectkey > 0  BEGIN
            -- Set status to 'Void' on the PO Report and PO Summary
			UPDATE taqproject
			   SET taqprojectstatuscode = @v_void,
			       lastuserid = @v_lastuserid,
			       lastmaintdate = getdate()
			 WHERE taqprojectkey = @i_projectkey
  				   
  				   
		     SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			 IF @error_var <> 0 BEGIN
				 SET @o_error_code = -1
			     SET @o_error_desc = 'Unable to set taqprojectstatuscode on taqproject (' + cast(@error_var AS VARCHAR) + ').'
			     RETURN 
		     END 
		     
		     UPDATE gpo
				SET gpostatus = 'V',
				    lastuserid = @v_lastuserid,
					lastmaintdate = getdate()
			  WHERE gpokey = @i_projectkey	
			   
			  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
				IF @error_var <> 0 BEGIN
				  SET @o_error_code = -1
				  SET @o_error_desc = 'Unable to set gpostatus on gpo (' + cast(@error_var AS VARCHAR) + ').'
				  RETURN 
				END			     
		     
			UPDATE taqproject
			   SET taqprojectstatuscode = @v_void,
			       lastuserid = @v_lastuserid,
			       lastmaintdate = getdate()
			 WHERE taqprojectkey = @v_saved_related_projectkey
  				   
  				   
		     SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			 IF @error_var <> 0 BEGIN
				 SET @o_error_code = -1
			     SET @o_error_desc = 'Unable to set taqprojectstatuscode on taqproject (' + cast(@error_var AS VARCHAR) + ').'
			     RETURN 
		     END 
		     
		     UPDATE gpo
				SET gpostatus = 'V',
				    lastuserid = @v_lastuserid,
					lastmaintdate = getdate()
			  WHERE gpokey = @v_po_taqprojectkey	
			   
			  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
				IF @error_var <> 0 BEGIN
				  SET @o_error_code = -1
				  SET @o_error_desc = 'Unable to set gpostatus on gpo (' + cast(@error_var AS VARCHAR) + ').'
				  RETURN 
				END			     
	    END 
       
         
       IF @v_amendentnumber2 > 0 BEGIN 
		   IF @v_amendentnumber2 = (@v_amendentnumber - 1) BEGIN
			SET @v_saved_related_projectkey2 = @v_related_projectkey
	          
			IF @v_saved_related_projectkey2 > 0 BEGIN
				-- Set previous PO Report project to have status of 'Pending'
				UPDATE taqproject
				   SET taqprojectstatuscode = @v_pending,
				   	   lastuserid = @v_lastuserid,
					   lastmaintdate = getdate()
				 WHERE taqprojectkey = @v_saved_related_projectkey2
					   
				 SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
				 IF @error_var <> 0 BEGIN
					 SET @o_error_code = -1
					 SET @o_error_desc = 'Unable to set taqprojectstatuscode on taqproject (' + cast(@error_var AS VARCHAR) + ').'
					 RETURN 
				 END 
			END
		END
	   END
	    	        
	   FETCH taqproductnumbers_cur INTO @v_po_numberkey2,@v_ponumber2,@v_related_projectkey 
    END  --WHILE @@fetch_status = 0
        
    CLOSE taqproductnumbers_cur
    DEALLOCATE taqproductnumbers_cur
               				
    -- Auto generate 'PO Voided' datetype on PO Report   
   	EXEC dbo.get_next_key 'taqprojecttask', @v_taqtaskkey OUT
			
		--print 'PO Voided'
		--print '@v_datetypecode'
		--print @v_datetypecode
        
    INSERT INTO taqprojecttask(taqtaskkey,taqprojectkey,datetypecode,keyind,activedate,actualind,lastuserid,lastmaintdate)
      VALUES (@v_taqtaskkey,@i_projectkey,@v_datetypecode,1,getdate(),1,@v_lastuserid, getdate())
      
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Unable to insert row into taqprojecttask for PO Voided (' + cast(@error_var AS VARCHAR) + ').'
		  RETURN 
		END 
	END 
END
GO

GRANT EXEC ON dbo.qpo_voidpo TO public
GO