DECLARE @v_datacode INT,
@v_datasubcode INT,
@v_saved_datacode INT,
@v_saved_datasubcode INT,
@v_count INT

BEGIN
	DECLARE bookproductdetail_cursor CURSOR LOCAL FAST_FORWARD FOR
		SELECT datacode, datasubcode 
		  FROM bookproductdetail 
		WHERE datasub2code > 0
		order by datacode,datasubcode,datasub2code

	OPEN bookproductdetail_cursor

	FETCH bookproductdetail_cursor INTO @v_datacode, @v_datasubcode

	SET @v_saved_datacode = 0
	SET @v_saved_datasubcode = 0

	WHILE (@@FETCH_STATUS = 0) BEGIN
	   	IF (@v_datacode <> @v_saved_datacode AND @v_datasubcode <> @v_saved_datasubcode) BEGIN
		    
			print '@v_datacode'
			print @v_datacode
			print '@v_datasubcode'
			print @v_datasubcode

			SELECT @v_count = COUNT(*)
			  FROM sub2gentables
			 WHERE tableid = 655 and datacode = @v_datacode and datasubcode = @v_datasubcode and 
				   datasub2code not in (select distinct(datasub2code) from bookproductdetail where datacode = @v_datacode and datasubcode = @v_datasubcode and datasub2code is not null)
			   AND datadesc not in ('2017','2018','2019','2020','2021','2022','2023','2024','2025','2026','2027','2028')

			print '@v_count'
			print @v_count

			IF @v_count > 0 BEGIN
				DELETE FROM sub2gentables
				 WHERE tableid = 655 and datacode = @v_datacode and datasubcode = @v_datasubcode and 
					   datasub2code not in (select distinct(datasub2code) from bookproductdetail where datacode = @v_datacode and datasubcode = @v_datasubcode and datasub2code is not null)
				   AND datadesc not in ('2017','2018','2019','2020','2021','2022','2023','2024','2025','2026','2027','2028')
			END

			SET @v_saved_datacode = @v_datacode
			SET @v_saved_datasubcode = @v_datasubcode

			FETCH bookproductdetail_cursor INTO @v_datacode, @v_datasubcode
		END
		ELSE BEGIN
			FETCH bookproductdetail_cursor INTO @v_datacode, @v_datasubcode
		END
	END

	CLOSE bookproductdetail_cursor
	DEALLOCATE bookproductdetail_cursor
END	