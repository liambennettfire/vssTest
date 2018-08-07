IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_bookdates_delete') AND type = 'TR')
	DROP TRIGGER dbo.core_bookdates_delete
GO

CREATE TRIGGER core_bookdates_delete ON bookdates
FOR DELETE AS

DECLARE @v_bookkey 		INT,
	@v_printingkey		INT,
	@v_newdatetypecode	INT, 
	@v_olddatetypecode	INT, 
	@v_bestdate			DATETIME,
	@v_estdate			DATETIME,
	@v_activedate		DATETIME,
	@v_nulldate 		DATETIME,
	@v_finaldateind		TINYINT

DECLARE bookdates_cur CURSOR FOR
SELECT d.bookkey,
	d.printingkey,  
	d.datetypecode,  
	d.estdate,  
	d.activedate,  
	COALESCE(d.activedate, d.estdate)
FROM deleted d

OPEN bookdates_cur

FETCH NEXT FROM bookdates_cur 
INTO @v_bookkey,
	@v_printingkey,  
 	@v_olddatetypecode,  
 	@v_estdate,  
	@v_activedate,  
	@v_bestdate

WHILE (@@FETCH_STATUS= 0)  /*LOOP*/
  BEGIN
	/*** Check Datetypecode so only certain dates are updated ***/
	IF @v_olddatetypecode > 0 
	  BEGIN
		/*** Clear out "old" data ***/
		SET @v_finaldateind = 0
	
		/*** PUB DATE ***/
		IF @v_olddatetypecode = 8 
		  BEGIN
			 UPDATE coretitleinfo
			 SET bestpubdate = null,
			  finalpubdateind = @v_finaldateind
			 WHERE bookkey = @v_bookkey AND 
					 printingkey = @v_printingkey 
		  END
	
		/*** RELEASE DATE ***/
		IF @v_olddatetypecode = 32 
		  BEGIN
			 UPDATE coretitleinfo
			 SET bestreldate = null,
			  finalreldateind = @v_finaldateind
			 WHERE bookkey = @v_bookkey AND 
					 printingkey = @v_printingkey 
		  END
	  END

	FETCH NEXT FROM bookdates_cur 
	INTO @v_bookkey,
		@v_printingkey,  
		@v_olddatetypecode,  
		@v_estdate,  
		@v_activedate,  
		@v_bestdate

  END

CLOSE bookdates_cur 
DEALLOCATE bookdates_cur 

GO


