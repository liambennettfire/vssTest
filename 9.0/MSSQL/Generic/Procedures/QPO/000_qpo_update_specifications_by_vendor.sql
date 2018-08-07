if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpo_update_specifications_by_vendor') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpo_update_specifications_by_vendor
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qpo_update_specifications_by_vendor
  (@i_projectkey integer,
  @i_globalcontactkey_original integer, 
  @i_globalcontactkey_current integer,   
  @i_rolecode integer, 
  @i_userid varchar(30),
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************************************************************
**  Name: qpo_update_specifications_by_vendor
**  Desc: This stored procedure updates the exisiting components to specified vendor and does Relate Specs and Costs 
**
**    Auth: Uday A. Khisty
**    Date: 03/31/15
**
**
*******************************************************************************************************************************/

DECLARE
  @v_userkey INT,
  @v_error  INT,
  @v_error_desc VARCHAR(2000),
  @v_rowcount INT,    
  @v_itemtypecode_for_PO INT,
  @v_usageclasscode_for_PO INT,   
  @v_itemtypecode_for_POReports_Proforma INT,
  @v_usageclasscode_for_POReports_Proforma INT,
  @v_itemtypecode_for_POReports_Final INT,
  @v_usageclasscode_for_POReports_Final INT,    
  @v_itemtypecode INT,
  @v_usageclasscode INT, 
  @v_itemtypecode_relatedproject INT,
  @v_usageclasscode_relatedproject INT,   
  @v_vendor_rolecode  INT,    
  @v_count INT,
  @v_relatespecscostind INT,
  @v_relatedprojectkey INT,
  @v_relationshipcode INT,
  @v_name_autogen TINYINT,
  @v_name_gen_sql VARCHAR(2000),  
  @v_result_value1 VARCHAR(255),
  @v_result_value2 VARCHAR(255),
  @v_result_value3 VARCHAR(255),
  @v_quote  CHAR(1),
  @v_generated_title VARCHAR(255),
  @v_taqprojectstatuscode INT    
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''  
  SET @v_relatespecscostind = 0
  SET @v_generated_title = NULL
  SET @v_taqprojectstatuscode = 0
  
  IF @i_globalcontactkey_original < 0 BEGIN
	SET @i_globalcontactkey_original = 0
  END
  
  IF @i_globalcontactkey_current < 0 BEGIN
	SET @i_globalcontactkey_current = 0  
  END  
  /** Get userkey for the given userid passed **/
  SELECT @v_userkey = userkey
  FROM qsiusers
  WHERE Upper(userid) = Upper(@i_userid)
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1  
    SET @o_error_desc = 'Error getting userkey for userid ' + CAST(@i_userid AS VARCHAR) + '.'
  END  
  
  SELECT @v_itemtypecode = searchitemcode, @v_usageclasscode = usageclasscode 
  FROM coreprojectinfo 
  WHERE projectkey = @i_projectkey     
  
  SELECT @v_itemtypecode_for_PO = datacode, @v_usageclasscode_for_PO = datasubcode 
  FROM subgentables 
  where tableid = 550 AND qsicode = 41    
  
  SELECT @v_itemtypecode_for_POReports_Proforma = datacode, @v_usageclasscode_for_POReports_Proforma = datasubcode 
  FROM subgentables 
  where tableid = 550 AND qsicode = 42      
  
  SELECT @v_itemtypecode_for_POReports_Final = datacode, @v_usageclasscode_for_POReports_Final = datasubcode 
  FROM subgentables 
  where tableid = 550 AND qsicode = 43      
  
  SELECT @v_vendor_rolecode = datacode
     FROM gentables
    WHERE tableid = 285 AND qsicode = 15      

  IF @v_vendor_rolecode = @i_rolecode BEGIN  
	 IF COALESCE(@i_globalcontactkey_current, 0) = 0 BEGIN
		SET @i_globalcontactkey_current = NULL
	 END
	 
	 IF @i_globalcontactkey_current = @i_globalcontactkey_original BEGIN
		RETURN
	 END
				
    IF exists(SELECT * FROM taqversionspeccategory WHERE taqprojectkey = @i_projectkey AND relatedspeccategorykey IS NOT NULL) BEGIN
		UPDATE taqversionspeccategory SET vendorcontactkey = @i_globalcontactkey_current 
		WHERE taqversionspecategorykey IN (SELECT relatedspeccategorykey FROM taqversionspeccategory WHERE taqprojectkey = @i_projectkey)
		AND COALESCE(vendorcontactkey, 0) = COALESCE(@i_globalcontactkey_original, 0)
		
		SELECT @v_error = @@ERROR
		IF @v_error <> 0 BEGIN
		  SET @o_error_desc = 'Error Updating taqversionspeccategory to set vendorcontactkey to '+ + ' for relatedspeccategorykey rows of taqprojectkey' + CAST(@i_projectkey AS VARCHAR) + '.'
		  RETURN
		END  				
    END					
			
	-- Update the specification rows to reflect the new globalcontactkey wherever the old globalcontactkey was present		
    UPDATE taqversionspeccategory SET vendorcontactkey = @i_globalcontactkey_current WHERE taqprojectkey = @i_projectkey AND COALESCE(vendorcontactkey, 0) = COALESCE(@i_globalcontactkey_original, 0)		
  
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
	  SET @o_error_desc = 'Error Updating taqversionspeccategory to set vendorcontactkey to '+ + ' for taqprojectkey' + CAST(@i_projectkey AS VARCHAR) + '.'
	  RETURN
    END  
    
    IF @v_itemtypecode = @v_itemtypecode_for_PO AND @v_usageclasscode = @v_usageclasscode_for_PO BEGIN
		select @v_generated_title = dbo.get_generated_purchaseordertitle(@i_projectkey)
    END
    ELSE IF @v_itemtypecode = @v_itemtypecode_for_POReports_Final AND @v_usageclasscode = @v_usageclasscode_for_POReports_Final BEGIN
		select @v_generated_title = dbo.get_generated_poreporttitle(@i_projectkey)			
    END 
    ELSE BEGIN	    	    
		SELECT @v_name_autogen = autogeneratenameind
		FROM taqproject
		WHERE taqprojectkey = @i_projectkey	   
		
		SELECT @v_name_gen_sql = alternatedesc1
		FROM subgentables
		WHERE tableid = 550 AND datacode = @v_itemtypecode AND datasubcode = @v_usageclasscode
		
		-- Execute the name auto-generation stored procedure if it exists for Printings and if taqproject.autogeneratenameind = 1
		IF @v_name_gen_sql IS NOT NULL AND @v_name_autogen = 1 BEGIN
		  -- Replace each parameter placeholder with corresponding value
		  SET @v_name_gen_sql = REPLACE(@v_name_gen_sql, '@userid', @v_quote + @i_userid + @v_quote)
		  SET @v_name_gen_sql = REPLACE(@v_name_gen_sql, '@projectkey', CONVERT(VARCHAR, @i_projectkey))
		  
		  -- Execute the stored name auto-generation stored procedure for Printings
		  EXEC qutl_execute_prodidsql2 @v_name_gen_sql, @v_result_value1 OUTPUT, @v_result_value2 OUTPUT, @v_result_value3 OUTPUT,
			@v_error OUTPUT, @v_error_desc OUTPUT
			
		  IF @v_error <> 0 BEGIN
			SET @o_error_code = -1  
			SET @o_error_desc = @v_error_desc
		  END   

		  SET @v_generated_title = @v_result_value1	
	  END	 		  		
	END		
	
	IF @v_generated_title IS NOT NULL BEGIN
		UPDATE taqproject
		SET taqprojecttitle = @v_generated_title, lastuserid = @i_userid, lastmaintdate = getdate()
		WHERE taqprojectkey = @i_projectkey
    END
				  
  ---- Get the related Printing Project Key
	DECLARE projects_cur CURSOR FOR 
	   SELECT DISTINCT r.relatedprojectkey, r.relationshipcode, t.searchitemcode, t.usageclasscode, t.taqprojectstatuscode
		FROM projectrelationshipview r , taqproject t 
	    WHERE r.taqprojectkey = @i_projectkey
	      AND r.relatedprojectkey = t.taqprojectkey
		  
	OPEN projects_cur 

	FETCH projects_cur INTO @v_relatedprojectkey, @v_relationshipcode, @v_itemtypecode_relatedproject, @v_usageclasscode_relatedproject, @v_taqprojectstatuscode
	
	WHILE @@fetch_status = 0 BEGIN
	  SELECT @v_relatespecscostind = coalesce(gen2ind,0) FROM gentables WHERE tableid=582 AND datacode = @v_relationshipcode
	  
	  IF @v_relatespecscostind = 1 AND COALESCE(@i_globalcontactkey_current, 0) > 0 BEGIN
		EXEC qpl_relate_specs_and_costs @i_projectkey, @v_relatedprojectkey, @i_globalcontactkey_current, @o_error_code OUTPUT, @o_error_desc OUTPUT

		IF @o_error_code <> 0 BEGIN
		  SET @o_error_code = -1
		  RETURN
		END 				
	  END
	  
-- Commenting this part out for now. If we need to generate the related Projects name, we must uncomment it
	 -- IF (@v_itemtypecode_relatedproject = @v_itemtypecode_for_POReports_Proforma AND @v_usageclasscode_relatedproject = @v_usageclasscode_for_POReports_Proforma) OR
	 --    (@v_itemtypecode_relatedproject = @v_itemtypecode_for_POReports_Final AND @v_usageclasscode_relatedproject = @v_usageclasscode_for_POReports_Final) BEGIN
		--  SET @v_generated_title = NULL
		--  select @v_generated_title = dbo.get_generated_poreporttitle(@v_relatedprojectkey)
		  
		--IF @v_generated_title IS NOT NULL AND @v_taqprojectstatuscode NOT IN (SELECT datacode FROM gentables WHERE tableid = 522 AND gen2ind = 1) BEGIN
		--	UPDATE taqproject
		--	SET taqprojecttitle = @v_generated_title, lastuserid = @i_userid, lastmaintdate = getdate()
		--	WHERE taqprojectkey = @v_relatedprojectkey
		--END			  
	 -- END
	 		  
	  FETCH projects_cur INTO @v_relatedprojectkey, @v_relationshipcode, @v_itemtypecode_relatedproject, @v_usageclasscode_relatedproject, @v_taqprojectstatuscode
	END --@@fetch_status = 0 for projects_cur
	
	CLOSE projects_cur 
	DEALLOCATE projects_cur 					  	  					 		 					  
  END
  
END
GO

GRANT EXEC ON qpo_update_specifications_by_vendor TO PUBLIC
GO


