IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TR' AND name = 'bookprice_coretitleinfo')
	BEGIN
		DROP  Trigger bookprice_coretitleinfo
	END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TR' AND name = 'core_bookprice')
	BEGIN
		DROP  Trigger core_bookprice
	END
GO

/** 9/16/03 - KW - Rewritten. Old trigger did't work properly when pricetype or currency changed. **/
/** Also, I'm renaming this trigger from bookprice_coretitleinfo to core_bookprice for consistency. **/

/******************************************************************************
**  File: bookprice_coretitleinfo.sql
**  Name: bookprice_coretitleinfo
**  Desc: This trigger updates the core tables with the
**         updated price when a price changes.
**
**  Auth: James P. Weber
**  Date: 04 Aug 2003
*******************************************************************************/

CREATE TRIGGER core_bookprice ON bookprice
FOR INSERT, UPDATE AS
IF UPDATE (finalprice) OR 
   UPDATE (budgetprice) OR 
   UPDATE (pricetypecode) OR 
   UPDATE (currencytypecode) OR
   UPDATE (activeind)

BEGIN
	DECLARE @v_bookkey	INT,
	  @v_new_activeind  TINYINT,
	  @v_old_activeind  TINYINT,
	  @v_new_finalprice	FLOAT,
	  @v_old_finalprice	FLOAT,
	  @v_new_budgetprice	FLOAT,
	  @v_old_budgetprice	FLOAT,
	  @v_new_pricetype	SMALLINT,
	  @v_old_pricetype	SMALLINT,
	  @v_new_currency		SMALLINT,
	  @v_old_currency		SMALLINT,
	  @v_system_pricetype	SMALLINT,
	  @v_system_currency	SMALLINT,
	  @v_system_currency_cdn  SMALLINT,
	  @v_set_pricetype	SMALLINT,
	  @v_set_currency		SMALLINT,
	  @v_count	SMALLINT,
	  @v_count2 SMALLINT

	/*** Get the TMM Header Price currency and price type ***/
	SELECT @v_system_pricetype = pricetypecode, @v_system_currency = currencytypecode FROM filterpricetype WHERE filterkey = 5 
	
	/* Get the TMM Canadian Price currency type */
	SELECT @v_system_currency_cdn = datacode FROM gentables WHERE gentables.tableid = 122 AND gentables.qsicode = 1

	/*** Get the Set Price currency and price type ***/
	SELECT @v_count = COUNT(*) FROM filterpricetype WHERE filterkey = 6
	
	IF @v_count > 0 BEGIN
	    SELECT @v_set_pricetype = pricetypecode, @v_set_currency = currencytypecode FROM filterpricetype WHERE filterkey = 6
	END 
	ELSE BEGIN
	    SET @v_set_pricetype = @v_system_pricetype
	    SET @v_set_currency = @v_system_currency
	END

	/** Get old and new values for comparison **/
	/** Must SORT by active indicator so that ACTIVE prices get processed LAST, **/
	/** and so that coretitle tmmprice and canadianprice have the proper ACTIVE value **/
	DECLARE bookprice_cur CURSOR FOR
	SELECT i.bookkey,
	  i.activeind,
	  deleted.activeind,
	  i.finalprice, 
	  deleted.finalprice,
	  i.budgetprice, 
	  deleted.budgetprice,
	  i.pricetypecode,
	  deleted.pricetypecode,
	  i.currencytypecode,
	  deleted.currencytypecode
	FROM inserted i 
	left outer join deleted on i.bookkey = deleted.bookkey
	ORDER BY i.activeind ASC

	OPEN bookprice_cur

	FETCH NEXT FROM bookprice_cur 
	INTO @v_bookkey,
	  @v_new_activeind,
	  @v_old_activeind,
	  @v_new_finalprice, 
	  @v_old_finalprice,
	  @v_new_budgetprice, 
	  @v_old_budgetprice,
	  @v_new_pricetype,
	  @v_old_pricetype,
	  @v_new_currency,
	  @v_old_currency

	WHILE (@@FETCH_STATUS=0)  /*LOOP*/
	  BEGIN
	  
	  IF @v_new_activeind IS NULL
	    SET @v_new_activeind = 0
	  IF @v_old_activeind IS NULL
	    SET @v_old_activeind = 0

		/** When new row's pricetype and currency matches TMM Price, update coretitle tmmprice **/
		IF (@v_new_pricetype = @v_system_pricetype) AND 
		    (@v_new_currency = @v_system_currency) AND 
		    (@v_new_activeind = 1) BEGIN
		    		  
			/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
			EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1	

			IF @v_new_finalprice IS NOT NULL
			  UPDATE coretitleinfo
			  SET tmmprice = @v_new_finalprice, finalpriceind = 1 
			  WHERE bookkey = @v_bookkey
			ELSE
			  UPDATE coretitleinfo 
			  SET tmmprice = @v_new_budgetprice, finalpriceind = 0
			  WHERE bookkey = @v_bookkey
		END
		
		/** When new row's pricetype and currency matches TMM Canadian Price, update coretitle canadianprice **/
		IF (@v_new_pricetype = @v_system_pricetype) AND 
		    (@v_new_currency = @v_system_currency_cdn) AND 
		    (@v_new_activeind = 1) BEGIN
		    		  
			/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
			EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1	

			IF @v_new_finalprice IS NOT NULL
			  UPDATE coretitleinfo
			  SET canadianprice = @v_new_finalprice
			  WHERE bookkey = @v_bookkey
			ELSE
			  UPDATE coretitleinfo 
			  SET canadianprice = @v_new_budgetprice
			  WHERE bookkey = @v_bookkey
		END		
	
		/** When new row's pricetype and currency matches the Set Price, update coretitle setprice **/
		IF (@v_new_pricetype = @v_set_pricetype) AND 
		    (@v_new_currency = @v_set_currency) AND 
		    (@v_new_activeind = 1) BEGIN
		    		  
			/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
			EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1	

			IF @v_new_finalprice IS NOT NULL
			  UPDATE coretitleinfo
			  SET setprice = @v_new_finalprice 
			  WHERE bookkey = @v_bookkey
			ELSE
			  UPDATE coretitleinfo 
			  SET setprice = @v_new_budgetprice
			  WHERE bookkey = @v_bookkey
		END

		/** CLEAR tmmprice on coretitleinfo table when necessary - when the modified price **/
		/** was changed from TMM Price to some other price **/
		IF @v_old_currency = @v_system_currency AND @v_old_pricetype = @v_system_pricetype
		BEGIN  /* was TMM Price before the change */

		  /* If the original (OLD) TMM price row becomes some other price (non-TMM Price): */
		  /* because the PriceType changed, or Currency changed, or price became inactive */
		  IF (@v_old_pricetype <> @v_new_pricetype AND @v_old_pricetype = @v_system_pricetype) OR 
		       (@v_old_currency <> @v_new_currency AND @v_old_currency = @v_system_currency) OR
		       (@v_old_activeind = 1 AND @v_new_activeind = 0) BEGIN
		       
		    SET @v_count2 = 0
		      
		    IF (@v_old_activeind = 1 AND @v_new_activeind = 0) AND
		       (@v_old_pricetype = @v_new_pricetype AND @v_old_pricetype = @v_system_pricetype) AND 
		       (@v_old_currency = @v_new_currency AND @v_old_currency = @v_system_currency) BEGIN
		        
				SELECT @v_count2 = COUNT(*) FROM bookprice WHERE bookkey = @v_bookkey AND 
					pricetypecode = @v_system_pricetype AND currencytypecode = @v_system_currency
					AND activeind = 1
			END
			
			IF (@v_old_currency = @v_new_currency AND @v_old_currency = @v_system_currency) AND (@v_count2 = 0) AND
			   (@v_old_activeind = 1 AND @v_new_activeind = 1) AND
			   (@v_old_pricetype <> @v_new_pricetype AND @v_old_pricetype = @v_system_pricetype) BEGIN
			   
				SELECT @v_count2 = COUNT(*) FROM bookprice WHERE bookkey = @v_bookkey AND currencytypecode = @v_system_currency
					AND pricetypecode = @v_system_pricetype AND activeind = 1
			END 
			
			IF @v_count2 = 0 BEGIN
			
				/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
				EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1
	  	
				UPDATE coretitleinfo
				SET tmmprice = NULL, finalpriceind = NULL
				WHERE bookkey = @v_bookkey
			END
		  END
		END
		
		/** CLEAR canadianprice on coretitleinfo table when necessary - when the modified price **/
		/** was changed from TMM Canadian Price to some other price **/
		IF (@v_old_currency = @v_system_currency_cdn AND @v_old_pricetype = @v_system_pricetype) 
		BEGIN  /* was TMM Canadian Price before the change */

		  /* If the original (OLD) TMM Canadian price row becomes some other price (non-TMM CAN Price): */
		  /* because the PriceType changed, or Currency changed, or price became inactive */
		  IF (@v_old_pricetype <> @v_new_pricetype AND @v_old_pricetype = @v_system_pricetype) OR 
		       (@v_old_currency <> @v_new_currency AND @v_old_currency = @v_system_currency_cdn) OR
		       (@v_old_activeind = 1 AND @v_new_activeind = 0) BEGIN
		       
		    SET @v_count2 = 0
		      
		    IF (@v_old_activeind = 1 AND @v_new_activeind = 0) AND
		       (@v_old_pricetype = @v_new_pricetype AND @v_old_pricetype = @v_system_pricetype) AND 
		       (@v_old_currency = @v_new_currency AND @v_old_currency = @v_system_currency_cdn) BEGIN
		       
				SELECT @v_count2 = COUNT(*) FROM bookprice WHERE bookkey = @v_bookkey AND 
					pricetypecode = @v_system_pricetype AND currencytypecode = @v_system_currency_cdn
					AND activeind = 1
			END 
			
			IF (@v_old_currency = @v_new_currency AND @v_old_currency = @v_system_currency_cdn) AND (@v_count2 = 0) AND
			   (@v_old_activeind = 1 AND @v_new_activeind = 1) AND
			   (@v_old_pricetype <> @v_new_pricetype AND @v_old_pricetype = @v_system_pricetype) BEGIN
			   
				SELECT @v_count2 = COUNT(*) FROM bookprice WHERE bookkey = @v_bookkey AND currencytypecode = @v_system_currency_cdn
					AND pricetypecode = @v_system_pricetype AND activeind = 1
			END 
					
			IF @v_count2 = 0 BEGIN
			
				/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
				EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1
	  	
				UPDATE coretitleinfo
				SET canadianprice = NULL
				WHERE bookkey = @v_bookkey
			END
		  END
		END

		/** CLEAR setprice on coretitleinfo table when necessary - when the modified price **/
		/** was changed from Set Price to some other price **/
		IF (@v_old_currency = @v_set_currency AND @v_old_pricetype = @v_set_pricetype) 
		BEGIN  /* was Set Price before the change */

		  /* If the original (OLD) Set price row becomes some other price (non-Set Price): */
		  /* because the PriceType changed, or Currency changed, or price became inactive */
		  IF (@v_old_pricetype <> @v_new_pricetype AND @v_old_pricetype = @v_set_pricetype) OR 
		       (@v_old_currency <> @v_new_currency AND @v_old_currency = @v_set_currency) OR
		       (@v_old_activeind = 1 AND @v_new_activeind = 0) BEGIN
		       
		    SET @v_count2 = 0
		      
		   IF (@v_old_activeind = 1 AND @v_new_activeind = 0) AND
		       (@v_old_pricetype = @v_new_pricetype AND @v_old_pricetype = @v_set_pricetype) AND 
		       (@v_old_currency = @v_new_currency AND @v_old_currency = @v_set_currency) BEGIN  
		       
				SELECT @v_count2 = COUNT(*) FROM bookprice WHERE bookkey = @v_bookkey AND 
					pricetypecode = @v_set_pricetype AND currencytypecode = @v_set_currency
					AND activeind = 1
			END 
			
			IF (@v_old_currency = @v_new_currency AND @v_old_currency = @v_set_currency) AND (@v_count2 = 0) AND
			   (@v_old_activeind = 1 AND @v_new_activeind = 1) AND
			   (@v_old_pricetype <> @v_new_pricetype AND @v_old_pricetype = @v_system_pricetype) BEGIN
			   
				SELECT @v_count2 = COUNT(*) FROM bookprice WHERE bookkey = @v_bookkey AND currencytypecode = @v_set_currency
					AND pricetypecode = @v_set_pricetype AND activeind = 1
			END 
					
			IF @v_count2 = 0 BEGIN
			
				/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
				EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1
	  	
				UPDATE coretitleinfo
				SET setprice = NULL
				WHERE bookkey = @v_bookkey
			END
		  END
		END


		FETCH NEXT FROM bookprice_cur 
		INTO @v_bookkey,
		  @v_new_activeind,
		  @v_old_activeind,
		  @v_new_finalprice, 
		  @v_old_finalprice,
		  @v_new_budgetprice, 
		  @v_old_budgetprice,
		  @v_new_pricetype,
		  @v_old_pricetype,
		  @v_new_currency,
		  @v_old_currency

	  END

	CLOSE bookprice_cur
	DEALLOCATE bookprice_cur
END
GO
