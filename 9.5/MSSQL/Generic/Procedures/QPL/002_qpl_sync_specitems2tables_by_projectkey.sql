
/****** Object:  StoredProcedure [dbo].[qpl_sync_specitems2tables_by_projectkey]    Script Date: 01/06/2015 10:26:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_sync_specitems2tables_by_projectkey]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_sync_specitems2tables_by_projectkey]
GO

/****** Object:  StoredProcedure [dbo].[qpl_sync_specitems2tables_by_projectkey]    Script Date: 01/06/2015 10:26:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.qpl_sync_specitems2tables_by_projectkey 
(@i_taqprojectkey int, 
 @i_taqversionkey int, 
 @i_userid varchar(255),  
 @o_error_code integer output,
 @o_error_desc varchar(2000) output)
AS
BEGIN
--based on projectkey and taqversionkey, determine if there are any specs to sync by crawling down the version to check all taqversioncategory\taqversionspecitem rows for the version
--once we have that list, we can call [dbo].[qpl_sync_specitems2tables] (@i_taqversionspecitemkey int,@i_userid varchar(50))  to process each specitemkey
--the calling sp may or may not know if it is the selected version or not so we check again in the qpl_sync_specitems2tables sp

DECLARE
@i_qtyvalue int,
@v_descvalue nvarchar(1000),
@v_desc2value nvarchar(1000),
@i_detailvalue int,
@i_detail2value int,
@i_uomvalue int,
@i_decimalvalue decimal(15,4),
@i_taqversionspecitemkey int,
@i_syncspecs int,
@i_syncspecs2 int,
@i_NumberRecords int,
@i_RowCount int,
@v_bookkey INT,
@v_itemtype INT,
@v_usageclass INT,
@v_project_qsicode INT,
@v_error    INT,
@v_rowcount INT,
@v_count  INT,
@v_printing_projectkey INT,
@v_min_printing_key INT,
@v_templateind INT

	SET @o_error_code = 0
	SET @o_error_desc = ''  
	
	IF @i_taqprojectkey IS NULL OR @i_taqprojectkey <= 0 BEGIN
	  SET @o_error_code = -1
	  RETURN @o_error_code
	END
	  
	SELECT @v_itemtype = searchitemcode, @v_usageclass = usageclasscode, @v_templateind = COALESCE(templateind, 0) 
	FROM coreprojectinfo  
	WHERE projectkey = @i_taqprojectkey
	 
	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
		SET @o_error_desc = 'Invalid projectkey.'
		GOTO RETURN_ERROR
	END    
	  
	SELECT @v_project_qsicode = COALESCE(qsicode, 0)
	FROM subgentables  
	WHERE tableid = 550 AND datacode = @v_itemtype AND datasubcode = @v_usageclass
	 
	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
	  SET @o_error_desc = 'Could not access subgentables 550 to get qsicode.'
	  GOTO RETURN_ERROR
	END    
	  
	IF @v_project_qsicode = 28 BEGIN  -- Works
	  SELECT @v_bookkey = workkey FROM taqproject WHERE taqprojectkey = @i_taqprojectkey
	  
	  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	  IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
	    SET @o_error_desc = 'Could not access taqproject for taqprojectkey: '+ cast(@i_taqprojectkey AS VARCHAR)
	    GOTO RETURN_ERROR
	  END            
	  
	  SET @v_min_printing_key = dbo.qproject_get_minprintingkey(@i_taqprojectkey) 
	  
	  IF @v_min_printing_key IS NULL OR @v_min_printing_key < 0 BEGIN
		RETURN
	  END	
	  
	  SELECT @v_printing_projectkey = taqprojectkey 
	  FROM taqprojectprinting_view
	  WHERE bookkey = @v_bookkey AND printingkey = @v_min_printing_key
	 
	  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	  
	  IF @v_rowcount <= 0 BEGIN
		RETURN
	  END
	  	  
	  IF @v_error <> 0 BEGIN
	    SET @o_error_desc = 'Could not access taqprojectprinting_view for bookkey= '+ cast(@v_bookkey AS VARCHAR) + ' and printingkey= ' + @v_min_printing_key
	    GOTO RETURN_ERROR
	  END 	  	  	  		
	END
	ELSE IF @v_project_qsicode = 40 BEGIN  -- Printing  
	  SET @v_printing_projectkey = @i_taqprojectkey
	END
	ELSE IF @v_project_qsicode = 41 OR @v_project_qsicode = 51 BEGIN -- Purchase Orders
	  SELECT @v_printing_projectkey = printingprojectkey 
	  FROM purchaseorderstitlesview
	  WHERE poprojectkey = @i_taqprojectkey
	 
	  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	  
	  IF @v_rowcount <= 0 BEGIN
		RETURN
	  END
	  
	  IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
	    SET @o_error_desc = 'Could not access purchaseorderstitlesview for poprojectkey= '+ cast(@i_taqprojectkey AS VARCHAR)
	    GOTO RETURN_ERROR
	  END 
	END
	ELSE BEGIN
	  return
	END	
	
	IF COALESCE(@v_printing_projectkey, 0) <= 0 BEGIN
		RETURN
	END

	DECLARE @specsynclist TABLE (rowid int identity (1,1), taqversionspecitemkey int)

	SET @i_NumberRecords=0

	-- determine if there are any specs on the version to sync by checking the qsiconfigspecsync for specitemcategorycode\specitemcodes
	select @i_syncspecs =  count(*) from  qsiconfigspecsync q
	inner join taqversionspeccategory c on q.specitemcategory= c.itemcategorycode and c.taqprojectkey = @v_printing_projectkey and c.taqversionkey=@i_taqversionkey 
	and q.synctospecsind=1 and q.activeind=1 
	---and q.tablename in ('printing','bindingspecs')
	inner join taqversionspecitems s on q.specitemcode = s.itemcode and c.taqversionspecategorykey = s.taqversionspecategorykey
	
	
	-- Determine if there are any related speccategorykeys to sync and add that to the temporary table
	SET @i_syncspecs2 = 0
	      
	SELECT @i_syncspecs2 =  COUNT(distinct v.taqversionspecitemkey)
	  FROM qsiconfigspecsync q, taqversionspecitems_view v
	 WHERE v.taqversionspecategorykey in (SELECT taqversionspecategorykey from taqversionrelatedcomponents_view
			WHERE taqprojectkey in
			   (SELECT relatedprojectkey FROM projectrelationshipview r , taqproject t 
				WHERE r.taqprojectkey = @i_taqprojectkey           
					 AND r.relatedprojectkey = t.taqprojectkey  ))    
		AND q.specitemcategory = v.itemcategorycode
		AND	q.specitemcode = v.itemcode
		AND synctospecsind=1 and activeind=1 

	IF coalesce(@i_syncspecs,0)>0 -- there are specs to sync, now loop through and get the taqversionspecitemkeys to process
	BEGIN
		set nocount on
		INSERT INTO @specsynclist (taqversionspecitemkey)
		select distinct(taqversionspecitemkey) from  qsiconfigspecsync q
		inner join taqversionspeccategory c on q.specitemcategory= c.itemcategorycode and c.taqprojectkey = @v_printing_projectkey and c.taqversionkey=@i_taqversionkey 
		and q.synctospecsind=1 and q.activeind=1 
		---and q.tablename in ('printing','bindingspecs')
		inner join taqversionspecitems s on q.specitemcode = s.itemcode and c.taqversionspecategorykey = s.taqversionspecategorykey
			
		SET @i_NumberRecords = @@ROWCOUNT
		
			--there are specs to sync for related speccategory rows				
		IF coalesce(@i_syncspecs2,0) > 0  BEGIN 
			INSERT INTO @specsynclist (taqversionspecitemkey)
				SELECT distinct (v.taqversionspecitemkey)
				  FROM qsiconfigspecsync q, taqversionspecitems_view v
	             WHERE v.taqversionspecategorykey in (SELECT taqversionspecategorykey from taqversionrelatedcomponents_view
					WHERE taqprojectkey in
						   (SELECT relatedprojectkey FROM projectrelationshipview r , taqproject t 
							WHERE r.taqprojectkey = @i_taqprojectkey           
							 AND r.relatedprojectkey = t.taqprojectkey  ))    
		         AND q.specitemcategory = v.itemcategorycode
		         AND q.specitemcode = v.itemcode
		         AND synctospecsind=1 and activeind=1 
		         AND NOT EXISTS (select distinct taqversionspecitemkey from @specsynclist)
					
			SET @i_NumberRecords = @@ROWCOUNT + @i_NumberRecords
		END 
		
		SET @i_RowCount = 1

		WHILE @i_rowcount <= @i_numberrecords
		BEGIN
		 SELECT @i_taqversionspecitemkey = taqversionspecitemkey
		 FROM @specsynclist
		 WHERE rowid = @i_rowcount
		 
		 
		 exec [dbo].[qpl_sync_specitems2tables] @i_taqversionspecitemkey,null,null,@i_userid
		 
		
		 SET @i_RowCount = @i_RowCount + 1
		END	
		set nocount off
	END

--now update the media\format
	exec [dbo].[qpl_sync_configitems2tables] 'bookdetail',@v_printing_projectkey,@i_taqversionkey,@i_userid
	
--do component level fields like quantity
	exec [dbo].[qpl_sync_speccategory2tables] null, @v_printing_projectkey,@i_taqversionkey, @i_userid  	
	
	RETURN
	
	RETURN_ERROR:  	    
	  SET @o_error_code = -1
	  RETURN 	
END
GO

GRANT EXEC ON qpl_sync_specitems2tables_by_projectkey TO PUBLIC
GO


