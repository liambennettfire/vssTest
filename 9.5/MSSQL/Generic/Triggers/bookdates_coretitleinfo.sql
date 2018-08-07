IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_bookdates') AND type = 'TR')
	DROP TRIGGER dbo.core_bookdates
GO

CREATE TRIGGER [dbo].[core_bookdates] ON [dbo].[bookdates]
FOR INSERT, UPDATE AS
IF UPDATE (datetypecode) OR 
	UPDATE (estdate) OR 
	UPDATE (activedate)

BEGIN
	DECLARE @v_bookkey 		INT,
		@v_printingkey		INT,
		@v_newdatetypecode	INT, 
		@v_olddatetypecode	INT, 
		@v_bestdate			DATETIME,
		@v_estdate			DATETIME,
		@v_activedate		DATETIME,
		@v_nulldate 		DATETIME,
		@v_finaldateind		TINYINT,
		@v_cnt				int


SELECT @v_cnt = count(*)
FROM inserted i 
right outer join deleted on i.bookkey = deleted.bookkey
where i.printingkey = deleted.printingkey

if @v_cnt > 0 begin
		DECLARE bookdates_cur_1 CURSOR FOR
		SELECT i.bookkey,
			   i.printingkey,  
			   i.datetypecode,  
			   deleted.datetypecode,  
			   i.estdate,  
			   i.activedate,  
			   COALESCE(i.activedate,i.estdate)
		FROM inserted i 
		right outer join deleted on i.bookkey = deleted.bookkey
		where i.printingkey = deleted.printingkey
end else begin
		DECLARE bookdates_cur_2 CURSOR FOR
		SELECT i.bookkey,
			   i.printingkey,  
			   i.datetypecode,  
			   null,  
			   i.estdate,  
			   i.activedate,  
			   COALESCE(i.activedate,i.estdate)
		FROM inserted i
end

if @v_cnt > 0 begin
	OPEN bookdates_cur_1
	FETCH NEXT FROM bookdates_cur_1 
	INTO @v_bookkey, @v_printingkey, @v_newdatetypecode, @v_olddatetypecode, @v_estdate, @v_activedate, @v_bestdate
end else begin
	OPEN bookdates_cur_2
	FETCH NEXT FROM bookdates_cur_2
	INTO @v_bookkey, @v_printingkey, @v_newdatetypecode, @v_olddatetypecode, @v_estdate, @v_activedate, @v_bestdate
end


	WHILE (@@FETCH_STATUS= 0)  /*LOOP*/
	  BEGIN

update temp_blob 
set htmldata = cast(@v_bookkey as varchar(20))
where keyid = 0

		/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
		EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, @v_printingkey, 0

		/*** Check Datetypecode so only certain dates are updated ***/
		/*** Update "new" data ***/
		/*** Set finaldateind ***/
		IF @v_bestdate = @v_activedate
		   SET @v_finaldateind = 1
		ELSE
		   SET @v_finaldateind = 0

		/*** PUB DATE ***/
		IF @v_newdatetypecode = 8 
		  BEGIN
		    UPDATE coretitleinfo
		    SET bestpubdate = @v_bestdate,
			  finalpubdateind = @v_finaldateind
		    WHERE bookkey = @v_bookkey AND 
		          printingkey = @v_printingkey 
		  END

		/*** RELEASE DATE ***/
		IF @v_newdatetypecode = 32 
		  BEGIN
		    UPDATE coretitleinfo
		    SET bestreldate = @v_bestdate,
			  finalreldateind = @v_finaldateind
		    WHERE bookkey = @v_bookkey AND 
		          printingkey = @v_printingkey 
		  END

		IF @v_olddatetypecode > 0 AND @v_olddatetypecode <> @v_newdatetypecode 
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

		/*** get next row ***/
		if @v_cnt > 0 begin
			FETCH NEXT FROM bookdates_cur_1 
			INTO @v_bookkey, @v_printingkey, @v_newdatetypecode, @v_olddatetypecode, @v_estdate, @v_activedate, @v_bestdate
		end else begin
			FETCH NEXT FROM bookdates_cur_2
			INTO @v_bookkey, @v_printingkey, @v_newdatetypecode, @v_olddatetypecode, @v_estdate, @v_activedate, @v_bestdate
		end
	  END

   if @v_cnt > 0 begin
	CLOSE bookdates_cur_1 
	DEALLOCATE bookdates_cur_1
   end  else begin
	CLOSE bookdates_cur_2 
	DEALLOCATE bookdates_cur_2
   end

END
GO

