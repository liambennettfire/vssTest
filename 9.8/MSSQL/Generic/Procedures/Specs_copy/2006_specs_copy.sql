/* Drop the PROCEDURE if it exists */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.copy_specifications') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.copy_specifications
END
GO

CREATE PROCEDURE copy_specifications (
  @i_from_bookkey     INT,
  @i_from_printingkey INT,
  @i_to_bookkey       INT,
  @i_to_printingkey   INT,
  @i_specind          INT,
  @i_printingjobs_boolean     INT,
  @i_copy             varchar(10),
  @i_userid           VARCHAR(30),
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT
)
AS

/*************************************************************************************************************************
**  File: 
**  Name: copy_specifications
**  Desc: Procedure written to use existing functionality of uo_po_copy_new_printing (CREATE NEW PRINTING)
**
**              
**    Return values: 
**
**    Called by:  w_copy_specs_from_title (POMS6.PBL)
**              
**    Parameters:
**    Input              
**    ----------         
**    from_bookkey - Bookkey of title being copied from - Required
**    from_printingkey - Printingkey of title being copied from - Required
**    to_bookkey - Bookkey of title being copied to - Required
**    to_printingkey - Printingkey of title being copied from - Required (First Printing will be assumed if 0) - Required
**    specind - specind of title being copied to - from book table -Required
**    printingjobs_boolean - value of option from options in options pbl -Required
**    copy - in above window value passed = 'title' to indicate that copy of specs. from one title to another - Required 
**           (in the future might use this procedure to write from a title/printing to another printing of the same title
**            in that case value = 'printing' - used to retrieve nextprinting and next job number for new printing)
**    userid - Userid of user causing write to history - Required
**    
**    Output
**    -----------
**    error_code - error code
**    error_desc - error message - empty if No Error
**
**    Auth: Kusum Basra
**    Date: 6/27/08
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:     Author:         Description:
**    --------  --------        -------------------------------------------
**    
*******************************************************************************/
  

DECLARE @v_printingnum   INT,
	@v_nextprintingnbr INT,
	@v_nextjobnbr  INT,
   @v_compkey INT,
   @v_count INT,
   @v_count2 INT,
   @v_bind TINYINT,
   @v_paper TINYINT,
   @v_cover TINYINT,
   @v_covinsert TINYINT,
   @v_secondcover TINYINT,
   @v_jacket TINYINT,
   @v_compspeckey INT,
   @v_print TINYINT,
   @v_finishedgoodind varchar(1)

BEGIN

	SET @v_bind = 0
   SET @v_paper = 0
   SET @v_cover = 0
   SET @v_covinsert = 0
   SET @v_secondcover = 0
   SET @v_jacket = 0
   SET @v_compspeckey = 0
   SET @v_print = 0

	IF @i_copy = 'printing'
   BEGIN
      EXEC specs_copy_nextprintingnbr @i_from_bookkey, @i_printingjobs_boolean,@v_nextprintingnbr OUTPUT,@v_nextjobnbr OUTPUT,
  					@o_error_code OUTPUT,@o_error_desc OUTPUT 
   END
   ELSE
   BEGIN
    SET @v_nextprintingnbr = NULL
	 SET @v_nextjobnbr = NULL
   END

	-- printing needs to be done before textspecs  because @v_printingnum is retrieved in printing and used in textspecs 
	EXEC specs_copy_write_printing @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_specind,
  			@v_nextprintingnbr,@v_nextjobnbr,@i_copy,@i_userid,@v_printingnum OUTPUT,@o_error_code OUTPUT,@o_error_desc OUTPUT 

	--estbook procedure
	SET @v_count2 = 0

   SELECT @v_count2 = count(*)
     FROM estbook
    WHERE bookkey = @i_to_bookkey AND
			 printingkey = @i_to_printingkey 

	IF @v_count2 = 0
   BEGIN
		EXEC specs_copy_write_estbook  @i_to_bookkey,@i_to_printingkey,@i_userid,@o_error_code OUTPUT, @o_error_desc OUTPUT
	END

	--bookcontributor procedure
	EXEC specs_copy_write_bookcontributor @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_specind,
  			@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT 

  DECLARE component_cursor INSENSITIVE CURSOR FOR
	SELECT distinct compkey
     FROM component
    WHERE (bookkey=@i_from_bookkey) AND
		    (printingkey=@i_from_printingkey)
    ORDER BY compkey ASC

  SET @v_bind = 0

  OPEN component_cursor

  FETCH NEXT FROM component_cursor INTO @v_compkey

  WHILE (@@FETCH_STATUS = 0 )
  BEGIN

		INSERT INTO component (bookkey,printingkey,compkey,pokey,lastuserid,lastmaintdate)
			VALUES (@i_to_bookkey,@i_to_printingkey,@v_compkey,0,@i_userid,getdate())
				
		IF @v_compkey = 2
      BEGIN
 			SET @v_bind = 1
         -- 'ALL' here specifies that bindcolor, case, sidestamp,spinestamp, notes need to be copied for bind component
         -- as well as bindingspec row
			EXEC specs_copy_write_binding  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_specind,'ALL',
				@i_userid,@o_error_code oUTPUT, @o_error_desc OUTPUT 

      END

		IF @v_compkey = 3
      BEGIN
 			SET @v_paper = 1
			EXEC specs_copy_write_text  @i_from_bookkey, @i_from_printingkey,@i_to_bookkey, @i_to_printingkey, @i_specind,@v_printingnum,
          @i_userid, @o_error_code OUTPUT,@o_error_desc OUTPUT 

         EXEC specs_copy_write_materialspecs  @i_from_bookkey, @i_from_printingkey,@i_to_bookkey, @i_to_printingkey, @i_specind,
          @i_userid, @o_error_code OUTPUT,@o_error_desc OUTPUT 
--print 'materialspecs done'
      END

		IF @v_compkey = 4
      BEGIN
 			SET @v_cover = 1
			EXEC specs_copy_write_coverspecs  @i_from_bookkey, @i_from_printingkey,@i_to_bookkey, @i_to_printingkey, @i_specind,
          @i_userid, @o_error_code OUTPUT,@o_error_desc OUTPUT 
--print 'coverspecs done'
      END

		IF @v_compkey = 27
      BEGIN
 			SET @v_covinsert = 1
			EXEC specs_copy_write_coverinsert  @i_from_bookkey, @i_from_printingkey,@i_to_bookkey, @i_to_printingkey, @i_specind,
          @i_userid, @o_error_code OUTPUT,@o_error_desc OUTPUT 
--print 'coverinsert done'
      END


		IF @v_compkey = 28
      BEGIN
 			SET @v_secondcover = 1
			EXEC specs_copy_write_secondcoverspecs  @i_from_bookkey, @i_from_printingkey,@i_to_bookkey, @i_to_printingkey, @i_specind,
          @i_userid, @o_error_code OUTPUT,@o_error_desc OUTPUT 
--print 'secondcovers done'
      END

		IF @v_compkey = 5
		BEGIN
         SET @v_jacket = 1
			EXEC specs_copy_write_jacketspecs  @i_from_bookkey, @i_from_printingkey,@i_to_bookkey, @i_to_printingkey, @i_specind,
			 @i_userid, @o_error_code OUTPUT,@o_error_desc OUTPUT 
--print 'jacketspecs done'
      END
      
		IF @v_compkey = 7
		BEGIN
			EXEC specs_copy_write_endpaper  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
--print 'endpapers done'
      END

		IF @v_compkey = 6
		BEGIN
			EXEC Specs_Copy_write_nonbook  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
--print 'nonbook done'
      END
		
	  IF @v_compkey = 8
		BEGIN
			EXEC specs_copy_write_illus  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT
      END

		IF @v_compkey = 10
		BEGIN
			EXEC specs_copy_write_diskettespecs  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
      END

		IF @v_compkey = 11
		BEGIN
			EXEC specs_copy_write_laserdiscspecs  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
      END

		IF @v_compkey = 12
		BEGIN
			EXEC specs_copy_write_cdromspecs  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
      END		
	

		IF @v_compkey = 13
		BEGIN
			EXEC specs_copy_write_videocassette  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
       END

		IF @v_compkey = 14
		BEGIN
			EXEC specs_copy_write_audiocassette  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
       END

		IF @v_compkey = 15
		BEGIN
			EXEC specs_copy_write_cardspecs  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
      END

		IF @v_compkey = 16
		BEGIN
			EXEC specs_copy_write_posterspecs  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
      END

		IF @v_compkey = 17
		BEGIN
			EXEC specs_copy_write_labelspecs  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
      END

		IF @v_compkey = 18
		BEGIN
			EXEC specs_copy_write_stickerspecs  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
      END	

		IF @v_compkey = 19
		BEGIN
			EXEC specs_copy_write_transparencyspecs  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
      END	

		IF @v_compkey = 20
		BEGIN
			EXEC specs_copy_write_mediainsertspecs  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
      END	

		IF @v_compkey = 21
		BEGIN
			EXEC specs_copy_write_bundlespecs  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
      END

		IF @v_compkey = 23
		BEGIN
			EXEC specs_copy_write_printpackaging  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
      END

		IF @v_compkey = 24
		BEGIN
			EXEC specs_copy_write_kitspecs  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
      END	

		IF @v_compkey = 25
		BEGIN
			EXEC specs_copy_write_assemblyspecs  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
      END	

		IF @v_compkey = 26
		BEGIN
			EXEC specs_copy_write_electpackagingspecs  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
      END

		IF @v_compkey = 29
		BEGIN
			EXEC specs_copy_write_errataspecs  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
      END

		IF @v_compkey = 30
		BEGIN
			EXEC specs_copy_write_documentationspecs  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid,
  				@o_error_code OUTPUT,@o_error_desc OUTPUT 
      END

      FETCH NEXT FROM component_cursor INTO @v_compkey
       
   END --component_cursor LOOP
      
   CLOSE component_cursor
   DEALLOCATE component_cursor

   SET @v_count2 = 0

   SELECT @v_count2 = count(*)
     FROM compspec
    WHERE bookkey = @i_from_bookkey AND
			 printingkey = @i_from_printingkey AND
          compkey = 2

	IF @v_count2 = 0
   BEGIN
		-- Bindingspecs might exist for titles without bind component 
		-- Added through TMM (extended product) OR PROD (Spec Summary) if cartonqty inserted for title/printing
		SELECT @v_count = count(*)
		  FROM bindingspecs
		 WHERE bookkey = @i_from_bookkey AND
				 printingkey = @i_from_printingkey
	
		IF @v_count > 0
		 BEGIN
         -- 'NO' here specifies that only bindingspec row needs to be copied
			EXEC specs_copy_write_binding  @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_specind,'NO',
				@i_userid,@o_error_code OUTPUT, @o_error_desc OUTPUT
		 END
	END

	IF @v_bind = 1 OR @v_print = 1 OR @v_cover = 1 OR @v_jacket = 1 OR @v_covinsert = 1 OR @v_secondcover = 1
	BEGIN
		EXEC specs_copy_write_misccompspecs  @i_from_bookkey, @i_from_printingkey,@i_to_bookkey, @i_to_printingkey,@i_userid, 
			@o_error_code OUTPUT,@o_error_desc OUTPUT 
--print 'misccompspecs done'
	END


	DECLARE compspec_cursor INSENSITIVE CURSOR FOR
	 SELECT compkey, finishedgoodind
		FROM compspec
	  WHERE (bookkey=@i_from_bookkey) AND
		    (printingkey=@i_from_printingkey)
    ORDER BY compkey ASC
	--write to the compspec table for all components
	OPEN compspec_cursor

	FETCH NEXT FROM compspec_cursor INTO @v_compkey, @v_finishedgoodind

	WHILE (@@FETCH_STATUS = 0 )
  	BEGIN

		UPDATE keys SET generickey = generickey+1,lastuserid = 'QSIADMIN',lastmaintdate = getdate()

		SELECT @v_compspeckey = generickey from keys
			
		INSERT INTO compspec  (compspeckey,bookkey,printingkey,compkey,finishedgoodind,activeind,gendetailsind,lastuserid,lastmaintdate )  
		 VALUES (@v_compspeckey,@i_to_bookkey,@i_to_printingkey,@v_compkey,@v_finishedgoodind,0,'Y',@i_userid,getdate())   
			
		FETCH NEXT FROM compspec_cursor INTO @v_compkey, @v_finishedgoodind
			 
	END --compspec_cursor LOOP
			
	CLOSE compspec_cursor
	DEALLOCATE compspec_cursor
   
END 
go