IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qtitle_update_titlehistory')
  BEGIN
    PRINT 'Dropping Procedure qtitle_update_titlehistory'
    DROP  Procedure  qtitle_update_titlehistory
  END

GO

PRINT 'Creating Procedure qtitle_update_titlehistory'
GO

CREATE PROCEDURE qtitle_update_titlehistory
 (@i_tablename          varchar(100),
  @i_columnname         varchar(100),
  @i_bookkey            integer,
  @i_printingkey        integer,
  @i_datetypecode       integer,
  @i_currentstringvalue varchar(255),
  @i_transtype          varchar(25),
  @i_userid             varchar(30),
  @i_historyorder       int,
  @i_fielddescdetail    varchar(120),
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output,
  @i_gentext1      varchar(255) = null)
AS

/******************************************************************************
**    Name: qtitle_update_titlehistory
**              
**    Input              
**    ----------         
**    tablename - Name of table where columnname is located - Required
**    columnname - Name of Column to get data to write to history  - Required
**    bookkey - bookkey of title writing to history - Required
**    printingkey - printingkey of title writing to history (First Printing will be assumed if 0) - Required
**    datetypecode - datetypecode of date for title writing to date history  - Pass 0 if not applicable
**    currentstringvalue - string version of data to be written to history - Required
**                        (NOTE: all datacode-like data should be translated prior to the call to this
**                         procedure and the description passed instead)
**    transtype - String that tells us what type of transaction caused the call to this procedure
**                (insert,update,delete) - Required
**    userid - Userid of user causing write to history - Required
**    
**    Output
**    -----------
**    error_code - error code
**    error_desc - error message - empty if No Error
**
**    Auth: Alan Katzen
**    Date: 4/26/04
**********************************************************************************
**    Change History
*************************************************************************************************
**    Date:       Author:        Description:
**    --------    --------        ---------------------------------------------------------------
**    03/22/2016   Kusum          Case 36980 File Location not Writing to Title History from Web         
**    09/28/2017   Colman         Case 46642 - Title history not written out to when propagating or copying Keywords
**    12/11/2017   Colman         Case 48598 - Title history not being written when editorial comment changed 
************************************************************************************************/

DECLARE
  @error_var    INT,
  @rowcount_var INT,
  @columnkey_var INT,
  @columnkey_multiples  INT,
  @columndesc_var VARCHAR(30),
  @datatype_var CHAR(1),
  @exporteloquenceind_var INT,
  @workfieldind_var INT,
  @setind_var INT,
  @lastmaintdate_var DATETIME,
  @lastuserid_var VARCHAR(30),
  @datekey_var INT,
  @fielddesc_length INT,
  @currentvalue_length INT,
  @datestage_var TINYINT,
  @fielddesc_var VARCHAR(80),
  @fielddesc_detail VARCHAR(80),
  @string_order VARCHAR(10),
  @currentstringvalue_var VARCHAR(255),
  @tempstring VARCHAR(255),
  @tempstring_length INT,
  @v_count INT,
  @v_datehistory_written tinyint,
  @v_commenttype_columnkey INT,
  @v_misctype INT,
  @v_misc_columnkey INT,
  @v_clientdefaultvalue INT,
  @v_dateformat_value VARCHAR(40),
  @v_dateformat_conversionvalue INT,
  @v_left INT,
  @v_right INT,
  @v_datacode INT,
  @v_stringvalue  VARCHAR(255),
  @v_ispriceupdate BIT,
  @v_templatekey INT,
  @v_assetkey INT,
  @v_metadatatypecode INT

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- verify tablename and columnname are filled in
  IF @i_tablename IS NULL OR ltrim(rtrim(@i_tablename)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update history: tablename is empty.'
    RETURN
  END 

  IF lower(@i_tablename) = 'filelocation' AND (@i_bookkey IS NULL OR @i_bookkey = 0) BEGIN
    -- not an error - filelocation is not just for titles anymore
    SET @o_error_code = 0
    SET @o_error_desc = ''
    RETURN
  END
  
  IF lower(@i_tablename) = 'qsicomments' AND (@i_bookkey IS NULL OR @i_bookkey = 0) BEGIN
    -- not an error - qsicomments is just for title citations
    SET @o_error_code = 0
    SET @o_error_desc = ''
    RETURN
  END    

  IF @i_columnname IS NULL OR ltrim(rtrim(@i_columnname)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update history: columnname is empty.'
    RETURN
  END 

  IF @i_tablename = 'bookkeywords'
  BEGIN
    IF LOWER(@i_transtype) = 'update'
      RETURN -- No such thing as a keyword update
  END

  SET @v_ispriceupdate = 0
  IF @i_gentext1 IS NOT NULL AND LEN(@i_gentext1) > 0 BEGIN
  IF LOWER(@i_tablename) = 'bookprice' --AND LOWER(@i_columnname) = 'pricetypecode'
  BEGIN
    SET @v_ispriceupdate = 1
  END

  IF @v_ispriceupdate = 1
  BEGIN
    SELECT TOP 1 @v_templatekey = templatekey
    FROM csdistributiontemplate
    WHERE eloquencefieldtag = @i_gentext1

    SELECT @v_assetkey = taqelementkey
    FROM taqprojectelement
    WHERE taqelementtypecode = (SELECT datacode FROM gentables WHERE tableid = 287 AND qsicode = 3)
      AND bookkey = @i_bookkey
  END
  END

--print @i_tablename
--print @i_columnname

  SELECT @v_count = count(*)
    FROM titlehistorycolumns
   WHERE tablename = @i_tablename AND 
         columnname = @i_columnname AND 
         activeind = 1 AND
         setind = 0

  IF @v_count <= 0 AND @i_columnname <> '(multiple)'
  BEGIN
    -- Not a history column - just return with no error
    SET @o_error_code = 0
    SET @o_error_desc = ''
    RETURN
  END 

 SET @v_datehistory_written = 0
 
  -- Cannot set columnkey based on history order - parse fielddesc instead
 SET @v_commenttype_columnkey = 0
 IF @i_tablename = 'bookcomments' AND @i_columnname = 'commentstring' BEGIN
   SET @fielddesc_var = SUBSTRING(@i_fielddescdetail, 1, 3) 
   IF @fielddesc_var = '(M)' BEGIN -- Marketing
     SET @v_commenttype_columnkey = 260
   END 
   ELSE IF @fielddesc_var = '(E)' BEGIN  -- Editorial
     SET @v_commenttype_columnkey = 261
   END 
   ELSE IF @fielddesc_var = '(T)' BEGIN  -- Title Notes
     SET @v_commenttype_columnkey = 70
   END 
   ELSE IF @fielddesc_var = '(P)' BEGIN  -- Publicity
     SET @v_commenttype_columnkey = 262
   END 
 END
 
 -- Determine misctype for title misc numeric value
 IF @i_tablename = 'bookmisc' AND @i_columnname = 'longvalue'
 BEGIN
  SELECT @v_misctype = misctype 
  FROM bookmiscitems 
  WHERE miscname = @i_fielddescdetail
  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @v_misctype = 0
  END
  
  SET @v_misc_columnkey = 0
  IF @v_misctype = 1
    SET @v_misc_columnkey = 225
  ELSE IF @v_misctype = 4
    SET @v_misc_columnkey = 247
  ELSE IF @v_misctype = 5
    SET @v_misc_columnkey = 248    
 END
 
 SET @columnkey_multiples = NULL
 IF @i_tablename = 'gentablesrelationshipdetail' AND @i_columnname = '(multiple)'
 BEGIN
   SET @columnkey_multiples = 276 --Country Grp Countries Updated
 END
 ELSE IF @i_tablename = 'territoryrights' AND @i_columnname = '(multiple)'
 BEGIN
   SET @columnkey_multiples = 272 --Title Territory Updated
 END
 ELSE IF @i_tablename = 'taqprojectrelationship' AND @i_columnname = '(multiple)'
 BEGIN
  IF LOWER(@i_transtype) = 'delete'
  BEGIN
    SET @columnkey_multiples = 274 --Work Removed to Contract
  END
  ELSE BEGIN
    SET @columnkey_multiples = 273 --Work Added to Contract
  END
 END
 ELSE IF @i_tablename = 'taqprojectrights' AND @i_columnname = '(multiple)'
 BEGIN
  SET @columnkey_multiples = 275 --Contract Territory Updated
 END
 
 DECLARE history_cur CURSOR FOR
  SELECT columnkey,columndescription,datatype,exporteloquenceind,
         workfieldind,setind  
    FROM titlehistorycolumns
   WHERE ((tablename = @i_tablename AND 
         columnname = @i_columnname) OR
         (columnkey IS NOT NULL AND
         columnkey = @columnkey_multiples)) AND 
         activeind = 1 AND
         setind = 0

--  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
--  IF @error_var <> 0 BEGIN
--    SET @o_error_code = -1
--    SET @o_error_desc = 'Unable to update history for table ' + @i_tablename + ' column ' + @i_columnname + ' (' + cast(@error_var AS VARCHAR) + ').'
--    RETURN
--  END 
--  IF @rowcount_var <= 0 BEGIN
--    -- Not a history column - just return with no error
--    SET @o_error_code = 0
--    SET @o_error_desc = ''
--    RETURN
--  END 

  OPEN history_cur
  FETCH history_cur INTO  @columnkey_var,@columndesc_var,
         @datatype_var,@exporteloquenceind_var,@workfieldind_var,@setind_var  

  WHILE @@fetch_status = 0 BEGIN
    -- History is kept for this column

    -- Continue to next row for Misc long values until correct columnkey is found
    IF @i_tablename = 'bookmisc' AND @i_columnname = 'longvalue'
      IF @v_misc_columnkey <> 0 AND @columnkey_var <> @v_misc_columnkey
        GOTO next_row

   --4/20/11 JL if bookmisc is being updated, pull sendtoeloquenceind from bookmisc, not titlehistorycolumns
        if @i_tablename = 'bookmisc'
        begin
               set @exporteloquenceind_var = 0
 
               select @exporteloquenceind_var = isnull(bm.sendtoeloquenceind, isnull(bmi.sendtoeloquenceind,0))
               from bookmiscitems bmi
               join bookmisc bm
               on bmi.misckey = bm.misckey
               where miscname = @i_fielddescdetail
               and bm.bookkey = @i_bookkey
        end
        
    -- verify that all other required values are filled in
    IF @i_userid IS NULL OR ltrim(rtrim(@i_userid)) = '' BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to update history: userid is empty.'
      goto finished
    END 

    IF @i_bookkey IS NULL OR @i_bookkey = 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to update history: bookkey is empty.'
      goto finished
    END 

    IF @i_transtype IS NULL OR ltrim(rtrim(@i_transtype)) = '' BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to update history: transtype is empty.'
      goto finished
    END 

    IF @i_printingkey IS NULL OR @i_printingkey = 0 BEGIN
      -- assume first printing if printingkey is not passed in
      SET @i_printingkey = 1
    END 

    IF @i_datetypecode IS NULL BEGIN
      -- datetypecode cannot be null
      SET @i_datetypecode = 0
    END 

    IF @i_datetypecode > 0 BEGIN
      
      -- datetypes have eloquence indicators, use them
      -- See netsuite case #05297
      SELECT @exporteloquenceind_var = ( select isNull(exporteloquenceind,0) from datetype where datetypecode = @i_datetypecode )  

      -- Date History
      IF @v_datehistory_written = 0 BEGIN
        -- generate datekey
        EXECUTE get_next_key @i_userid, @datekey_var OUTPUT
        IF @datekey_var IS NULL OR @datekey_var = 0 BEGIN
          -- Error
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to generate datekey.'
          goto finished
        END
      
        IF (lower(ltrim(rtrim(@i_columnname))) = 'activedate') BEGIN
          SET @datestage_var = 1
        END
        ELSE BEGIN
          SET @datestage_var = 2
        END

        IF (ltrim(rtrim(@i_currentstringvalue)) = '' or ltrim(rtrim(@i_currentstringvalue)) = 'NULL') BEGIN
          SET @i_currentstringvalue = null
        END 
      
        -- print @i_currentstringvalue
        
        IF @datatype_var = 'd' AND (COALESCE(@i_currentstringvalue, '') <> '') AND @i_currentstringvalue <> '(Not Present)' AND @i_currentstringvalue <> '(DELETED)'
        BEGIN
          SET @currentstringvalue_var = @i_currentstringvalue 
        
          SET @v_left = CHARINDEX('''', @currentstringvalue_var)
          SET @v_right = CHARINDEX('''', REVERSE(@currentstringvalue_var))
    
          IF (@v_left > 0 AND @v_right > 0) BEGIN
            SET @v_right = LEN(@currentstringvalue_var) - (@v_left) - (@v_right)
            SET @currentstringvalue_var = LTRIM(RTRIM(SUBSTRING(@currentstringvalue_var, @v_left + 1,@v_right)))
          END
        
          IF ISDATE(CONVERT(datetime,@currentstringvalue_var, 101)) = 1
          BEGIN        
             SELECT @i_currentstringvalue = CONVERT(datetime,@currentstringvalue_var, 101)
          END
        END           
      
        INSERT INTO datehistory (bookkey,datetypecode,datekey,printingkey,
                                  datechanged,lastuserid,lastmaintdate,datestagecode)
              VALUES (@i_bookkey,@i_datetypecode,@datekey_var,@i_printingkey,
                      @i_currentstringvalue,@i_userid,getdate(),@datestage_var)

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to insert into datehistory (' + cast(@error_var AS VARCHAR) + ').'
          goto finished
        END 
        
        SET @v_datehistory_written = 1
      END
    END
    ELSE BEGIN
      -- Title History
      IF @i_tablename = 'bookcomments' AND @i_columnname = 'commentstring' AND @columnkey_var <> @v_commenttype_columnkey
        goto next_row
      
      -- set field desc
      SET @fielddesc_var = @columndesc_var
      SET @string_order = CONVERT(VARCHAR, @i_historyorder)
      IF @string_order IS NULL
        SET @string_order = ''
      IF @i_fielddescdetail IS NULL
        SET @fielddesc_detail = ''
      ELSE
        SET @fielddesc_detail = LTRIM(RTRIM(@i_fielddescdetail))

      SET @fielddesc_length = LEN(@fielddesc_detail)
      SET @currentvalue_length = LEN(@i_currentstringvalue)
      IF @currentvalue_length > 0
        SET @tempstring_length = @fielddesc_length - @currentvalue_length
    
      SET @tempstring = RIGHT(@fielddesc_detail, @currentvalue_length)
    
--      IF UPPER(LTRIM(RTRIM(@tempstring))) = UPPER(@i_currentstringvalue)
--      BEGIN
--        IF @tempstring_length > 3
--          SET @fielddesc_detail = SUBSTRING(@fielddesc_detail, 1, @tempstring_length - 3)
--      END
-- As per discussion with Alan, commented code above does not make sense (Refer to Case 20437)

      IF @i_tablename = 'bookprice'
        SET @fielddesc_var = 'Price ' + @string_order
      ELSE IF @i_tablename = 'bookauthor'
        SET @fielddesc_var = 'Author ' + @string_order
      ELSE IF @i_tablename = 'bookbisaccategory'
        SET @fielddesc_var = 'Category ' + @string_order
      ELSE IF @i_tablename = 'booksubjectcategory'
        SET @fielddesc_var = 'Subject ' + @string_order
      ELSE IF @i_tablename = 'bookproductdetail'
        SET @fielddesc_var = 'Product ' + @string_order        
      ELSE IF @i_tablename = 'citation'
        SET @fielddesc_var = 'Citation ' + @string_order
      ELSE IF @i_tablename = 'filelocation' AND @i_historyorder > 0
        SET @fielddesc_var = 'File ' + @string_order
      ELSE IF @i_tablename = 'filelocation' AND (@i_historyorder IS NULL OR @i_historyorder = 0)
        SET @fielddesc_var = 'File ' 
      ELSE IF @i_tablename = 'bookcontributor'
        SET @fielddesc_var = 'Contributor ' + @string_order
      ELSE IF @i_tablename = 'bookqtybreakdown'
        SET @fielddesc_var = 'Qty Breakdown ' + @string_order
      ELSE IF @i_tablename = 'bookaudience'
        SET @fielddesc_var = 'Audience ' + @string_order
      ELSE IF @i_tablename = 'qsicomments'
        SET @fielddesc_var = 'Citation Comment ' + @string_order
    
      -- add field description detail if nonblank
      IF @fielddesc_detail <> ''
        -- No need to append detail to fielddesc for:
        -- Author Name, Price Type, BISAC Heading, Subject Category
        IF @i_tablename = 'bookauthor' AND @i_columnname = 'authorkey'
          SET @fielddesc_var = @fielddesc_var
        ELSE IF @i_tablename = 'bookprice' AND @i_columnname = 'pricetypecode'
          SET @fielddesc_var = @fielddesc_var
        ELSE IF @i_tablename = 'bookbisaccategory' AND @i_columnname = 'bisaccategorycode'
          SET @fielddesc_var = @fielddesc_var
        ELSE IF @i_tablename = 'bookbisaccategory' AND @i_columnname = 'bisaccategorysubcode' 
          SET @fielddesc_var = @fielddesc_var
        ELSE IF @i_tablename = 'booksubjectcategory' AND @i_columnname = 'categorycode'
          SET @fielddesc_var = @fielddesc_var
        ELSE IF @i_tablename = 'bookproductdetail' AND @i_columnname = 'datacode'
          SET @fielddesc_var = @fielddesc_var          
        ELSE IF @i_tablename = 'bookorgentry' OR @i_tablename = 'bookcomments'
          SET @fielddesc_var = @fielddesc_detail
        ELSE IF @i_tablename = 'associatedtitles' AND @i_columnname = 'isbn'
          SET @fielddesc_var = @fielddesc_detail
        ELSE IF @i_tablename = 'bookdetail' AND @i_columnname = 'mediatypesubcode'
          SET @fielddesc_var = @fielddesc_detail
        ELSE IF @i_tablename = 'bookmisc'
          SET @fielddesc_var = @i_fielddescdetail
        ELSE IF @i_tablename = 'bookkeywords'
          SET @fielddesc_var = @i_fielddescdetail
        ELSE
          SET @fielddesc_var = @fielddesc_var + ' - ' + @fielddesc_detail
   
      SET @currentstringvalue_var = ''
      IF lower(ltrim(rtrim(@i_transtype))) = 'delete'
      BEGIN
        SET @currentstringvalue_var = '(DELETED)'
      END
      
      IF ltrim(rtrim(@i_currentstringvalue)) = 'NULL' BEGIN
        SET @i_currentstringvalue = null
      END 

      IF @i_currentstringvalue IS NULL OR ltrim(rtrim(@i_currentstringvalue)) = '' BEGIN
        IF lower(ltrim(rtrim(@i_transtype))) = 'delete'
        BEGIN    
          -- Append detail to deleted rows that had no additional detail info appended to fielddesc above
          IF (@i_tablename = 'bookauthor' AND @i_columnname = 'authorkey') OR
            (@i_tablename = 'bookprice' AND @i_columnname = 'pricetypecode') OR
            (@i_tablename = 'bookbisaccategory' AND @i_columnname = 'bisaccategorycode') OR
            (@i_tablename = 'bookbisaccategory' AND @i_columnname = 'bisaccategorysubcode') OR
            (@i_tablename = 'booksubjectcategory' AND @i_columnname = 'categorycode') OR
            (@i_tablename = 'qsicomments' AND @i_columnname = 'commenttext') OR
            (@i_tablename = 'bookproductdetail' AND @i_columnname = 'datacode') OR 
            (@i_tablename = 'bookproductdetail' AND @i_columnname = 'datasubcode') OR    
            (@i_tablename = 'bookproductdetail' AND @i_columnname = 'datasub2code')                                  
            BEGIN
              SET @currentstringvalue_var = @currentstringvalue_var + ' - ' + @fielddesc_detail
            END
        END
        ELSE BEGIN
          SET @currentstringvalue_var = '(Not Present)'
        END
      END 
      ELSE BEGIN  
        IF lower(ltrim(rtrim(@i_columnname))) = 'releasetoeloquenceind' OR 
           lower(ltrim(rtrim(@i_columnname))) = 'proofedind' OR 
           lower(ltrim(rtrim(@i_columnname))) = 'webind' OR
           (lower(ltrim(rtrim(@i_columnname))) = 'longvalue' AND @i_tablename = 'bookmisc' AND @v_misctype = 4) BEGIN

          IF ltrim(rtrim(@i_currentstringvalue)) = '1'
            SET @currentstringvalue_var = 'Y'
          ELSE
            SET @currentstringvalue_var = 'N'
        END 
        ELSE BEGIN
          IF (lower(ltrim(rtrim(@i_columnname)))) = 'commenttext' AND @i_tablename = 'qsicomments' 
            SET @currentstringvalue_var = @currentstringvalue_var
          ELSE IF @currentstringvalue_var = ''
             SET @currentstringvalue_var = @i_currentstringvalue
          ELSE
            SET @currentstringvalue_var = @currentstringvalue_var + ' - ' + @i_currentstringvalue
        END
      END

      SET @lastmaintdate_var = getdate()
     
    --PRINT 'bk=' + CONVERT(VARCHAR, @i_bookkey) + ', pk=' + CONVERT(VARCHAR, @i_printingkey) + ', columnkey=' + CONVERT(VARCHAR, @columnkey_var)
    --PRINT 'fielddesc=' + @fielddesc_var
    --PRINT 'currstingvalue=' + @currentstringvalue_var
    --PRINT 'lastmaintdate=' + CONVERT(VARCHAR, @lastmaintdate_var, 9)    
      
      IF @currentstringvalue_var IS NULL OR @currentstringvalue_var = '' OR @currentstringvalue_var = '(Not Present)'
      BEGIN
        IF @i_tablename = 'gentablesrelationshipdetail' AND @i_columnname = '(multiple)'
        BEGIN
          SET @currentstringvalue_var = 'Titles affected by Country Group to Country change'
        END
        ELSE IF @i_tablename = 'territoryrights' AND @i_columnname = '(multiple)'
        BEGIN
          SET @currentstringvalue_var = 'Titles affected by Territory Rights change'
        END
        ELSE IF @i_tablename = 'qsicomments' AND @i_columnname = 'commenttext'
        BEGIN
           SET @currentstringvalue_var = 'Citation Comment'
        END
      END
      
      IF @i_tablename = 'book' AND @i_columnname = 'workkey' AND @columnkey_var = 268  AND ISNUMERIC(@currentstringvalue_var) = 1  BEGIN
        IF EXISTS (SELECT * FROM isbn WHERE bookkey = @currentstringvalue_var) BEGIN
          SELECT @currentstringvalue_var = COALESCE(ean, '(Not Present)') FROM isbn WHERE bookkey = @currentstringvalue_var
        END
        ELSE BEGIN 
          SET @currentstringvalue_var = '(Not Present)'
        END 
      END
      
      IF @datatype_var = 'd' AND (COALESCE(@currentstringvalue_var, '') <> '') AND @currentstringvalue_var <> '(Not Present)' AND @currentstringvalue_var <> '(DELETED)'
      BEGIN
        SELECT @v_clientdefaultvalue = COALESCE(CAST(clientdefaultvalue AS INT), 1) FROM clientdefaults WHERE clientdefaultid = 79    
        SELECT @v_dateformat_value = LTRIM(RTRIM(UPPER(datadesc))), @v_datacode = datacode  FROM gentables WHERE tableid = 607 AND qsicode = @v_clientdefaultvalue
        SELECT @v_dateformat_conversionvalue = CAST(COALESCE(gentext2, '101') AS INT) FROM gentables_ext WHERE tableid = 607 AND datacode = @v_datacode      
        
        SET @v_left = CHARINDEX('''', @currentstringvalue_var)
        SET @v_right = CHARINDEX('''', REVERSE(@currentstringvalue_var))
    
        IF (@v_left > 0 AND @v_right > 0) BEGIN
          SET @v_right = LEN(@currentstringvalue_var) - (@v_left) - (@v_right)
          SET @currentstringvalue_var = LTRIM(RTRIM(SUBSTRING(@currentstringvalue_var, @v_left + 1,@v_right)))
        END
        
        IF ISDATE(CONVERT(datetime,@currentstringvalue_var, 101)) = 1
        BEGIN        
           SELECT @currentstringvalue_var = CONVERT(VARCHAR(255), CONVERT(datetime, @currentstringvalue_var, 101), @v_dateformat_conversionvalue)                          
        END
      END 
    
      -- Get the previous history row info for row
      IF @i_tablename = 'bookmisc'
      BEGIN
        --46568: bookmisc columnkey could represent a wide variety of things, so also need fielddesc here to differentiate
        SELECT @v_count = COUNT(*)
        FROM titlehistory
        WHERE bookkey = @i_bookkey AND columnkey = @columnkey_var AND fielddesc = @fielddesc_var
      END
      ELSE IF @i_tablename = 'bookkeywords'
      BEGIN
        SET @v_count = 0
      END
      ELSE BEGIN
        SELECT @v_count = COUNT(*)
        FROM titlehistory
        WHERE bookkey = @i_bookkey AND columnkey = @columnkey_var
      END
    
      IF @v_count > 0
      BEGIN
        IF @i_tablename IN ('bookmisc', 'bookcomments')
        BEGIN
          --46568: bookmisc columnkey could represent a wide variety of things, so also need fielddesc here to differentiate
          SELECT top 1 @v_stringvalue = currentstringvalue
          FROM titlehistory 
          WHERE bookkey = @i_bookkey AND columnkey = @columnkey_var AND fielddesc = @fielddesc_var
          ORDER BY lastmaintdate DESC
        END
        ELSE BEGIN
          SELECT top 1 @v_stringvalue = currentstringvalue
          FROM titlehistory 
          WHERE bookkey = @i_bookkey AND columnkey = @columnkey_var
          ORDER BY lastmaintdate DESC
        END

        IF @v_stringvalue IS NULL
        BEGIN
          SET @v_stringvalue = '(Not Present)'
        END
      END
      ELSE IF @i_tablename = 'bookkeywords'
      BEGIN
        IF LOWER(@i_transtype) = 'delete'
        BEGIN
          SET @currentstringvalue_var = '(DELETED) - ' + @i_currentstringvalue
          SET @v_stringvalue = @i_currentstringvalue
        END
        ELSE IF LOWER(@i_transtype) = 'insert'
        BEGIN
          SET @currentstringvalue_var = @i_currentstringvalue
          SET @v_stringvalue = '(Not Present)'
        END
      END
      ELSE BEGIN
        SET @v_stringvalue = '(Not Present)'
      END
    
    --TODO: If price type has a template elofieldtag in gentext1 then write title history as normal but don't update metadata last update date...?
      
      IF 
      (
        (    (@i_tablename = 'bookcomments' AND @i_columnname = 'commentstring') -- comments may exceed 255 characters and cannot be meaningfully compared
          OR (ISNULL(@currentstringvalue_var, '') <> ISNULL(@v_stringvalue, ''))
        )
        AND NOT (ISNULL(@currentstringvalue_var, '') = '(Not Present)' AND ISNULL(@v_stringvalue, '') = '(DELETED)')
        AND NOT (ISNULL(@currentstringvalue_var, '') = '(DELETED)' AND ISNULL(@v_stringvalue, '') = '(Not Present)')
      )
      BEGIN
        INSERT INTO titlehistory (bookkey,printingkey,columnkey,lastmaintdate,
               lastuserid,currentstringvalue,stringvalue,fielddesc, history_order)
        VALUES (@i_bookkey,@i_printingkey,@columnkey_var,@lastmaintdate_var,
               @i_userid,@currentstringvalue_var,@v_stringvalue,@fielddesc_var, @i_historyorder)

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to insert into titlehistory (' + cast(@error_var AS VARCHAR) + ').'
          goto finished
        END
      END

    --write a row to a new "schedule for re-send" table for the bookkey, template, and assetkey (for the metadata asset). This is the “Custom Re-Send outbox”
    IF @v_ispriceupdate = 1 AND COALESCE(@i_bookkey, 0) > 0 AND COALESCE(@v_templatekey, 0) > 0 AND COALESCE(@v_assetkey, 0) > 0
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM cloudscheduleforresend
      WHERE bookkey = @i_bookkey
        AND templatekey = @v_templatekey
      AND assetkey = @v_assetkey
      
      IF @v_count = 0
      BEGIN
        INSERT INTO cloudscheduleforresend
        (bookkey, templatekey, assetkey, lastuserid, lastmaintdate)
        VALUES
        (@i_bookkey, @v_templatekey, @v_assetkey, @i_userid, GETDATE())
      END
    END
    END -- Title History
    
    IF @i_tablename = 'bookcomments' AND EXISTS(SELECT * FROM subgentables WHERE tableid = 284 AND qsicode = 7) AND LEN(@i_fielddescdetail) >= 3 BEGIN
      IF SUBSTRING(@i_fielddescdetail, 1, 3) = '(G)' BEGIN
        SET @exporteloquenceind_var = 0
      END
    END       
  
    IF @exporteloquenceind_var = 1 BEGIN
      -- update bookedistatus
      EXECUTE qtitle_update_bookedistatus @i_bookkey, @i_printingkey, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
      IF @o_error_code < 0 BEGIN
        -- Error
        SET @o_error_code = -1
        --SET @o_error_desc = 'Unable to update bookedistatus.'
        goto finished
      END
    END

    IF @exporteloquenceind_var = 1 AND @v_ispriceupdate <> 1 BEGIN
       -- update bookdetail
       EXECUTE qtitle_update_bookdetail_csmetadatastatuscode @i_bookkey,  @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
       IF @o_error_code < 0 BEGIN
          -- Error
          SET @o_error_code = -1
          --SET @o_error_desc = 'Unable to update csmetadatastatuscode on bookdetail(' + cast(@error_var AS VARCHAR) + ').'
          goto finished
       END
    END

    next_row:
    FETCH history_cur INTO  @columnkey_var,@columndesc_var,
           @datatype_var,@exporteloquenceind_var,@workfieldind_var,@setind_var  
  END

  finished:
  CLOSE history_cur 
  DEALLOCATE history_cur
  RETURN
  
END 
GO

GRANT EXEC ON qtitle_update_titlehistory TO PUBLIC
GO
