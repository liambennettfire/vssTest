PRINT 'STORED PROCEDURE : insert_or_update_title_from_onix_product'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'insert_or_update_title_from_onix_product')
	BEGIN
		PRINT 'Dropping Procedure insert_or_update_title_from_onix_product'
		DROP  Procedure  insert_or_update_title_from_onix_product
	END

GO

PRINT 'Creating Procedure insert_or_update_title_from_onix_product';
GO

CREATE Procedure insert_or_update_title_from_onix_product
(
  @i_onix_product                       text,
  @i_onix_header                        text,
  @i_onix_filename                      varchar(100),  -- Must be specified so that we can log information about the import.
  @i_lowest_level_orgentry_key          int ,  -- If specified, it will determine where the book it entered.
  @i_level_1_orgentry_key               int ,  -- If specified, all other keys must correspond and items looked up must also be valid with respect to this key.
  @i_onix_file_datetime                 datetime = null,
  @i_imprint_org_level                  int = null,
  @i_imprint_orgentry_key               int = null,
  @i_create_imprint_if_needed           bit = 0,
  @i_publisher_org_level                int = null,
  @i_publisher_orgentry_key             int = null,
  @i_create_publisher_if_needed         bit = 0,
  @i_force_title_overwrite              bit = 0, -- Even if current owner is not the same.
  @i_publish_to_web                     bit = 1,
  @i_create_rtf_from_plain_text     	bit = 0,
  @i_check_and_update_customerauthor    bit = 0,
  @i_user                               varchar(30) = 'ONIX product import', -- Support for the last user column.
  @o_error_code                         int out,
  @o_error_desc                         varchar(2000) out 
)
AS

/******************************************************************************
** File: insert_or_update_title_from_onix_product.sql
** Name: insert_or_update_title_from_onix_product
** Desc: This stored procedure does not take in a complete
**       ONIX document.  It only takes in a product
**       record since that is what is needed in most
**       cases. 
**
** Last intErr = 524288
**
** Auth: James P. Weber
** Date: 04 Jul 2003
*******************************************************************************/

BEGIN
  SET NOCOUNT ON;
  DECLARE @intErr INT;
  DECLARE @intRowcount INT;
  DECLARE @intHeaderDoc INT;
  DECLARE @intDoc INT;
  DECLARE @bolOpen BIT;
  DECLARE @bolHeaderOpen BIT;
  DECLARE @bolTransactionStarted BIT;
  DECLARE @sp_return_value INT;
  DECLARE @temp_error_code INT;
  DECLARE @temp_error_desc varchar(2000);
  DECLARE @FilterOrgLevlKey int;
  DECLARE @summary_error   varchar(4000); 

  SET @intErr = 0;
  SET @o_error_desc = 'HELLO WORLD';

  -- DEBUG
  --PRINT 'Start';
  
  -- DO THIS OUTSIDE THE TRANSACTION SO THAT WE HAVE A RECORD OF THE ATTEMPT.  THE
  -- INITIAL VALUES HERE WILL BE LEFT IN PLACE IF AN EXCEPTION HAPPENS THAT
  -- IS NOT CAUGHT BY TH END.
  DECLARE @file_key int;
  exec next_generic_key null, @file_key output, @temp_error_code output, @temp_error_desc output;
  if (@file_key is not null) 
  BEGIN
    INSERT INTO importfileprocesslog (filekey, filename, filedatetime, customerid, starttime, messagetext, filestatus,  lastuserid, lastmaintdate) 
      VALUES (@file_key, @i_onix_filename, @i_onix_file_datetime, CONVERT(varchar, @i_publisher_orgentry_key), GETDATE(), 'EXCEPTION DURING PROCESSING', 0, @i_user, GETDATE());
  END

  -- This will be set as soon as we get to the point
  -- where the transaction for this import is stared.
  -- We do not want to start it too soon since we may
  -- never do anthing of interest and we don't want
  -- to slow down the system for nothing.
  SET @bolTransactionStarted = 0
  SET @o_error_code = -1;
  SET @o_error_desc = 'Unspecfied Error : ';
  SET @summary_error = '1:';

  -- Validate defaults
  if @i_create_imprint_if_needed is null SET @i_create_imprint_if_needed  = 0
  if @i_create_publisher_if_needed is null SET @i_create_publisher_if_needed  = 0
  if @i_force_title_overwrite is null SET @i_force_title_overwrite  = 0
  if @i_user is null SET @i_user  = 'ONIX product import'
  if @i_publish_to_web is null SET @i_publish_to_web  = 1
  if @i_create_rtf_from_plain_text is null SET @i_create_rtf_from_plain_text = 0;
  if @i_check_and_update_customerauthor is null SET @i_check_and_update_customerauthor = 0;
  
  SET @summary_error = @summary_error + '2:'

  -- In order to know that we have the ability to completely
  -- enter a book into the system, it must exist in the book org entry
  -- table at all levels.  This means that the title belongs to a specific 
  -- organization at the lowest level.  To that end we need 
  DECLARE @numorglevels INT
  SELECT @numorglevels = max(orglevelkey) from orglevel
  --PRINT 'Organization levels = ' + CONVERT(varchar, @numorglevels) 

  -- Get the publisher level if it is not specified.
  if (@i_publisher_org_level is null)
  BEGIN
     -- WARNING MAGIC NUMBER : key to filterorglevel (May eventually want to make this generic to the db and not eloquence specific)
    SELECT @i_publisher_org_level = filterorglevelkey from filterorglevel where filterkey = 18;
  END
  --PRINT 'Publisher Org Level = ' + CONVERT(varchar(100), @i_publisher_org_level)

  -- Get imprint level if it is not specified.
  if (@i_imprint_org_level is null)
  BEGIN
    -- WARNING MAGIC NUMBER : key to filterorglevel (May eventually want to make this generic to the db and not eloquence specific)
    SELECT @i_imprint_org_level = filterorglevelkey from filterorglevel where filterkey = 19;
  END
  --PRINT 'Imprint Org Level   = ' + CONVERT(varchar(100), @i_imprint_org_level)
  SET @summary_error = @summary_error + '3:';
  IF @i_imprint_org_level is not null SET @summary_error = @summary_error + 'Imprint Org Level : ' + CONVERT(varchar(100), @i_imprint_org_level) + ' : ';
  
  --print len(@summary_error);
  -- Verify that we have the information needed to be able to run the stored
  -- procedure.
  if (@i_lowest_level_orgentry_key is null)
  BEGIN
    IF (@numorglevels > @i_imprint_org_level)
    BEGIN
      --print 'The imprint is not at the lowest level of the , a specific organization for the insert must be specified.';
      SET @intErr = @intErr + 1;
      SET @summary_error = @summary_error + 'The imprint is not at the lowest level of the organization, a specific organization for the insert must be specified. ';
      GOTO ExitHandler
    END

    IF (@i_imprint_org_level - @i_publisher_org_level > 1)
    BEGIN
      --print 'Without a specified insert location the imprint must be one level below or the same as the publisher in order to have a valid title import.';
      SET @intErr = @intErr + 2;
      SET @summary_error = @summary_error + 'Without a specified insert location the imprint must be one level below or the same as the publisher in order to have a valid title import. ';
      GOTO ExitHandler
    END
  END
   
  SET @bolOpen = 0;
  EXEC sp_xml_preparedocument @intDoc OUTPUT, @i_onix_product

  IF @@ERROR <> 0 BEGIN
      --print 'Error loading the onix product record.';
      SET @intErr = @intErr +4;
      SET @summary_error = @summary_error + 'Error loading the onix product record.:';
      GOTO ExitHandler
  END
  SET @bolOpen = 1;
  
  SET @bolHeaderOpen = 0;
  if (@i_onix_header is not null)
  BEGIN
    EXEC sp_xml_preparedocument @intHeaderDoc OUTPUT, @i_onix_header

    IF @@ERROR <> 0 BEGIN
      --print 'Error loading the onix header record.';
      SET @intErr = @intErr + 8;
      SET @summary_error = @summary_error + 'Error loading the onix header record.:';
      GOTO ExitHandler
    END
    SET @bolHeaderOpen = 1;
  END 
  
  -- DEBUG CODE
  SET @summary_error = @summary_error + '4: ';
  -- END DEBUG CODE

  -- If the header information is available, read the possible default values, if they are 
  -- not available, make sure to set up default values that are reasonable for the use
  -- of this stored procedure by Quality Solutions.
  DECLARE @FromPerson_m175                 varchar(300);
  DECLARE @DefaultLanguageOfText_m184      varchar(3);
  DECLARE @DefaultPriceTypeCode_m185       varchar(2);
  DECLARE @DefaultCurrencyCode_m186        varchar(3);
  DECLARE @DefaultLinearUnit_m187          varchar(2);
  DECLARE @DefaultWeightUnit_m188          varchar(2);
  DECLARE @DefaultClassOfTrade_m193        varchar(100);

  if (@bolHeaderOpen = 1)
  BEGIN
  SELECT @FromPerson_m175 = fromperson, 
         @DefaultLanguageOfText_m184=defaultlanguageoftext, 
         @DefaultPriceTypeCode_m185=defaultpricetypecode, 
         @DefaultCurrencyCode_m186=defaultcurrencycode, 
         @DefaultLinearUnit_m187=defaultlinearunit, 
         @DefaultWeightUnit_m188=defaultweightunit, 
         @DefaultClassOfTrade_m193=defaultclassoftrade
  FROM OPENXML(@intHeaderDoc,  '/')
  WITH (fromperson            varchar(300) '//m175', 
        defaultlanguageoftext varchar(3)   '//m184', 
        defaultpricetypecode  varchar(2)   '//m185',  
        defaultcurrencycode   varchar(3)   '//m186', 
        defaultlinearunit     varchar(2)   '//m187', 
        defaultweightunit     varchar(2)   '//m188', 
        defaultclassoftrade   varchar(100) '//m193');

  END

  IF @FromPerson_m175             is null Set @FromPerson_m175 = '';
  IF @DefaultLanguageOfText_m184  is null Set @DefaultLanguageOfText_m184 = 'eng';
  IF @DefaultPriceTypeCode_m185   is null Set @DefaultPriceTypeCode_m185 = '01';
  IF @DefaultCurrencyCode_m186    is null Set @DefaultCurrencyCode_m186 = 'USD';
  IF @DefaultLinearUnit_m187      is null Set @DefaultLinearUnit_m187 = 'in';
  IF @DefaultWeightUnit_m188      is null Set @DefaultWeightUnit_m188 = 'lb';
  IF @DefaultClassOfTrade_m193    is null Set @DefaultClassOfTrade_m193 = '';

  --PRINT '@FromPerson_m175';
  --PRINT @FromPerson_m175;
  --PRINT '@DefaultLanguageOfText_m184';
  --PRINT @DefaultLanguageOfText_m184;
  --PRINT '@DefaultPriceTypeCode_m185';
  --PRINT @DefaultPriceTypeCode_m185;
  --PRINT '@DefaultCurrencyCode_m186';
  --PRINT @DefaultCurrencyCode_m186;
  --PRINT '@DefaultLinearUnit_m187';
  --PRINT @DefaultLinearUnit_m187;
  --PRINT '@DefaultWeightUnit_m188';
  --PRINT @DefaultWeightUnit_m188;
  --PRINT '@DefaultClassOfTrade_m193';
  --PRINT @DefaultClassOfTrade_m193;
  SET @summary_error = @summary_error + '5:';
  SET @o_error_desc = '5 : ';


  -- Basic information about the book/title needed to get started with 
  -- the title import process.
  DECLARE @Notification_Type_a002 as varchar(2);
  DECLARE @ISBN10_b004 as varchar(15);
  DECLARE @ProductForm_b012 as varchar(2);
  DECLARE @Title_b028 as varchar(300);
  DECLARE @SubTitle_b029 as varchar(300);
  DECLARE @TitlePrefix_b030 as varchar(50);
  DECLARE @TitleWithoutPrefix_b031 as varchar(300);
  DECLARE @ImprintName_b079 as varchar(100);
  DECLARE @PublisherName_b081 as varchar(100);
  DECLARE @PublicationDate_b003 as varchar(8);
--  DECLARE @PublicationYear as varchar(4);
  DECLARE @PublicationMonth as varchar(2);
--  DECLARE @PublicationDay   as varchar(2);
  DECLARE @IllustrationsNote_b062 as varchar(200);
  DECLARE @NumberOfPages_b061 as int;
  DECLARE @Height_c096 as varchar(10);
  DECLARE @Width_c097 as varchar(10);
  DECLARE @LanguageOfText_b059 as varchar(3);
  DECLARE @BASICMainSubject_b064 as varchar(9);
  
  
  -- Get it out for use in the stored procedure as a whole.
  SELECT @Notification_Type_a002 = notificationtype, 
         @ISBN10_b004=isbn, 
         @ProductForm_b012=productform, 
         @Title_b028=title, 
         @SubTitle_b029=subtitle, 
         @TitlePrefix_b030=titleprefix, 
         @TitleWithoutPrefix_b031=titlewithoutprefix, 
         @ImprintName_b079 = imprintname, 
         @PublisherName_b081=publishername,
         @PublicationDate_b003=publicationdate,
         @IllustrationsNote_b062 = illustrationsnote,
         @NumberOfPages_b061 = numberofpages,
         @Height_c096 = height,
         @Width_c097 = width,
         @LanguageOfText_b059 = languageoftext,
         @BASICMainSubject_b064 = basicmainsubject
  FROM OPENXML(@intDoc,  '/product')
  WITH (notificationtype varchar(2) 'a002', 
        isbn varchar(15) 'b004', 
        productform varchar(2) 'b012',  
        title varchar(300) 'b028', 
        subtitle varchar(300) 'b029', 
        titleprefix varchar(50) 'b030', 
        titlewithoutprefix varchar(300) 'b031', 
        imprintname varchar(100) '//b079', 
        publishername varchar(100) '//b081',
        publicationdate varchar(8) 'b003',
        illustrationsnote varchar(200) 'b062',
        numberofpages int 'b061',
        height varchar(10) 'c096',
        width varchar(10) 'c097',
        languageoftext varchar(23) 'b059',
        basicmainsubject varchar(9) 'b064');

  -- RESULTS FOR DEBUGGING.
  --PRINT '@Notification_Type_a002';
  --PRINT @Notification_Type_a002;
  --PRINT '@ISBN10_b004';
  --PRINT @ISBN10_b004;
  --PRINT '@ProductForm_b012';
  --PRINT @ProductForm_b012;
  --PRINT '@Title_b028';
  --PRINT @Title_b028;
  --PRINT '@SubTitle_b029';
  --PRINT @SubTitle_b029;
  --PRINT '@TitlePrefix_b030';
  --PRINT @TitlePrefix_b030;
  --PRINT '@TitleWithoutPrefix_b031';
  --PRINT @TitleWithoutPrefix_b031;
  --PRINT '@ImprintName_b079';
  --PRINT @ImprintName_b079;
  --PRINT '@PublisherName_b081';
  --PRINT @PublisherName_b081;
  --PRINT '@PublicationDate_b003';
  --PRINT @PublicationDate_b003;
  --PRINT '@IllustrationsNote_b062';
  --PRINT @IllustrationsNote_b062;
  --PRINT '@NumberOfPages_b061';
  --PRINT @NumberOfPages_b061;
  --PRINT '@Height_c096';
  --PRINT @Height_c096;
  --PRINT '@Width_c097';
  --PRINT @Width_c097;
  --PRINT '@LanguageOfText_b059';
  --PRINT @LanguageOfText_b059;
  --PRINT '@BASICMainSubject_b064';
  --PRINT @BASICMainSubject_b064;
  
  SET @summary_error = @summary_error + '6:';

  --
  -- Create the date from the date peices.
  --
  DECLARE @PublicationDate datetime;
  SET @PublicationDate = null;
 
  if (@PublicationDate_b003 is not null)
  BEGIN
    SET @PublicationMonth =  SUBSTRING(@PublicationDate_b003, 5, 2);
    SET @PublicationDate = dbo.date_from_onix_datestring(@PublicationDate_b003);
    --PRINT '@PublicationDate'
    --PRINT @PublicationDate
  END
   
  -- Transfer some data so that the title has the main portion of the information.
  -- 
  if (@TitlePrefix_b030 is not null)
  BEGIN
    SET @Title_b028 = @TitleWithoutPrefix_b031;
  END 

  if (LTRIM(@TitlePrefix_b030) = '')
  BEGIN
    SET @TitlePrefix_b030 = null;
  END

  -- Test
  --PRINT 'Organization Processing';
  --PRINT '';

  -- Find the publisher organization if it was
  -- not specified by the call.
  if (@i_publisher_orgentry_key is null)
  BEGIN
    --PRINT 'TRYING TO Find the publisher organization'
    if (@i_level_1_orgentry_key is null)
    BEGIN
      SELECT @i_publisher_orgentry_key = oe.orgentrykey
        from orgentry oe where oe.orgentrydesc=@PublisherName_b081
                             and oe.orglevelkey=@i_publisher_org_level 
    END
    ELSE
    BEGIN 
      DECLARE @existing_orgentry_key int;
      --print 'Parameters'
      --print @i_level_1_orgentry_key;
      --print @PublisherName_b081;
      --print 'exec orgentry_find_child_of_by_description';

      exec @sp_return_value = orgentry_find_child_of_by_description @i_level_1_orgentry_key, @PublisherName_b081, @existing_orgentry_key out, @temp_error_code out, @temp_error_desc out
      --print '@existing_orgentry_key'
      --print @existing_orgentry_key
      if (@existing_orgentry_key is not null)
      BEGIN
        SET @i_publisher_orgentry_key = @existing_orgentry_key;
      END
    END

    -- Test
    --PRINT '@i_publisher_orgentry_key = ' + CONVERT(varchar, @i_publisher_orgentry_key)
  END
  ELSE
  BEGIN
    --PRINT 'PUBLISHER GIVEN'
    --PRINT '@i_publisher_orgentry_key = ' + CONVERT(varchar, @i_publisher_orgentry_key)
    --if (@i_level_1_orgentry_key is not null)
    --BEGIN
    --  PRINT 'The publisher must be a child of the given level 1 organization.'
    --END
    
    -- Verify that the organization entry exists.
    DECLARE @l_temp_org_level_key int;
    SELECT @l_temp_org_level_key = orglevelkey from orgentry where orgentrykey = @i_publisher_orgentry_key 
    if ((@l_temp_org_level_key is null) or (@l_temp_org_level_key != @i_publisher_org_level))
    BEGIN
      SET @intErr = @intErr + 16384;
      SET @summary_error = @summary_error + 'The publisher given is not in the orgentry table or the entry exists but at the wrong level.:';
      GOTO ExitHandler
    END
  END

  -- Find the imprint organization if it was
  -- not specified by the call.
  if (@i_imprint_orgentry_key is null)
  BEGIN
    --PRINT 'TRYING TO Find the imprint organization : if found see below, if blank it was not found.'
    SELECT @i_imprint_orgentry_key = oe.orgentrykey
      from orgentry oe where oe.orgentrydesc=@ImprintName_b079
                             and oe.orglevelkey=@i_imprint_org_level 
    --PRINT '@i_imprint_orgentry_key = ' + CONVERT(varchar, @i_imprint_orgentry_key)
  END
  SET @summary_error = @summary_error + '7:';
  SET @o_error_desc = '7: ';


  -- If we don't have a publisher organization at this point
  -- we need to abandon the attempt.  This routine should not have
  -- the ability to change the publisher information in the 
  -- target system.
  if (@i_publisher_orgentry_key is null)
  BEGIN
    --PRINT 'Not able to determine publisher.  Cannot insert the book.';
    SET @intErr = @intErr + 16;
    SET @summary_error = @summary_error + 'Not able to determine publisher.  Cannot insert the book. ';
    --print @summary_error;
    GOTO ExitHandler
  END 

  if (@i_imprint_orgentry_key is null and @i_create_imprint_if_needed = 0)
  BEGIN
    --PRINT 'Imprint was not found and it cannot be created in current configuration.';
    SET @intErr = @intErr + 32;
    SET @summary_error = @summary_error + 'Imprint was not found and it cannot be created in current configuration. ';
    --print @summary_error
    GOTO ExitHandler
  END 

  IF @i_publisher_orgentry_key is not null SET @summary_error = @summary_error + 'PubOrgEntry=' + CONVERT(varchar, @i_publisher_orgentry_key) +':';
  IF @i_imprint_orgentry_key   is not null SET @summary_error = @summary_error + 'ImprintOrgEntry=' + CONVERT(varchar, @i_imprint_orgentry_key) +':';
  SET @summary_error = @summary_error + '8:';

  -- Create the ISBN with dashes from the 10 digit one found
  -- in the onix document.
  DECLARE @ISBN13 as varchar(13);
  exec isbn_13_from_isbn_10 @ISBN10_b004, @ISBN13 output, @temp_error_code output, @temp_error_desc output
  --PRINT '@ISBN13';
  --PRINT @ISBN13;

  -- Based on this inital information that has been extracted, 
  -- clean up some of the data and convert it to a form that is 
  -- easy to use in the database.
    

  -- In order to be able to insert the book we must have a format description, use the
  -- extracted to code to find the gentables value for that item. This is a mandatory field
  -- so it should be available.
  DECLARE @media_type_code int;
  DECLARE @media_subtype_code int;

  SELECT @media_type_code = subgentables.datacode, @media_subtype_code = subgentables.datasubcode from subgentables where tableid=312 and subgentables.onixsubcode = @ProductForm_b012    
  --PRINT 'Media Type Code     : ' + CONVERT(varchar, @media_type_code)
  --PRINT 'Media Sub Type Code : ' + CONVERT(varchar, @media_subtype_code)


  -- If we are given a lowest level organization key, use it to walk the tree
  -- and get the actual organization keys that would be correct based on the
  -- lowest level key.  In this way we can check the validity of the other 
  -- parameters and issue warnings as needed and we can make sure we get 
  -- all of the levels set when the imprint is not at the lowest level.
  
  -- Test
  --print 'ORGANIZATION PROCESSING';
  --print '@i_lowest_level_orgentry_key'
  --print @i_lowest_level_orgentry_key

  DECLARE @imprint_orgentrykey_from_ll_key int;
  DECLARE @publisher_orgentrykey_from_ll_key int;
  DECLARE @level1_orgentrykey_from_ll_key int;
  DECLARE @current_orgentrykey int;        -- temp storage
  DECLARE @current_orgentryparentkey int;  -- temp storage
  DECLARE @current_orglevel int;           -- temp storage

  SET @imprint_orgentrykey_from_ll_key   = null;
  SET @publisher_orgentrykey_from_ll_key = null;
  SET @level1_orgentrykey_from_ll_key    = null;

  set @current_orglevel = null;
  select @current_orgentrykey = orgentrykey, @current_orglevel = orglevelkey, @current_orgentryparentkey = orgentryparentkey from orgentry where orgentrykey = @i_lowest_level_orgentry_key and orglevelkey = @numorglevels;
  while (@current_orglevel is not null)
  BEGIN
    -- TEST
    --PRINT '@current_orgentrykey';
    --PRINT @current_orgentrykey;
    --PRINT '@current_orgentryparentkey';
    --PRINT @current_orgentryparentkey;
    --PRINT '@current_orglevel';
    --PRINT @current_orglevel;
    --IF (@current_orglevel is not null) SET @summary_error = @summary_error + 'CurrentOrgLevel =' + CONVERT(VARCHAR, @current_orglevel) + ' : '

    if (@current_orglevel = 1) SET @level1_orgentrykey_from_ll_key = @current_orgentrykey;
    if (@current_orglevel = @i_imprint_org_level) SET @imprint_orgentrykey_from_ll_key = @current_orgentrykey;
    if (@current_orglevel = @i_publisher_org_level) SET @publisher_orgentrykey_from_ll_key = @current_orgentrykey;
      
    set @current_orglevel = null;
    select @current_orgentrykey = orgentrykey, @current_orglevel = orglevelkey,  @current_orgentryparentkey = orgentryparentkey  from orgentry where orgentrykey = @current_orgentryparentkey;
  END

  -- Test
  --PRINT '@imprint_orgentrykey_from_ll_key';
  --PRINT @imprint_orgentrykey_from_ll_key ;
  --PRINT '@publisher_orgentrykey_from_ll_key';
  --PRINT @publisher_orgentrykey_from_ll_key;
  --PRINT '@level1_orgentrykey_from_ll_key';
  --PRINT @level1_orgentrykey_from_ll_key;

  if (@publisher_orgentrykey_from_ll_key is not null and @publisher_orgentrykey_from_ll_key <> @i_publisher_orgentry_key)
  BEGIN
    --PRINT 'Warning : The publisher key found from the lowest level key is not same as that provided or computed.'
    SET @i_publisher_orgentry_key = @publisher_orgentrykey_from_ll_key;
  END

  if (@imprint_orgentrykey_from_ll_key is not null and @imprint_orgentrykey_from_ll_key <> @i_imprint_orgentry_key)
  BEGIN
    --PRINT 'Warning : The imprint key found from the lowest level key is not same as that provided or computed.'
    SET @summary_error = @summary_error + 'Warning : The imprint key found from the lowest level key is not same as that provided or computed.' ;
    SET @i_imprint_orgentry_key = @imprint_orgentrykey_from_ll_key;
  END
  
  -- Test CODE
  --SET @summary_error = @summary_error + 'Imprint : ' + @ImprintName_b079 ;
  -- END TEST CODE

  -- Final check to see that we have a publisher organization.
  if (@i_publisher_orgentry_key is null)
  BEGIN
    --print 'No publisher found';
    SET @intErr = @intErr + 64
    SET @summary_error = @summary_error + 'Not Able to Resolve publisher orgentry key!:';
    GOTO ExitHandler
  END 

  -- Final check to see that we have a imprint organization.
  --if (@i_imprint_orgentry_key is null)
  --BEGIN
  --  print 'No imprint found';
  --  SET @o_error_code = @o_error_code + 1;
  --  SET @summary_error = @summary_error + 'Not Able to Resolve imprint orgentry key!:';
  --  GOTO ExitHandler
  --END 
  --if @summary_error is null set @summary_error = 'Summary Error was null at transaction start.'
  
  -- This is the point where we know we can attemp the update/insertion of a book/title
  -- record.  The transaction should work such that the new information will not be kept
  -- except in the case of some 'text' data types that are from the 'othertext' portion
  -- of the xml document.
  BEGIN TRANSACTION ADDBOOK
  SET @bolTransactionStarted = 1
  --PRINT 'Starting Transaction for Title Import'
  SET @summary_error = @summary_error + 'STARTTRANS:';
  --print len(@summary_error)
  SET @o_error_desc = 'STARTTRANS: ';
  
  if (@i_imprint_orgentry_key is null)
  BEGIN
    -- We must create a imprint for this publisher.
    exec next_generic_key null, @i_imprint_orgentry_key output, @temp_error_code output, @temp_error_desc output;
    insert into orgentry (orgentrykey, orglevelkey, orgentrydesc, orgentryparentkey, orgentryshortdesc, deletestatus, lastuserid, lastmaintdate, createtitlesinpomsind) VALUES
      (@i_imprint_orgentry_key, 3, @ImprintName_b079, @i_publisher_orgentry_key, CONVERT(varchar(20), @ImprintName_b079), 'N', @i_user, GETDATE(), 0 )     
  if (@@ERROR > 0)
    BEGIN
      SET @intErr = @intErr + 1048576
      SET @summary_error = @summary_error + 'ExError=1:';
      GOTO ExitHandler
    END
  END 


  -- We want to start the transaction here so that we can keep from deleting the
  -- existing book if we have to abandon the import.
  declare @bookeytemp int;
  select @bookeytemp = bookkey from isbn where isbn10 = @ISBN10_b004;

  declare @bookOrgEntry int;
  
  -- DEBUG
  --PRINT 'Checking to see if book currently exists'

  if (@bookeytemp is not null)
  BEGIN
    --PRINT 'Existing Book Key : @bookeytemp';
    --print @bookeytemp;
    --IF (@i_publisher_orgentry_key is not null) SET @summary_error = @summary_error + 'Pub Org Entry Key =' + CONVERT(VARCHAR, @i_publisher_orgentry_key) + ' : '
    --SET @summary_error = @summary_error + '*****' 
    --IF (@i_publisher_org_level is null) SET @summary_error = @summary_error + '@i_publisher_org_level is null : '


    select @bookOrgEntry = orgentrykey from bookorgentry where bookkey = @bookeytemp and orglevelkey = @i_publisher_org_level and orgentrykey = @i_publisher_orgentry_key;
	
    --print 'Existing Org Entry :' + CONVERT(VARCHAR, @bookOrgEntry);
    IF (@bookOrgEntry is not null) SET @summary_error  = @summary_error + 'Existing Org Entry :' + CONVERT(VARCHAR, @bookOrgEntry) + char(13) + char(10);
    --print len(@summary_error)
    if (@bookOrgEntry is not null or @i_force_title_overwrite = 1)
    BEGIN
      --print 'Deleting existing book (' + @ISBN10_b004 + ') :' + CONVERT(VARCHAR, @bookeytemp); 
      exec deletetitle_delete_book @bookeytemp
      IF (@bookeytemp is not null) SET @summary_error  = @summary_error + 'DELETING BOOKKEY:' + CONVERT(VARCHAR, @bookeytemp) + char(13) + char(10)
    END
    ELSE
    BEGIN
      select @bookOrgEntry = orgentrykey from bookorgentry where bookkey = @bookeytemp and orglevelkey = @i_publisher_org_level
      --print 'WARNING:'
      --print 'Cannot delete title because it belongs to another organization.'
      --print 'ISBN = ' + @ISBN10_b004
      --print 'Existing book Org Entry (publisher level) :' + CONVERT(VARCHAR, @bookOrgEntry);
      --print 'Specified publisher or computed publisher :' + CONVERT(VARCHAR, @i_publisher_orgentry_key);
      SET @intErr = @intErr + 8192
      SET @summary_error = @summary_error + 'Cannot import title because it belongs to another organization. ' 
      IF (@i_publisher_org_level is not null) SET @summary_error = @summary_error + 'Pub org Level =' + CONVERT(VARCHAR, @i_publisher_org_level) + ' : '
      IF (@bookOrgEntry is not null) SET @summary_error = @summary_error + 'Existing book Org Entry (publisher level) =' + CONVERT(VARCHAR, @bookOrgEntry) + ' : '
      IF (@i_publisher_orgentry_key is not null) SET @summary_error = @summary_error + 'Specified publisher or computed publisher :' + CONVERT(VARCHAR, @i_publisher_orgentry_key) + ' : '
      GOTO ExitHandler
    END
  END
  -- Resolve some codes as needed.
  
  -- Language.
  DECLARE @LanguageDataCode int;
  SELECT @LanguageDataCode = datacode from gentables where tableid = 318 and onixcode = @LanguageOfText_b059

  -- Test
  --Print 'Processing book'
  DECLARE @newBookKey int;
  exec next_generic_key null, @newBookKey output, @temp_error_code output, @temp_error_desc output;
  --print 'NEW BOOK KEY :' + CONVERT(VARCHAR, @newBookKey);
  INSERT INTO book (bookkey, workkey, title, subtitle, linklevelcode, propagatefromprimarycode, standardind, lastuserid, lastmaintdate, creationdate) VALUES (
     @newBookKey, @newBookKey, @Title_b028, @SubTitle_b029, 10, 0, 'N', @i_user, GETDATE(), GETDATE() )
  if (@@ERROR > 0)
  BEGIN
    SET @intErr = @intErr + 128
    SET @summary_error = @summary_error + 'Insert Error (book):';
    GOTO ExitHandler
  END
  INSERT INTO bookdetail (bookkey, titleprefix, mediatypecode, mediatypesubcode, publishtowebind, languagecode, lastuserid, lastmaintdate) VALUES 
      (@newBookKey, @TitlePrefix_b030, @media_type_code, @media_subtype_code, @i_publish_to_web, @LanguageDataCode, @i_user, GETDATE());
  if (@@ERROR > 0)
  BEGIN
    SET @intErr = @intErr + 256
    SET @summary_error = @summary_error + 'Insert Error (bookdetail):';
    GOTO ExitHandler
  END

  INSERT INTO printing (bookkey, printingkey, issuenumber, actualinsertillus, pagecount, trimsizelength, trimsizewidth, pubmonth, pubmonthcode, lastuserid, lastmaintdate) VALUES
      (@newBookKey, 1, 1, @IllustrationsNote_b062, @NumberOfPages_b061, @Height_c096, @Width_c097, @PublicationDate, @PublicationMonth, @i_user, GETDATE())
  if (@@ERROR > 0)
  BEGIN
    SET @intErr = @intErr + 512
    SET @summary_error = @summary_error + 'Insert Error (printing):';
    GOTO ExitHandler
  END
  
    --print len(@summary_error)

  INSERT INTO bookedipartner (edipartnerkey, bookkey, printingkey, sendtoeloquenceind, lastuserid, lastmaintdate) VALUES
      (1, @newBookKey, 1, 1, @i_user, getdate());
  if (@@ERROR > 0)
  BEGIN
    SET @intErr = @intErr + 1024
    SET @summary_error = @summary_error + 'Insert Error (bookedipartner):';
    GOTO ExitHandler
  END
  DECLARE @newISBNKey int;
  exec next_generic_key null, @newISBNKey output, @temp_error_code output, @temp_error_desc output;
  --print 'NEW ISBN KEY :' + CONVERT(VARCHAR, @newISBNKey);
  INSERT INTO isbn (isbn10, isbn, bookkey, isbnkey, lastuserid, lastmaintdate) VALUES (@ISBN10_b004, @ISBN13, @newBookKey, @newISBNKey, @i_user, getdate());
  if (@@ERROR > 0)
  BEGIN
    SET @intErr = @intErr + 2048
    SET @summary_error = @summary_error + 'Insert Error (isbn):'
    GOTO ExitHandler
  END
    
  -- Set up the title in the bookorgentry table.
  exec bookorgentry_insert_update_bookkey @newBookKey, @i_imprint_orgentry_key, @i_user, @temp_error_code out, @temp_error_desc out 
  if (@@ERROR > 0 or @temp_error_code > 0)
  BEGIN
    SET @intErr = @intErr + 4096
    SET @summary_error = @summary_error + 'Insert Error (bookorgentry_insert_update_bookkey):'
    IF (@temp_error_desc is not null) SET @summary_error = @summary_error + '@temp_error_desc='+ @temp_error_desc + ' : '
    GOTO ExitHandler
  END

  -- If the pub date is available, enter it now.
  IF (@PublicationDate is not null)
  BEGIN
    INSERT INTO bookdates (bookkey, printingkey, datetypecode, activedate, actualind, recentchangeind, lastuserid, lastmaintdate) VALUES
      (@newBookKey, 1, 8, @PublicationDate, 1, 1, @i_user, GETDATE());
    if (@@ERROR > 0)
    BEGIN
      SET @intErr = @intErr + 131072
      SET @summary_error = @summary_error + 'Insert Error (bookdates):';
      GOTO ExitHandler
    END

  END
  -- Test
  --select * from bookorgentry where bookkey = @newBookKey;

  SET CURSOR_CLOSE_ON_COMMIT ON;
  
  --PRINT 'BEFORE INSERT TO OTHERTEXT'
  INSERT INTO importtext ( transactionkey, tempkey1, tempkey2, textvalue, lastmaintdate)
    SELECT transactionkey=@@SPID, tempkey1=texttypecode_d102, tempkey2=textformat_d103, textvalue=text_d104, lastmaintdate=GETDATE()
    FROM OPENXML(@intDoc,  '/product/othertext')
    WITH (texttypecode_d102 varchar(2) 'd102', textformat_d103 varchar(2) 'd103', text_d104 text 'd104')
  IF @@ERROR > 0
  BEGIN
    SET @intErr = @intErr + 32768
    SET @summary_error = @summary_error + 'Insert Error (importtext):';
    GOTO ExitHandler
  END
 
  --PRINT 'BEFORE UPDATE'
  UPDATE importtext SET tempkey3=sgt.datacode, tempkey4=sgt.datasubcode from subgentables sgt, importtext it where it.tempkey1 = sgt.onixsubcode and sgt.tableid = 284
  if (@@ERROR > 0)
  BEGIN
    SET @intErr = @intErr + 65536
    SET @summary_error = @summary_error + 'Insert Error (importtext):';
    GOTO ExitHandler
  END


  -- In this section we willl clean up the other text information so that the 
  -- individual records can be entered into the database.
  DECLARE import_text_cursor cursor for 
    SELECT importtextkey, tempkey1 from importtext where tempkey1 = 8;  -- Review Codes

  OPEN import_text_cursor

  DECLARE @import_text_key int;
  DECLARE @onix_text_type_code int;
  DECLARE @review_quote_count int;
  DECLARE @new_subcode int;
  SET @review_quote_count = 0

  -- Get the first row of the cursor before entering the loop to process.
  FETCH NEXT FROM import_text_cursor INTO @import_text_key, @onix_text_type_code

  -- Check @@FETCH_STATUS to see if there are any more rows to fetch.
  WHILE @@FETCH_STATUS = 0
  BEGIN
    SET @review_quote_count = @review_quote_count + 1

    IF @review_quote_count = 1 SET @new_subcode = 4
    IF @review_quote_count = 2 SET @new_subcode = 5
    IF @review_quote_count = 3 SET @new_subcode = 6
    IF @review_quote_count = 4 SET @new_subcode = 45
    IF @review_quote_count = 5 SET @new_subcode = 46
    IF @review_quote_count = 6 SET @new_subcode = 47
    IF @review_quote_count = 7 SET @new_subcode = 48
    IF @review_quote_count = 8 SET @new_subcode = 49

    -- If we have too many review quotes for the current configuration, 
    -- delete them so that we can do the insert without error.
    if (@review_quote_count < 9)
      BEGIN
        update importtext SET tempkey4 = @new_subcode where importtextkey = @import_text_key;
      END
    ELSE
      BEGIN
        delete from importtext where importtextkey = @import_text_key;
      END

    FETCH NEXT FROM import_text_cursor INTO @import_text_key, @onix_text_type_code;

  END

  --PRINT 'Closing cursor import_text_cursor';
  close import_text_cursor;
  deallocate import_text_cursor;  

  
  -- Select the contibutors biographies and place them
  -- in one place separated by a couple of spaces.  This
  -- Will allow us to create the needed entries for the 
  -- export.

  DECLARE @BiographicalNote_b044            varchar(2000);	-- 8.18 <BiographicalNote>A Harvard graduate in Latin ...</BiographicalNote>
   
  DECLARE biographicalnote_cursor CURSOR FOR 
  SELECT  BiographicalNote_b044
    FROM OPENXML(@intDoc,  '/product/contributor')
      WITH (BiographicalNote_b044 varchar(2000) 'b044') 


  OPEN biographicalnote_cursor

  SET @BiographicalNote_b044 = null;
  DECLARE @BiographyPtr varbinary(16);
  FETCH NEXT FROM biographicalnote_cursor INTO 
          @BiographicalNote_b044;

  SELECT @BiographyPtr = null
  IF  @@FETCH_STATUS = 0 and @BiographicalNote_b044 <> ''
  BEGIN
    INSERT INTO importtext (transactionkey, tempkey1, tempkey2, textvalue, lastmaintdate)
     VALUES( @@SPID, 13, 0, '', GETDATE())
    
    -- Fix up the mapping.
    UPDATE importtext SET tempkey3=sgt.datacode, tempkey4=sgt.datasubcode from subgentables sgt, importtext it where it.tempkey1 = sgt.onixsubcode and sgt.tableid = 284 and it.tempkey1 = 13 and it.tempkey2 = 0;
    if (@@ERROR > 0)
    BEGIN
      SET @intErr = @intErr + 1048576
      SET @summary_error = @summary_error + 'ExError=2:';
      GOTO ExitHandler
    END
    
    SELECT @BiographyPtr=TEXTPTR(textvalue) FROM importtext where transactionkey = @@SPID and tempkey1 = 13 and tempkey2 = 0;

  END

  WHILE @@FETCH_STATUS = 0
  BEGIN

   IF (@BiographicalNote_b044 is not null and @BiographicalNote_b044 <> '')
   BEGIN
     IF (@BiographyPtr is null)
     BEGIN
       INSERT INTO importtext (transactionkey, tempkey1, tempkey2, textvalue, lastmaintdate)
         VALUES( @@SPID, 13, 0, '', GETDATE())
    
       -- Fix up the mapping.
       UPDATE importtext SET tempkey3=sgt.datacode, tempkey4=sgt.datasubcode from subgentables sgt, importtext it where it.tempkey1 = sgt.onixsubcode and sgt.tableid = 284 and it.tempkey1 = 13 and it.tempkey2 = 0;
       if (@@ERROR > 0)
       BEGIN
         SET @intErr = @intErr + 1048576
         SET @summary_error = @summary_error + 'ExError=3:';
         GOTO ExitHandler
       END
    
       SELECT @BiographyPtr=TEXTPTR(textvalue) FROM importtext where transactionkey = @@SPID and tempkey1 = 13 and tempkey2 = 0;
     END
     SET @BiographicalNote_b044 = RTRIM(LTRIM(@BiographicalNote_b044)) + char(13) +char(10) + char(13) + char(10);
     UPDATETEXT importtext.textvalue @BiographyPtr null null @BiographicalNote_b044
     if (@@ERROR > 0)
       BEGIN
         SET @intErr = @intErr + 1048576
         SET @summary_error = @summary_error + 'ExError=4:';
         GOTO ExitHandler
     END
   END

   SET @BiographicalNote_b044 = null;
   FETCH NEXT FROM biographicalnote_cursor INTO 
          @BiographicalNote_b044;

  END

  close biographicalnote_cursor;
  deallocate biographicalnote_cursor;


  -- TEST
  --select * from importtext;

  -- Test creation of rtf from plain text.
  if (@i_create_rtf_from_plain_text = 1)
  BEGIN
    exec bookcomments_to_bookcommentsrtf;
  END
  
  -- Delete any item that did not have new codes created.
  delete from importtext where transactionkey=@@SPID and (tempkey3 is null) and (tempkey4 is null)
  if (@@ERROR > 0)
  BEGIN
    SET @intErr = @intErr + 1048576
    SET @summary_error = @summary_error + 'ExError=5:';
    GOTO ExitHandler
  END
  
  -- Insert the text fields that we have obtained and made ready for the movement to the
  -- new tables.
  INSERT INTO bookcomments (bookkey, printingkey, commenttypecode, commenttypesubcode, commenttext, lastuserid, lastmaintdate)
    SELECT bookkey=@newBookKey, printingkey=1, commenttypecode=tempkey3, commenttypesubcode=tempkey4, commenttext=textvalue, lastuserid=@i_user, lastmaintdate=GETDATE() FROM importtext where transactionkey=@@SPID and tempkey2 = 0; -- Plain Text
  if (@@ERROR > 0)
  BEGIN
    SET @intErr = @intErr + 1048576
    SET @summary_error = @summary_error + 'ExError=6:';
    GOTO ExitHandler
  END

  INSERT INTO bookcommenthtml (bookkey, printingkey, commenttypecode, commenttypesubcode, commenttext, lastuserid, lastmaintdate)
    SELECT bookkey=@newBookKey, printingkey=1, commenttypecode=tempkey3, commenttypesubcode=tempkey4, commenttext=textvalue, lastuserid=@i_user, lastmaintdate=GETDATE() FROM importtext where transactionkey=@@SPID and tempkey2 = 2; -- Plain Text
  if (@@ERROR > 0)
  BEGIN
    SET @intErr = @intErr + 1048576
    SET @summary_error = @summary_error + 'ExError=7:';
    GOTO ExitHandler
  END

  INSERT INTO bookcommentrtf (bookkey, printingkey, commenttypecode, commenttypesubcode, commenttext, lastuserid, lastmaintdate)
    SELECT bookkey=@newBookKey, printingkey=1, commenttypecode=tempkey3, commenttypesubcode=tempkey4, commenttext=textvalue, lastuserid=@i_user, lastmaintdate=GETDATE() FROM importtext where transactionkey=@@SPID and tempkey2 = -1; -- Computed RTF
  if (@@ERROR > 0)
  BEGIN
    SET @intErr = @intErr + 1048576
    SET @summary_error = @summary_error + 'ExError=8:';
    GOTO ExitHandler
  END

  -- TEST
  --SELECT * from bookcomments where bookkey = @newBookKey;
  --SELECT * from bookcommenthtml where bookkey = @newBookKey;
  --SELECT * from bookcommentrtf where bookkey = @newBookKey;

  DELETE FROM importtext where transactionkey = @@SPID;
  if (@@ERROR > 0)
  BEGIN
    SET @intErr = @intErr + 1048576
    SET @summary_error = @summary_error + 'ExError=9:';
    GOTO ExitHandler
  END

  -- TEST
  -- select * from importtext;
  
  
  -- Contibutor section	"contributor";                          -- 8
  DECLARE @SequenceNumber_b034              int;                -- 8.1 <SequenceNumber>3</SequenceNumber>
  DECLARE @ContributorRole_b035             varchar(3);	        -- 8.2 <ContributorRole>A01</ContributorRole>
  DECLARE @PersonName_b036                  varchar(200);       -- 8.4 <PersonName>James J. Johnson III</PersonName>
  DECLARE @PersonNameInverted_b037          varchar(200);       -- 8.5 <PersonNameInverted>Schur, Norman W</PersonNameInverted>
  DECLARE @TitlesBeforeNames_b038           varchar(100);	-- 8.6 <TitlesBeforeNames>Prince</TitlesBeforeNames>
  DECLARE @NamesBeforeKey_b039              varchar(100);	-- 8.7 <NamesBeforeKey>James J.</NamesBeforeKey> 
  DECLARE @PrefixToKey_b247                 varchar(100);	-- 8.8 <PrefixToKey>van</PrefixToKey>  (From Ludwig van Beethoven)
  DECLARE @KeyNames_b040                    varchar(100);	-- 8.9 <KeyNames>Beethoven</KeyNames> or Francis de Sales (Saint Francis de Sales)
  DECLARE @NamesAfterKey_b041               varchar(100);	-- 8.10 <NamesAfterKey>Ibrahim</NamesAfterKey> (in Anwar Ibrahim)
  DECLARE @SuffixToKey_b248                 varchar(100);	-- 8.11 <SuffixToKey>Jr</SuffixToKey>
  DECLARE @LettersAfterName_b042            varchar(100);	-- 8.12 <LettersAfterName>MB FRCS</LettersAfterName>
  DECLARE @TitlesAfterNames_b043            varchar(100);	-- 8.13 <TitlesAfterNames>Duke of Edinburgh</TitlesAfterNames>
  DECLARE @PersonNameType_b250              varchar(100);	-- 8.14 <PersonNameType>01</PersonNameType>
  DECLARE @ProfessionalPosition_b045        varchar(100);	-- 8.15 <ProfessionalPosition>Humboldt Professor of Oceanography</ProfessionalPosition>
  DECLARE @Affiliation_b046                 varchar(100);	-- 8.16 <Affiliation>Universidad de La Laguna</Affiliation>
  DECLARE @CorporateName_b047               varchar(100);	-- 8.17 <CorporateName>Good Housekeeping Institute</CorporateName>
-- Declared above:  DECLARE @BiographicalNote_b044            varchar(2000);	-- 8.18 <BiographicalNote>A Harvard graduate in Latin ...</BiographicalNote>
  DECLARE @ContributorDescription_b048      varchar(2000);	-- 8.19 <ContributorDescription>Skipper of the winning crew in the Americas Cup, 1998</ContributorDescription>
  DECLARE @UnnamedPersons_b249              varchar(100);	-- 8.20 <UnnamedPersons>02</UnnamedPersons> (Code list 01, Unknown; 02 Anonymous, etc..
        

  DECLARE contibutor_cursor CURSOR FOR 
  SELECT  SequenceNumber_b034,
          ContributorRole_b035,
          PersonName_b036,
          PersonNameInverted_b037,
          TitlesBeforeNames_b038,
          NamesBeforeKey_b039,
          PrefixToKey_b247,
          KeyNames_b040,
          NamesAfterKey_b041,
          SuffixToKey_b248,
          LettersAfterName_b042,
          TitlesAfterNames_b043,
          PersonNameType_b250,
          ProfessionalPosition_b045,
          Affiliation_b046,
          CorporateName_b047,
          BiographicalNote_b044,
          ContributorDescription_b048,
          UnnamedPersons_b249 
    FROM OPENXML(@intDoc,  '/product/contributor')
    WITH (SequenceNumber_b034 int 'b034',
          ContributorRole_b035 varchar(100) 'b035',
          PersonName_b036 varchar(200) 'b036',
          PersonNameInverted_b037 varchar(200) 'b037',
          TitlesBeforeNames_b038 varchar(100) 'b038',
          NamesBeforeKey_b039 varchar(100) 'b039',
          PrefixToKey_b247 varchar(100) 'b247',
          KeyNames_b040 varchar(100) 'b040',
          NamesAfterKey_b041 varchar(100) 'b041',
          SuffixToKey_b248 varchar(100) 'b248',
          LettersAfterName_b042 varchar(100) 'b042',
          TitlesAfterNames_b043 varchar(100) 'b043',
          PersonNameType_b250 varchar(100) 'b250',
          ProfessionalPosition_b045 varchar(100) 'b045',
          Affiliation_b046 varchar(100) 'b046',
          CorporateName_b047 varchar(100) 'b047',
          BiographicalNote_b044 varchar(2000) 'b044',
          ContributorDescription_b048 varchar(2000) 'b048',
          UnnamedPersons_b249 varchar(100) 'b249') 
  --PRINT 'AFTER  DECLARE contibutor_cursor';

  OPEN contibutor_cursor

  --PRINT 'AFTER OPEN contibutor_cursor';

  -- Perform the first fetch.
  FETCH NEXT FROM contibutor_cursor INTO 
          @SequenceNumber_b034,
          @ContributorRole_b035,
          @PersonName_b036,
          @PersonNameInverted_b037,
          @TitlesBeforeNames_b038,
          @NamesBeforeKey_b039,
          @PrefixToKey_b247,
          @KeyNames_b040,
          @NamesAfterKey_b041,
          @SuffixToKey_b248,
          @LettersAfterName_b042,
          @TitlesAfterNames_b043,
          @PersonNameType_b250,
          @ProfessionalPosition_b045,
          @Affiliation_b046,
          @CorporateName_b047,
          @BiographicalNote_b044,
          @ContributorDescription_b048,
          @UnnamedPersons_b249


  -- Check @@FETCH_STATUS to see if there are any more rows to fetch.
  WHILE @@FETCH_STATUS = 0
  BEGIN

    --Test
    --PRINT '@SequenceNumber_b034';
    --PRINT @SequenceNumber_b034;
    --PRINT '@ContributorRole_b035';
    --PRINT @ContributorRole_b035;
    --PRINT '@PersonName_b036';
    --PRINT @PersonName_b036;
    --PRINT '@PersonNameInverted_b037';
    --PRINT @PersonNameInverted_b037;
    --PRINT '@TitlesBeforeNames_b038';
    --PRINT @TitlesBeforeNames_b038;
    --PRINT '@NamesBeforeKey_b039';
    --PRINT @NamesBeforeKey_b039;
    --PRINT '@PrefixToKey_b247';
    --PRINT @PrefixToKey_b247;
    --PRINT '@KeyNames_b040';
    --PRINT @KeyNames_b040;
    --PRINT '@NamesAfterKey_b041';
    --PRINT @NamesAfterKey_b041;
    --PRINT '@SuffixToKey_b248';
    --PRINT @SuffixToKey_b248;
    --PRINT '@LettersAfterName_b042';
    --PRINT @LettersAfterName_b042;
    --PRINT '@TitlesAfterNames_b043';
    --PRINT @TitlesAfterNames_b043;
    --PRINT '@PersonNameType_b250';
    --PRINT @PersonNameType_b250;
    --PRINT '@ProfessionalPosition_b045';
    --PRINT @ProfessionalPosition_b045;
    --PRINT '@Affiliation_b046';
    --PRINT @Affiliation_b046;
    --PRINT '@CorporateName_b047';
    --PRINT @CorporateName_b047;
    --PRINT '@BiographicalNote_b044';
    --PRINT @BiographicalNote_b044;
    --PRINT '@ContributorDescription_b048';
    --PRINT @ContributorDescription_b048;
    --PRINT '@UnnamedPersons_b249' 
    --PRINT @UnnamedPersons_b249 

    DECLARE @author_type_code int; 
    SET @author_type_code = null;
  
    DECLARE @existing_author_key int;
    SET @existing_author_key = null;
    
    -- Process the contributor by inserting into the system as needed.
    if (@UnnamedPersons_b249 is not null)
    BEGIN
      --PRINT 'Unamed Person'
     SET @summary_error = @summary_error + 'Unhandled Unamed Person:';
    END 
    ELSE IF (@CorporateName_b047 is not null)
    BEGIN
      -- Test
      --PRINT 'Corporate Contributor'

      SET @existing_author_key = null;
      EXEC author_match_author_with_customerauthor null, @CorporateName_b047, null, null, @i_publisher_orgentry_key, @existing_author_key out, @temp_error_code out, @temp_error_desc out

      SET @author_type_code = null;
      SELECT @author_type_code = datacode from gentables where tableid = 134 and onixcode = @ContributorRole_b035;

	  if (@author_type_code is null)
	  BEGIN
        SELECT @author_type_code = datacode from gentables where tableid = 134 and onixcode = 'A99';
	  END
	  
      if (@existing_author_key is null)
      BEGIN
        --PRINT 'Add author since it was not found. (Corporate Contributor)';
        exec next_generic_key null, @existing_author_key output, @temp_error_code output, @temp_error_desc output;
        INSERT author (authorkey, displayname, firstname, lastname, middlename, title, activeind, corporatecontributorind, lastuserid, lastmaintdate) 
          VALUES (@existing_author_key, @CorporateName_b047, null, @CorporateName_b047, null, null, 1, 1, @i_user, GETDATE()); 
        if (@@ERROR > 0)
        BEGIN
          SET @intErr = @intErr + 1048576
          SET @summary_error = @summary_error + 'ExError=10:';
          GOTO ExitHandler
        END
          
        if (@i_check_and_update_customerauthor = 1)
        BEGIN
          INSERT customerauthor (authorkey, customerkey, lastuserid, lastmaintdate) VALUES
            (@existing_author_key, @i_publisher_orgentry_key, @i_user, GETDATE());
        if (@@ERROR > 0)
        BEGIN
          SET @intErr = @intErr + 1048576
          SET @summary_error = @summary_error + 'ExError=11:';
          GOTO ExitHandler
        END
        END

      END 
      
      UPDATE author SET biography = @BiographicalNote_b044 WHERE author.authorkey = @existing_author_key;
      if (@@ERROR > 0)
      BEGIN
        SET @intErr = @intErr + 1048576
        SET @summary_error = @summary_error + 'ExError=12:';
        GOTO ExitHandler
      END
      INSERT bookauthor (bookkey, authorkey, authortypecode, reportind, primaryind, sortorder,  lastuserid, lastmaintdate) 
        VALUES (@newBookKey, @existing_author_key, @author_type_code, 1,  1, @SequenceNumber_b034, @i_user, GETDATE());
      if (@@ERROR > 0)
      BEGIN
        SET @intErr = @intErr + 1048576
        SET @summary_error = @summary_error + 'ExError=13:';
        GOTO ExitHandler
      END

    END
    ELSE
    BEGIN
      --PRINT 'Regular Person'
      DECLARE @middle_names varchar(100);
      DECLARE @first_name varchar(100);
      DECLARE @LocationFirstSpace int;
      DECLARE @LengthOfb039 int;

      -- Separate out the first name from the middle name(s).
      SET @NamesBeforeKey_b039 = LTRIM(RTRIM(@NamesBeforeKey_b039));
      SET @first_name = @NamesBeforeKey_b039;
      SET @middle_names = null;
      SET @LocationFirstSpace = CHARINDEX(' ', @NamesBeforeKey_b039, 0)
      SET @LengthOfb039 = LEN(@NamesBeforeKey_b039);

      IF (@LengthOfb039 = 0)
      BEGIN
        SET @first_name = null;
      END
      
      IF (@LengthOfb039 != 0 and @LocationFirstSpace != 0)
      BEGIN
        -- Test
        --PRINT '@LengthOfb039';
        --PRINT @LengthOfb039;
        --PRINT '@LocationFirstSpace';
        --PRINT @LocationFirstSpace;
	
        SET @middle_names = SUBSTRING(@NamesBeforeKey_b039, @LocationFirstSpace+1, @LengthOfb039 - @LocationFirstSpace);
        SET @first_name = SUBSTRING(@NamesBeforeKey_b039, 0, @LocationFirstSpace);
        
        -- Test
        --PRINT '@middle_names';
        --PRINT @middle_names;
        --PRINT '@NamesBeforeKey_b039';
        --PRINT @NamesBeforeKey_b039;

      END

      SET @existing_author_key = null;
      EXEC author_match_author_with_customerauthor @first_name, @KeyNames_b040, @middle_names, @TitlesBeforeNames_b038, @i_publisher_orgentry_key, @existing_author_key out, @temp_error_code out, @temp_error_desc out
      
      SET @author_type_code = null;
      SELECT @author_type_code = datacode from gentables where tableid = 134 and onixcode = @ContributorRole_b035;

	  if (@author_type_code is null)
	  BEGIN
        SELECT @author_type_code = datacode from gentables where tableid = 134 and onixcode = 'A99';
	  END

      if (@existing_author_key is null)
      BEGIN
        --PRINT 'Add author since it was not found. (Regular Person)';
        exec next_generic_key null, @existing_author_key output, @temp_error_code output, @temp_error_desc output;
        INSERT author (authorkey, displayname,  firstname, lastname, middlename, title, activeind, corporatecontributorind, lastuserid, lastmaintdate) 
          VALUES (@existing_author_key, @KeyNames_b040 + ', ' + @NamesBeforeKey_b039, @first_name, @KeyNames_b040, @middle_names, @TitlesBeforeNames_b038, 1, 0, @i_user, GETDATE()); 
          if (@@ERROR > 0)
          BEGIN
            SET @intErr = @intErr + 1048576
            SET @summary_error = @summary_error + 'ExError=14:';
            GOTO ExitHandler
          END
          
        if (@i_check_and_update_customerauthor = 1)
        BEGIN
          INSERT customerauthor (authorkey, customerkey, lastuserid, lastmaintdate) VALUES
            (@existing_author_key, @i_publisher_orgentry_key, @i_user, GETDATE());
          if (@@ERROR > 0)
          BEGIN
            SET @intErr = @intErr + 1048576
            SET @summary_error = @summary_error + 'ExError=15:';
            GOTO ExitHandler
          END
        END

      END 
      
      UPDATE author SET biography = @BiographicalNote_b044 WHERE author.authorkey = @existing_author_key;
      INSERT bookauthor (bookkey, authorkey, authortypecode, reportind, primaryind, sortorder,  lastuserid, lastmaintdate) 
        VALUES (@newBookKey, @existing_author_key, @author_type_code, 1,  1, @SequenceNumber_b034, @i_user, GETDATE());

    END

    
    
    -- Get the next item.
    FETCH NEXT FROM contibutor_cursor INTO 
          @SequenceNumber_b034,
          @ContributorRole_b035,
          @PersonName_b036,
          @PersonNameInverted_b037,
          @TitlesBeforeNames_b038,
          @NamesBeforeKey_b039,
          @PrefixToKey_b247,
          @KeyNames_b040,
          @NamesAfterKey_b041,
          @SuffixToKey_b248,
          @LettersAfterName_b042,
          @TitlesAfterNames_b043,
          @PersonNameType_b250,
          @ProfessionalPosition_b045,
          @Affiliation_b046,
          @CorporateName_b047,
          @BiographicalNote_b044,
          @ContributorDescription_b048,
          @UnnamedPersons_b249 
  END

  close contibutor_cursor;
  deallocate contibutor_cursor;

  -- Test
  --select bk.bookkey, au.authorkey, au. firstname, au.lastname, au.middlename, au.title from author au, bookauthor bk where bk.bookkey = @newbookkey and bk.authorkey = au.authorkey 


  --PRINT 'Get product website information';
  DECLARE @ProductWebsiteDescription_f170 varchar(300);	    -- 16.4 <ProductWebsiteDescription>????</ProductWebsiteDescription
  DECLARE @ProductWebsiteLink_f123        varchar(300);	    -- 16.5 <ProductWebsiteLink>http://....</ProductWebsiteLink>

  DECLARE productwebsite_cursor CURSOR FOR 
  
  SELECT  ProductWebsiteDescription_f170,
          ProductWebsiteLink_f123 
    FROM OPENXML(@intDoc,  '/product/productwebsite')
    WITH (ProductWebsiteDescription_f170 varchar(300) 'f170',
          ProductWebsiteLink_f123 varchar(300) 'f123') 

  open productwebsite_cursor;
          
  FETCH NEXT FROM productwebsite_cursor INTO 
          @ProductWebsiteDescription_f170,
          @ProductWebsiteLink_f123
        
  
  IF @@FETCH_STATUS = 0  -- For now only process one entry.
  BEGIN
  
    --PRINT '@ProductWebsiteDescription_f170'
    --PRINT @ProductWebsiteDescription_f170
    --PRINT 'ProductWebsiteLink_f123'
    --PRINT @ProductWebsiteLink_f123

    DECLARE @newFileLocationKey int;
    exec next_generic_key null, @newFileLocationKey output, @temp_error_code output, @temp_error_desc output;
 
    insert into filelocation (bookkey, printingkey, filetypecode, filelocationkey, filestatuscode, pathname, sendtoeloquenceind, lastuserid, lastmaintdate) VALUES 
            (@newBookKey, 1, 4, @newFileLocationKey, 1, @ProductWebsiteLink_f123, 1, @i_user, getdate());
    if (@@ERROR > 0)
    BEGIN
      SET @intErr = @intErr + 1048576
      SET @summary_error = @summary_error + 'ExError=15:';
      GOTO ExitHandler
    END
  
--    FETCH NEXT FROM productwebsite_cursor INTO 
--          @ProductWebsiteDescription_f170,
--          @ProductWebsiteLink_f123
   
  END

  close productwebsite_cursor;
  deallocate productwebsite_cursor;
  
  
  -- Supply details.
                                                        -- Supply Detail Composite.
  DECLARE @SupplierEANLocationNumber_j135 varchar(13);	-- 24.1 <SupplierEANLocationNumber>5012340098745</SupplierEANLocationNumber>
  DECLARE @SupplierSAN_j136 varchar(7);			-- 24.2 <SupplierSAN>1234567</SupplierSAN>
  DECLARE @SupplierName_j137 varchar(150);		-- 24.3 <SupplierName>Littlehamption Book Services</SupplierName>
  DECLARE @TelephoneNumber_j270 varchar(20);		-- 24.4 <TelephoneNumber>+44 20 8843 8607</TelephoneNumber>
  DECLARE @FaxNumber_j271 varchar(20);		        -- 24.5 <FaxNumber>+44 20 8843 8744<FaxNumber>
  DECLARE @EmailAddress_j272 varchar(100);		-- 24.6 <EmailAddress>david@polecat.dircon.co.uk</EmailAddress>
  DECLARE @SupplyToCountry_j138 varchar(2);		-- 24.7 <SupplyToCountry>Littlehamption Book Services</SupplyToCountry>
  DECLARE @SupplyToRegion_j139 varchar(3);		-- 24.8 <SupplyToRegion>OM</SupplyToRegion>
  DECLARE @SupplyToCountryExcluded_j140 varchar(2);	-- 24.9 <SupplyToCountryExcluded>US</SupplyToCountryExcluded>
  DECLARE @ReturnsCodeType_j268 varchar(2);		-- 24.10 <ReturnsCodeType>01</ReturnsCodeType>
  DECLARE @ReturnsCode_j269 varchar(100);		-- 24.11 <ReturnsCode>?????</ReturnsCode>
  DECLARE @AvailabilityCode_j141 varchar(2);		-- 24.12 <AvailabilityCode>IP</AvailabilityCode>
  DECLARE @PackQuantity_j145 int;			-- 24.23 <PackQuantity>24</PackQuantity>
  
  
  DECLARE supplydetail_cursor CURSOR FOR 
  
    SELECT
      SupplierEANLocationNumber_j135,
      SupplierSAN_j136,
      SupplierName_j137,
      TelephoneNumber_j270 ,
      FaxNumber_j271,
      EmailAddress_j272,
      SupplyToCountry_j138,
      SupplyToRegion_j139,
      SupplyToCountryExcluded_j140,
      ReturnsCodeType_j268,
      ReturnsCode_j269,
      AvailabilityCode_j141,
      PackQuantity_j145

    FROM OPENXML(@intDoc,  '/product/supplydetail')
    WITH (SupplierEANLocationNumber_j135 varchar(13) 'j135',
      SupplierSAN_j136 varchar(7) 'j136',
      SupplierName_j137 varchar(150) 'j137',
      TelephoneNumber_j270 varchar(20) 'j270',
      FaxNumber_j271 varchar(20) 'j271',
      EmailAddress_j272 varchar(100) 'j272',
      SupplyToCountry_j138 varchar(2) 'j138',
      SupplyToRegion_j139 varchar(3) 'j139',
      SupplyToCountryExcluded_j140 varchar(2) 'j140',
      ReturnsCodeType_j268 varchar(2) 'j268',
      ReturnsCode_j269 varchar(100) 'j269',
      AvailabilityCode_j141 varchar(2) 'j141',
      PackQuantity_j145 int 'j145'	) 


  open supplydetail_cursor;
          
  FETCH NEXT FROM supplydetail_cursor INTO 
      @SupplierEANLocationNumber_j135,
      @SupplierSAN_j136,
      @SupplierName_j137,
      @TelephoneNumber_j270,
      @FaxNumber_j271,
      @EmailAddress_j272,
      @SupplyToCountry_j138,
      @SupplyToRegion_j139,
      @SupplyToCountryExcluded_j140,
      @ReturnsCodeType_j268,
      @ReturnsCode_j269,
      @AvailabilityCode_j141,
      @PackQuantity_j145
        
  
  IF (@@FETCH_STATUS) = 0  -- For now just process the first result.
  BEGIN

    -- Test
    --PRINT '@SupplierEANLocationNumber_j135';
    --PRINT @SupplierEANLocationNumber_j135;
    --PRINT '@SupplierSAN_j136';
    --PRINT @SupplierSAN_j136;
    --PRINT '@SupplierName_j137';
    --PRINT @SupplierName_j137;
    --PRINT '@TelephoneNumber_j270';
    --PRINT @TelephoneNumber_j270;
    --PRINT '@FaxNumber_j271';
    --PRINT @FaxNumber_j271;
    --PRINT '@EmailAddress_j272';
    --PRINT @EmailAddress_j272;
    --PRINT '@SupplyToCountry_j138';
    --PRINT @SupplyToCountry_j138;
    --PRINT '@SupplyToRegion_j139';
    --PRINT @SupplyToRegion_j139;
    --PRINT '@SupplyToCountryExcluded_j140';
    --PRINT @SupplyToCountryExcluded_j140;
    --PRINT '@ReturnsCodeType_j268';
    --PRINT @ReturnsCodeType_j268;
    --PRINT '@ReturnsCode_j269';
    --PRINT @ReturnsCode_j269;
    --PRINT '@AvailabilityCode_j141';
    --PRINT @AvailabilityCode_j141;
    --PRINT '@PackQuantity_j145';
    --PRINT @PackQuantity_j145;
        
    -- Get the BISAC Status Code for the title.
    DECLARE @BISAC_Status_Data_Code int;
    SELECT @BISAC_Status_Data_Code = datacode from gentables where tableid = 314 and onixcode = @AvailabilityCode_j141;

    UPDATE bookdetail set bisacstatuscode = @BISAC_Status_Data_Code where bookkey = @newBookKey;
    if (@@ERROR > 0)
    BEGIN
      SET @intErr = @intErr + 1048576
      SET @summary_error = @summary_error + 'ExError=16:';
      GOTO ExitHandler
    END

-- Part of looping structure that we are not now using
--  FETCH NEXT FROM supplydetail_cursor INTO 
--      @SupplierEANLocationNumber_j135,
--      @SupplierSAN_j136,
--      @SupplierName_j137,
--      @TelephoneNumber_j270,
--      @FaxNumber_j271,
--      @EmailAddress_j272,
--      @SupplyToCountry_j138,
--      @SupplyToRegion_j139,
--      @SupplyToCountryExcluded_j140,
--      @ReturnsCodeType_j268,
--      @ReturnsCode_j269,
--      @AvailabilityCode_j141,
--      @PackQuantity_j145
        

  END

  close supplydetail_cursor;
  deallocate supplydetail_cursor;

  -- Create a cursor that will get the price information and
  -- we will insert it as needed, but keep in mind that we
  -- only want the prices from the first supply detail because
  -- we don't know how to handle any more supply details.
  -- Audience Code
  --PRINT 'Price Processing';
  DECLARE @PriceCount int;
  SET @PriceCount = 1;

  -- Declare the things that make up the price composite.
  DECLARE @PriceTypeCode_j148 varchar(2);       -- 24.28 <PriceTypeCode>01</PriceTypeCode>
  DECLARE @ClassOfTrade_j149 varchar(100);      -- 24.35 <ClassOfTrade>gen</ClassOfTrade>
  DECLARE @PriceAmount_j151 varchar(12);        -- 24.39 <PriceAmount>35.00</PriceAmount>
  DECLARE @CurrencyCode_j152 varchar(3);        -- 24.40 <CurrencyCode>USD</CurrencyCode>
  DECLARE @PriceEffectiveFrom_j161 varchar(8);  -- 24.50 <PriceEffectiveFrom>20000615</PriceEffectiveFrom>
  DECLARE @PriceEffectiveUntil_j162 varchar(8); -- 24.51 <PriceEffectiveUntil>20000615</PriceEffectiveUntil>
  
  DECLARE @PriceEntryCount int;
  SET     @PriceEntryCount = 0;

  DECLARE @NewPriceKey int;
  SET     @NewPriceKey = null;

  DECLARE @PriceTypeCode int;
  SET     @PriceTypeCode = null;

  DECLARE @CurrencyTypeCode int;
  SET     @CurrencyTypeCode = null;

  DECLARE price_cursor CURSOR FOR 
  
  SELECT  PriceTypeCode_j148,
          ClassOfTrade_j149,
          PriceAmount_j151,
          CurrencyCode_j152,
          PriceEffectiveFrom_j161,
          PriceEffectiveUntil_j162
    FROM OPENXML(@intDoc,  '/product/supplydetail/price')
    WITH (PriceTypeCode_j148 varchar(2) 'j148',
          ClassOfTrade_j149 varchar(100) 'j149',
          PriceAmount_j151 varchar(12) 'j151',
          CurrencyCode_j152 varchar(3) 'j152',
          PriceEffectiveFrom_j161 varchar(8) 'j161',
          PriceEffectiveUntil_j162 varchar(8) 'j162'
         ) 

  open price_cursor;
          
  FETCH NEXT FROM price_cursor INTO 
          @PriceTypeCode_j148,
          @ClassOfTrade_j149,
          @PriceAmount_j151,
          @CurrencyCode_j152,
          @PriceEffectiveFrom_j161,
          @PriceEffectiveUntil_j162
        
  DECLARE @DiscountCode int;
  
  WHILE @@FETCH_STATUS = 0
  BEGIN
    Set @PriceEntryCount = @PriceEntryCount + 1;
  
    -- Test
    --PRINT '@PriceEntryCount';
    --PRINT @PriceEntryCount;
    --PRINT '@PriceTypeCode_j148';
    --PRINT @PriceTypeCode_j148;
    --PRINT '@ClassOfTrade_j149';
    --PRINT @ClassOfTrade_j149;
    --PRINT '@PriceAmount_j151';
    --PRINT @PriceAmount_j151;
    --PRINT '@CurrencyCode_j152';
    --PRINT @CurrencyCode_j152;
    --PRINT '@PriceEffectiveFrom_j161';
    --PRINT @PriceEffectiveFrom_j161;
    --PRINT '@PriceEffectiveUntil_j162';
    --PRINT @PriceEffectiveUntil_j162;

    -- Only process a dicount code if it is the first one and
    -- it is not blank.
    if (@ClassOfTrade_j149 = '') SET @ClassOfTrade_j149 = null;
    if (@PriceCount = 1 and @ClassOfTrade_j149 is not null)
    BEGIN
      --PRINT 'Use the first class of trade/discount code available  table id 459';
      SET @DiscountCode = null;
      SELECT @DiscountCode = gt.datacode from gentables gt, gentablesorglevel gtol where gt.tableid = 459 and  gtol.tableid = gt.tableid and  gtol.datacode = gt.datacode  and gt.deletestatus = 'N' and gt.alternatedesc1 = @ClassOfTrade_j149;

      IF (@DiscountCode is null)
      BEGIN
        SELECT @DiscountCode = gt.datacode from gentables gt, gentablesorglevel gtol where gt.tableid = 459 and  gtol.tableid = gt.tableid and  gtol.datacode = gt.datacode  and gt.deletestatus = 'N' and gt.datadesc = @ClassOfTrade_j149;
      END

      -- Test
      --PRINT '@DiscountCode';
      --PRINT @DiscountCode;
    
      IF (@DiscountCode is null)
      BEGIN
        SET @FilterOrgLevlKey = null;
        select @FilterOrgLevlKey=filterorglevelkey from gentablesdesc where tableid = 459;
      
        if (@FilterOrgLevlKey is null)
        BEGIN
          UPDATE gentablesdesc SET filterorglevelkey=@i_publisher_org_level where tableid = 459;
	      SET @FilterOrgLevlKey = @i_publisher_org_level; 
          if (@@ERROR > 0)
          BEGIN
            SET @intErr = @intErr + 1048576
            SET @summary_error = @summary_error + 'ExError=17:';
            GOTO ExitHandler
          END
        END 

        --PRINT '@FilterOrgLevlKey';
        --PRINT @FilterOrgLevlKey;
        select @DiscountCode = max(datacode)+1 from gentables where tableid=459;
        insert into gentables (tableid, datacode, datadesc, datadescshort, deletestatus, tablemnemonic, alternatedesc1, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, lastuserid, lastmaintdate ) values
          (459, @DiscountCode, @ClassOfTrade_j149, @ClassOfTrade_j149, 'N', 'DistCode', @ClassOfTrade_j149, 1, 1, 0, 0, @i_user, getdate());
          if (@@ERROR > 0)
          BEGIN
            SET @intErr = @intErr + 1048576
            SET @summary_error = @summary_error + 'ExError=17:';
            GOTO ExitHandler
          END
        insert into gentablesorglevel (tableid, datacode, orgentrykey, lastuserid, lastmaintdate) VALUES
          (459, @DiscountCode, @i_publisher_orgentry_key, @i_user, getdate() )
          if (@@ERROR > 0)
          BEGIN
            SET @intErr = @intErr + 262144
            SET @summary_error = @summary_error + 'Error inserting filter for discount code.'
            GOTO ExitHandler
          END
      END
    END

    -- Test
    --PRINT '@DiscountCode';
    --PRINT @DiscountCode;

    update bookdetail set discountcode = @DiscountCode where bookkey = @newBookKey;
    if (@@ERROR > 0)
    BEGIN
      SET @intErr = @intErr + 1048576
      SET @summary_error = @summary_error + 'ExError=17:';
      GOTO ExitHandler
    END

    -- Enter the prices into the price table if there is a mapping available.
    -- Any entries without a mapping will be dropped at this point.
    SET @NewPriceKey = null;
    exec next_generic_key null, @NewPriceKey output, @temp_error_code output, @temp_error_desc output;
    --print 'NEW PRICE KEY :' + CONVERT(VARCHAR, @NewPriceKey);


    Set @PriceTypeCode    = null;
    Set @CurrencyTypeCode = null;

    select @PriceTypeCode=datacode from gentables where tableid=306 and onixcode = @PriceTypeCode_j148;
    select @CurrencyTypeCode=datacode from gentables where tableid=122 and onixcode = @CurrencyCode_j152;
    
    if @PriceTypeCode is not null and @CurrencyTypeCode is not null
    BEGIN
      --PRINT 'Insert a new Price';
      INSERT INTO bookprice (pricekey, bookkey, pricetypecode, currencytypecode, activeind, budgetprice, finalprice, effectivedate, expirationdate, sortorder, lastuserid, lastmaintdate) VALUES
        (@NewPriceKey, @newBookKey, @PriceTypeCode, @CurrencyTypeCode, 1, @PriceAmount_j151, @PriceAmount_j151, dbo.date_from_onix_datestring(@PriceEffectiveFrom_j161), dbo.date_from_onix_datestring(@PriceEffectiveUntil_j162), @PriceEntryCount, @i_user, getdate());
      if (@@ERROR > 0)
      BEGIN
        SET @intErr = @intErr + 1048576
        SET @summary_error = @summary_error + 'ExError=18:';
        GOTO ExitHandler
      END
    END



    -- Get the next price entry so that it can be processed.
    FETCH NEXT FROM price_cursor INTO 
          @PriceTypeCode_j148,
          @ClassOfTrade_j149,
          @PriceAmount_j151,
          @CurrencyCode_j152,
          @PriceEffectiveFrom_j161,
          @PriceEffectiveUntil_j162
  
  END

  close price_cursor;
  deallocate price_cursor;


  -- 
  -- This code loads up any and all BISAC categories that
  -- are in the file.  The main one is put in as the first one
  -- and the rest are placed after it.
  DECLARE @BASIC_Subject_Count int;
  SET @BASIC_Subject_Count = 1;
  DECLARE @BISAC_Data_Code int;
  DECLARE @BISAC_SubData_Code int;

  if (@BASICMainSubject_b064 is not null)
  BEGIN
    select @BISAC_Data_Code = datacode, @BISAC_SubData_Code = datasubcode from subgentables where tableid=339 and onixcode = @BASICMainSubject_b064
    insert into bookbisaccategory (bookkey, printingkey, bisaccategorycode, bisaccategorysubcode, sortorder, lastuserid, lastmaintdate) VALUES 
       (@newBookKey, 1, @BISAC_Data_Code, @BISAC_SubData_Code, @BASIC_Subject_Count, @i_user, getdate())
    if (@@ERROR > 0)
    BEGIN
      SET @intErr = @intErr + 1048576
      SET @summary_error = @summary_error + 'ExError=19:';
      GOTO ExitHandler
    END
    SET @BASIC_Subject_Count = @BASIC_Subject_Count + 1;
  END

  -- Now find the ones that are in the
  --PRINT 'Getting subject information with internal query of product record.';
  DECLARE @SubjectSchemeIdentifier_b067 varchar(2);     -- 13.9  <SubjectSchemeIdentifier>03</SubjectSchemeIdentifier>
  DECLARE @SubjectSchemeName_b171 varchar(100);         -- 13.10 <SubjectSchemeName>21</SubjectSchemeName>
  DECLARE @SubjectSchemeVersion_b068 varchar(20);       -- 13.11 <SubjectSchemeVersion>2</SubjectSchemeVersion>
  DECLARE @SubjectCode_b069 varchar(30);                -- 13.12 <SubjectCode>2.01</SubjectCode>
  DECLARE @SubjectHeadingText_b070 varchar(100);        -- 13.13 <SubjectHeadingText>Labor and industrial relations</SubjectHeadingText>

  DECLARE subject_cursor CURSOR FOR 
  
  SELECT  SubjectSchemeIdentifier_b067,
          SubjectSchemeName_b171,
          SubjectSchemeVersion_b068,
          SubjectCode_b069,
          SubjectHeadingText_b070
    FROM OPENXML(@intDoc,  '/product/subject[b067=''10'']')
    WITH (SubjectSchemeIdentifier_b067 varchar(2) 'b067',
          SubjectSchemeName_b171 varchar(100) 'b171',
          SubjectSchemeVersion_b068 varchar(20) 'b068',
          SubjectCode_b069 varchar(30) 'b069',
          SubjectHeadingText_b070 varchar(100) 'b070'
         ) 

  open subject_cursor;
          
  FETCH NEXT FROM subject_cursor INTO 
          @SubjectSchemeIdentifier_b067,
          @SubjectSchemeName_b171,
          @SubjectSchemeVersion_b068,
          @SubjectCode_b069,
          @SubjectHeadingText_b070
        
  
  WHILE @@FETCH_STATUS = 0
  BEGIN
  
    -- Test
    --PRINT '@SubjectSchemeIdentifier_b067';
    --PRINT @SubjectSchemeIdentifier_b067;
    --PRINT '@SubjectSchemeName_b171';
    --PRINT @SubjectSchemeName_b171;
    --PRINT '@SubjectSchemeVersion_b068';
    --PRINT @SubjectSchemeVersion_b068;
    --PRINT '@SubjectCode_b069';
    --PRINT @SubjectCode_b069;
    --PRINT '@SubjectHeadingText_b070';
    --PRINT @SubjectHeadingText_b070;


    SET @BISAC_Data_Code = null
    SET @BISAC_SubData_Code = null
    select @BISAC_Data_Code = datacode, @BISAC_SubData_Code = datasubcode from subgentables where tableid=339 and onixcode = @SubjectCode_b069

    DECLARE @l_TempBookKey int
    SET @l_TempBookKey = null
    select @l_TempBookKey = bookkey from bookbisaccategory where bookkey=@newBookKey and printingkey = 1 and bisaccategorycode = @BISAC_Data_Code and bisaccategorysubcode = @BISAC_SubData_Code 

    if @l_TempBookKey is null
    BEGIN
      insert into bookbisaccategory (bookkey, printingkey, bisaccategorycode, bisaccategorysubcode, sortorder, lastuserid, lastmaintdate) VALUES 
         (@newBookKey, 1, @BISAC_Data_Code, @BISAC_SubData_Code, @BASIC_Subject_Count, @i_user, getdate())
      if (@@ERROR > 0)
      BEGIN
        SET @intErr = @intErr + 1048576
        SET @summary_error = @summary_error + 'ExError=20:';
        GOTO ExitHandler
      END
      SET @BASIC_Subject_Count = @BASIC_Subject_Count + 1;
    END
  FETCH NEXT FROM subject_cursor INTO 
          @SubjectSchemeIdentifier_b067,
          @SubjectSchemeName_b171,
          @SubjectSchemeVersion_b068,
          @SubjectCode_b069,
          @SubjectHeadingText_b070
    
  END

  close subject_cursor;
  deallocate subject_cursor;


  -- Audience Code
  --PRINT 'Audience Processing';
  DECLARE @AudienceCode int;
  DECLARE @AudienceCodeCount int;
  SET @AudienceCodeCount = 1;

  -- Now find the ones that are in the
  DECLARE @AudienceCode_b073 varchar(2); 
    
  DECLARE audience_cursor CURSOR FOR 
  
  SELECT  AudienceCode_b073
    FROM OPENXML(@intDoc,  '/product/b073')
    WITH (AudienceCode_b073 varchar(2) '.'
         ) 

  open audience_cursor;
          
  FETCH NEXT FROM audience_cursor INTO 
          @AudienceCode_b073
        
  
  WHILE @@FETCH_STATUS = 0
  BEGIN
  
    --PRINT '@AudienceCode_b073';
    --PRINT @AudienceCode_b073;

    SET @AudienceCode = null;
    SELECT @AudienceCode = datacode from gentables where tableid = 460 and onixcode = @AudienceCode_b073;


    insert into bookaudience (bookkey, audiencecode, sortorder, lastuserid, lastmaintdate) VALUES 
       (@newBookKey, @AudienceCode, @AudienceCodeCount, @i_user, getdate())
    if (@@ERROR > 0)
    BEGIN
      SET @intErr = @intErr + 104857
      SET @summary_error = @summary_error + 'ExError=21:';
      GOTO ExitHandler
    END
    SET @AudienceCodeCount = @AudienceCodeCount + 1;
  
  FETCH NEXT FROM audience_cursor INTO 
          @AudienceCode_b073
  
  END

  close audience_cursor;
  deallocate audience_cursor;


  -- Series (Stored in gentables, table id = 327)
  --PRINT 'Series Processing';
  DECLARE @SeriesCode int;

  DECLARE @TitleOfSeries_b018 varchar(300); 
    
  DECLARE series_cursor CURSOR FOR 
  
  SELECT  TitleOfSeries_b018
    FROM OPENXML(@intDoc,  '/product/series')
    WITH (TitleOfSeries_b018 varchar(300) 'b018'
         ) 

  open series_cursor;
          
  FETCH NEXT FROM series_cursor INTO 
          @TitleOfSeries_b018
        
  
  IF @@FETCH_STATUS = 0 and @TitleOfSeries_b018 is not null
  BEGIN
  
    -- Test
    --PRINT '@TitleOfSeries_b018';
    --PRINT @TitleOfSeries_b018;

    SET @SeriesCode = null;
    SELECT @SeriesCode = gt.datacode from gentables gt, gentablesorglevel gtol where gt.tableid = 327 and  gtol.tableid = gt.tableid and  gtol.datacode = gt.datacode  and gt.deletestatus = 'N' and gt.alternatedesc1 = @TitleOfSeries_b018;

    IF (@SeriesCode is null)
    BEGIN
      SELECT @SeriesCode = gt.datacode from gentables gt, gentablesorglevel gtol where gt.tableid = 327 and  gtol.tableid = gt.tableid and  gtol.datacode = gt.datacode  and gt.deletestatus = 'N' and gt.datadesc = @TitleOfSeries_b018;
    END
    -- Test
    --PRINT '@SeriesCode';
    --PRINT @SeriesCode;
    
    IF (@SeriesCode is null)
    BEGIN
      SET @FilterOrgLevlKey = null; 
      select @FilterOrgLevlKey=filterorglevelkey from gentablesdesc where tableid = 327
      
      if (@FilterOrgLevlKey is null)
      BEGIN
        UPDATE gentablesdesc SET filterorglevelkey=@i_publisher_org_level where tableid = 327
        if (@@ERROR > 0)
        BEGIN
          SET @intErr = @intErr + 104857
          SET @summary_error = @summary_error + 'ExError=22:';
          GOTO ExitHandler
        END
	    SET @FilterOrgLevlKey = @i_publisher_org_level; 
      END 

      --PRINT '@FilterOrgLevlKey'
      --PRINT @FilterOrgLevlKey
      select @SeriesCode = max(datacode)+1 from gentables where tableid=327
      insert into gentables (tableid, datacode, datadesc, datadescshort, deletestatus, tablemnemonic, alternatedesc1, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, lastuserid, lastmaintdate ) values
        (327, @SeriesCode, @TitleOfSeries_b018, CONVERT(varchar(20), @TitleOfSeries_b018), 'N', 'SERIES', @TitleOfSeries_b018, 1, 1, 0, 0, @i_user, getdate())
      if (@@ERROR > 0)
      BEGIN
        SET @intErr = @intErr + 524288
        SET @summary_error = @summary_error + 'Error inserting filter for series.'
        close series_cursor;
        deallocate series_cursor;
        GOTO ExitHandler
      END        
      insert into gentablesorglevel (tableid, datacode, orgentrykey, lastuserid, lastmaintdate) VALUES
        (327, @SeriesCode, @i_publisher_orgentry_key, @i_user, getdate() )
      if (@@ERROR > 0)
      BEGIN
        SET @intErr = @intErr + 524288
        SET @summary_error = @summary_error + 'Error inserting filter for series.'
        close series_cursor;
        deallocate series_cursor;
        GOTO ExitHandler
      END
    END

    --PRINT '@SeriesCode';
    --PRINT @SeriesCode;

    update bookdetail set seriescode = @SeriesCode where bookkey = @newBookKey;
  
-- Change back if you swithch back to a loop.
--  FETCH NEXT FROM series_cursor INTO 
--          @AudienceCode_b073
  
  END

  close series_cursor;
  deallocate series_cursor;
  if @o_error_code = -1
  BEGIN
    SET @o_error_code = 0
  END
  
  SET @summary_error = @summary_error + 'END:CODE-' + CONVERT(VARCHAR, @o_error_code) + ':@intErr-' + CONVERT(VARCHAR, @intErr) + ':';
  SET @o_error_desc = 'END: ';
  
ExitHandler:
    --print 'Exit Handler'
  SET @summary_error = @summary_error + 'EXIT:';
  SET @o_error_desc = 'EXIT: ';
 
    IF @bolOpen = 1 BEGIN
        --PRINT 'Removing Product Document';
        EXEC sp_xml_removedocument @intDoc

    END
    IF @bolHeaderOpen = 1 BEGIN
        --PRINT 'Removing Header Document';
        EXEC sp_xml_removedocument @intHeaderDoc

    END
  
  --PRINT '@@Error';
  --PRINT @@ERROR;
  if @bolTransactionStarted = 1
  BEGIN
    if @intErr = 0 and @@ERROR = 0
    BEGIN
      -- DEBUG
      --PRINT 'COMMIT Transaction'
      --ROLLBACK TRANSACTION
      --PRINT '@file_key';
      --PRINT @file_key;
      SET @summary_error = @summary_error + 'COMMIT:';
      SET @o_error_desc = 'COMMIT: ';

      COMMIT TRANSACTION ADDBOOK
      --(filekey, filename, customerid, starttime, messagetext, filestatus,  lastuserid, lastmaintdate) 
      --     VALUES (@file_key, @i_onix_filename, CONVERT(varchar, @i_publisher_orgentry_key), GETDATE(), 'EXCEPTION DURING PROCESSING', 0, @i_user, GETDATE());
      UPDATE importfileprocesslog SET customerid = '0' + CONVERT(varchar, @i_publisher_orgentry_key), 
                                      endtime = GETDATE(), 
                                      messagetext=@i_onix_filename + ' processed sucessfully.', 
                                      filestatus=1,
                                      lastuserid = @i_user
                                WHERE filekey = @file_key;

      UPDATE importfileprocesslog SET lastmaintdate = GETDATE()
                                WHERE filekey = @file_key;


     --select * from importfileprocesslog where filekey = @file_key;
     
     --insert into Jimtest (Message) VALUES ('Commited')


    END
    ELSE
    BEGIN
      if @intErr = 0 SET @intErr = @@ERROR

      -- PRINT 'ROLLBACK Transaction'
      -- PRINT 'ISBN';
      -- PRINT @ISBN10_b004
      SET @summary_error = @summary_error + 'ROLLBACK:';
      SET @o_error_desc = 'ROLLBACK: ';
      ROLLBACK TRANSACTION ADDBOOK
      UPDATE importfileprocesslog SET customerid = '0' + CONVERT(varchar, @i_publisher_orgentry_key), 
                                      endtime = GETDATE(), 
                                      messagetext=@i_onix_filename + ' pocessing failed.  ISBN not Entered : ' + @ISBN10_b004,
                                      filestatus=1,
                                      lastuserid = @i_user
                                WHERE filekey = @file_key;

      UPDATE importfileprocesslog SET lastmaintdate = GETDATE()
                                WHERE filekey = @file_key
      
      --insert into Jimtest (Message) VALUES ('Rolling back')

                                
     END
  END
  ELSE
  BEGIN
     -- No transaction started
      SET @summary_error = @summary_error + 'NOTRANS:';
      SET @o_error_desc = 'NOTRANS: ';

  END  

  --PRINT 'Returning....'
  SET @o_error_code = @intErr
  --print len(@summary_error)
  if @summary_error is not null
  BEGIN
    SET @o_error_desc = @summary_error;
  END
  ELSE
  BEGIN
    SET @o_error_desc = 'Summary is null, possible coding error and most likely using a convert to add a null object to the summary string.'
    --print 'Summary string is null : ERROR'
  END
  
  RETURN @intErr

  
END

GO

GRANT EXEC ON insert_or_update_title_from_onix_product TO PUBLIC
GO

PRINT 'STORED PROCEDURE : insert_or_update_title_from_onix_product complete'
GO


 

 