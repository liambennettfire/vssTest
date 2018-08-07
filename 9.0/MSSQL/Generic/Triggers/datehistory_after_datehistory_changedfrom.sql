create trigger AFTER_DATEHISTORY_CHANGEDFROM
ON DATEHISTORY
FOR INSERT, UPDATE 
AS

DECLARE	@v_bookkey		int
DECLARE	@v_printingkey	int
DECLARE	@v_datekey		int
DECLARE	@v_datetype		int
DECLARE	@v_fromvalue	varchar(255)
DECLARE	@v_lastmaintdate	datetime

DECLARE	@v_test		varchar(100)
DECLARE	@historystatus 	int

select 
	@v_bookkey = ins.bookkey,
	@v_printingkey = ins.printingkey,
	@v_datekey = ins.datekey ,
	@v_datetype = ins.datetypecode,
	@v_fromvalue = ins.datechanged,
	@v_lastmaintdate = ins.lastmaintdate
			from inserted ins


	DECLARE cur_olddatehistory CURSOR
	  FOR
		SELECT datechanged
		FROM datehistory
		WHERE bookkey = @v_bookkey AND
			printingkey = @v_printingkey AND
			datetypecode = @v_datetype
		ORDER BY lastmaintdate DESC 

		FOR READ ONLY

		OPEN cur_olddatehistory
		FETCH NEXT FROM cur_olddatehistory INTO @v_fromvalue 
		
		FETCH NEXT FROM cur_olddatehistory INTO @v_fromvalue 

		select @historystatus  = @@FETCH_STATUS

		IF (@historystatus<>0)
		  begin
			select @v_fromvalue = NULL 	/* no old value found - stringvalue should stand at (Not Present) 
							   change to null to avoid the 1/1/1900 date displaying*/
		  END

		CLOSE cur_olddatehistory 
		deallocate cur_olddatehistory

		UPDATE datehistory
		SET dateprior = @v_fromvalue
		WHERE bookkey = @v_bookkey AND
			printingkey = @v_printingkey AND
			datekey = @v_datekey		

	
