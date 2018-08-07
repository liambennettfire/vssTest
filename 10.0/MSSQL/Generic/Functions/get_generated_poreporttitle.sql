if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].get_generated_poreporttitle') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].get_generated_poreporttitle
GO

CREATE FUNCTION get_generated_poreporttitle (  
  @i_projectkey   integer)
RETURNS   VARCHAR(255)
AS
/*************************************************************************************
**  Name: get_generated_poreporttitle
**  Desc: This stored procedure returns the title for a project title for PO Reports class.
**
**  Auth: Uday A. Khisty
**  Date: June 10 2014
** 
**  Modified: December 19 2014
**          : Kusum Case 30433
**        
**          : January 12 2015 Kusum Case 31198
**          : January 14 2015 Kusum Case 31213
**			: November 15 2015 Uday Case 35111
**			: March	   09 2017 Uday Case 43752
**************************************************************************************/

BEGIN

  DECLARE
    @error_var		INT,
    @rowcount_var	INT, 
    --@v_datacode_vendor INT,
    --@v_datadesc_vendor VARCHAR(40),
	@v_itemtype INT,
	@v_rowcount INT,
	@v_rowcount_printing INT,	
	@v_usageclass INT,
    @v_displayname VARCHAR(255),
    @v_gentablesrelationshipkey int,
    @v_taqprojectkey2 INT,
    @v_projecttitle VARCHAR(255),
    @v_printingnum INT,
    @v_printingstring VARCHAR(50),
    @v_printingstring_withspace VARCHAR(50),
    @v_printingstring_temp VARCHAR(50),
    @v_datadesc1 VARCHAR(40),
    @v_datadesc2 VARCHAR(40),
    @v_productnumber VARCHAR(50) ,
    @v_projecttype INT,
    @o_error_code   INT,
	@o_error_desc   varchar(2000),
    @o_result VARCHAR(255),
    @v_currentstringvalue_var VARCHAR(255),
    @v_left INT,
    @v_right INT,
    @v_current_appended_value_string VARCHAR(255),
    @v_current_appended_value_number INT,
    @v_count INT,
    @v_qsicode INT,
    @v_itemcategorycode INT,
    @v_projecttitle_PO VARCHAR(255),
    @v_datacode_PO INT,
    @v_datasubcode_PO INT,
    @v_datasubcode_ExpressPO INT,
	@v_datasubcode_PrintRunPO INT,
    @v_rowcount_PO INT    
    
    
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
  SET @o_result = ''
  SET @v_rowcount = 0
  SET @v_rowcount_printing = 0
  SET @v_current_appended_value_string = ''
  SET @v_projecttitle_PO = ''  
  
  -- Get itemtype and usage class for this project 
  SELECT @v_itemtype = searchitemcode, @v_usageclass = usageclasscode
  FROM  coreprojectinfo
  WHERE projectkey = @i_projectkey
  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
      RETURN  @o_result
  END     
  
  SELECT @v_datacode_PO = datacode, @v_datasubcode_PO = datasubcode 
  FROM subgentables 
  WHERE tableid = 550 and qsicode = 41
  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
      RETURN  @o_result
  END   
  
  SELECT @v_datasubcode_ExpressPO = datasubcode 
  FROM subgentables 
  WHERE tableid = 550 and qsicode = 51
  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
      RETURN  @o_result
  END  
  
  SELECT @v_datasubcode_PrintRunPO = datasubcode 
  FROM subgentables 
  WHERE tableid = 550 and qsicode = 60
  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
      RETURN  @o_result
  END     
  
  --select @v_datacode_vendor = datacode, @v_datadesc_vendor = datadesc 
  --from gentables 
  --where tableid = 285 and qsicode = 15
  
  --SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  --IF @error_var <> 0 BEGIN
  --    RETURN  @o_result
  --END   
  	  
  --IF EXISTS(SELECT * FROM taqprojectcontactrole WHERE rolecode IN (SELECT datacode FROM gentables WHERE tableid = 285 AND qsicode = 15) AND taqprojectkey = @i_projectkey) BEGIN
	 -- SELECT TOP(1) @v_displayname = g.displayname 
	 -- FROM globalcontact g 
	 -- WHERE globalcontactkey = (SELECT DISTINCT globalcontactkey 
		--						FROM taqprojectcontact 
		--						WHERE taqprojectcontactkey IN (
		--									SELECT taqprojectcontactkey 
		--									FROM taqprojectcontactrole 
		--									WHERE rolecode IN (SELECT datacode FROM gentables WHERE tableid = 285 AND qsicode = 15) 
		--													and taqprojectkey = @i_projectkey))   	  
	  
	 -- SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	 -- IF @error_var <> 0 BEGIN
		--RETURN  @o_result
	 -- END   	  
	  
	 -- IF @o_result <> '' BEGIN
		--SET @o_result = @o_result + ' ' +  @v_displayname	
	 -- END
	 -- ELSE BEGIN
		--SET @o_result = @v_displayname		
	 -- END
  --END
              
  --SELECT @v_rowcount_printing = count(*) FROM purchaseorderstitlesview WHERE poprojectkey = @i_projectkey
                                 
  --SELECT @error_var = @@ERROR, @v_rowcount_printing = @@ROWCOUNT
  --IF @error_var <> 0 BEGIN
  --    RETURN  @o_result
  --END                                   
                          
     
  
  IF EXISTS(SELECT * FROM taqproductnumbers where productidcode = (SELECT datacode FROM gentables where tableid = 594 AND qsicode = 7) AND productnumber IS NOT NULL AND taqprojectkey = @i_projectkey) BEGIN
	 -- PO #
	 SELECT TOP(1) @v_productnumber =  productnumber FROM taqproductnumbers WHERE productidcode = (SELECT datacode FROM gentables where tableid = 594 AND qsicode = 7)  AND productnumber IS NOT NULL AND taqprojectkey = @i_projectkey
		
		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 or @rowcount_var > 1 BEGIN
		  RETURN  @o_result
		END   		
		
		IF @o_result <> '' BEGIN
		  SET @o_result = @o_result + ' ' + LTRIM(RTRIM(@v_productnumber))	
		END
		ELSE BEGIN
		  SET @o_result = LTRIM(RTRIM(@v_productnumber))			
		END    		
		
		IF EXISTS(SELECT * FROM taqproductnumbers where productidcode = (SELECT datacode FROM gentables where tableid = 594 AND qsicode = 13) AND productnumber IS NOT NULL AND taqprojectkey = @i_projectkey) BEGIN		
		    -- PO Amendment #
			SELECT TOP(1) @v_productnumber =  productnumber FROM taqproductnumbers WHERE productidcode = (SELECT datacode FROM gentables where tableid = 594 AND qsicode = 13) AND productnumber IS NOT NULL AND taqprojectkey = @i_projectkey
			
			SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			IF @error_var <> 0 or @rowcount_var > 1 BEGIN
				RETURN  @o_result
			END   			
			
			SET @o_result = @o_result + '-' + LTRIM(RTRIM(@v_productnumber))	
		END
  END  
  
  SELECT @v_rowcount_PO = count(*)
  FROM projectrelationshipview r 
  LEFT OUTER JOIN coreprojectinfo cp ON cp.projectkey = r.taqprojectkey
  WHERE  r.relatedprojectkey = @i_projectkey AND cp.searchitemcode = @v_datacode_PO and cp.usageclasscode IN (@v_datasubcode_PO, @v_datasubcode_ExpressPO, @v_datasubcode_PrintRunPO)
                                 
  SELECT @error_var = @@ERROR, @v_rowcount_printing = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
      RETURN  @o_result
  END    
  
  IF @v_rowcount_PO > 0 BEGIN
	SELECT TOP(1) @v_projecttitle_PO = COALESCE(projecttitle, '')
	FROM projectrelationshipview r 
	LEFT OUTER JOIN coreprojectinfo cp ON cp.projectkey = r.taqprojectkey
	WHERE  r.relatedprojectkey = @i_projectkey AND cp.searchitemcode = @v_datacode_PO and cp.usageclasscode IN (@v_datasubcode_PO, @v_datasubcode_ExpressPO, @v_datasubcode_PrintRunPO)
	
    IF @o_result <> '' BEGIN
	  SET @o_result = @o_result + ' ' + @v_projecttitle_PO
    END
    ELSE BEGIN
	  SET @o_result = @v_projecttitle_PO			
    END 	
  END   
  
  --IF @v_rowcount_printing = 1 BEGIN
		
		--select @v_taqprojectkey2 =  printingprojectkey FROM purchaseorderstitlesview 
		--WHERE poprojectkey = @i_projectkey	
							  
  --      SELECT 	@v_projecttitle	= projecttitle FROM coreprojectinfo WHERE projectkey = @v_taqprojectkey2		

	 --   SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	 --   IF @error_var <> 0 or @rowcount_var > 1 BEGIN
		--  RETURN  @o_result  
	 --   END          
        		  
  --      SELECT @v_printingnum = printingnum FROM purchaseorderstitlesview WHERE poprojectkey = @i_projectkey AND printingprojectkey = @v_taqprojectkey2
        
  --      SET @v_printingstring = '#'+ convert(varchar, @v_printingnum)
  --      SET @v_printingstring_withspace = '# '+ convert(varchar, @v_printingnum)
        
  --      SET @v_printingstring_temp = ''
        
  --      IF LEN(@v_projecttitle) > LEN(@v_printingstring) BEGIN
		--	SELECT @v_printingstring_temp = RIGHT(LTRIM(RTRIM(@v_projecttitle)), LEN(@v_printingstring))
  --      END
        
  --      IF (@v_printingstring_temp <> @v_printingstring) AND (LEN(@v_projecttitle) > LEN(@v_printingstring_withspace)) BEGIN
		--	SELECT @v_printingstring_temp = RIGHT(LTRIM(RTRIM(@v_projecttitle)), LEN(@v_printingstring_withspace))
  --      END
        
  --      IF @v_printingstring = @v_printingstring_temp OR @v_printingstring_withspace = @v_printingstring_temp   BEGIN
		--    IF @o_result <> '' BEGIN
		--	  SET @o_result = @o_result + ' ' + @v_projecttitle 
		--    END
		--    ELSE BEGIN
		--	  SET @o_result = @v_projecttitle			
		--    END  		                
  --      END
  --      ELSE BEGIN
		--    IF @o_result <> '' BEGIN
		--	  SET @o_result = @o_result + ' ' + @v_projecttitle + ' ' + @v_printingstring	
		--    END
		--    ELSE BEGIN
		--	  SET @o_result = @v_projecttitle + ' ' + @v_printingstring			
		--    END                     
  --      END   
        
        
  --      SELECT @v_rowcount = COUNT(DISTINCT t.itemcategorycode)
		--FROM taqversionspeccategory t 
		--WHERE t.taqprojectkey = @i_projectkey
		----(
		----SELECT taqprojectkey1 from taqprojectrelationship WHERE taqprojectkey2 = @i_projectkey
		----UNION
		----SELECT taqprojectkey2 from taqprojectrelationship WHERE taqprojectkey1 = @i_projectkey
		----) 
		     
		
		--SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		--IF @error_var <> 0 or @rowcount_var > 1 BEGIN
		--	RETURN  @o_result
		--END   
		
	 -- IF @v_rowcount > 0 BEGIN
		--DECLARE @Category table (itemcategorycode INT)
		--INSERT INTO @Category
		--	SELECT DISTINCT  t.itemcategorycode
		--	FROM taqversionspeccategory t 
		--	WHERE t.taqprojectkey = @i_projectkey
		--	--(
		--	--SELECT taqprojectkey1 from taqprojectrelationship WHERE taqprojectkey2 = @i_projectkey
		--	--UNION
		--	--SELECT taqprojectkey2 from taqprojectrelationship WHERE taqprojectkey1 = @i_projectkey
		--	--) 
		--	ORDER BY t.itemcategorycode asc  
	  
		--DECLARE CategoryCursor CURSOR FOR
		--	SELECT itemcategorycode
		--	  FROM @Category
		--	ORDER BY itemcategorycode
		--OPEN CategoryCursor;
		--FETCH CategoryCursor INTO @v_itemcategorycode;
		
		--SET @v_count = 0 
							
		--WHILE @@FETCH_STATUS = 0 BEGIN
		--	IF @v_rowcount > 0 AND @v_rowcount <= 3 BEGIN
		--		SELECT @v_datadesc1 =  g.datadesc, @v_qsicode = COALESCE(qsicode,0) FROM gentables g WHERE tableid = 616 AND g.datacode = @v_itemcategorycode
				
		--		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		--		IF @error_var <> 0 or @rowcount_var > 1 BEGIN
		--			RETURN  @o_result
		--		END
				
		--		IF @v_qsicode = 0 BEGIN
		--			IF @v_datadesc1 IS NOT NULL AND @v_datadesc1 <> '' BEGIN
		--			    IF @v_count = 0 BEGIN
		--					IF @o_result <> '' BEGIN
		--						SET @o_result = @o_result + ' ' + @v_datadesc1
		--					END
		--					ELSE BEGIN
  --								SET @o_result = @v_datadesc1
		--					END	
					    
		--			        SET @v_count = 1
		--			    END
		--			    ELSE IF @v_count > 0 BEGIN
		--					IF @o_result <> '' BEGIN
		--						SET @o_result = @o_result + '/' + @v_datadesc1
		--					END
		--					ELSE BEGIN
  --								SET @o_result = @v_datadesc1
		--					END	
		--				END
		--			END	
		--		END
		--	END
		--	ELSE BEGIN
		--		SELECT @v_datadesc1 =  g.datadescshort, @v_qsicode = COALESCE(qsicode,0) FROM gentables g WHERE tableid = 616 AND g.datacode = @v_itemcategorycode
				
		--		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		--		IF @error_var <> 0 or @rowcount_var > 1 BEGIN
		--			RETURN  @o_result
		--		END
				
		--		IF @v_qsicode = 0 BEGIN
		--			IF @v_datadesc1 IS NULL 
		--				SELECT @v_datadesc1 = COALESCE(COALESCE(datadescshort, datadesc), '') FROM gentables where tableid = 521 AND 
		--				  datacode = (select projecttype FROM coreprojectinfo WHERE projectkey = @i_projectkey)
					
		--			IF @v_datadesc1 IS NOT NULL AND @v_datadesc1 <> '' BEGIN
		--			    IF @v_count = 0 BEGIN
		--					IF @o_result <> '' BEGIN
		--						SET @o_result = @o_result + ' ' + @v_datadesc1
		--					END
		--					ELSE BEGIN
  --								SET @o_result = @v_datadesc1
		--					END	
		--					SET @v_count = 1
		--				END
		--				ELSE IF @v_count = 1 BEGIN
		--					IF @o_result <> '' BEGIN
		--						SET @o_result = @o_result + '/' + @v_datadesc1
		--					END
		--					ELSE BEGIN
  --								SET @o_result = @v_datadesc1
		--					END	
		--				END
		--			END	
		--		 END
		--	END
		--	FETCH CategoryCursor INTO @v_itemcategorycode;
		--END;
		--CLOSE CategoryCursor;
		--DEALLOCATE CategoryCursor;
	 -- END                          				           			  
  --END --@v_rowcount_printing = 1                          
  
  SELECT @v_projecttype = projecttype FROM coreprojectinfo WHERE projectkey = @i_projectkey
  
  IF @v_projecttype IS NOT NULL BEGIN
	SELECT @v_datadesc1 = LTRIM(RTRIM(COALESCE(COALESCE(datadescshort, datadesc), ''))) FROM gentables where tableid = 521 AND datacode = @v_projecttype
	
	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 or @rowcount_var > 1 BEGIN
      RETURN  @o_result 
	END   	
	
	IF @v_datadesc1 <> '' BEGIN	
		IF LEN(@v_datadesc1) >= 6 BEGIN
			IF RIGHT(LOWER(@v_datadesc1), 6)  = 'report' BEGIN
			   SET @v_datadesc1 = LEFT(@v_datadesc1, LEN(@v_datadesc1)-6)
			END
		END	
		IF @o_result <> '' BEGIN
		  SET @o_result = @o_result + ' ' + @v_datadesc1
		END
		ELSE BEGIN
		  SET @o_result = @v_datadesc1			
		END 	
    END
  END
    
 -- SELECT @v_rowcount = COUNT(*) 
 -- FROM coreprojectinfo 
 -- WHERE searchitemcode = @v_itemtype AND usageclasscode = @v_usageclass 
 -- AND projecttitle = '' + @o_result + '' 
 -- OR projecttitle LIKE '' + @o_result + ' #[0-9]%'
  
 -- IF  @v_rowcount > 0 BEGIN
	--SELECT TOP(1) @v_currentstringvalue_var = projecttitle 
	--FROM coreprojectinfo 
	--WHERE searchitemcode = @v_itemtype AND usageclasscode = @v_usageclass 
	--  AND projecttitle = '' + @o_result + '' 
	--  OR projecttitle LIKE '' + @o_result + ' #[0-9]%'  
	--ORDER BY projecttitle DESC 
	  
	--SET @v_left = 1	
	--SET @v_right = CHARINDEX('#', REVERSE(LTRIM(RTRIM(@v_currentstringvalue_var)))) - 1
	
	--IF (@v_right < 0) BEGIN
	--	SET @v_current_appended_value_string = ''
	--END
	
	--ELSE BEGIN
	--	SET  @v_current_appended_value_string = LTRIM(RTRIM(REVERSE(LTRIM(RTRIM(SUBSTRING(REVERSE(@v_currentstringvalue_var), @v_left,
	--	 @v_right))))))
	--END	  
	
	--IF ISNUMERIC(@v_current_appended_value_string) = 1 BEGIN
	--	SET @v_current_appended_value_number = CONVERT(INT, @v_current_appended_value_string) 
	--	SET @v_current_appended_value_number = @v_current_appended_value_number + 1
	--	SET @o_result = @o_result + ' #' + convert(varchar, @v_current_appended_value_number)	
	--END
	--ELSE BEGIN
	--	SET @o_result = @o_result + ' #1'
	--END	
 -- END
  
 RETURN @o_result       
END
GO

GRANT EXEC ON get_generated_poreporttitle TO PUBLIC
GO
