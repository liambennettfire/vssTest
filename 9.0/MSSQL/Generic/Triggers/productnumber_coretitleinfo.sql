IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_productnumber') AND type = 'TR')
	DROP TRIGGER dbo.core_productnumber
GO

CREATE TRIGGER core_productnumber ON productnumber
FOR INSERT, UPDATE AS

IF UPDATE (productnumber)
BEGIN
	DECLARE @v_bookkey INT,
		@v_productnumber VARCHAR(50)
	
  DECLARE prod_cur CURSOR FOR
	  SELECT i.bookkey, i.productnumber
	  FROM inserted i

  OPEN prod_cur

  FETCH NEXT FROM prod_cur 
  INTO @v_bookkey, @v_productnumber

  WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
  BEGIN

	  /*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
	  EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1

	  UPDATE coretitleinfo
	  SET productnumber = @v_productnumber, productnumberx = REPLACE(@v_productnumber, '-', '') 
	  WHERE bookkey = @v_bookkey
	  
    FETCH NEXT FROM prod_cur 
    INTO @v_bookkey, @v_productnumber	  
  END

  CLOSE prod_cur
  DEALLOCATE prod_cur  
	  
END
GO
