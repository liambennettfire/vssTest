BEGIN
  DECLARE
    @v_count1	INT,
    @v_count2	INT

	CREATE TABLE dbo.bookbisaccategory_bkup_bisac2009(
		bookkey int NOT NULL ,
		printingkey int NOT NULL,
		bisaccategorycode int NOT NULL,
		bisaccategorysubcode int NOT NULL,
		sortorder int NULL,
		lastuserid varchar(30) NULL,
		lastmaintdate datetime NULL)
	
	
	INSERT INTO bookbisaccategory_bkup_bisac2009
		 (bookkey,printingkey, bisaccategorycode, bisaccategorysubcode, sortorder, lastuserid, lastmaintdate)
		 SELECT bookkey,printingkey, bisaccategorycode, bisaccategorysubcode, sortorder, lastuserid, lastmaintdate
		  FROM bookbisaccategory

	 SELECT @v_count1 = COUNT(*)
	  FROM bookbisaccategory
	
	  SELECT @v_count2 = COUNT(*)
	  FROM bookbisaccategory_bkup_bisac2009
	
	  /** Make sure insert into the temp table succeeded **/
	  IF @v_count1 <> @v_count2
		 BEGIN
			SELECT 'ERROR !!! Data did not get copied properly to temp table !!!!'
		 END
	  ELSE
		 BEGIN
			SELECT 'Script completed successfully'
		 END

END /* MAIN */
GO


CREATE unique index bookbisaccategory_bkup_bisac2009_qp ON bookbisaccategory_bkup_bisac2009 (bookkey,printingkey,bisaccategorycode,bisaccategorysubcode)
go
GRANT select,update,delete,insert on dbo.bookbisaccategory_bkup_bisac2009 to PUBLIC 
go