/* Drop the PROCEDURE if it exists */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.Specs_Copy_write_binding') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.Specs_Copy_write_binding
END
GO

CREATE PROCEDURE Specs_Copy_write_binding	(
  @i_from_bookkey     INT,
  @i_from_printingkey INT,
  @i_to_bookkey       INT,
  @i_to_printingkey   INT,
  @i_specind          INT,
  @i_copytype         VARCHAR(5),
  @i_userid           VARCHAR(30),
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT
)
AS

/*************************************************************************************************************************
**  File: 
**  Name: specs_copy_write_binding
**  Desc: 
**
**              
**    Return values: 
**
**    Called by:  copy_specifications
**              
**    Parameters:
**    Input              
**    ----------         
**    from_bookkey - Bookkey of title being copied from - Required
**    from_printingkey - Printingkey of title being copied from - Required
**    to_bookkey - Bookkey of title being copied to - Required
**    to_printingkey - Printingkey of title being copied from - Required (First Printing will be assumed if 0) - Required
**    specind - specind of title being copied to - from book table -Required
**    copytype - values are 'ALL' or 'NO' - bindingspec row can exist without a bind component - 
**        'ALL' specifies a bind component exists on title and that bindcolor, bind notes ,case , sidestamp, spinestamp rows 
**              need to be copied as well as binding spec row
**        'NO' specifes that no bind component exists on title and therefore only bindingspec row needs to be copied
**    userid - Userid of user causing write to history - Required
**    
**    Output
**    -----------
**    error_code - error code
**    error_desc - error message - empty if No Error
**
**    Auth: Kusum Basra
**    Date: 6/27/08
******************************************************************************************************************************
**    Change History
******************************************************************************************************************************
**    Date:     Author:         Description:
**    --------  --------        --------------------------------------------------------------------------------------------
**    
****************************************************************************************************************************/

DECLARE
	@v_vendorkey INT,
	@v_bindingdie	varchar(20),
	@v_reinforcements  SMALLINT,
	@v_backingcode	INT,
	@v_bindsignatures	VARCHAR(30),
	@v_bindingmethod	SMALLINT,
	@v_insert8page	SMALLINT,
	@v_insert8pgtext	VARCHAR(40),
	@v_insert16page	SMALLINT,
	@v_insert16pgtext	VARCHAR(40),
	@v_insert24page	SMALLINT,
	@v_insert24pgtext VARCHAR(30),
	@v_insert32page	SMALLINT,
	@v_insert32pgtext VARCHAR(40),
	@v_endpapertype	VARCHAR(1),
	@v_endpapermatl SMALLINT,
	@v_endpapercolor	VARCHAR(15),
	@v_insert2page	SMALLINT,
	@v_insert4page	SMALLINT,
	@v_insert2pgtext	VARCHAR(40),
	@v_insert4pgtext	VARCHAR(40),
	@v_topstainind	VARCHAR(1),
	@v_topstaincolor	VARCHAR(100),
	@v_covertype	SMALLINT,
	@v_booktrim		SMALLINT,
	@v_oblongind	VARCHAR(1),	
	@v_gatefoldind	VARCHAR(1),
	@v_gatefoldcomments	VARCHAR(40),
	@v_diecutind	VARCHAR(1),
	@v_diecutcomments	VARCHAR(50),
	@v_cartonqty1  SMALLINT,
	@v_prepackind	VARCHAR(1),
	@v_cartontype	SMALLINT,
   @v_count 		INT,
	@v_tocartonqty1 SMALLINT,
	@v_ConvBindingMethod SMALLINT,
	@v_ConvVendorkey INT,
	@v_convendpapmtl SMALLINT,
   @v_convcovertype SMALLINT,
	@v_convbooktrim SMALLINT,
	@v_toprepackind VARCHAR(1),
	@v_toendpapertype VARCHAR(1),
	@v_toendpapercolor VARCHAR(15),
   @v_vendorname VARCHAR(75),
   @v_colorkey  INT,
   @v_colordesc VARCHAR(100),
   @v_foilamount FLOAT,
   @v_casetypethickness SMALLINT,
   @v_boardthickness SMALLINT,
   @v_notekey 	INT,
   @v_hitfoil	INT,
   @v_sidecolor VARCHAR(50),
   @v_sidestampcolor VARCHAR(50),
   @v_sidematerial INT,
   @v_sidestamptype INT,
   @v_spinematerial INT,
	@v_spinecolor VARCHAR(50),  
   @v_spinestamptype INT,   
   @v_spinestampcolor VARCHAR(50),  
	@v_spineinchestoshow FLOAT


 
	DECLARE bindcolor_cursor CURSOR FOR
	 SELECT colorkey,colordesc FROM bindcolor
	  WHERE (bookkey=@i_from_bookkey) AND
			  (printingkey=@i_from_printingkey) 
		
	

BEGIN
	SELECT @v_count = count(*)
     FROM bindingspecs
    WHERE bookkey = @i_from_bookkey AND
          printingkey = @i_from_printingkey


	IF @v_count > 0 
   BEGIN
		SELECT @v_vendorkey = vendorkey,@v_bindingdie = bindingdie,@v_reinforcements = reinforcements,@v_backingcode = backingcode,
			 @v_bindsignatures =bindsignatures,@v_bindingmethod = bindingmethod,@v_insert8page = insert8page,@v_insert8pgtext = insert8pgtext,
          @v_insert16page = insert16page,@v_insert16pgtext = insert16pgtext,@v_insert24page = insert24page,@v_insert24pgtext = insert24pgtext,
			 @v_insert32page =insert32page,@v_insert32pgtext = insert32pgtext,@v_endpapertype = endpapertype,@v_endpapermatl = endpapermatl,
			 @v_endpapercolor = endpapercolor,@v_insert2page = insert2page,@v_insert4page = insert4page,@v_insert2pgtext = insert2pgtext,
			 @v_insert4pgtext = insert4pgtext,@v_topstainind = topstainind,@v_topstaincolor = topstaincolor,@v_covertype = covertype,
			 @v_booktrim = booktrim,@v_oblongind = oblongind, @v_gatefoldind = gatefoldind,@v_gatefoldcomments = gatefoldcomments,
			 @v_diecutind = diecutind,@v_diecutcomments = diecutcomments,@v_cartonqty1 = cartonqty1,@v_prepackind = prepackind,
			 @v_cartontype =cartontype
		 FROM bindingspecs
		WHERE bookkey = @i_from_bookkey AND
            printingkey = @i_from_printingkey
 	END
	ELSE
   BEGIN
		SET @v_vendorkey = NULL 
		SET @v_bindingdie	= NULL
		SET @v_reinforcements  = NULL
		SET @v_backingcode	= NULL
		SET @v_bindsignatures	= NULL
		SET @v_bindingmethod	= NULL
		SET @v_insert8page	= NULL
		SET @v_insert8pgtext	= NULL
		SET @v_insert16page = NULL
		SET @v_insert16pgtext	= NULL
		SET @v_insert24page	= NULL
		SET @v_insert24pgtext = NULL
		SET @v_insert32page	= NULL
		SET @v_insert32pgtext = NULL
		SET @v_endpapertype	= NULL
		SET @v_endpapermatl = NULL
		SET @v_endpapercolor	= NULL
		SET @v_insert2page	= NULL
		SET @v_insert4page	= NULL
		SET @v_insert2pgtext	= NULL
		SET @v_insert4pgtext	= NULL
		SET @v_topstainind	= NULL
		SET @v_topstaincolor	= NULL
		SET @v_covertype	= NULL
		SET @v_booktrim		= NULL
		SET @v_oblongind	= NULL
		SET @v_gatefoldind	= NULL
		SET @v_gatefoldcomments	= NULL
		SET @v_diecutind	= NULL
		SET @v_diecutcomments	= NULL
		SET @v_cartonqty1  = NULL
		SET @v_prepackind	= NULL
		SET @v_cartontype	= NULL
		SET @v_count = NULL
	END

	IF @i_specind = 1
   BEGIN
		INSERT INTO bindingspecs
			(bookkey,printingkey,vendorkey,bindingdie,reinforcements,backingcode,bindsignatures,bindingmethod,
          insert8page,insert8pgtext,insert16page,insert16pgtext,insert24page,insert24pgtext,insert32page,insert32pgtext,
          endpapertype,endpapermatl,endpapercolor,insert2page,insert4page,insert2pgtext,insert4pgtext,topstainind,
			 topstaincolor,covertype,booktrim,oblongind,gatefoldind,gatefoldcomments,diecutind,diecutcomments,
		 	lastuserid,lastmaintdate,cartonqty1,prepackind,cartontype)	
		VALUES(@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_bindingdie,@v_reinforcements,@v_backingcode,@v_bindsignatures,@v_bindingmethod,
            @v_insert8page,@v_insert8pgtext,@v_insert16page,@v_insert16pgtext,@v_insert24page,@v_insert24pgtext,@v_insert32page,@v_insert32pgtext,
				@v_endpapertype,@v_endpapermatl,@v_endpapercolor,@v_insert2page,@v_insert4page,@v_insert2pgtext,@v_insert4pgtext,@v_topstainind,
				@v_topstaincolor,@v_covertype,@v_booktrim,@v_oblongind,@v_gatefoldind,@v_gatefoldcomments,@v_diecutind,@v_diecutcomments,
            @i_userid,getdate(),@v_cartonqty1,@v_prepackind,@v_cartontype)
	END

   IF @i_specind = 0   
   -- no specs for title/printing being copied from but title/printing being copied to might have some specs
   BEGIN

      SELECT @v_count = count(*)
		  FROM bindingspecs
		 WHERE bookkey = @i_to_bookkey AND
					 printingkey = @i_to_printingkey 
	
	
		IF @v_count > 0 
		BEGIN
			SELECT @v_tocartonqty1=cartonqty1,@v_ConvBindingMethod=bindingmethod,@v_ConvVendorkey=vendorkey,@v_convendpapmtl=endpapermatl,
					 @v_convcovertype =covertype,@v_convbooktrim = booktrim, @v_toprepackind = prepackind,@v_toendpapertype = endpapertype,
					 @v_toendpapercolor = endpapercolor
			  FROM bindingspecs
			 WHERE bookkey = @i_to_bookkey AND
					 printingkey = @i_to_printingkey 

			-- update and don't overwrite cartonqty1 unless it is null
			IF @v_tocartonqty1 IS NOT NULL
				SET @v_cartonqty1 = @v_tocartonqty1
			
			IF @v_toprepackind IS NOT NULL 
				SET @v_prepackind = @v_toprepackind
			
			
			IF @v_toendpapercolor IS NOT NULL 
				SET @v_endpapercolor = @v_toendpapercolor
						
			IF @v_toendpapertype IS NOT NULL 
				SET @v_endpapertype = @v_toendpapertype
								
			IF @v_ConvBindingMethod IS NOT NULL AND @v_ConvBindingMethod <> 0 
				SET @v_bindingmethod = @v_ConvBindingMethod
			
	
			IF @v_ConvVendorkey IS NOT NULL AND @v_ConvVendorkey <> 0 
				SET @v_vendorkey = @v_ConvVendorkey
			
			IF @v_convendpapmtl IS NOT NULL AND @v_convendpapmtl<> 0 
				SET @v_endpapermatl = @v_convendpapmtl
			
			IF @v_convbooktrim IS NOT NULL AND @v_convbooktrim<> 0 
				SET @v_booktrim = @v_convbooktrim
			
			IF @v_convcovertype IS NOT NULL AND @v_convcovertype<> 0 
				SET @v_covertype = @v_convcovertype
			
			UPDATE bindingspecs
				SET vendorkey = @v_vendorkey,cartonqty1 = @v_cartonqty1,bindingdie = @v_bindingdie,reinforcements = @v_reinforcements,backingcode = @v_backingcode,
					 bindsignatures = @v_bindsignatures,bindingmethod = @v_bindingmethod,insert8page = @v_insert8page,insert8pgtext = @v_insert8pgtext,
					 insert16page = @v_insert16page,insert16pgtext = @v_insert16pgtext,insert24page = @v_insert24page,insert24pgtext = @v_insert24pgtext,
					 insert32page = @v_insert32page,insert32pgtext = @v_insert32pgtext,endpapertype = @v_endpapertype,endpapermatl = @v_endpapermatl,
					 endpapercolor = @v_endpapercolor,insert2page = @v_insert2page,insert4page = @v_insert4page,insert2pgtext = @v_insert2pgtext,
					 insert4pgtext = @v_insert4pgtext,topstainind = @v_topstainind,topstaincolor = @v_topstaincolor,covertype = @v_covertype,
					 booktrim = @v_booktrim,oblongind = @v_oblongind,gatefoldind = @v_gatefoldind,gatefoldcomments = @v_gatefoldcomments,diecutind = @v_diecutind,
					 diecutcomments = @v_diecutcomments,lastuserid = @i_userid,lastmaintdate = getdate(),prepackind = @v_prepackind,cartontype = @v_cartontype
			 WHERE bookkey = @i_to_bookkey AND
					 printingkey = @i_to_printingkey 

      END
      ELSE
		BEGIN
			INSERT INTO bindingspecs
				(bookkey,printingkey,vendorkey,bindingdie,reinforcements,backingcode,bindsignatures,bindingmethod,
				 insert8page,insert8pgtext,insert16page,insert16pgtext,insert24page,insert24pgtext,insert32page,insert32pgtext,
				 endpapertype,endpapermatl,endpapercolor,insert2page,insert4page,insert2pgtext,insert4pgtext,topstainind,
				 topstaincolor,covertype,booktrim,oblongind,gatefoldind,gatefoldcomments,diecutind,diecutcomments,
				lastuserid,lastmaintdate,cartonqty1,prepackind,cartontype)	
			VALUES(@i_to_bookkey,@i_to_printingkey,@v_vendorkey,@v_bindingdie,@v_reinforcements,@v_backingcode,@v_bindsignatures,@v_bindingmethod,
					@v_insert8page,@v_insert8pgtext,@v_insert16page,@v_insert16pgtext,@v_insert24page,@v_insert24pgtext,@v_insert32page,@v_insert32pgtext,
					@v_endpapertype,@v_endpapermatl,@v_endpapercolor,@v_insert2page,@v_insert4page,@v_insert2pgtext,@v_insert4pgtext,@v_topstainind,
					@v_topstaincolor,@v_covertype,@v_booktrim,@v_oblongind,@v_gatefoldind,@v_gatefoldcomments,@v_diecutind,@v_diecutcomments,
					@i_userid,getdate(),@v_cartonqty1,@v_prepackind,@v_cartontype)
		END  --@v_count = 0
	END --specind = 0

	-- update titlehistory
	IF @v_vendorkey IS NOT NULL 
	BEGIN
		SELECT @v_vendorname = name
        FROM vendor
       WHERE vendorkey = @v_vendorkey

		EXECUTE qtitle_update_titlehistory 'bindingspecs','vendorkey',@i_to_bookkey,@i_to_printingkey,0,
				  @v_vendorname,'insert',@i_userid,null,'Binding Vendor',@o_error_code output,@o_error_desc output
		
		IF @o_error_code < 0 BEGIN
		RETURN
		END
    END
   
	-- Copy all notes associated with bind specs 
   EXEC Specs_Copy_write_notes @i_from_bookkey,@i_from_printingkey,@i_to_bookkey, @i_to_printingkey,2,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT 
	IF @o_error_code < 0 
   BEGIN
  		SET @o_error_desc = 'Unable to write bindingspec notes.'
      RETURN
   END

	IF @i_copytype = 'ALL'
   BEGIN
		-- Copy all bindcolor specs
		OPEN bindcolor_cursor
	
		FETCH NEXT FROM bindcolor_cursor INTO @v_colorkey, @v_colordesc
		
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN
	
			INSERT INTO bindcolor(bookkey,printingkey,colorkey,colordesc,lastuserid,lastmaintdate)
				VALUES (@i_to_bookkey,@i_to_printingkey,@v_colorkey,@v_colordesc,@i_userid,getdate())
					
			FETCH NEXT FROM bindcolor_cursor INTO @v_colorkey, @v_colordesc
				 
		END --bindcolor_cursor LOOP
				
		CLOSE bindcolor_cursor
---	DEALLOCATE bindcolor_cursor
	
		-- Copy all case specs
		SELECT @v_count = count(*)
		  FROM casespecs  
		 WHERE bookkey = @i_from_bookkey AND
				 printingkey = @i_from_printingkey
	
		IF @v_count > 0 
		BEGIN
			SELECT @v_casetypethickness = casetypethickness,@v_boardthickness=boardthickness,@v_foilamount=foilamount,@v_notekey=notekey,@v_hitfoil=hitfoil
			  FROM casespecs  
			 WHERE bookkey = @i_from_bookkey AND
					 printingkey = @i_from_printingkey
	
			INSERT INTO casespecs(bookkey,printingkey,casetypethickness,boardthickness,foilamount,notekey,hitfoil)
				VALUES (@i_to_bookkey,@i_to_printingkey,@v_casetypethickness,@v_boardthickness,@v_foilamount,@v_notekey,@v_hitfoil)
		END
	
		-- Copy all sidestamp specs
		SELECT @v_count = count(*)
		  FROM sidestamp  
		 WHERE bookkey = @i_from_bookkey AND
				 printingkey = @i_from_printingkey
	
		IF @v_count > 0 
		BEGIN
			SELECT @v_sidematerial =sidematerial,@v_sidecolor = sidecolor,@v_sidestamptype=sidestamptype, @v_sidestampcolor=sidestampcolor   
			  FROM sidestamp
			  WHERE (bookkey=@i_from_bookkey) AND
						  (printingkey=@i_from_printingkey) 
	
			INSERT INTO sidestamp (bookkey,printingkey,sidematerial,sidecolor,sidestamptype,sidestampcolor,lastuserid,lastmaintdate)
				VALUES (@i_to_bookkey,@i_to_printingkey,@v_sidematerial,@v_sidecolor,@v_sidestamptype,@v_sidestampcolor,@i_userid,getdate())
		END
	
		-- Copy all spinestamp specs
		SELECT @v_count = count(*)
		  FROM spinestamp  
		 WHERE bookkey = @i_from_bookkey AND
				 printingkey = @i_from_printingkey
	
		IF @v_count > 0 
		BEGIN
			SELECT @v_spinematerial=spinematerial,@v_spinecolor=spinecolor,@v_spinestamptype=spinestamptype,@v_spinestampcolor=spinestampcolor,
					 @v_spineinchestoshow=spineinchestoshow
			 FROM spinestamp  
			WHERE (bookkey=@i_from_bookkey) AND
					  (printingkey=@i_from_printingkey) 
	
			INSERT INTO spinestamp (bookkey,printingkey,spinematerial,spinecolor,spinestamptype,spinestampcolor,lastuserid,lastmaintdate,spineinchestoshow)
				VALUES (@i_to_bookkey,@i_to_printingkey,@v_spinematerial,@v_spinecolor,@v_spinestamptype,@v_spinestampcolor,@i_userid,getdate(),@v_spineinchestoshow);
		END
	END
  	DEALLOCATE bindcolor_cursor
END
go
