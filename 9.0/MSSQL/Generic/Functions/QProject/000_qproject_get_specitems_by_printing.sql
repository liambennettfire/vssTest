if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qproject_get_specitems_by_printing') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qproject_get_specitems_by_printing
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE FUNCTION [dbo].[qproject_get_specitems_by_printing](@i_taqversionformatyearkey int)

RETURNS @specitemsbyprinting TABLE(
		taqversionformatyearkey INT,
		printingnumber INT,
		yearcode INT,
		taqprojectkey INT,
		plstagecode INT,
		taqversionkey INT,
		taqprojectformatkey INT,
    taqversionspecategorykey INT,
    itemcategorycode	INT,
    speccategorydescription VARCHAR(255),
    scaleprojecttype	INT,
    scaleprojectdesc	VARCHAR(40),
    vendorcontactkey	INT,
    vendordisplayname	VARCHAR(255),
    taqversionspecitemkey	INT,
    itemcode	INT,
    itemdesc		VARCHAR(120),
    usefunctionforqtyind	TINYINT,
		usefunctionfordescind TINYINT,
		usefunctionforitemdetailind	TINYINT,
		usefunctionfordecimalind		TINYINT,
		usefunctionforuomind		TINYINT,
    validforprtscode		INT,
    validforprtsdesc		VARCHAR(40),
    itemdetailcode INT,
    description VARCHAR(2000),
    quantity  INT,
    decimalvalue  NUMERIC(15,4),
    unitofmeasurecode INT
		
	)
AS
BEGIN
			DECLARE	@v_taqversionformatyearkey	integer,
				@v_printingnumber	integer,
				@v_yearcode	integer,
  			@v_taqprojectkey	integer,
				@v_plstagecode	integer,
				@v_taqversionkey	integer,
				@v_taqprojectformatkey	integer,
				@v_taqversionspecategorykey	integer,
				@v_itemcategorycode	integer, 
				@v_speccategorydescription	VARCHAR(255), 
				@v_scaleprojecttype	integer,
				@v_scaleprojectdesc	varchar(255),
				@v_vendorcontactkey	integer,
				@v_vendordisplayname	varchar(255),
				@v_taqversionspecitemkey	integer, 
				@v_itemcode integer,
				@v_itemdesc	varchar(120),
     		@v_unitofmeasurecode	integer,
        @v_unitofmeasuredesc	VARCHAR(40),
				@v_validforprtgscode integer,
				@v_validforprtsdesc	VARCHAR(40),
     		@v_itemdetailcode	integer,
				@v_usefunctionforitemdetailind TINYINT,
				@v_usefunctionforqtyind	TINYINT,
        @v_usefunctionfordescind       TINYINT,
				@v_usefunctionfordecimalind	TINYINT,
        @v_usefunctionforuomind      TINYINT,
			  @v_numericdesc1	VARCHAR(120),
				@v_count1 INT,
				@v_count2 INT,
				@v_sql  NVARCHAR(4000),
        @v_description VARCHAR(4000),
        @v_quantity INT,
        @v_decimalvalue NUMERIC(15,4)
      
      IF @i_taqversionformatyearkey > 0 BEGIN
			  DECLARE taqversionformatyear_cur CURSOR fast_forward FOR
			    SELECT taqversionformatyearkey,printingnumber,yearcode, taqprojectkey, plstagecode,taqversionkey, taqprojectformatkey
				   FROM taqversionformatyear
				  WHERE printingnumber > 0
				    AND taqversionformatyearkey = @i_taqversionformatyearkey
      END
      ELSE BEGIN		
			  DECLARE taqversionformatyear_cur CURSOR fast_forward FOR
			    SELECT taqversionformatyearkey,printingnumber,yearcode, taqprojectkey, plstagecode,taqversionkey, taqprojectformatkey
				   FROM taqversionformatyear
				  WHERE printingnumber > 0 
		  END
		  
			 OPEN taqversionformatyear_cur
		
			 FETCH from taqversionformatyear_cur INTO @v_taqversionformatyearkey,@v_printingnumber, @v_yearcode, @v_taqprojectkey,@v_plstagecode,@v_taqversionkey,@v_taqprojectformatkey


			WHILE @@fetch_status = 0 BEGIN

        DECLARE taqversionspeccategory_cur CURSOR FOR
				  SELECT itemcategorycode,speccategorydescription,scaleprojecttype,taqversionspecategorykey,vendorcontactkey
				    FROM taqversionspeccategory
           WHERE taqprojectkey = @v_taqprojectkey
             AND plstagecode = @v_plstagecode
             AND taqversionkey = @v_taqversionkey
             AND taqversionformatkey = @v_taqprojectformatkey

        OPEN taqversionspeccategory_cur

        FETCH taqversionspeccategory_cur INTO @v_itemcategorycode,@v_speccategorydescription,@v_scaleprojecttype,@v_taqversionspecategorykey,
           @v_vendorcontactkey

        WHILE @@fetch_status = 0 BEGIN

          --IF @v_printingnumber IS NULL OR @v_printingnumber = 0 BEGIN
          --   --- No printing for this year so CONTINUE to next row
          --   FETCH from taqversionformatyear_cur INTO @v_taqversionformatyearkey,@v_printingnumber, @v_yearcode, @v_taqprojectkey,
          --          @v_plstagecode,@v_taqversionkey,@v_taqprojectformatkey
          --END
          --ELSE BEGIN
				    IF @v_printingnumber = 1 BEGIN
					    DECLARE taqversionspecitems_cur CURSOR fast_forward FOR
					      SELECT taqversionspecategorykey,taqversionspecitemkey, itemcode,unitofmeasurecode,validforprtgscode,itemdetailcode,
                       description,quantity,decimalvalue,unitofmeasurecode
						      FROM taqversionspecitems
                 WHERE taqversionspecategorykey = @v_taqversionspecategorykey
                   AND COALESCE(validforprtgscode,3) in (1,3)
				    END
				    ELSE IF @v_printingnumber > 1 BEGIN
					    DECLARE taqversionspecitems_cur CURSOR fast_forward FOR
					      SELECT taqversionspecategorykey,taqversionspecitemkey, itemcode,unitofmeasurecode,validforprtgscode,itemdetailcode,
                       description,quantity,decimalvalue,unitofmeasurecode
						      FROM taqversionspecitems
                 WHERE taqversionspecategorykey = @v_taqversionspecategorykey
                   AND COALESCE(validforprtgscode,3) in (2,3)
				    END
    				
    		
				    OPEN taqversionspecitems_cur
    		
				    FETCH from taqversionspecitems_cur INTO @v_taqversionspecategorykey,@v_taqversionspecitemkey, @v_itemcode,@v_unitofmeasurecode,
                   @v_validforprtgscode,@v_itemdetailcode,@v_description,@v_quantity,@v_decimalvalue,@v_unitofmeasurecode

				    WHILE @@fetch_status = 0 BEGIN

					    IF @v_scaleprojecttype IS NOT NULL AND @v_scaleprojecttype <> 0 BEGIN
					      SELECT @v_scaleprojectdesc = datadesc FROM gentables where tableid = 521 AND datacode = @v_scaleprojecttype
					    END
					    ELSE BEGIN
						    SELECT @v_scaleprojectdesc = NULL
					    END

					    IF @v_itemcategorycode IS NOT NULL AND @v_itemcategorycode <> 0 BEGIN
					      SELECT @v_itemdesc = datadesc FROM subgentables WHERE tableid = 616 AND datacode = @v_itemcategorycode AND
                      datasubcode = @v_itemcode
					    END
					    ELSE BEGIN
						    SELECT @v_itemdesc = NULL
					    END

					    IF @v_vendorcontactkey IS NOT NULL AND @v_vendorcontactkey <> 0 BEGIN
						    SELECT @v_vendordisplayname = displayname
						      FROM globalcontact
					       WHERE globalcontactkey = @v_vendorcontactkey
					    END
              ELSE BEGIN
						    SELECT @v_vendordisplayname = NULL
					    END
    	
					    SELECT @v_usefunctionforitemdetailind = usefunctionforitemdetailind, @v_usefunctionforqtyind = usefunctionforqtyind, 
                     @v_usefunctionfordescind = usefunctionfordescind, @v_usefunctionfordecimalind = usefunctionfordecimalind, 
                     @v_usefunctionforuomind = usefunctionforuomind
					      FROM taqspecadmin
               WHERE itemcategorycode = @v_itemcategorycode
					       AND itemcode = @v_itemcode

					    IF @v_validforprtgscode > 0 BEGIN
						    SELECT @v_validforprtsdesc = datadesc FROM gentables where tableid = 623 AND datacode = @v_validforprtgscode
        	    END
					    ELSE BEGIN
						    SET @v_validforprtsdesc = NULL
					    END

					    INSERT INTO @specitemsbyprinting
						    (taqversionformatyearkey,printingnumber,yearcode,taqprojectkey,plstagecode,taqversionkey,taqprojectformatkey,taqversionspecategorykey,itemcategorycode,
                 speccategorydescription,scaleprojecttype,scaleprojectdesc,vendorcontactkey,vendordisplayname,taqversionspecitemkey,itemcode,itemdesc,
                 usefunctionforqtyind,usefunctionfordescind,usefunctionforitemdetailind,usefunctionfordecimalind,usefunctionforuomind,
                 validforprtscode,validforprtsdesc,description,quantity,decimalvalue,unitofmeasurecode,itemdetailcode)
					    VALUES
						    (@v_taqversionformatyearkey, @v_printingnumber,@v_yearcode,@v_taqprojectkey,@v_plstagecode,@v_taqversionkey,@v_taqprojectformatkey,	@v_taqversionspecategorykey,@v_itemcategorycode,
                 @v_speccategorydescription,@v_scaleprojecttype,@v_scaleprojectdesc,@v_vendorcontactkey,@v_vendordisplayname,@v_taqversionspecitemkey,@v_itemcode,@v_itemdesc,
                 @v_usefunctionforqtyind,@v_usefunctionfordescind,@v_usefunctionforitemdetailind,@v_usefunctionfordecimalind,@v_usefunctionforuomind,
                 @v_validforprtgscode, @v_validforprtsdesc,@v_description,@v_quantity,@v_decimalvalue,@v_unitofmeasurecode,@v_itemdetailcode)

					    FETCH from taqversionspecitems_cur INTO @v_taqversionspecategorykey,@v_taqversionspecitemkey, @v_itemcode,
                 @v_unitofmeasurecode,@v_validforprtgscode,@v_itemdetailcode,@v_description,@v_quantity,@v_decimalvalue,@v_unitofmeasurecode
				    END  --taqversionspecitems_cur

				    CLOSE taqversionspecitems_cur
				    DEALLOCATE taqversionspecitems_cur 
          --END
            FETCH taqversionspeccategory_cur INTO @v_itemcategorycode,@v_speccategorydescription,@v_scaleprojecttype,@v_taqversionspecategorykey,
           @v_vendorcontactkey
        END 
        CLOSE taqversionspeccategory_cur
        DEALLOCATE taqversionspeccategory_cur

				FETCH from taqversionformatyear_cur INTO @v_taqversionformatyearkey,@v_printingnumber, @v_yearcode, @v_taqprojectkey,@v_plstagecode,@v_taqversionkey,@v_taqprojectformatkey
		 END  --taqversionformatyear_cur
	  
		 CLOSE taqversionformatyear_cur
		 DEALLOCATE taqversionformatyear_cur
	RETURN
END