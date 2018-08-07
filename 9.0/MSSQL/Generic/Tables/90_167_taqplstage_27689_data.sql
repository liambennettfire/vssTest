DECLARE 
	@v_itemtypecode_SpecTemplate INT,
	@v_itemtypesubcode_SpecTemplate INT,
	@v_projectkey INT,
	@v_plstagecode INT		
		
	SELECT @v_itemtypecode_SpecTemplate = datacode, @v_itemtypesubcode_SpecTemplate = datasubcode FROM subgentables where tableid = 550 and qsicode = 44	
    SELECT @v_plstagecode = datacode FROM gentables WHERE tableid = 562 AND qsicode = 2
	
	  DECLARE pl_coreprojectinfo_cur CURSOR FOR
		SELECT projectkey FROM coreprojectinfo where searchitemcode = @v_itemtypecode_SpecTemplate and usageclasscode = @v_itemtypesubcode_SpecTemplate
	  OPEN pl_coreprojectinfo_cur

	  FETCH NEXT FROM pl_coreprojectinfo_cur INTO @v_projectkey

	  WHILE (@@FETCH_STATUS = 0) 
	  BEGIN	  
		  IF NOT EXISTS(SELECT * FROM taqplstage WHERE taqprojectkey = @v_projectkey) 
		  BEGIN	  

			INSERT INTO taqplstage
				(taqprojectkey, plstagecode, selectedversionkey, lastuserid, lastmaintdate, exchangerate, exchangeratelockind)
			VALUES
				(@v_projectkey, @v_plstagecode, 1, 'QSIDBA', getdate(), NULL, 0)			
		  END
		 -- ELSE BEGIN
			--UPDATE taqplstage SET plstagecode = @v_plstagecode, selectedversionkey = 1 WHERE taqprojectkey = @v_projectkey
		 -- END	
		  PRINT @v_projectkey
		  UPDATE taqplstage SET plstagecode = @v_plstagecode, selectedversionkey = 1 WHERE taqprojectkey = @v_projectkey		  
		  UPDATE taqversion SET plstagecode = @v_plstagecode, taqversionkey = 1 WHERE taqprojectkey = @v_projectkey		
		  UPDATE taqversionformat SET plstagecode = @v_plstagecode, taqversionkey = 1 WHERE taqprojectkey = @v_projectkey		
		  UPDATE taqversionspeccategory SET plstagecode = @v_plstagecode, taqversionkey = 1 WHERE taqprojectkey = @v_projectkey			
		  UPDATE taqversionsubrights SET plstagecode = @v_plstagecode, taqversionkey = 1 WHERE taqprojectkey = @v_projectkey	
		  UPDATE taqversionmarket SET plstagecode = @v_plstagecode, taqversionkey = 1 WHERE taqprojectkey = @v_projectkey		
		  UPDATE taqversionformatyear SET plstagecode = @v_plstagecode, taqversionkey = 1 WHERE taqprojectkey = @v_projectkey		
		  UPDATE taqversionaddtlunits SET plstagecode = @v_plstagecode, taqversionkey = 1 WHERE taqprojectkey = @v_projectkey		
		  UPDATE taqversionroyaltysaleschannel SET plstagecode = @v_plstagecode, taqversionkey = 1 WHERE taqprojectkey = @v_projectkey		
		  UPDATE taqversionsaleschannel SET plstagecode = @v_plstagecode, taqversionkey = 1 WHERE taqprojectkey = @v_projectkey	
		  UPDATE taqversionclientvalues SET plstagecode = @v_plstagecode, taqversionkey = 1 WHERE taqprojectkey = @v_projectkey		
		  UPDATE taqversioncomments SET plstagecode = @v_plstagecode, taqversionkey = 1 WHERE taqprojectkey = @v_projectkey		
		  UPDATE taqversionroyaltyadvance SET plstagecode = @v_plstagecode, taqversionkey = 1 WHERE taqprojectkey = @v_projectkey	
		  UPDATE taqversionformatcomplete SET plstagecode = @v_plstagecode, taqversionkey = 1 WHERE taqprojectkey = @v_projectkey		
		  UPDATE taqversioncomplete SET plstagecode = @v_plstagecode, taqversionkey = 1 WHERE taqprojectkey = @v_projectkey	
		  UPDATE taqplsummaryitems SET plstagecode = @v_plstagecode, taqversionkey = 1 WHERE taqprojectkey = @v_projectkey			  		  		    			  	  		  		  	  		  	  	  			    	          
		FETCH NEXT FROM pl_coreprojectinfo_cur INTO @v_projectkey
	  END

	  CLOSE pl_coreprojectinfo_cur 
	  DEALLOCATE pl_coreprojectinfo_cur