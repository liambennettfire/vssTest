IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_bookmisc') AND type = 'TR')
  DROP TRIGGER dbo.core_bookmisc
GO

CREATE TRIGGER core_bookmisc ON bookmisc
FOR INSERT, UPDATE AS

DECLARE
  @v_bookkey INT,  
  @v_corecolnum TINYINT,
  @v_corecolumn VARCHAR(20),
  @v_coremisckey  INT,
  @v_datacode INT,
  @v_format VARCHAR(40),
  @v_misckey  INT,
  @v_misctype INT,
  @v_newfloat FLOAT,
  @v_newint  INT,
  @v_newstring  VARCHAR(255),
  @v_oldstring  VARCHAR(255),
  @v_quote CHAR(1),
  @v_valuesclause VARCHAR(2000),
  @v_sqlstring NVARCHAR(4000)

SET @v_valuesclause = ''
SET @v_quote = CHAR(39)

/** Cursor for Misc Items that should be displayed in search results **/
DECLARE miscfieldsetup_cur CURSOR FOR
  SELECT misckey, misctype, fieldformat, datacode, coretitlemisccolnumber 
  FROM bookmiscitems 
  WHERE coretitlemisccolnumber IS NOT NULL
  ORDER BY coretitlemisccolnumber		

OPEN miscfieldsetup_cur 

/** Get Misc Item setup values ***/
FETCH NEXT FROM miscfieldsetup_cur
INTO @v_coremisckey, @v_misctype, @v_format, @v_datacode, @v_corecolnum

WHILE (@@FETCH_STATUS = 0)
BEGIN

  /** Cursor for all modified bookmisc rows **/
  DECLARE bookmisc_cur CURSOR FOR
    SELECT i.bookkey, i.misckey, i.textvalue, i.longvalue, i.floatvalue
    FROM inserted i

  OPEN bookmisc_cur 

  FETCH NEXT FROM bookmisc_cur
  INTO @v_bookkey, @v_misckey, @v_newstring, @v_newint, @v_newfloat

  WHILE (@@FETCH_STATUS = 0)
  BEGIN

    IF @v_misckey = @v_coremisckey --yes, current search results Misc Item
    BEGIN
       
      -- Convert Float/Calculated value to string using the format from Misc Item Setup
      IF @v_misctype = 2 OR @v_misctype = 6 --Float or Calculated
      BEGIN        
        SET @v_newstring = dbo.qutl_format_string(@v_newfloat, @v_format)
      END

      -- Convert Numeric/Checkbox/Gentable value to string
      IF @v_misctype = 1 OR @v_misctype = 4 OR @v_misctype = 5
      BEGIN
        IF @v_misctype = 5	--Gentable
        BEGIN
          -- For Gentable drop-down, get gentable description as the new string value
          SELECT @v_newstring = datadesc
          FROM subgentables
          WHERE tableid = 525 AND
              datacode = @v_datacode AND
              datasubcode = @v_newint
        END 
        ELSE IF @v_misctype = 4 --Checkbox
        BEGIN
          -- For Check Box set 'Yes' or 'No' on coretitle
          IF @v_newint = 1
            SET @v_newstring = 'Yes'
          ELSE
            SET @v_newstring = 'No'
        END
        ELSE
        BEGIN
          -- Format Numeric value to string using the format from Misc Item Setup
          SET @v_newstring = dbo.qutl_format_string(@v_newint, @v_format)
        END
      END --END Numeric, Checkbox or Gentable

      SET @v_corecolumn = 'miscfield' + CONVERT(VARCHAR, @v_corecolnum)

      /*** Check if new value is different from that on coretitleinfo. ***/
      SET @v_sqlstring = N'SELECT @p_oldvalue = ' + @v_corecolumn +
        ' FROM coretitleinfo ' +
        ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_bookkey) + ' AND printingkey = 1'

      EXECUTE sp_executesql @v_sqlstring, 
        N'@p_oldvalue VARCHAR(255) OUTPUT', @v_oldstring OUTPUT


      -- If new value string differs from current coretitleinfo value, build update SQL
      -- If both values are the same (or both NULL), continue - nothing to do
      IF (@v_oldstring IS NULL AND @v_newstring IS NULL) OR (@v_oldstring = @v_newstring)
        GOTO FETCH_NEXT_CORECOLUMN
      ELSE
        BEGIN
          SET @v_newstring = REPLACE(@v_newstring, @v_quote, @v_quote + @v_quote)

          IF @v_valuesclause = ''
            IF @v_newstring IS NULL
				SET @v_valuesclause = @v_corecolumn + '= NULL'
            ELSE
				SET @v_valuesclause = @v_corecolumn + '=' + @v_quote + @v_newstring + @v_quote
          ELSE
			IF @v_newstring IS NULL
				SET @v_valuesclause = @v_valuesclause + 
				  ', ' + @v_corecolumn + '= NULL'
			ELSE
				SET @v_valuesclause = @v_valuesclause + 
				  ', ' + @v_corecolumn + '=' + @v_quote + @v_newstring + @v_quote				  
              
          GOTO FETCH_NEXT_CORECOLUMN
        END		

    END --IF @v_misckey = @v_coremisckey
    
    FETCH_NEXT_BOOKMISC:
    FETCH NEXT FROM bookmisc_cur
    INTO @v_bookkey, @v_misckey, @v_newstring, @v_newint, @v_newfloat
    
  END  /* bookmisc_cur LOOP*/
  
  FETCH_NEXT_CORECOLUMN:  
  CLOSE bookmisc_cur
  DEALLOCATE bookmisc_cur  
  
  FETCH NEXT FROM miscfieldsetup_cur
  INTO @v_coremisckey, @v_misctype, @v_format, @v_datacode, @v_corecolnum

END  /*miscfieldsetup_cur LOOP*/

/** Close the cursor **/
CLOSE miscfieldsetup_cur
DEALLOCATE miscfieldsetup_cur		

/*** Build the update statement ***/
IF @v_valuesclause <> ''
BEGIN
  SET @v_sqlstring = N'UPDATE coretitleinfo SET ' + 
    @v_valuesclause + ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_bookkey)

  EXECUTE sp_executesql @v_sqlstring
END
	
GO
