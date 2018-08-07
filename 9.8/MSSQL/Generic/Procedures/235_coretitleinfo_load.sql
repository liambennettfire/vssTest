set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

/******************************************************************************
**  Name: CoreTitleInfo_Load
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  02/10/2016   UK		     Case 36206
*******************************************************************************/

/*** Pass a bookkey and printingkey(optional) to update only 1 row (incremental) ***/
/*** NOTE:  Printingkey will default to 1 if not passed   ***/
/*** If no bookkey is passed in, then a full load is done ***/
ALTER PROCEDURE [dbo].[CoreTitleInfo_Load] 
(
	@i_bookkey int = 0,
	@i_printingkey int = 0
)
AS
BEGIN

DECLARE
  @v_firstrow			CHAR(1), 
  @v_isauthor			CHAR(1),
  @v_bookkey			INT,    
  @v_printingkey		INT,
  @v_printingkey_param		INT,  
  @v_media			INT,
  @v_format			INT,
  @v_editioncode 		INT,
  @v_bisacstatus		INT,
  @v_seriescode   		INT,
  @v_origincode   		INT,
  @v_seasonkey			INT,
  @v_count	 		INT,
  @v_authoption			INT,
  @v_childformat		INT,
  @v_imprintkey			INT,
  @v_imprintlevel		INT,
  @v_publisherkey		INT,
  @v_publisherlevel			INT,
  @v_tmmhdrlevel1		INT,
  @v_tmmhdrkey1			INT,
  @v_tmmhdrlevel2		INT,
  @v_tmmhdrkey2			INT,
  @v_publisherdesc VARCHAR(40),
  @v_orglevelkey		INT,
  @v_orgentrykey		INT,
  @v_pricetype		INT,
  @v_currency		INT,
  @v_currency_cdn		INT,  
  @v_set_pricetype	INT,
  @v_set_currency		INT,
  @v_allagesind			INT,
  @v_agelowupind		INT,
  @v_agehighupind		INT,
  @v_gradelowupind		INT,
  @v_gradehighupind		INT,
  @v_finalpriceind		INT,
  @v_agelow			FLOAT,
  @v_agehigh			FLOAT,
  @v_budgetprice		FLOAT,
  @v_finalprice			FLOAT,
  @v_budgetprice_cdn	FLOAT,
  @v_finalprice_cdn		FLOAT,
  @v_set_finalprice		FLOAT,
  @v_set_budgetprice	FLOAT,
  @v_pubdate			DATETIME,
  @v_reldate			DATETIME,
  @v_testdate			DATETIME,
  @v_gradelow			VARCHAR(4), 
  @v_gradehigh			VARCHAR(4),
  @v_authorname			VARCHAR(150),
  @v_tempstring			VARCHAR(50),
  @v_isbn			VARCHAR(13),
  @v_upc			VARCHAR(50),
  @v_ean			VARCHAR(50),
  @v_itemnumber VARCHAR(50),
  @v_gentabledesc		VARCHAR(40),
  @v_imprintdesc		VARCHAR(40),
  @v_tmmhdrorgdesc1		VARCHAR(40),
  @v_tmmhdrorgdesc2		VARCHAR(40),
  @v_ageinfo			VARCHAR(20),
  @v_gradeinfo			VARCHAR(20),
  @v_agegradeinfo		VARCHAR(40),
  @v_seasondesc			VARCHAR(80),
  @v_formatname			VARCHAR(120),
  @v_orgentryfilter		VARCHAR(40),
  @v_auth_firstname  		VARCHAR(75),
  @v_auth_lastname		VARCHAR(75),
  @v_auth_middlename		VARCHAR(75),
  @v_auth_suffix		VARCHAR(75),
  @v_auth_degree		VARCHAR(75),
  @v_auth_corpcontrind		TINYINT,
  @v_illus_firstname  		VARCHAR(75),
  @v_illus_lastname   		VARCHAR(75),
  @v_illus_middlename		VARCHAR(75),
  @v_illus_suffix		VARCHAR(75),
  @v_illus_degree		VARCHAR(75),
  @v_illus_corpcontrind		TINYINT,
  @v_source_bookkey		INT,
  @v_source_printingkey		INT,
  @v_source_mediatypecode	INT,
  @v_source_mediatypesubcode	INT,
  @v_source_editioncode		INT,
  @v_source_editiondescription VARCHAR(40),
  @v_source_bisacstatuscode	SMALLINT,
  @v_source_titleverifycode	SMALLINT,
  @v_source_seriescode		INT,
  @v_source_origincode		INT,
  @v_source_issuenumber		INT,
  @v_source_jobnumberalpha	CHAR(7),
  @v_source_title		VARCHAR(255),
  @v_source_subtitle  VARCHAR(255),
  @v_source_editionnumber INT,
  @v_source_titleprefix		VARCHAR(15),
  @v_source_shorttitle		VARCHAR(50),
  @v_source_titleprefixupper	VARCHAR(15),
  @v_source_pubmonthcode	INT,
  @v_pubmonth			VARCHAR(15),
  @v_source_pubyear		INT,
  @v_source_allagesind		INT,
  @v_source_agelowupind 	INT,
  @v_source_agehighupind 	INT,
  @v_source_agelow 		FLOAT,
  @v_source_agehigh 		FLOAT,
  @v_source_gradelowupind	INT,
  @v_source_gradehighupind	INT,
  @v_source_gradelow		VARCHAR(4),
  @v_source_gradehigh 		VARCHAR(4),
  @v_source_linklevelcode	TINYINT,
  @v_source_standardind		CHAR(1),
  @v_source_publishtowebind	CHAR(1),
  @v_source_sendtoeloind	CHAR(1),
  @v_source_seasonkey 		INT,
  @v_source_estseasonkey 	INT,
  @v_source_titlestatuscode	INT,
  @v_source_titletypecode	INT,
  @v_source_workkey		INT,
  @v_counter			INT,
  @v_columnname 		VARCHAR(50),
  @v_corecolumn			VARCHAR(20),
  @v_formatstr			VARCHAR(15),
  @v_columnnumber		TINYINT,
  @v_tableid			INT,
  @v_newvalue			FLOAT,
  @v_newvalue_str		VARCHAR(40), 
  @v_valuesclause		VARCHAR(2000),
  @v_sqlstring 			NVARCHAR(4000),
  @v_coltype			CHAR(9),
  @v_num			CHAR(2),
  @v_quote			CHAR(1),
  @v_edistatuscode  INT,
  @v_value_item     VARCHAR(50),
  @v_prodnum_set_column VARCHAR(50),
  @v_prodnum_set_table  VARCHAR(50),
  @v_prodnum_set_alt_column VARCHAR(50),
  @v_prodnum_set_alt_table  VARCHAR(50),
  @v_prodnum_title_column VARCHAR(50),
  @v_prodnum_title_table  VARCHAR(50),
  @v_prodnum_title_alt_table  VARCHAR(50),
  @v_prodnum_title_alt_column VARCHAR(50),
  @v_prodnum_column   VARCHAR(50),
  @v_prodnum_table    VARCHAR(50),
  @v_product_shortlabel_primary VARCHAR(7),
  @v_product_shortlabel_secondary VARCHAR(7),
  @v_product_shortlabel_full VARCHAR(50),
  @v_error  INT,
  @v_source_titleverifyelobasic		INT,
  @v_source_titleverifybna       INT,
  @v_source_titleverifybooknet     INT,
  @v_usageclasscode INT,
  @v_csapprovalcode	INT,
  @v_searchfield VARCHAR(2000)

IF @i_printingkey > 0 BEGIN
  SET @v_printingkey_param = @i_printingkey
END
ELSE BEGIN
  SET @v_printingkey_param = 1
END

DECLARE filterpricetype_tmm_cur CURSOR FOR
  SELECT pricetypecode, currencytypecode
  FROM filterpricetype
  WHERE filterkey = 5 	/* TMM Header Price - GENMSDEV 8,6 */

DECLARE filterpricetype_set_cur CURSOR FOR
  SELECT pricetypecode, currencytypecode
  FROM filterpricetype
  WHERE filterkey = 6 	/* Set Price - GENMSDEV 8,6 */
  
DECLARE gentables_cdn_cur CURSOR FOR
  SELECT datacode
  FROM gentables
  WHERE gentables.tableid = 122 AND 
	 gentables.qsicode = 1   /* Canadian Dollars */

IF @i_bookkey > 0 BEGIN
  /* 1 row */
  DECLARE source_cur CURSOR FOR
    SELECT p.bookkey,
	    p.printingkey,
	    p.issuenumber,
	    p.jobnumberalpha,
	    b.title,
	    b.subtitle,
	    bd.titleprefix,
	    b.shorttitle,
	    p.pubmonthcode,
	    YEAR(p.pubmonth) pubyear,
	    bd.mediatypecode,
	    bd.mediatypesubcode,
	    bd.editioncode, 
      bd.editionnumber,
	    bd.bisacstatuscode,
	    b.titlestatuscode,
	    b.titletypecode,
	    bd.seriescode,
	    bd.origincode,
	    p.estseasonkey,
	    p.seasonkey,
	    b.linklevelcode,
	    b.standardind,
	    bd.publishtowebind,
	    b.sendtoeloind,
	    b.workkey,
	    REPLACE(UPPER(bd.titleprefix), ' ', '') titleprefixupper,
	    bd.allagesind, 
	    bd.agelowupind, 
	    bd.agehighupind, 
	    bd.agelow, 
	    bd.agehigh,
	    bd.gradelowupind,
	    bd.gradehighupind, 
	    bd.gradehigh, 
	    bd.gradelow,
	    b.usageclasscode,	
	    bd.csapprovalcode
    FROM printing p,
	    book b,
	    bookdetail bd
    WHERE p.bookkey = b.bookkey AND
	    b.bookkey = bd.bookkey AND
      p.bookkey = @i_bookkey AND
      p.printingkey = @v_printingkey_param
    ORDER BY p.bookkey, p.printingkey
END
ELSE BEGIN
  /* all rows */
  DECLARE source_cur CURSOR fast_forward FOR    
    SELECT p.bookkey,
	    p.printingkey,
	    p.issuenumber,
	    p.jobnumberalpha,
	    b.title,
	    b.subtitle,
	    bd.titleprefix,
	    b.shorttitle,
	    p.pubmonthcode,
	    YEAR(p.pubmonth) pubyear,
	    bd.mediatypecode,
	    bd.mediatypesubcode,
	    bd.editioncode,
      bd.editionnumber,
	    bd.bisacstatuscode,
	    b.titlestatuscode,
	    b.titletypecode,
	    bd.seriescode,
	    bd.origincode,
	    p.estseasonkey,
	    p.seasonkey,
	    b.linklevelcode,
	    b.standardind,
	    bd.publishtowebind,
	    b.sendtoeloind,
	    b.workkey,
	    REPLACE(UPPER(bd.titleprefix), ' ', '') titleprefixupper,
	    bd.allagesind, 
	    bd.agelowupind, 
	    bd.agehighupind, 
	    bd.agelow, 
	    bd.agehigh,
	    bd.gradelowupind,
	    bd.gradehighupind, 
	    bd.gradehigh, 
	    bd.gradelow,
	    b.usageclasscode,
        bd.csapprovalcode
    FROM printing p,
	    book b,
	    bookdetail bd
    WHERE p.bookkey = b.bookkey AND
	    b.bookkey = bd.bookkey
    ORDER BY p.bookkey, p.printingkey
END

/* Check the client option for Author Full Displayname - prefer to use cursors to avoid raised exceptions */
DECLARE option_cur CURSOR FOR
  SELECT optionvalue
  FROM clientoptions
  WHERE optionname = 'full displayname'

OPEN option_cur 	
FETCH NEXT FROM option_cur INTO @v_authoption 

IF @@FETCH_STATUS < 0  /*option_cur%NOTFOUND */
  SET @v_authoption = 0 

CLOSE option_cur 
DEALLOCATE option_cur 

/* Get Price Type and Currency for the TMM Header Price */
OPEN filterpricetype_tmm_cur 	
FETCH NEXT FROM filterpricetype_tmm_cur INTO @v_pricetype, @v_currency 

IF @@FETCH_STATUS < 0  /* Default price to Retail US Dollars */
BEGIN
	SET @v_pricetype = 8 
	SET @v_currency = 6 
END

CLOSE filterpricetype_tmm_cur
DEALLOCATE filterpricetype_tmm_cur

/* Get Price Type and Currency for the Set Price */
OPEN filterpricetype_set_cur 	
FETCH NEXT FROM filterpricetype_set_cur INTO @v_set_pricetype, @v_set_currency 

IF @@FETCH_STATUS < 0  /* Default price to TMM Header */
BEGIN
	SET @v_set_pricetype = @v_pricetype 
	SET @v_set_currency = @v_currency
END

CLOSE filterpricetype_set_cur
DEALLOCATE filterpricetype_set_cur

/* Get Currency for the Canadian Price */
OPEN gentables_cdn_cur	
FETCH NEXT FROM gentables_cdn_cur INTO @v_currency_cdn

IF @@FETCH_STATUS < 0  /* Default currency to 11 - Candian Dollars */
BEGIN 
	SET @v_currency_cdn = 11
END

CLOSE gentables_cdn_cur
DEALLOCATE gentables_cdn_cur

/*** Get source table and column for the primary productnumber value for TITLES ***/
SELECT @v_prodnum_title_table = LOWER(tablename), @v_prodnum_title_column = LOWER(columnname)
FROM productnumlocation
WHERE productnumlockey = 1

/*** Get source table and column for the primary productnumber value for SETS ***/
SELECT @v_prodnum_set_table = LOWER(tablename), @v_prodnum_set_column = LOWER(columnname)
FROM productnumlocation
WHERE productnumlockey = 2

/*** Get source table and column for the secondary productnumber value for TITLES ***/
SELECT @v_prodnum_title_alt_table = LOWER(tablename), @v_prodnum_title_alt_column = LOWER(columnname)
FROM productnumlocation
WHERE productnumlockey = 3

/*** Get source table and column for the secondary productnumber value for SETS ***/
SELECT @v_prodnum_set_alt_table = LOWER(tablename), @v_prodnum_set_alt_column = LOWER(columnname)
FROM productnumlocation
WHERE productnumlockey = 4

/*** Get primary/secondary product short labels for TITLES ***/
SELECT @v_product_shortlabel_primary = labelshort
FROM isbnlabels
WHERE LOWER(columnname) = @v_prodnum_title_column

SELECT @v_product_shortlabel_secondary = labelshort
FROM isbnlabels
WHERE LOWER(columnname) = @v_prodnum_title_alt_column

SET @v_product_shortlabel_primary = LTRIM(RTRIM(@v_product_shortlabel_primary))
SET @v_product_shortlabel_secondary = LTRIM(RTRIM(@v_product_shortlabel_secondary))

IF @v_product_shortlabel_primary = @v_product_shortlabel_secondary
  SET @v_product_shortlabel_full = @v_product_shortlabel_primary
ELSE
  SET @v_product_shortlabel_full = @v_product_shortlabel_primary + ' / ' + @v_product_shortlabel_secondary

/*** Get primary/secondary product short labels for SETS ***/
SELECT @v_product_shortlabel_primary = labelshort
FROM isbnlabels
WHERE LOWER(columnname) = @v_prodnum_set_column

SELECT @v_product_shortlabel_secondary = labelshort
FROM isbnlabels
WHERE LOWER(columnname) = @v_prodnum_set_alt_column

SET @v_product_shortlabel_primary = LTRIM(RTRIM(@v_product_shortlabel_primary))
SET @v_product_shortlabel_secondary = LTRIM(RTRIM(@v_product_shortlabel_secondary))

IF CHARINDEX(@v_product_shortlabel_primary, @v_product_shortlabel_full) = 0
  SET @v_product_shortlabel_full = @v_product_shortlabel_full + ' / ' + @v_product_shortlabel_primary
  
IF CHARINDEX(@v_product_shortlabel_secondary, @v_product_shortlabel_full) = 0
  SET @v_product_shortlabel_full = @v_product_shortlabel_full + ' / ' + @v_product_shortlabel_secondary

/*** The combined primary/secondary product descriptions for titles and sets will be used ***/
/*** as the Product Number search criteria label (qse_searchcriteria, searchcriteriakey=61) ***/
UPDATE qse_searchcriteria
SET description = @v_product_shortlabel_full
WHERE searchcriteriakey = 61  /* Product Number */

/* Check at which organizational level this client stores Imprint */
SELECT @v_imprintlevel = filterorglevelkey
FROM filterorglevel
WHERE filterkey = 15  /* Imprint */
/* NOTE: not checking for errors here - IMPRINT filterorglevel record must exist */

/* Check at which organizational level this client stores Publisher */
SELECT @v_publisherlevel = filterorglevelkey
FROM filterorglevel
WHERE filterkey = 18  /* publisher */
/* NOTE: not checking for errors here - PUBLISHER filterorglevel record must exist */

/* Check at which organizational level this client stores TMM Header Display Level 1 */
SELECT @v_tmmhdrlevel1 = filterorglevelkey
FROM filterorglevel
WHERE filterkey = 16	/* Title Header Level One */
/* NOTE: not checking for errors here - TMM Header1 filterorglevel record must exist */

/* Check at which organizational level this client stores TMM Header Display Level 1 */
SELECT @v_tmmhdrlevel2 = filterorglevelkey
FROM filterorglevel
WHERE filterkey = 17	/* Title Header Level Two */
/* NOTE: not checking for errors here - TMM Header2 filterorglevel record must exist */

/** Initialize quote **/
SET @v_quote = CHAR(39) 

IF @i_bookkey > 0 BEGIN
  /*** Delete the row on coretitleinfo ***/
  DELETE FROM coretitleinfo
  WHERE bookkey = @i_bookkey
    AND printingkey = @v_printingkey_param
END
ELSE BEGIN
  /*** Delete all rows on coretitleinfo ***/
  TRUNCATE TABLE coretitleinfo  
END

/* <<source_cursor>> */
OPEN source_cur

FETCH NEXT FROM source_cur
INTO @v_source_bookkey, @v_source_printingkey, @v_source_issuenumber,@v_source_jobnumberalpha,
@v_source_title, @v_source_subtitle, @v_source_titleprefix, @v_source_shorttitle, @v_source_pubmonthcode,
@v_source_pubyear, @v_source_mediatypecode, @v_source_mediatypesubcode, @v_source_editioncode, @v_source_editionnumber,
@v_source_bisacstatuscode, @v_source_titlestatuscode, @v_source_titletypecode, @v_source_seriescode, 
@v_source_origincode, @v_source_estseasonkey, @v_source_seasonkey, @v_source_linklevelcode, 
@v_source_standardind, @v_source_publishtowebind, @v_source_sendtoeloind, @v_source_workkey, 
@v_source_titleprefixupper, @v_source_allagesind, @v_source_agelowupind,
@v_source_agehighupind, @v_source_agelow, @v_source_agehigh, @v_source_gradelowupind,
@v_source_gradehighupind, @v_source_gradehigh, @v_source_gradelow, @v_usageclasscode,@v_csapprovalcode 

WHILE (@@FETCH_STATUS = 0)  /*FOR @v_source_data IN source_cur LOOP */
  BEGIN
--begin transaction	
	SET @v_bookkey = @v_source_bookkey 
	SET @v_printingkey = @v_source_printingkey 
	SET @v_media = @v_source_mediatypecode 
	SET @v_format = @v_source_mediatypesubcode 
	SET @v_editioncode = @v_source_editioncode 
	SET @v_bisacstatus = @v_source_bisacstatuscode 
	SET @v_seriescode = @v_source_seriescode 
	SET @v_origincode = @v_source_origincode 
	SET @v_authorname = NULL 
	SET @v_tempstring = NULL 
	SET @v_ageinfo = NULL 
	SET @v_gradeinfo = NULL 
	SET @v_agegradeinfo = NULL
	SET @v_imprintkey = NULL
	SET @v_imprintdesc = NULL
	SET @v_tmmhdrkey1 = NULL
	SET @v_tmmhdrkey2 = NULL
	SET @v_tmmhdrorgdesc1 = NULL
	SET @v_tmmhdrorgdesc2 = NULL
	SET @v_orgentryfilter = NULL

	/* Convert month code into string */
	SELECT @v_pubmonth =
	CASE @v_source_pubmonthcode
	  WHEN 1 THEN 'January'
	  WHEN 2 THEN 'February'
	  WHEN 3 THEN 'March'
	  WHEN 4 THEN 'April'
	  WHEN 5 THEN 'May'
	  WHEN 6 THEN 'June'
	  WHEN 7 THEN 'July'
	  WHEN 8 THEN 'August'
	  WHEN 9 THEN 'September'
	  WHEN 10 THEN 'October'
	  WHEN 11 THEN 'November'
	  WHEN 12 THEN 'December'
	END

	--get title titleverifystatuscode from bookverification
	--this field has been moved from bookdetail
	select @v_source_titleverifycode = titleverifystatuscode 
	from bookverification
	where verificationtypecode = 1
	and bookkey = @v_bookkey

    select @v_source_titleverifyelobasic = titleverifystatuscode 
	from bookverification
	where verificationtypecode = 2
	and bookkey = @v_bookkey

    select @v_source_titleverifybna = titleverifystatuscode 
	from bookverification
	where verificationtypecode = 3
	and bookkey = @v_bookkey

    select @v_source_titleverifybooknet = titleverifystatuscode 
	from bookverification
	where verificationtypecode = 4
	and bookkey = @v_bookkey

	INSERT INTO coretitleinfo
	 (bookkey,
	 printingkey,
	 issuenumber,
	 jobnumberalpha,
	 title,
	 titleprefix,
	 shorttitle,
	 subtitle,
	 pubmonth,
	 pubyear,
	 mediatypecode,
	 mediatypesubcode,
	 editioncode,
   editionnumber,
	 bisacstatuscode,
	 titlestatuscode,
	 titletypecode,
	 seriescode,
	 origincode,
	 estseasonkey,
	 seasonkey,
	 linklevelcode,
	 itemtypecode,
   usageclasscode,
   usageclassdesc,
	 standardind,
	 publishtowebind,
	 sendtoeloind,
	 workkey,
	 titleprefixupper,
	 titleverifycode,
     verifelobasic,
     verifbna,
     verifbooknet,
     csapprovalcode )
	VALUES
	 (@v_bookkey,
	 @v_printingkey,
	 @v_source_issuenumber,
	 @v_source_jobnumberalpha,
	 @v_source_title,
	 @v_source_titleprefix,
	 @v_source_shorttitle,
	 @v_source_subtitle,
	 @v_pubmonth,
	 @v_source_pubyear,
	 @v_media,
	 @v_format,
	 @v_editioncode,
   @v_source_editionnumber,
	 @v_bisacstatus,
	 @v_source_titlestatuscode,
	 @v_source_titletypecode,
	 @v_seriescode,
	 @v_origincode,
	 @v_source_estseasonkey,
	 @v_source_seasonkey,
	 @v_source_linklevelcode,
	 1,
   @v_usageclasscode,
   dbo.get_subgentables_desc (550,1,@v_usageclasscode,'long'),
	 @v_source_standardind,
	 @v_source_publishtowebind,
	 @v_source_sendtoeloind,
	 @v_source_workkey,
	 @v_source_titleprefixupper,
	 @v_source_titleverifycode,
      @v_source_titleverifyelobasic,
      @v_source_titleverifybna,
      @v_source_titleverifybooknet,
      @v_csapprovalcode) 

	/*** Update the PRIMARY productnumber value (coretitleinfo.productnumber) ***/
	/*** based on productnumlocation table setup ***/
  IF @v_source_linklevelcode = 30  --SETS
    BEGIN
      SET @v_prodnum_table = @v_prodnum_set_table
      SET @v_prodnum_column = @v_prodnum_set_column
    END
  ELSE  --TITLES
    BEGIN
      SET @v_prodnum_table = @v_prodnum_title_table
      SET @v_prodnum_column = @v_prodnum_title_column
    END
    
  /*** 6/27/06 - KW - Build and run dynamic SQL select to get the given value ***/
  /*** based on productnumlocation configuration ***/
  SET @v_sqlstring = N'SELECT @p_value = ' + @v_prodnum_column + 
		  ' FROM ' + @v_prodnum_table +
		  ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_bookkey)
		
	EXECUTE sp_executesql @v_sqlstring, 
	    N'@p_value VARCHAR(50) OUTPUT', @v_value_item OUTPUT

  SELECT @v_error = @@ERROR
  IF @v_error = 0   --execute was successful
  BEGIN
    UPDATE coretitleinfo
    SET productnumber = @v_value_item, productnumberx = REPLACE(@v_value_item, '-', '')
    WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
    
    /* Also update productnumber when existing value different from update value */
    /* Note: trigger on productnumber is disabled for coretitle rerun */
    UPDATE productnumber
    SET productnumber = @v_value_item
    WHERE bookkey = @v_bookkey AND 
        (productnumber IS NULL OR productnumber <> @v_value_item)
  END
  
  
	/*** Update the SECONDARY productnumber value (coretitleinfo.altproductnumber) ***/
	/*** based on productnumlocation table setup ***/
  IF @v_source_linklevelcode = 30  --SETS
    BEGIN
      SET @v_prodnum_table = @v_prodnum_set_alt_table
      SET @v_prodnum_column = @v_prodnum_set_alt_column
    END
  ELSE  --TITLES
    BEGIN
      SET @v_prodnum_table = @v_prodnum_title_alt_table
      SET @v_prodnum_column = @v_prodnum_title_alt_column
    END
    
  /* Build and run dynamic SQL select to get the given value */
  SET @v_sqlstring = N'SELECT @p_value = ' + @v_prodnum_column + 
		  ' FROM ' + @v_prodnum_table +
		  ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_bookkey)
		
	EXECUTE sp_executesql @v_sqlstring, 
	    N'@p_value VARCHAR(50) OUTPUT', @v_value_item OUTPUT

  SELECT @v_error = @@ERROR
  IF @v_error = 0   --execute was successful
  BEGIN
    UPDATE coretitleinfo
    SET altproductnumber = @v_value_item, altproductnumberx = REPLACE(@v_value_item, '-', '')
    WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
  END   


	/*** Fill in Edistatuscode - Only for edipartnerkey = 1 ***/
	SELECT @v_count = count(*)
	FROM bookedistatus
	WHERE bookedistatus.bookkey = @v_bookkey AND
	      bookedistatus.printingkey = @v_printingkey AND
	      bookedistatus.edipartnerkey = 1

  IF @v_count <= 0
    SET @v_edistatuscode = 0
  ELSE
    SELECT @v_edistatuscode = edistatuscode
    FROM bookedistatus
    WHERE bookedistatus.bookkey = @v_bookkey AND
        bookedistatus.printingkey = @v_printingkey AND
        bookedistatus.edipartnerkey = 1

	UPDATE coretitleinfo
	SET edistatuscode = @v_edistatuscode
	WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey


	/*** Fill in AUTHOR NAME ***/
	SELECT @v_count = count(*)
	FROM bookauthor, author
	WHERE bookauthor.authorkey = author.authorkey AND
		bookauthor.bookkey = @v_bookkey AND
		bookauthor.primaryind = 1

	DECLARE author_cur CURSOR FOR
	SELECT a.firstname,
		a.lastname,			
		a.middlename,
		a.authorsuffix,
		a.authordegree,
		a.corporatecontributorind
	FROM bookauthor ba, author a
	WHERE ba.authorkey = a.authorkey AND
		ba.bookkey = @v_bookkey AND 
		ba.primaryind = 1 
	ORDER BY ba.sortorder 
	
	OPEN author_cur
	
	IF @v_count = 1 
	  BEGIN
		/* Fetch the primary author row */
		FETCH NEXT FROM author_cur 
		INTO @v_auth_firstname, @v_auth_lastname, @v_auth_middlename, @v_auth_suffix, @v_auth_degree, @v_auth_corpcontrind
	
		/* Generate Author displayname based on clientoption and the author data retrieved */
		IF @@FETCH_STATUS = 0
		  EXEC CoreAuthorDisplayname @v_authoption,'T',@v_auth_firstname,@v_auth_lastname,@v_auth_middlename,@v_auth_suffix,@v_auth_degree,@v_auth_corpcontrind,@v_authorname OUTPUT
	
	  END /* @v_count=1 */

	ELSE IF @v_count > 1
	  BEGIN
		/* Only show first 2 primary author lastnames */
		SET @v_firstrow = 'T'  /*TRUE*/
		SET @v_counter = 0
	
			 /* Fetch the primary author row */
		FETCH NEXT FROM author_cur 
		INTO @v_auth_firstname, @v_auth_lastname, @v_auth_middlename, @v_auth_suffix, @v_auth_degree, @v_auth_corpcontrind
	
		WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
		  BEGIN
			/* Use firstname if lastname is missing */
			SET @v_tempstring = @v_auth_lastname 
	
			IF @v_tempstring IS NULL 
			  SET @v_tempstring = @v_auth_firstname 
	
			IF @v_tempstring IS NOT NULL 
			  BEGIN       
				IF @v_firstrow = 'T'  /*TRUE*/ 
				  SET @v_authorname = @v_tempstring 
				ELSE
				  SET @v_authorname = @v_authorname + '/' + @v_tempstring 
			  END   	      
			
			SET @v_counter = @v_counter + 1
	
			/* When 2 primary author rows have been processed, exit - displayname will include first 2 primary authors if more exist */
			IF @v_counter = 2 
			  BREAK
	
			SET @v_firstrow = 'F'  /*FALSE*/
			 
			/* Fetch the primary author row */
			FETCH NEXT FROM author_cur 
			INTO @v_auth_firstname, @v_auth_lastname, @v_auth_middlename, @v_auth_suffix, @v_auth_degree, @v_auth_corpcontrind

		  END	/* @@FETCH_STATUS=0 */
	  END /* @v_count > 1 */
	
	CLOSE author_cur 
	DEALLOCATE author_cur
		
	IF @v_authorname IS NOT NULL
	  UPDATE coretitleinfo
	  SET authorname = @v_authorname
	  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
	
	SET @v_authorname = NULL 
	SET @v_tempstring = NULL 
	
	/*** Fill in ILLUSTRATOR NAME ***/
	SELECT @v_count = count(*)
	FROM bookauthor ba, author a, gentables g
	WHERE ba.authorkey = a.authorkey AND
		ba.authortypecode = g.datacode AND
		ba.bookkey = @v_bookkey AND			
		g.tableid = 134 AND
		g.gen2ind = 1
	
	DECLARE illus_cur CURSOR FOR
	SELECT a.firstname,
		a.lastname,			
		a.middlename,
		a.authorsuffix,
		a.authordegree,
		a.corporatecontributorind
	FROM bookauthor ba, author a, gentables g
	WHERE ba.authorkey = a.authorkey AND
		ba.authortypecode = g.datacode AND
		ba.bookkey = @v_bookkey AND 
		g.tableid = 134 AND
		g.gen2ind = 1
	ORDER BY ba.sortorder 
	
	OPEN illus_cur
	
	IF @v_count = 1 
	  BEGIN
		/* Fetch the illustrator row */
		FETCH NEXT FROM illus_cur 
		INTO @v_illus_firstname, @v_illus_lastname, @v_illus_middlename, @v_illus_suffix, @v_illus_degree, @v_illus_corpcontrind
	
		/* Generate Illustrator displayname based on clientoption and the illustrator data retrieved */
		IF @@FETCH_STATUS = 0
		  EXEC CoreAuthorDisplayname @v_authoption, 'T', @v_illus_firstname,@v_illus_lastname,@v_illus_middlename,@v_illus_suffix,@v_illus_degree,@v_illus_corpcontrind,@v_authorname OUTPUT

	  END	/* @v_count=1 */

	ELSE IF @v_count > 1 
	  BEGIN
		/* Only show first 2 illustrator lastnames */
		SET @v_firstrow = 'T'  /*TRUE*/
		SET @v_counter = 0
	
		/* Fetch the illustrator row */
		FETCH NEXT FROM illus_cur INTO @v_illus_firstname, @v_illus_lastname, @v_illus_middlename, @v_illus_suffix, @v_illus_degree, @v_illus_corpcontrind
		
		WHILE (@@FETCH_STATUS = 0) 
		  BEGIN
			/* Use firstname if lastname is missing */
			SET @v_tempstring = @v_illus_lastname 
			
			IF @v_tempstring IS NULL 
				SET @v_tempstring = @v_illus_firstname

			IF @v_tempstring IS NOT NULL 
			  BEGIN  
				IF @v_firstrow = 'T'  /*TRUE*/
				  SET @v_authorname = @v_tempstring 
				ELSE
				  SET @v_authorname = @v_authorname + '/' + @v_tempstring 
			  END
	
			SET @v_counter = @v_counter + 1
	
			/* When 2 illustrator rows have been processed, exit - displayname will include first 2 illustrators if more than 2 exist */
			IF @v_counter = 2 
			  BREAK  /*EXIT illustrator_cursor */
	  
			SET @v_firstrow = 'F'  /*FALSE*/
	
			/* Fetch the illustrator row */
			FETCH NEXT FROM illus_cur 
			INTO @v_illus_firstname, @v_illus_lastname, @v_illus_middlename, @v_illus_suffix, @v_illus_degree, @v_illus_corpcontrind

		  END	/* @@FETCH_STATUS=0 */
	  END /* @v_count > 1 */
	
	CLOSE illus_cur 
	DEALLOCATE illus_cur
		
	IF @v_authorname IS NOT NULL
		UPDATE coretitleinfo
		SET illustratorname = @v_authorname
		WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
	
	/*** Fill in PUB DATE ***/
    set @v_pubdate=null
    set @v_testdate=null
	  SELECT top 1 @v_pubdate=bestdate, @v_testdate=activedate
	  FROM pubdate_view
	  WHERE bookkey = @v_bookkey AND
			printingkey = @v_printingkey 
	  IF @v_pubdate IS NOT NULL 
		BEGIN
		  UPDATE coretitleinfo
		  SET bestpubdate = @v_pubdate
		  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
	
		  IF @v_pubdate = @v_testdate
			UPDATE coretitleinfo
			SET finalpubdateind = 1
			WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
		END 
	
	/*** Fill in RELEASE DATE ***/
      set @v_reldate=null
      set @v_testdate=null
	  SELECT top 1 @v_reldate=bestdate, @v_testdate=activedate
	  FROM releasedate_view
	  WHERE bookkey = @v_bookkey AND
			printingkey = @v_printingkey
	  IF @v_reldate IS NOT NULL 
		BEGIN
		  UPDATE coretitleinfo
		  SET bestreldate = @v_reldate
		  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey

		  IF @v_reldate = @v_testdate
			UPDATE coretitleinfo
			SET finalreldateind = 1
			WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
		END
	
	/*** Fill in FORMAT DESCRIPTION ***/
    set @v_formatname=null
	  SELECT top 1 @v_formatname=datadesc
	  FROM subgentables
	  WHERE tableid = 312 AND
			datacode = @v_media AND
			datasubcode = @v_format 
	
	  IF @v_formatname IS NOT NULL
		BEGIN
		  UPDATE coretitleinfo
		  SET formatname = @v_formatname
		  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
		END

	/*** Fill in EDITION DESCRIPTION ***/
    SELECT @v_source_editiondescription = editiondescription
      FROM bookdetail
     WHERE bookkey = @v_bookkey

    IF @v_source_editiondescription IS NULL OR @v_source_editiondescription = '' BEGIN
      SET @v_source_editiondescription = dbo.qtitle_get_edition_description(@v_bookkey)

	    IF @v_source_editiondescription IS NOT NULL 
		  BEGIN
		    UPDATE coretitleinfo
		    SET editiondesc = @v_source_editiondescription
		    WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
		  END
   END
   ELSE BEGIN
     UPDATE coretitleinfo
		    SET editiondesc = @v_source_editiondescription
		  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
	 END
	
	/*** Fill in BISAC STATUS DESCRIPTION ***/
	set @v_gentabledesc=null
	  SELECT top 1 @v_gentabledesc=datadesc
	  FROM gentables
	  WHERE tableid = 314 AND
			datacode = @v_bisacstatus 
	
	  IF @v_gentabledesc IS NOT NULL 
		BEGIN
		  UPDATE coretitleinfo
		  SET bisacstatusdesc = @v_gentabledesc
		  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
		END
	
	/*** Fill in Title Verify DESCRIPTION ***/
	set @v_gentabledesc=null
	  SELECT top 1 @v_gentabledesc=datadesc
	  FROM gentables
	  WHERE tableid = 513 AND
	   datacode = @v_source_titleverifycode 
	  IF @v_gentabledesc IS NOT NULL 
		BEGIN
		  UPDATE coretitleinfo
		  SET titleverifydesc = @v_gentabledesc
		  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
		END

/*** Fill in SERIES DESCRIPTION ***/
	set @v_gentabledesc=null
	  SELECT top 1 @v_gentabledesc=datadesc
	  FROM gentables
	  WHERE tableid = 327 AND
			datacode = @v_seriescode 
	  IF @v_gentabledesc IS NOT NULL 
		BEGIN
		  UPDATE coretitleinfo
		  SET seriesdesc = @v_gentabledesc
		  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
		END

	/*** Fill in ORIGIN DESCRIPTION ***/
	set @v_gentabledesc=null
	  SELECT top 1 @v_gentabledesc=datadesc
	  FROM gentables
	  WHERE tableid = 315 AND
		datacode = @v_origincode 
	  IF @v_gentabledesc IS NOT NULL 
		BEGIN
		  UPDATE coretitleinfo
		  SET origindesc = @v_gentabledesc
		  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
		END
	
	/*** Fill in SEASON information ***/
	SET @v_seasonkey = @v_source_seasonkey

	/* If Season is missing, use estimated season */
	IF @v_seasonkey IS NULL OR @v_seasonkey = 0 
	  SET @v_seasonkey = @v_source_estseasonkey

	/* Only if season or estimated season is filled in, get description and update core table */
	IF @v_seasonkey IS NOT NULL AND @v_seasonkey <> 0 			
	  BEGIN
		set @v_seasondesc=null
		  SELECT top 1 @v_seasondesc=seasondesc
		  FROM season
		  WHERE seasonkey = @v_seasonkey
		  IF @v_seasondesc IS NOT NULL 
			BEGIN
			  UPDATE coretitleinfo
			  SET bestseasonkey = @v_seasonkey,
					seasondesc = @v_seasondesc
			  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
			END
	  END	/* @v_seasonkey IS NOT NULL AND @v_seasonkey<>0 */
	
	/*** Fill in CHILDRENS FORMAT information ***/
	DECLARE childformat_cur CURSOR FOR
	  SELECT formatchildcode
	  FROM booksimon
	  WHERE bookkey = @v_bookkey 
	
	OPEN childformat_cur
	FETCH NEXT FROM childformat_cur INTO @v_childformat 
	
	IF @@FETCH_STATUS = 0  /*childformat_cur%FOUND */
	  IF @v_childformat IS NOT NULL AND @v_childformat <> 0 
		BEGIN
		  /* Get Children's Format description */
		  DECLARE childformatdesc_cur CURSOR FOR
			SELECT datadesc
			FROM gentables
			WHERE tableid = 300 AND
					datacode = @v_childformat 
	
		  OPEN childformatdesc_cur
		  FETCH NEXT FROM childformatdesc_cur INTO @v_gentabledesc 
	
		  IF @@FETCH_STATUS = 0  /*childformatdesc_cur%FOUND */
			IF @v_gentabledesc IS NOT NULL 
			  BEGIN
				UPDATE coretitleinfo
				SET formatchildcode = @v_childformat,
					childformatdesc = @v_gentabledesc
				WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
			  END 
	
		  CLOSE childformatdesc_cur 
		  DEALLOCATE childformatdesc_cur

		END /* @v_childformat IS NOT NULL AND @v_childformat<>0 */
	
	CLOSE childformat_cur 
	DEALLOCATE childformat_cur
	
	/*** Fill in IMPRINT information ****/
      set @v_imprintkey=null
      set @v_imprintdesc=null
	  SELECT @v_imprintkey=o.orgentrykey, @v_imprintdesc=o.orgentrydesc
	  FROM bookorgentry bo, orgentry o
	  WHERE bo.orgentrykey = o.orgentrykey AND
			bo.bookkey = @v_bookkey AND
			bo.orglevelkey = @v_imprintlevel
		IF @v_imprintdesc IS NOT NULL 
		  BEGIN
			UPDATE coretitleinfo
			SET imprintkey = @v_imprintkey,
				imprintname = @v_imprintdesc
			WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
		  END /* @v_gentabledesc IS NOT NULL */

	/*** Fill in TMM HEADER LEVEL 1 information ****/
	IF @v_imprintlevel = @v_tmmhdrlevel1
	  /* If TMM Header Level 1 is identical to Imprint level, use retrieved info above */
	  UPDATE coretitleinfo
	  SET tmmheaderorg1key = @v_imprintkey,
			tmmheaderorg1desc = @v_imprintdesc
	  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
	
	ELSE	/* @v_imprintlevel <> @v_tmmhdrlevel1 */
	  BEGIN
        set @v_tmmhdrkey1=null
        set @v_tmmhdrorgdesc1=null
		SELECT top 1 @v_tmmhdrkey1=o.orgentrykey, @v_tmmhdrorgdesc1=o.orgentrydesc
		  FROM bookorgentry bo, orgentry o
		  WHERE bo.orgentrykey = o.orgentrykey AND
				bo.bookkey = @v_bookkey AND
				bo.orglevelkey = @v_tmmhdrlevel1
     	  IF @v_tmmhdrorgdesc1 IS NOT NULL
			UPDATE coretitleinfo
			SET tmmheaderorg1key = @v_tmmhdrkey1,
				tmmheaderorg1desc = @v_tmmhdrorgdesc1
			WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
	  END /* @v_imprintlevel <> @v_tmmhdrlevel1 */
	
	/*** Fill in TMM HEADER LEVEL 2 information ****/
	IF @v_imprintlevel = @v_tmmhdrlevel2
	  /* If TMM Header Level 2 is identical to Imprint level, use retrieved info above */
	  UPDATE coretitleinfo
	  SET tmmheaderorg2key = @v_imprintkey,
			tmmheaderorg2desc = @v_imprintdesc
	  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
	
	ELSE IF @v_tmmhdrlevel1 = @v_tmmhdrlevel2
	  /* If TMM Header Level 2 is identical to TMM Header Level 1, use retrieved info above */
	  UPDATE coretitleinfo
	  SET tmmheaderorg2key = @v_tmmhdrkey1,
			tmmheaderorg2desc = @v_tmmhdrorgdesc1
	  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey

	ELSE
	  BEGIN /* @v_imprintlevel <> @v_tmmhdrlevel2 AND @v_tmmhdrlevel1 <> @v_tmmhdrlevel2 */
        set @v_tmmhdrkey2=null
        set @v_tmmhdrorgdesc2=null
		SELECT top 1 @v_tmmhdrkey2=o.orgentrykey, @v_tmmhdrorgdesc2=o.orgentrydesc
		  FROM bookorgentry bo, orgentry o
		  WHERE bo.orgentrykey = o.orgentrykey AND
				bo.bookkey = @v_bookkey AND
				bo.orglevelkey = @v_tmmhdrlevel2
	    IF @v_tmmhdrorgdesc2 IS NOT NULL
	 	  UPDATE coretitleinfo
		  SET tmmheaderorg2key = @v_tmmhdrkey2,
			tmmheaderorg2desc = @v_tmmhdrorgdesc2
		  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
	  END /* @v_imprintlevel <> @v_tmmhdrlevel2 AND @v_tmmhdrlevel1 <> @v_tmmhdrlevel2 */


	/*** Fill in PUBLISHER information ****/
	IF @v_imprintlevel = @v_publisherlevel
	  /* If Publisher Level is identical to Imprint level, use retrieved info above */
	  UPDATE coretitleinfo
	  SET publisherkey = @v_imprintkey,
		 publisherdesc= @v_imprintdesc
	  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
	
	ELSE IF @v_tmmhdrlevel1 = @v_publisherlevel
	  /* If Publisher Level is identical to TMM Header Level 1, use retrieved info above */
	  UPDATE coretitleinfo
	  SET publisherkey = @v_tmmhdrkey1,
		  publisherdesc = @v_tmmhdrorgdesc1
	  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey

	ELSE IF @v_tmmhdrlevel2 = @v_publisherlevel
	  /* If Publisher Level is identical to TMM Header Level 2, use retrieved info above */
	  UPDATE coretitleinfo
	  SET publisherkey = @v_tmmhdrkey2,
		  publisherdesc = @v_tmmhdrorgdesc2
	  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey

	ELSE
	  BEGIN /* @v_imprintlevel <> @v_publisherlevel AND @v_tmmhdrlevel1 <> v  AND <> @v_tmmhdrlevel2 <> @v_publisherlevel*/
        set @v_publisherkey=null
        set @v_publisherdesc=null
		SELECT top 1 @v_publisherkey=o.orgentrykey, @v_publisherdesc=o.orgentrydesc
		  FROM bookorgentry bo, orgentry o
		  WHERE bo.orgentrykey = o.orgentrykey AND
				bo.bookkey = @v_bookkey AND
				bo.orglevelkey = @v_publisherlevel
		  IF @v_publisherdesc IS NOT NULL
			UPDATE coretitleinfo
			  SET publisherkey = @v_publisherkey,
				publisherdesc = @v_publisherdesc
              WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
	  END /* @v_imprintlevel <> @v_tmmhdrlevel2 AND @v_tmmhdrlevel1 <> @v_tmmhdrlevel2 */
	
	/*** Fill in ORGENTRY FILTER string ****/
	DECLARE bookorgentry_cur CURSOR FOR
	  SELECT orglevelkey, orgentrykey
	  FROM bookorgentry
	  WHERE bookkey = @v_bookkey
	  ORDER BY orglevelkey 
	
	OPEN bookorgentry_cur
	
	FETCH bookorgentry_cur INTO @v_orglevelkey, @v_orgentrykey
	
	SET @v_counter = 1
	
	WHILE (@@FETCH_STATUS = 0)
	  BEGIN
		IF @v_counter = 1  /* bookorgentry_cur%ROWCOUNT*/
		  SET @v_orgentryfilter = '(' + LTRIM(STR(@v_orgentrykey))
		ELSE		
		  SET @v_orgentryfilter = @v_orgentryfilter + ',' + LTRIM(STR(@v_orgentrykey))
		
		FETCH bookorgentry_cur INTO @v_orglevelkey, @v_orgentrykey
	
		SET @v_counter = @v_counter + 1
	  END  /* LOOP (@@FETCH_STATUS = 0) */
	
	IF @v_orgentryfilter IS NOT NULL
	  BEGIN
		SET @v_orgentryfilter = @v_orgentryfilter + ')'
	
		UPDATE coretitleinfo
		SET orgentryfilter = @v_orgentryfilter
		WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
	  END
	
	CLOSE bookorgentry_cur
	DEALLOCATE bookorgentry_cur
	
	/*** Fill in AGE and GRADE information ***/
	SET @v_allagesind = @v_source_allagesind 
	SET @v_agelowupind = @v_source_agelowupind 
	SET @v_agehighupind = @v_source_agehighupind 
	SET @v_agelow = @v_source_agelow 
	SET @v_agehigh = @v_source_agehigh 
	SET @v_gradelowupind = @v_source_gradelowupind 
	SET @v_gradehighupind = @v_source_gradehighupind 
	SET @v_gradelow = @v_source_gradelow 
	SET @v_gradehigh = @v_source_gradehigh 

	IF @v_agelow IS NULL 
	  SET @v_agelow = 0 

	IF @v_agehigh IS NULL 
	  SET @v_agehigh = 0 

	IF @v_gradelow IS NULL 
	  SET @v_gradelow = '0' 
	
	IF @v_gradehigh IS NULL 
	  SET @v_gradehigh = '0' 

	IF @v_allagesind = 1 
	  SET @v_ageinfo = 'All' 
	ELSE IF @v_agelowupind = 1 
	  SET @v_ageinfo = 'Up to ' + LTRIM(STR(@v_agehigh))
	ELSE IF @v_agehighupind = 1 
	  SET @v_ageinfo = LTRIM(STR(@v_agelow)) + ' and up' 
	ELSE IF @v_agelow <> 0 AND @v_agehigh <> 0 
	  SET @v_ageinfo = LTRIM(STR(@v_agelow)) + ' to ' + LTRIM(STR(@v_agehigh))

	IF @v_gradelowupind = 1 
	  SET @v_gradeinfo = 'Up to ' + @v_gradehigh
	ELSE IF @v_gradehighupind = 1 
	  SET @v_gradeinfo = @v_gradelow + ' and up' 
	ELSE IF @v_gradelow <> '0' AND @v_gradehigh <> '0' 
	  SET @v_gradeinfo = @v_gradelow + ' to ' + @v_gradehigh

	IF @v_ageinfo IS NOT NULL AND @v_gradeinfo IS NOT NULL 
	  SET @v_agegradeinfo = @v_ageinfo + ' / ' + @v_gradeinfo 
	ELSE
	  BEGIN
		IF @v_gradeinfo IS NOT NULL 
		  SET @v_agegradeinfo = '/ ' + @v_gradeinfo 
		 ELSE IF @v_ageinfo IS NOT NULL 
			SET @v_agegradeinfo = @v_ageinfo 
	  END

	IF @v_agegradeinfo IS NOT NULL 		
	  BEGIN
		 UPDATE coretitleinfo
		 SET ageinfo = @v_agegradeinfo
		 WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey 
	  END  


  /* Reset price variables */
  SET @v_finalprice = NULL
  SET @v_budgetprice = NULL

	/*** Fill in the TMM Header price ***/
	DECLARE price_cur CURSOR FOR
	  SELECT budgetprice, finalprice
	  FROM bookprice
	  WHERE bookkey = @v_bookkey AND
		  pricetypecode = @v_pricetype AND
		  currencytypecode = @v_currency AND
		  activeind = 1

	OPEN price_cur
	FETCH NEXT FROM price_cur INTO @v_budgetprice, @v_finalprice 

	IF @@FETCH_STATUS = 0  /*price_cur%FOUND */
	  BEGIN
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
	 
		/* Only if budget or final price is filled in, update core table */
		IF @v_finalprice IS NOT NULL AND @v_finalprice <> 0 			
		  BEGIN
		    UPDATE coretitleinfo
		    SET tmmprice = @v_finalprice, finalpriceind = @v_finalpriceind
		    WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
		  END
	  END /* @@FETCH_STATUS=0 */

	CLOSE price_cur 
	DEALLOCATE price_cur 


	/*** Fill in the Canadian TMM Header price ***/
	DECLARE price_cur CURSOR FOR
	  SELECT budgetprice, finalprice
	  FROM bookprice
	  WHERE bookkey = @v_bookkey AND
		  pricetypecode = @v_pricetype AND
		  currencytypecode = @v_currency_cdn AND
		  activeind = 1

	OPEN price_cur
	FETCH NEXT FROM price_cur INTO @v_budgetprice_cdn, @v_finalprice_cdn 

	IF @@FETCH_STATUS = 0  /*price_cur%FOUND */
	  BEGIN
		/* If final price is missing, use budget price */
		IF @v_finalprice_cdn IS NULL OR @v_finalprice_cdn = 0 
		  BEGIN
		    SET @v_finalprice_cdn = @v_budgetprice_cdn
		  END
	 
		/* Only if budget or final price is filled in, update core table */
		IF @v_finalprice_cdn IS NOT NULL AND @v_finalprice_cdn <> 0 			
		  BEGIN
		    UPDATE coretitleinfo
		    SET canadianprice = @v_finalprice_cdn
		    WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
		  END
	  END /* @@FETCH_STATUS=0 */

	CLOSE price_cur 
	DEALLOCATE price_cur 


	/*** Fill in the Set Price ***/
	IF @v_set_pricetype = @v_pricetype AND @v_set_currency = @v_currency
	  BEGIN
		  UPDATE coretitleinfo
		  SET setprice = @v_finalprice
		  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
	  END
	ELSE
	  BEGIN
			DECLARE price_cur CURSOR FOR
				SELECT budgetprice, finalprice
				FROM bookprice
				WHERE bookkey = @v_bookkey AND
					pricetypecode = @v_set_pricetype AND
					currencytypecode = @v_set_currency AND
					activeind = 1
		
			OPEN price_cur
			FETCH NEXT FROM price_cur INTO @v_set_budgetprice, @v_set_finalprice 
		
			IF @@FETCH_STATUS = 0  /*price_cur%FOUND */
				BEGIN
				/* If final price is missing, use budget price */
				IF @v_set_finalprice IS NULL OR @v_set_finalprice = 0 
					BEGIN
						SET @v_set_finalprice = @v_set_budgetprice
					END
			 
				/* Only if budget or final price is filled in, update core table */
				IF @v_set_finalprice IS NOT NULL AND @v_set_finalprice <> 0 			
					BEGIN
						UPDATE coretitleinfo
						SET setprice = @v_set_finalprice
						WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
					END
				END /* @@FETCH_STATUS=0 */
		
			CLOSE price_cur 
			DEALLOCATE price_cur 
	  END
	
	
	/*** Fill in ISBN, EAN and UPC ***/
	SELECT @v_isbn = isbn, @v_ean = ean, @v_upc = upc, @v_itemnumber = itemnumber
	FROM isbn
	WHERE bookkey = @v_bookkey

  IF @v_isbn IS NOT NULL
  BEGIN
	  UPDATE coretitleinfo
	  SET isbn = @v_isbn, isbnx = REPLACE(@v_isbn, '-', '')
	  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
  END

  IF @v_ean IS NOT NULL
  BEGIN
    UPDATE coretitleinfo
    SET ean = @v_ean, eanx = REPLACE(@v_ean, '-', '')
    WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
  END

  IF @v_upc IS NOT NULL
  BEGIN
    UPDATE coretitleinfo
    SET upc = @v_upc, upcx = REPLACE(@v_upc, '-', '')
    WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
  END

   IF @v_itemnumber IS NOT NULL
  BEGIN
    UPDATE coretitleinfo
    SET itemnumber = @v_itemnumber
    WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
  END

  /* Get searchfield data*/
  exec [qtitle_get_coretitleinfo_searchfield] @v_bookkey, @v_searchfield OUTPUT
  UPDATE coretitleinfo
  SET searchfield = @v_searchfield
  WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey

  /******* Fill in CUSTOM fields *******/
  SET @v_valuesclause = ''

  DECLARE customfieldsetup_cur CURSOR FOR
    SELECT customfieldname, customfieldformat, corecustomcolnumber
    FROM customfieldsetup
    WHERE corecustomcolnumber IS NOT NULL
    ORDER BY corecustomcolnumber

  OPEN customfieldsetup_cur 

  FETCH NEXT FROM customfieldsetup_cur
  INTO @v_columnname, @v_formatstr, @v_columnnumber

  WHILE (@@FETCH_STATUS = 0)  /*customfieldsetup cursor LOOP*/
  BEGIN
    /*** Inititialize variables ***/
    SET @v_newvalue = NULL
    SET @v_newvalue_str = NULL

    /*** Get the column type and column number ***/	
    SET @v_coltype = SUBSTRING(@v_columnname, 1, 9)
    SET @v_num = RIGHT(@v_columnname, 2)	/** last 2 characters of column name **/

    /*** Get the bookcustom value for the column being processed ***/
    SET @v_sqlstring = N'SELECT @p_newvalue = ' + @v_columnname + 
      ' FROM bookcustom' +
      ' WHERE bookkey = @p_bookkey'

    EXECUTE sp_executesql @v_sqlstring, 
      N'@p_newvalue FLOAT OUTPUT,@p_bookkey INT', 
      @v_newvalue OUTPUT, @v_bookkey


    /*** When NO_DATA_FOUND error occurs here, there is no bookcustom record for this bookkey. ***/
    /*** Always update indicators to 'No' even in the cases where no bookcustom exists. ***/
    IF @@error = 1
    BEGIN
      IF @v_coltype = 'customind'
      BEGIN
        SET @v_corecolumn = 'customfield' + CONVERT(VARCHAR, @v_columnnumber)
        SET @v_newvalue_str = 'No'
        SET @v_sqlstring = N'UPDATE coretitleinfo SET ' +
          @v_corecolumn + ' = ' + @v_quote + @v_newvalue_str + @v_quote +
          ' WHERE bookkey = @p_bookkey'
        EXECUTE sp_executesql @v_sqlstring, N'@p_bookkey INT', @v_bookkey
      END

      FETCH NEXT FROM customfieldsetup_cur
      INTO @v_columnname, @v_formatstr, @v_columnnumber

      CONTINUE
    END

    /*** For Drop-downs, get the gentables description as the new string value. ***/
    IF @v_coltype = 'customcod'	/*** Drop-Down ***/
    BEGIN
      SELECT @v_tableid =
        CASE SUBSTRING(@v_columnname, 11, 2)
          WHEN '01' THEN 417
          WHEN '02' THEN 418
          WHEN '03' THEN 419
          WHEN '04' THEN 420
          WHEN '05' THEN 421
          WHEN '06' THEN 422
          WHEN '07' THEN 423
          WHEN '08' THEN 424
          WHEN '09' THEN 425
          WHEN '10' THEN 426
        END

      IF @v_newvalue IS NOT NULL
      SELECT @v_newvalue_str = datadesc
      FROM gentables
      WHERE tableid = @v_tableid AND datacode = @v_newvalue
    END

    /*** For Indicators, set 'Yes' or 'No' on coretitle. ***/
    ELSE IF @v_coltype = 'customind'	/** Indicator **/
    BEGIN
      IF @v_newvalue = 1
        SET @v_newvalue_str = 'Yes'
      ELSE
        SET @v_newvalue_str = 'No'
    END

    /*** For all other numeric columns, call the qutl_format_string function to format ***/
    /*** the new bookcustom value to string in the same format as coretitleinfo ***/
    /*** search results column for proper comparison. ***/
    ELSE
    BEGIN
      SET @v_newvalue_str = dbo.qutl_format_string(@v_newvalue, @v_formatstr)
    END

    -- Set core custom column based on column number
    SET @v_corecolumn = 'customfield' + CONVERT(VARCHAR, @v_columnnumber)
    -- Process quotes withing the value string
    SET @v_newvalue_str = REPLACE(@v_newvalue_str, @v_quote, @v_quote + @v_quote)

    /*** Check if this column needs to be updated on coretitleinfo table ***/
    IF @v_newvalue_str IS NULL  --value is null - check if not null value exists
      SET @v_sqlstring = N'SELECT @p_count = COUNT(*) FROM coretitleinfo ' +
        ' WHERE bookkey = @p_bookkey AND ' + @v_corecolumn + ' IS NOT NULL'
    ELSE  -- value is not null -check if NULL or different value exists
      SET @v_sqlstring = N'SELECT @p_count = COUNT(*) FROM coretitleinfo ' +
        ' WHERE bookkey = @p_bookkey AND (' + @v_corecolumn + ' IS NULL OR ' + 
        @v_corecolumn + '<>' + @v_quote + @v_newvalue_str + @v_quote + ')'

    EXECUTE sp_executesql @v_sqlstring, 
      N'@p_count INT OUTPUT, @p_bookkey INT', 
      @v_count OUTPUT, @v_bookkey
      
    /*** Build SQL update statement, if value not null ***/
    IF (@v_count = 0)
      BEGIN
        FETCH NEXT FROM customfieldsetup_cur
        INTO @v_columnname, @v_formatstr, @v_columnnumber

        CONTINUE
      END
    ELSE
      IF @v_valuesclause = ''
        SET @v_valuesclause = @v_corecolumn + ' = ' + @v_quote + @v_newvalue_str + @v_quote
      ELSE
        SET @v_valuesclause = @v_valuesclause + 
          ', ' + @v_corecolumn + ' = ' + @v_quote + @v_newvalue_str + @v_quote

    FETCH NEXT FROM customfieldsetup_cur
    INTO @v_columnname, @v_formatstr, @v_columnnumber

  END  /*customfieldsetup cursor LOOP*/

  /** Close the cursor **/
  CLOSE customfieldsetup_cur
  DEALLOCATE customfieldsetup_cur

  /*** Update coretitleinfo with all custom field values ***/
  IF @v_valuesclause <> ''
  BEGIN
    SET @v_sqlstring = N'UPDATE coretitleinfo SET ' + @v_valuesclause + ' WHERE bookkey = @p_bookkey'

    EXECUTE sp_executesql @v_sqlstring, N'@p_bookkey INT', @v_bookkey
  END


  /******* Fill in MISCELLANEOUS fields *******/
  SET @v_valuesclause = ''

  DECLARE miscfieldsetup_cur CURSOR FOR
    SELECT miscname, fieldformat, coretitlemisccolnumber
    FROM bookmiscitems
    WHERE coretitlemisccolnumber IS NOT NULL
    ORDER BY coretitlemisccolnumber

  OPEN miscfieldsetup_cur 

  FETCH NEXT FROM miscfieldsetup_cur
  INTO @v_columnname, @v_formatstr, @v_columnnumber

  WHILE (@@FETCH_STATUS = 0)  /*miscfieldsetup cursor LOOP*/
  BEGIN

    /* Call the qtitle_get_misc_value to get the value for this results column from bookmisc table */
    SET @v_newvalue_str = dbo.qtitle_get_misc_value(@v_bookkey, @v_columnnumber)
    SET @v_newvalue_str = REPLACE(@v_newvalue_str, @v_quote, @v_quote + @v_quote)

    SET @v_corecolumn = 'miscfield' + CONVERT(VARCHAR, @v_columnnumber)		  

    /*** Check if this column needs to be updated on coretitleinfo table ***/
    IF @v_newvalue_str IS NULL  --value is null - check if not null value exists
      SET @v_sqlstring = N'SELECT @p_count = COUNT(*) FROM coretitleinfo ' +
        ' WHERE bookkey = @p_bookkey AND ' + @v_corecolumn + ' IS NOT NULL'
    ELSE  -- value is not null - check if NULL or different value exists
      SET @v_sqlstring = N'SELECT @p_count = COUNT(*) FROM coretitleinfo ' +
        ' WHERE bookkey = @p_bookkey AND (' + @v_corecolumn + ' IS NULL OR ' + 
        @v_corecolumn + '<>' + @v_quote + @v_newvalue_str + @v_quote + ')'

    EXECUTE sp_executesql @v_sqlstring, 
      N'@p_count INT OUTPUT, @p_bookkey INT', 
      @v_count OUTPUT, @v_bookkey
      
    /*** Build SQL update statement ***/
    IF (@v_count = 0)
      BEGIN
        FETCH NEXT FROM miscfieldsetup_cur
        INTO @v_columnname, @v_formatstr, @v_columnnumber

        CONTINUE
      END
    ELSE
      IF @v_valuesclause = ''
        SET @v_valuesclause = @v_corecolumn + ' = ' + @v_quote + @v_newvalue_str + @v_quote
      ELSE
        SET @v_valuesclause = @v_valuesclause + 
          ', ' + @v_corecolumn + ' = ' + @v_quote + @v_newvalue_str + @v_quote  	

    FETCH NEXT FROM miscfieldsetup_cur
    INTO @v_columnname, @v_formatstr, @v_columnnumber

  END  /*miscfieldsetup cursor LOOP*/

  /** Close the cursor **/
  CLOSE miscfieldsetup_cur
  DEALLOCATE miscfieldsetup_cur

  /*** Update coretitleinfo with all Misc Item field values ***/
  IF @v_valuesclause IS NOT NULL AND @v_valuesclause <> ''
  BEGIN
    SET @v_sqlstring = N'UPDATE coretitleinfo SET ' + @v_valuesclause + ' WHERE bookkey = @p_bookkey'

    EXECUTE sp_executesql @v_sqlstring, N'@p_bookkey INT', @v_bookkey
  END

--commit 
  FETCH NEXT FROM source_cur
  INTO @v_source_bookkey, @v_source_printingkey, @v_source_issuenumber,@v_source_jobnumberalpha,
  @v_source_title, @v_source_subtitle, @v_source_titleprefix, @v_source_shorttitle, @v_source_pubmonthcode,
  @v_source_pubyear, @v_source_mediatypecode, @v_source_mediatypesubcode, @v_source_editioncode, @v_source_editionnumber,
  @v_source_bisacstatuscode, @v_source_titlestatuscode, @v_source_titletypecode, @v_source_seriescode, 
  @v_source_origincode, @v_source_estseasonkey, @v_source_seasonkey, @v_source_linklevelcode, 
  @v_source_standardind, @v_source_publishtowebind, @v_source_sendtoeloind, @v_source_workkey, 
  @v_source_titleprefixupper, @v_source_allagesind, @v_source_agelowupind,
  @v_source_agehighupind, @v_source_agelow, @v_source_agehigh, @v_source_gradelowupind,
  @v_source_gradehighupind, @v_source_gradehigh, @v_source_gradelow, @v_usageclasscode,@v_csapprovalcode 

END  /*LOOP source_cursor */

CLOSE source_cur
DEALLOCATE source_cur

END