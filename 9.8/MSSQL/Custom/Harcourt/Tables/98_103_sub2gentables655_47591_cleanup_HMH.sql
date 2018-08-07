set nocount on
go

DECLARE @v_datacode INT,
@v_datasubcode INT,
@v_datasub2code INT,
@v_count INT

BEGIN
	DECLARE sub2gentables_cursor CURSOR LOCAL FAST_FORWARD FOR
		SELECT datacode, datasubcode, datasub2code 
		  FROM sub2gentables 
		WHERE tableid = 655
		  AND datadesc not in ('2017','2018','2019','2020','2021','2022','2023','2024','2025','2026','2027','2028')
		order by datacode,datasubcode,datasub2code

	OPEN sub2gentables_cursor

	FETCH sub2gentables_cursor INTO @v_datacode, @v_datasubcode, @v_datasub2code

	
	WHILE (@@FETCH_STATUS = 0) BEGIN
	  
		    
			print '@v_datacode'
			print @v_datacode
			print '@v_datasubcode'
			print @v_datasubcode
			print '@v_datasub2code'
			print @v_datasub2code

			SELECT @v_count = COUNT(*)
			  FROM bookproductdetail
			 WHERE tableid = 655 and datacode = @v_datacode and datasubcode = @v_datasubcode and datasub2code = @v_datasub2code 
				   

			print '@v_count'
			print @v_count

			IF @v_count = 0 BEGIN
				DELETE FROM sub2gentables
				 WHERE tableid = 655 and datacode = @v_datacode and datasubcode = @v_datasubcode and datasub2code = @v_datasub2code
					  
			END

			
			FETCH sub2gentables_cursor INTO @v_datacode, @v_datasubcode, @v_datasub2code
		
	END

	CLOSE sub2gentables_cursor
	DEALLOCATE sub2gentables_cursor
END	
go

set nocount off
go