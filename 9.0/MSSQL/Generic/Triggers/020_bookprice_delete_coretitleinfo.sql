IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TR' AND name = 'bookprice_delete_coretitleinfo')
	BEGIN
		DROP  Trigger bookprice_delete_coretitleinfo
	END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TR' AND name = 'core_bookprice_delete')
	BEGIN
		DROP  Trigger core_bookprice_delete
	END
GO

/** 9/16/03 - KW - Renaming this trigger from bookprice_delete_coretitleinfo to core_bookprice_delete for consistency. **/

/******************************************************************************
**  File: bookprice_delete_coretitleinfo.sql
**  Name: bookprice_delete_coretitleinfo
**  Desc: This trigger updates the core table 
**        when a price is deleted.
**
**  Auth: James P. Weber
**  Date: 06 Aug 2003
*******************************************************************************/

CREATE TRIGGER core_bookprice_delete ON bookprice
FOR DELETE AS

BEGIN

  DECLARE @v_bookkey    int,
    @v_pricetypecode    smallint,
    @v_currencytypecode smallint,
    @v_system_pricetypecode smallint,
    @v_system_currencytypecode smallint,
    @v_system_currencytypecode_cdn  smallint,
    @v_set_pricetype	SMALLINT,
    @v_set_currency	SMALLINT,
    @v_count  SMALLINT,
    @err_msg  varchar(200)

  /*** Get the TMM Price currency and price type ***/
  SELECT @v_system_pricetypecode = pricetypecode, 
	@v_system_currencytypecode = currencytypecode
  FROM filterpricetype
  WHERE filterkey = 5
  
  /* Get the TMM Canadian Price currency type */
  SELECT @v_system_currencytypecode_cdn = datacode
  FROM gentables
  WHERE gentables.tableid = 122 AND 
      gentables.qsicode = 1   /* Canadian Dollars */  

  /*** Get the Set Price currency and price type ***/
  SELECT @v_count = COUNT(*)
  FROM filterpricetype
  WHERE filterkey = 6
	
  IF @v_count > 0
    BEGIN
      SELECT @v_set_pricetype = pricetypecode, 
        @v_set_currency = currencytypecode
      FROM filterpricetype
      WHERE filterkey = 6
    END
  ELSE
    BEGIN
      SET @v_set_pricetype = @v_system_pricetypecode
      SET @v_set_currency = @v_system_currencytypecode
    END

  /* We only care when the ACTIVE price gets deleted */
  DECLARE bookprice_cur CURSOR FOR
  SELECT d.bookkey,
         d.pricetypecode,
         d.currencytypecode
  FROM deleted d
  WHERE d.activeind = 1

  OPEN bookprice_cur

  FETCH NEXT FROM bookprice_cur 
  INTO @v_bookkey, @v_pricetypecode, @v_currencytypecode

  WHILE (@@FETCH_STATUS= 0)  /*LOOP*/
	BEGIN

	  /*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
	  EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1
	  IF @@error != 0
		BEGIN
		  ROLLBACK TRANSACTION
		  select @err_msg = 'Book key for in the Core title table was not found.'
		  print @err_msg
		END	
	
	  /** When the active price being deleted is the TMM Price, **/
	  /** clear tmmprice on coretitleinfo table **/
	  IF @v_pricetypecode = @v_system_pricetypecode AND 
	      @v_currencytypecode = @v_system_currencytypecode BEGIN
	
		  UPDATE coretitleinfo 
		  SET tmmprice = NULL, finalpriceind = NULL 
		  WHERE bookkey = @v_bookkey
	
		  IF @@error != 0
			BEGIN
			  ROLLBACK TRANSACTION
			  select @err_msg = 'Could not update the coretitle tmmprice as expected. (On price delete.)'
			  print @err_msg
			END
		END
		
	  /** When the active price being deleted is the TMM Canadian Price, **/
	  /** clear canadianprice on coretitleinfo table **/
	  IF @v_pricetypecode = @v_system_pricetypecode AND 
	      @v_currencytypecode = @v_system_currencytypecode_cdn BEGIN
	
		  UPDATE coretitleinfo 
		  SET canadianprice = NULL
		  WHERE bookkey = @v_bookkey
	
		  IF @@error != 0
			BEGIN
			  ROLLBACK TRANSACTION
			  select @err_msg = 'Could not update the coretitle canadianprice as expected. (On price delete.)'
			  print @err_msg
			END
		END

	  /** When the active price being deleted is the Set Price, **/
	  /** clear setprice on coretitleinfo table **/
	  IF @v_pricetypecode = @v_set_pricetype AND 
	      @v_currencytypecode = @v_set_currency BEGIN
	
		  UPDATE coretitleinfo 
		  SET setprice = NULL
		  WHERE bookkey = @v_bookkey
	
		  IF @@error != 0
			BEGIN
			  ROLLBACK TRANSACTION
			  select @err_msg = 'Could not update the coretitle setprice as expected. (On price delete.)'
			  print @err_msg
			END
		END

	  FETCH NEXT FROM bookprice_cur 
	  INTO @v_bookkey, @v_pricetypecode, @v_currencytypecode

	END

CLOSE bookprice_cur
DEALLOCATE bookprice_cur

END
GO
