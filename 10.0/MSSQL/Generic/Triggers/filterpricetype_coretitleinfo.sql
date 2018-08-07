IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_filterpricetype') AND type = 'TR')
	DROP TRIGGER dbo.core_filterpricetype
GO

CREATE TRIGGER core_filterpricetype ON filterpricetype
FOR INSERT, UPDATE AS
IF UPDATE (pricetypecode) OR 
	UPDATE (currencytypecode)
BEGIN
	DECLARE @v_bookkey 		INT,
		@v_printingkey		INT,
		@v_pricetype 		INT, 
		@v_currency 		INT, 
		@v_budgetprice    	FLOAT, 
		@v_finalprice 		FLOAT, 
		@v_filterkey      	SMALLINT,
		@v_finalpriceind		SMALLINT

	
	SELECT @v_filterkey=i.filterkey,
	       @v_pricetype=i.pricetypecode,  
	       @v_currency=i.currencytypecode
	FROM inserted i

	/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
	/*** Don't need to do this - ALL rows on coretitleinfo need to be modified with new price info ***/
	/*EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1*/

	IF @v_filterkey = 5     /*** filterkey = 5 is tmm header price ***/
	  BEGIN
		/*** Need to update ALL titles currently on coretitleinfo ***/
		DECLARE coretitle_cur CURSOR FOR
		SELECT DISTINCT bookkey
		FROM coretitleinfo

	    OPEN coretitle_cur
	    FETCH NEXT FROM coretitle_cur INTO @v_bookkey 

		WHILE (@@FETCH_STATUS= 0)  /*LOOP*/
        	BEGIN
		      	/*** Fill in the price ***/
	    		SELECT @v_budgetprice=b.budgetprice, 
					 @v_finalprice=b.finalprice
		    	FROM bookprice b
		    	WHERE bookkey = @v_bookkey AND
					pricetypecode = @v_pricetype AND
				  	currencytypecode = @v_currency 

				/* If final price is missing, use budget price */
				IF @v_finalprice IS NULL OR @v_finalprice = 0 
				  BEGIN
					SET @v_finalprice = @v_budgetprice 
		 			SET @v_finalpriceind = 0
				  END
				ELSE
				  BEGIN
					SET @v_finalpriceind = 1
      			  END

				UPDATE coretitleinfo
	            SET tmmprice = @v_finalprice,
				    finalpriceind = @v_finalpriceind
	            WHERE bookkey = @v_bookkey

	      		FETCH NEXT FROM coretitle_cur INTO @v_bookkey 
			END

      	CLOSE coretitle_cur 
      	DEALLOCATE coretitle_cur 
  	END
END
GO


