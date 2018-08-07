IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_productnumber') AND type = 'TR')
	DROP TRIGGER dbo.core_productnumber
GO

/******************************************************************************
**  Name: core_bookauthor_delete
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  02/10/2016   UK		     Case 36206
*******************************************************************************/

CREATE TRIGGER core_productnumber ON productnumber
FOR INSERT, UPDATE AS

IF UPDATE (productnumber)
BEGIN
	DECLARE @v_bookkey INT,
		@v_productnumber VARCHAR(50),
		@v_searchfield	VARCHAR(2000)
	
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

	  /* Get searchfield data*/
      exec [qtitle_get_coretitleinfo_searchfield] @v_bookkey, @v_searchfield OUTPUT

	  UPDATE coretitleinfo
	  SET productnumber = @v_productnumber, productnumberx = REPLACE(@v_productnumber, '-', ''),
		  searchfield = @v_searchfield
	  WHERE bookkey = @v_bookkey
	  
    FETCH NEXT FROM prod_cur 
    INTO @v_bookkey, @v_productnumber	  
  END

  CLOSE prod_cur
  DEALLOCATE prod_cur  
	  
END
GO
