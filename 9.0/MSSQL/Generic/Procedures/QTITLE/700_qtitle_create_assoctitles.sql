if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_create_assoctitles') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_create_assoctitles 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_create_assoctitles
 (@i_bookkey                  integer,
  @i_printingkey              integer,
  @i_associationtypecode      integer,
  @i_associationtypesubcode   integer,
  @i_productnumber            varchar(19),
  @i_productidtype            integer,
  @i_userid                   varchar(30),
  @i_stoponwarning            tinyint,
  @i_reverse_assoctypecode    integer,
  @i_reverse_assoctypesubcode integer,
  @i_sortorder                integer,
  @o_associatetitlebookkey    integer output,
  @o_error_code               integer output,
  @o_error_desc               varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_create_assoctitles
**  Desc: This stored procedure will create a title relationship 
**        between 2 titles.      
**
**    Parameters:
**    Input              
**    ----------         
**    bookkey - bookkey of the title from which the relationship is created - Required
**             (NOTE:  the relationship will be created from the bookkeys point of view)
**    printingkey - printingkey of title from which the relationship is created - Required
**             (First Printing will be assumed if 0 or null)
**    associationtypecode - datacode of type of relation (tableid 440) - Required
**    associationtypesubcode - datasubcode of type of relation (0 will be used if null)
**    productnumber - productnumber of other title in relationship - Required
**    productidtype - datacode to define the productnumber type (GTIN, ISBN10, ISBN13, etc) - tableid 551 - Required
**    userid - Userid of user creating relationship - Required
**    stoponwarning - Flag to tell us what to do on warnings - use 1 to stop processing on warnings 
**                    (0 will be assumed if not filled in) 
**    reverse_assoctypecode - datacode of type of opposite relation (tableid 440) - pass 0 if none
**    reverse_assoctypesubcode - datasubcode of type of relation - pass 0 if none
**    sortorder - defaults to 1 if not passed in
** 
**    Output
**    -----------
**    associatetitlebookkey - if the productnumber is found on the database, return its bookkey (return 0 if not on database)
**    error_code - error code
**    error_desc - error message - empty if No Error
**
**    Auth: Alan Katzen
**    Date: 28 February 2006
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  DECLARE @error_var                  INT,
          @rowcount_var               INT,
          @v_authorkey                INT,
          @v_bookkey                  INT,
          @v_printingkey              INT,
          @v_associationtypecode      INT,
          @v_associationtypesubcode   INT,
          @v_reverse_assoctypecode    INT,
          @v_reverse_assoctypesubcode INT,
          @v_productnumber            VARCHAR(50),
          @v_productdesc              VARCHAR(50),
          @v_tempstring               VARCHAR(10),
          @v_work_string              VARCHAR(50),
          @v_productidtype            INT,
          @v_productidtype_for_column INT,
          @v_last_digit               CHAR(1),
          @v_check_digit              CHAR(1),
          @v_product_type             TINYINT,
          @v_new_check_digit          TINYINT,
          @v_userid                   varchar(30),
          @v_whereclause              NVARCHAR(4000),
          @v_columnname               VARCHAR(50),
          @SQLString_var              NVARCHAR(4000),
          @SQLparams_var              NVARCHAR(4000),
          @v_count                    INT,
          @v_length                   INT,
          @v_associatetitlebookkey    INT,
          @v_stoponwarning            tinyint,
          @v_sortorder                INT,
          @v_main_productnumber       VARCHAR(19),
          @v_assoctypesubcode_desc    varchar(50)

  SET @v_sortorder = @i_sortorder
  SET @o_associatetitlebookkey = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_bookkey = @i_bookkey
  SET @v_printingkey = @i_printingkey
  SET @v_associationtypecode = @i_associationtypecode
  SET @v_associationtypesubcode = @i_associationtypesubcode
  SET @v_reverse_assoctypecode = @i_reverse_assoctypecode
  SET @v_reverse_assoctypesubcode = @i_reverse_assoctypesubcode
  SET @v_productnumber = @i_productnumber
  SET @v_productidtype = @i_productidtype
  SET @v_userid = @i_userid
  SET @v_stoponwarning = @i_stoponwarning

  IF @v_bookkey IS NULL OR @v_bookkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to create Title Relationship: bookkey is empty.'
    RETURN
  END 

  IF @v_printingkey IS NULL OR @v_printingkey = 0 BEGIN
    SET @v_printingkey = 1
  END 

  IF @v_associationtypecode IS NULL OR @v_associationtypecode = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to create Title Relationship: associationtypecode is empty.'
    RETURN
  END 

  IF @v_associationtypesubcode IS NULL BEGIN
    SET @v_associationtypesubcode = 0
  END 

  IF @v_reverse_assoctypecode IS NULL BEGIN
    SET @v_reverse_assoctypecode = 0
  END 

  IF @v_reverse_assoctypesubcode IS NULL BEGIN
    SET @v_reverse_assoctypesubcode = 0
  END 

  IF @v_sortorder IS NULL BEGIN
    SET @v_sortorder = 1
  END 

  IF @v_productnumber IS NULL OR ltrim(rtrim(@v_productnumber)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to create Title Relationship: productnumber is empty.'
    RETURN
  END 

  IF @v_productidtype IS NULL OR @v_productidtype = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to create Title Relationship: productidtype is empty.'
    RETURN
  END 

  IF @v_stoponwarning IS NULL OR @v_stoponwarning > 1 OR @v_stoponwarning < 0 BEGIN
    SET @v_stoponwarning = 0
  END 

  IF @v_userid IS NULL OR ltrim(rtrim(@v_userid)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to create Title Relationship: userid is empty.'
    RETURN
  END 

  -- reset @v_associatetitlebookkey
  SET @v_associatetitlebookkey = 0


  -- Get the productnumber columnname using productnumlocation table configuration 
  -- for titles (productnumlockey=1)
  SELECT @v_columnname = lower(columnname)
  FROM productnumlocation
  WHERE productnumlockey = 1
  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'no data found on productnumlocation table (productnumlockey=1).'
    RETURN
  END
  
  SELECT @v_productdesc = label
  FROM isbnlabels
  WHERE columnname = @v_columnname
  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'no data found on isbnlabels table (columnname=' + @v_columnname + ').'
    RETURN
  END  
  
  -- Determine ProductIdType corresponding to the productnumber column above
  SET @v_productidtype_for_column = 
    CASE @v_columnname
      WHEN 'isbn' THEN 1
      WHEN 'isbn10' THEN 1
      WHEN 'gtin' THEN 3
      WHEN 'gtin14' THEN 3
	  WHEN 'itemnumber' THEN 0
      ELSE 2  --default to EAN/ISBN-13
    END
  
-- Validate product for 'isbn', 'isbn10','gtin'
  IF @v_productidtype_for_column > 0
  BEGIN
	  -- Set up the product_type argument to the ean_generate_check_digit and
	  -- ean_validate_product stored procedures below
	  SET @v_product_type = 
		CASE @v_productidtype_for_column
		  WHEN 1 THEN 0   -- ISBN-10
		  WHEN 3 THEN 2   -- GTIN
		  ELSE 1          --default to EAN/ISBN-13
		END
	        
	  -- If entered productnumber DOES NOT match the default productnumber
	  -- as configured on productnumlocation table, we must convert 
	  -- entered productnumber to the expected form
	  IF @v_productidtype <> @v_productidtype_for_column
	  BEGIN
	    
		-- Save entered productnumber (without dashes or spaces) into @v_work_string
		SET @v_work_string = REPLACE(@v_productnumber, '-', '')
		SET @v_work_string = REPLACE(@v_work_string, ' ', '')
		SET @v_work_string = UPPER(@v_work_string)
	    
		-- Extract the last digit for comparison with the generated check digit later
		SET @v_last_digit = RIGHT(@v_work_string, 1)
	    
		-- Store all digits before the check digit into @v_work_string
		SET @v_length = LEN(@v_work_string)
		SET @v_work_string = SUBSTRING(@v_work_string, 1, @v_length - 1)    
		SET @v_length = LEN(@v_work_string)
	    
		-- Assume we don't have to regenerate the check digit
		SET @v_new_check_digit = 0
	    
		IF @v_productidtype_for_column = 1  --must save ISBN-10
		BEGIN    
		  IF @v_productidtype = 2 --entered EAN/ISBN-13 (13 digits)
			BEGIN
			  -- Take out the 3 characters (EAN Prefix) from work_string 
			  SET @v_work_string = RIGHT(@v_work_string, @v_length - 3)
			END      
		  ELSE  -- @v_productidtype=3 --entered GTIN  (14 digits)
			BEGIN
			  -- Take out the 4 characters (0 + EAN Prefix) from work_string 
			  SET @v_work_string = RIGHT(@v_work_string, @v_length - 4)
			END  
	      
		  -- Since both EAN/ISBN-13 and GTIN have a different check digit than ISBN-10,
		  -- we have to regenerate the check digit to replace the current one
		  SET @v_new_check_digit = 1
		END
	    
		IF @v_productidtype_for_column = 2  --must save EAN/ISBN-13
		BEGIN
		  IF @v_productidtype = 1 --entered ISBN-10 (10 digits)
			BEGIN
			  -- Add EAN Prefix (currently 978) to work_string
			  SET @v_work_string = '978' + @v_work_string
			  SET @v_new_check_digit = 1
			END
		  ELSE  -- @v_productidtype=3 --entered GTIN  (14 digits)
			BEGIN
			  -- Take out the first 1 character (0) from work_string 
			  SET @v_work_string = RIGHT(@v_work_string, @v_length - 1)
			END
		END
	    
		IF @v_productidtype_for_column = 3  --must save GTIN
		BEGIN
		  IF @v_productidtype = 1 --entered ISBN-10 (10 digits)
			BEGIN
			  -- Add 0 + EAN Prefix (currently 978) to work_string
			  SET @v_work_string = '0978' + @v_work_string
			  SET @v_new_check_digit = 1
			END
		  ELSE  -- @v_productidtype=2 --entered EAN/ISBN-13 (13 digits)
			BEGIN
			  -- Add 0 to work_string
			  SET @v_work_string = '0' + @v_work_string
			END
		END
	    
		-- Generate a new check digit for the productnumber to be saved
		IF @v_new_check_digit = 1
		  BEGIN    
			EXEC qean_generate_check_digit @v_work_string, 
			  @v_check_digit OUTPUT, @v_product_type
	        
			SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			IF @error_var <> 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'Error generating check digit for ' + @v_productdesc + ' (qean_generate_check_digit).'
			  RETURN
			END
		  END
		ELSE
		  SET @v_check_digit = @v_last_digit  --keep entered check digit
	    
		-- Now add the proper check digit to the work_string
		SET @v_work_string = @v_work_string + @v_check_digit

		-- Call the product validation procedure to hyphenate the product to be saved
		EXEC qean_validate_product @v_work_string, @v_product_type, 0, 0,
		  @v_productnumber OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
	      
		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @o_error_code < 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Error validating product (qean_validate_product).'
		  RETURN
		END      
	  END
  END

  IF  @v_productidtype_for_column = 0
  BEGIN
	SET @v_productnumber =  @i_productnumber 
  END

  SET @v_whereclause = @v_columnname + ' = ''' + ltrim(rtrim(@v_productnumber)) + ''''
  --SET @SQLString_var = N'SELECT @numitems = count(*) FROM isbn' +
  ---                      N' WHERE ' + cast(@v_whereclause AS NVARCHAR)
  SET @SQLString_var = N'SELECT @numitems = count(*) FROM isbn' +
                       N' WHERE ' + @v_whereclause


--SET @o_error_desc = '@SQLString_var = ' + CONVERT(varchar(2000),@SQLString_var)

---print @v_whereclause
  set @SQLparams_var = N'@numitems INT OUTPUT' 
  EXECUTE sp_executesql @SQLString_var, @SQLparams_var, @v_count OUTPUT

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to check if data exists on isbn (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 

  -- add title relationship from the bookkeys point of view
  SET @v_associatetitlebookkey = 0
  IF @v_count > 0 BEGIN
    -- productnumber (title) exists on the database - get its bookkey
    SET @v_whereclause = @v_columnname + ' = ''' + ltrim(rtrim(@v_productnumber)) + ''''
    SET @SQLString_var = N'SELECT TOP 1 @v_associatetitlebookkey = isbn.bookkey' +
                          ' FROM coretitleinfo' +
			  ' LEFT OUTER JOIN isbn ON coretitleinfo.bookkey = isbn.bookkey' +   
                          ' WHERE coretitleinfo.printingkey=1 AND isbn.' + @v_whereclause  +
                          ' ORDER BY coretitleinfo.linklevelcode, coretitleinfo.issuenumber DESC'
                         
    SET @SQLparams_var = N'@v_associatetitlebookkey INT OUTPUT' 
    EXECUTE sp_executesql @SQLString_var, @SQLparams_var, @v_associatetitlebookkey OUTPUT

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to retrieve data from isbn (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END
  END 
  ELSE BEGIN
    -- associated title does not exist
    IF @v_stoponwarning = 1 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Error: Cannot find associated title on the database (' + ltrim(rtrim(@v_productnumber)) + ').'
      RETURN
    END
  END

  IF @v_associatetitlebookkey > 0 BEGIN
  
    -- If only 1 primary author exists for the title, save it to associatedtitles
    SELECT @v_count = COUNT(*)
    FROM bookauthor
    WHERE bookkey = @v_associatetitlebookkey AND primaryind = 1
    
    IF @v_count = 1
      SELECT @v_authorkey = authorkey
      FROM bookauthor
      WHERE bookkey = @v_associatetitlebookkey AND primaryind = 1
    ELSE
      SET @v_authorkey = NULL
      
    -- associated title exists - get data and insert into associatedtitles
    INSERT INTO associatedtitles 
          (bookkey,associationtypecode,associatetitlebookkey,sortorder,isbn,title,authorname,
           bisacstatus,origpubhousecode,mediatypecode,mediatypesubcode,price,pubdate,salesunitgross,
           salesunitnet,reportind,authorkey,lastuserid,lastmaintdate,associationtypesubcode,productidtype)
    SELECT @v_bookkey,@v_associationtypecode,@v_associatetitlebookkey,@v_sortorder,@v_productnumber,UPPER(c.title),
           c.authorname,c.bisacstatuscode,null,c.mediatypecode,c.mediatypesubcode,c.tmmprice,c.bestpubdate,null,
           null,0,@v_authorkey,@v_userid,getdate(),@v_associationtypesubcode,@v_productidtype
      FROM coretitleinfo c 
     WHERE c.bookkey = @v_associatetitlebookkey and
           c.printingkey = @v_printingkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to insert data into associatedtitles (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END

    -- Title History and Send to Eloquence
    SET @v_assoctypesubcode_desc = ltrim(rtrim(dbo.get_subgentables_desc(440,@v_associationtypecode,@v_associationtypesubcode,'long')))
    EXECUTE qtitle_update_titlehistory 'associatedtitles','isbn',@v_bookkey,@v_printingkey,0,
                                       @v_productnumber,'insert',@v_userid,null,@v_assoctypesubcode_desc,
                                       @o_error_code output,@o_error_desc output

    IF @o_error_code < 0 BEGIN
      RETURN
    END

    SET @o_associatetitlebookkey = @v_associatetitlebookkey

    -- create opposite relationship if necessary
    IF @v_reverse_assoctypecode > 0 BEGIN

      -- need to get productnumber of main title
      --SET @v_whereclause = @v_columnname + ' = ''' + ltrim(rtrim(@v_productnumber)) + ''''
      SET @SQLString_var = N'SELECT @v_main_productnumber = ' + @v_columnname + ' FROM isbn' +
                           N' WHERE bookkey = ' + cast(@v_bookkey AS NVARCHAR)

--- print '@SQLString_var= ' + @SQLString_var

      SET @SQLparams_var = N'@v_main_productnumber VARCHAR(19) OUTPUT' 
      EXECUTE sp_executesql @SQLString_var, @SQLparams_var, @v_main_productnumber OUTPUT

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to retrieve productnumber from isbn (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END

      -- If only 1 primary author exists for the title, save it to associatedtitles
      SELECT @v_count = COUNT(*)
      FROM bookauthor
      WHERE bookkey = @v_bookkey AND primaryind = 1
      
      IF @v_count = 1
        SELECT @v_authorkey = authorkey
        FROM bookauthor
        WHERE bookkey = @v_bookkey AND primaryind = 1
      ELSE
        SET @v_authorkey = NULL

      INSERT INTO associatedtitles 
            (bookkey,associationtypecode,associatetitlebookkey,sortorder,isbn,title,authorname,
             bisacstatus,origpubhousecode,mediatypecode,mediatypesubcode,price,pubdate,salesunitgross,
             salesunitnet,reportind,authorkey,lastuserid,lastmaintdate,associationtypesubcode,productidtype)
      SELECT @v_associatetitlebookkey,@v_reverse_assoctypecode,@v_bookkey,@v_sortorder,@v_main_productnumber,UPPER(c.title),
             c.authorname,c.bisacstatuscode,null,c.mediatypecode,c.mediatypesubcode,c.tmmprice,c.bestpubdate,null,
             null,0,null,@v_userid,getdate(),@v_reverse_assoctypesubcode,@v_productidtype
        FROM coretitleinfo c 
       WHERE c.bookkey = @v_bookkey and
             c.printingkey = @v_printingkey

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to insert data into associatedtitles 2 (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END

      -- Title History and Send to Eloquence
      SET @v_assoctypesubcode_desc = ltrim(rtrim(dbo.get_subgentables_desc(440,@v_reverse_assoctypecode,@v_reverse_assoctypesubcode,'long')))
      EXECUTE qtitle_update_titlehistory 'associatedtitles','isbn',@v_associatetitlebookkey,@v_printingkey,0,
                                         @v_main_productnumber,'insert',@v_userid,null,@v_assoctypesubcode_desc,
                                         @o_error_code output,@o_error_desc output
      
      IF @o_error_code < 0 BEGIN
        RETURN
      END
    END
  END 
  ELSE BEGIN
    -- associated title does not exist - just insert what we can into associatedtitle
    INSERT INTO associatedtitles 
           (bookkey,associationtypecode,associatetitlebookkey,sortorder,isbn,
            lastuserid,lastmaintdate,associationtypesubcode,productidtype)
    VALUES (@v_bookkey,@v_associationtypecode,@v_associatetitlebookkey,@v_sortorder,@v_productnumber,
            @v_userid,getdate(),@v_associationtypesubcode,@v_productidtype)

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to insert data into associatedtitles (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END

    -- Title History and Send to Eloquence
    SET @v_assoctypesubcode_desc = ltrim(rtrim(dbo.get_subgentables_desc(440,@v_associationtypecode,@v_associationtypesubcode,'long')))
    EXECUTE qtitle_update_titlehistory 'associatedtitles','isbn',@v_bookkey,@v_printingkey,0,
                                       @v_productnumber,'insert',@v_userid,null,@v_assoctypesubcode_desc,
                                       @o_error_code output,@o_error_desc output

    IF @o_error_code < 0 BEGIN
      RETURN
    END
  END
GO
GRANT EXEC ON qtitle_create_assoctitles TO PUBLIC
GO