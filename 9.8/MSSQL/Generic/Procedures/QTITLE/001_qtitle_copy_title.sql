if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_create_title') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_create_title 
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_copy_title') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_copy_title
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_copy_title
 (@i_bookkey                integer,
  @i_printingkey            integer,
  @i_templatebookkey        integer,
  @i_templateprintingkey    integer,
  @i_copydatagroups_list	  varchar(2000),
  @i_cleardatagroups_list	  varchar(2000),
  @i_userid                 varchar(30),
  @i_titleprefix            varchar(15),
  @o_error_code             integer output,
  @o_error_desc             varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_copy_title
**  Desc: This stored procedure will copy information from a 
**        template/title to a new title during title creation process.
**
**  Auth: Kate Wiewiora
**  Date: 26 May 2009
*********************************************************************************************************************
**  Change History
**********************************************************************************************************************
**  Date:     Author: Description:
**  -----     ------  -------------------------------------------
**  07/21/16  Kusum   Case 35718 - Enable Copy Misc Configuration by Misc. Item
**  09/09/16  Uday	  Case 40327
**  11/10/16  Uday    Case 41641
**  08/15/17  Colman  Case 41074 - XML parse error while writing title history record for BIC categories 
**  03/26/18  Colman  Case 49769 - Added copyfrombookkey column
********************************************************************************************************************/

DECLARE
  @v_client_option tinyint,
  @v_prox_name varchar(200),
  @v_sql nvarchar(500),
  @v_action_count INT,
  @v_activedate DATETIME,
  @v_activeind  TINYINT,
  @v_actualind  TINYINT,
  @v_actualinsertillus  VARCHAR(255),
  @v_addtleditioninfo VARCHAR(100),
  @v_agehigh  FLOAT,
  @v_agehighind TINYINT,
  @v_agelow FLOAT,
  @v_agelowind TINYINT,
  @v_allagesind TINYINT,
  @v_announcedfirstprint  INT,
  @v_assobookkey  INT,
  @v_assotitles_xml  VARCHAR(MAX),
  @v_assotype INT,
  @v_assosubtype  INT,
  @v_audiencecode INT,
  @v_audiocassettespecs_xml VARCHAR(2000),
  @v_authorkey  INT,
  @v_authortype INT,
  @v_authortypedesc VARCHAR(40),
  @v_autodescind  TINYINT,
  @v_barcode1 INT,
  @v_barcodepos1  INT,
  @v_barcode2 INT,
  @v_barcodepos2  INT,
  @v_bindingspecs_xml VARCHAR(2000),
  @v_bisacstatus  INT,
  @v_book_xml VARCHAR(2000),
  @v_bookaudience_xml VARCHAR(MAX),
  @v_bookauthor_xml VARCHAR(MAX),
  @v_bookbisaccategory_xml  VARCHAR(MAX),
  @v_bookbulk FLOAT,
  @v_bookcategory_xml VARCHAR(MAX),
  @v_bookcomments_xml VARCHAR(MAX),
  @v_bookcontactkey INT,
  @v_bookcontact_xml  VARCHAR(MAX),
  @v_bookcustom_xml VARCHAR(MAX),
  @v_bookdates_xml  VARCHAR(MAX),
  @v_bookdetail_xml VARCHAR(MAX),
  @v_bookmisc_xml VARCHAR(MAX),
  @v_bookpos  INT,
  @v_bookprice_xml  VARCHAR(MAX),
  @v_booksets_xml   VARCHAR(2000),
  @v_booksimon_xml  VARCHAR(2000),
  @v_booksubjectcategory_xml  VARCHAR(MAX),
  @v_bookver_xml  VARCHAR(MAX),
  @v_bookweight FLOAT,
  @v_bookweight_UOM INT,
  @v_budgetprice  FLOAT,
  @v_cartonqty  INT,
  @v_categorycode INT,
  @v_categorydesc VARCHAR(120),
  @v_categorysubcode  INT,
  @v_categorysubdesc  VARCHAR(120),
  @v_categorysub2code INT,
  @v_categorysub2desc VARCHAR(120),
  @v_categorytableid  INT,
  @v_citation_author VARCHAR(80),
  @v_citation_date DATETIME,
  @v_citation_desc VARCHAR(40),
  @v_citation_historyorder INT,
  @v_citation_proofedind INT,
  @v_citation_qsiobjectkey INT,
  @v_citation_reltoeloq INT,
  @v_citation_sortorder INT,
  @v_citation_source VARCHAR(80),
  @v_citation_typecode INT,
  @v_citation_externaltypecode  INT,
  @v_citation_webind INT,
  @v_citations_xml VARCHAR(MAX),
  @v_cleardata  CHAR(1),
  @v_cleardates CHAR(1),
  @v_commentkey INT,
  @v_commentkey2 INT,
  @v_commenttype  INT,
  @v_commentsubtype INT,
  @v_commentstring  VARCHAR(2000),
  @v_contactkey INT,
  @v_contactkey2  INT,
  @v_contractexclusiveind TINYINT,
  @v_contractterritorycode  INT,
  @v_countrycode  INT,
  @v_countrygroupcode INT,
  @v_copycontacts CHAR(1),
  @v_copyrightyear INT,
  @v_count  INT,
  @v_count2 INT,
  @v_currencydesc VARCHAR(40),
  @v_currencyshort  VARCHAR(20),
  @v_currencytype INT,
  @v_currentcategorytableid INT,
  @v_curterritorycode INT,
  @v_custcode01  INT,
  @v_custcode02  INT,
  @v_custcode03  INT,
  @v_custcode04  INT,
  @v_custcode05  INT,
  @v_custcode06  INT,
  @v_custcode07  INT,
  @v_custcode08  INT,
  @v_custcode09  INT,
  @v_custcode10  INT,
  @v_custfloat01  FLOAT,
  @v_custfloat02  FLOAT,
  @v_custfloat03  FLOAT,
  @v_custfloat04  FLOAT,
  @v_custfloat05  FLOAT,
  @v_custfloat06  FLOAT,
  @v_custfloat07  FLOAT,
  @v_custfloat08  FLOAT,
  @v_custfloat09  FLOAT,
  @v_custfloat10  FLOAT,  
  @v_custind01  TINYINT,
  @v_custind02  TINYINT,
  @v_custind03  TINYINT,
  @v_custind04  TINYINT,
  @v_custind05  TINYINT,
  @v_custind06  TINYINT,
  @v_custind07  TINYINT,
  @v_custind08  TINYINT,
  @v_custind09  TINYINT,
  @v_custind10  TINYINT,
  @v_custint01  INT,
  @v_custint02  INT,
  @v_custint03  INT,
  @v_custint04  INT,
  @v_custint05  INT,
  @v_custint06  INT,
  @v_custint07  INT,
  @v_custint08  INT,
  @v_custint09  INT,
  @v_custint10  INT,
  @v_datacode INT,
  @v_datadesc  VARCHAR(120),
  @v_datetype INT,
  @v_dbitem_count INT,
  @v_dbitem_count2  INT,
  @v_decisioncode INT,
  @v_department INT,
  @v_description  VARCHAR(2000),
  @v_discount INT,
  @v_discountpercent  FLOAT,
  @v_duration INT,
  @v_edistatus  SMALLINT,
  @v_edition  INT,
  @v_editiondesc  VARCHAR(150),
  @v_editionnum INT,
  @v_elementkey INT,
  @v_error  INT,
  @v_estannouncedfirstprint INT,
  @v_estdate  DATETIME,
  @v_estinsertillus VARCHAR(255),
  @v_estprojectedsales  INT,
  @v_estseasonkey INT,
  @v_esttrimlength VARCHAR(10),
  @v_esttrimwidth  VARCHAR(10),
  @v_exclusivecode  INT,
  @v_expdate  DATETIME,
  @v_effectivedate DATETIME,
  @v_expshipdate_req  TINYINT,
  @v_expshipdate_code INT,
  @v_fielddesc  VARCHAR(120),
  @v_filedesc VARCHAR(255),
  @v_fileformat INT,
  @v_filelocation_xml VARCHAR(MAX),
  @v_filelocationkey  INT,
  @v_filestatus INT, 
  @v_filetype  SMALLINT,
  @v_finalprice FLOAT,
  @v_firstprintqty INT,
  @v_floatvalue FLOAT,
  @v_formatchild  INT,
  @v_formatkey  INT,
  @v_formatdesc VARCHAR(120),
  @v_forsaleind INT,
  @v_fullauthorkey  INT,
  @v_fullauthorname VARCHAR(255),
  @v_globalcontactkey INT,
  @v_gradehigh  VARCHAR(4),
  @v_gradehighind TINYINT,
  @v_gradelow VARCHAR(4),
  @v_gradelowind  TINYINT,
  @v_hiddenstatus INT,
  @v_historyorder INT,
  @v_illustrations VARCHAR(255),
  @v_ind1 TINYINT,
  @v_ind2 TINYINT,
  @v_initial_status INT,
  @v_isbn VARCHAR(19),
  @v_iselotab TINYINT,
  @v_itemtype INT,
  @v_keyind TINYINT,
  @v_language INT,
  @v_language2 INT,
  @v_locationtype INT,
  @v_longvalue  INT,
  @v_ltdpos INT,
  @v_mediatype  INT,
  @v_mediasubtype INT,
  @v_misckey  INT,
  @v_misctype INT,
  @v_newkeycount  INT,
  @v_newkey INT,
  @v_newkeys_str  VARCHAR(4000),
  @v_newtitleheading  INT,
  @v_note VARCHAR(2000),
  @v_numcassettes INT,
  @v_numtitles  INT,
  @v_origin INT,
  @v_originaldate DATETIME,
  @v_origpubhouse INT,
  @v_pagecount  INT,
  @v_participantnote  VARCHAR(2000),
  @v_path VARCHAR(2000),  
  @v_paymentamt NUMERIC(9, 2),
  @v_platform INT,
  @v_prevyrpos  INT,
  @v_price  FLOAT,
  @v_pricekey INT,
  @v_pricetypedesc  VARCHAR(40),
  @v_pricetypeshort VARCHAR(20),
  @v_pricetype  INT,
  @v_pricevalgroupcode INT,
  @v_primaryind TINYINT,
  @v_printing_xml VARCHAR(MAX),
  @v_prodavailability INT,
  @v_productidtype  INT,
  @v_projectkey INT,
  @v_projectrole  SMALLINT,
  @v_pubdate  DATETIME,
  @v_pubmonth DATETIME,
  @v_pubmonthcode INT,
  @v_qsicomments_commentkey INT,
  @v_qsicomments_invalidhtmlind INT,
  @v_qsicomments_parenttable VARCHAR(30),
  @v_qsicomments_reltoeloq INT,
  @v_qsicomments_subtypecode INT,
  @v_qsicomments_typecode INT,
  @v_qty1 INT,
  @v_qty2 INT,  
  @v_quote  CHAR(1),
  @v_ratetype INT,
  @v_relateditemname  VARCHAR(100),
  @v_relateditemparticipants VARCHAR(100),
  @v_relateditemstatus  VARCHAR(100),
  @v_reltoeloind  TINYINT,
  @v_reportind  TINYINT, 
  @v_restriction  INT,
  @v_return INT,
  @v_rightskey  INT,
  @v_role INT,
  @v_role2  INT,
  @v_rowcount INT,
  @v_salesdivision  INT,
  @v_salesrestriction  INT,
  @v_salesunitgross INT,
  @v_salesunitnet INT,
  @v_scheduleind TINYINT,
  @v_seasonkey  INT,
  @v_sendtoeloind TINYINT,
  @v_series INT,
  @v_settype  INT,
  @v_simulpubind  TINYINT,
  @v_slot INT,
  @v_sortorder  INT,
  @v_sortorder_price INT,
  @v_spinesize  VARCHAR(15),
  @v_spinesize_UOM INT,
  @v_stagecode  INT,
  @v_taqprojecttask_xml VARCHAR(MAX),
  @v_taqprojecttitle_xml VARCHAR(MAX),
  @v_taskkey  INT,
  @v_taskqty  INT,
  @v_tentativepagecount INT,
  @v_tentativeqty INT,
  @v_territories  INT,
  @v_territorialrights_xml  VARCHAR(MAX),
  @v_territoryrightskey INT,
  @v_test_activedate  DATETIME,
  @v_test_actualinsertillus VARCHAR(255),
  @v_test_addtleditioninfo  VARCHAR(100),
  @v_test_agehigh  FLOAT,
  @v_test_agehighind TINYINT,
  @v_test_agelow FLOAT,
  @v_test_agelowind TINYINT,
  @v_test_allagesind TINYINT,
  @v_test_announcedfirstprint INT,
  @v_test_barcode1  INT,
  @v_test_barcodepos1 INT,
  @v_test_barcode2  INT,
  @v_test_barcodepos2 INT,
  @v_test_bisacstatus INT,
  @v_test_bookbulk  FLOAT,
  @v_test_bookweight  FLOAT,
  @v_test_bookweight_UOM INT,
  @v_test_budgetprice FLOAT,
  @v_test_cartonqty   INT,
  @v_test_copyrightyear INT,
  @v_test_custcode01  INT,
  @v_test_custcode02  INT,
  @v_test_custcode03  INT,
  @v_test_custcode04  INT,
  @v_test_custcode05  INT,
  @v_test_custcode06  INT,
  @v_test_custcode07  INT,
  @v_test_custcode08  INT,
  @v_test_custcode09  INT,
  @v_test_custcode10  INT,
  @v_test_custfloat01  FLOAT,
  @v_test_custfloat02  FLOAT,
  @v_test_custfloat03  FLOAT,
  @v_test_custfloat04  FLOAT,
  @v_test_custfloat05  FLOAT,
  @v_test_custfloat06  FLOAT,
  @v_test_custfloat07  FLOAT,
  @v_test_custfloat08  FLOAT,
  @v_test_custfloat09  FLOAT,
  @v_test_custfloat10  FLOAT,  
  @v_test_custind01  TINYINT,
  @v_test_custind02  TINYINT,
  @v_test_custind03  TINYINT,
  @v_test_custind04  TINYINT,
  @v_test_custind05  TINYINT,
  @v_test_custind06  TINYINT,
  @v_test_custind07  TINYINT,
  @v_test_custind08  TINYINT,
  @v_test_custind09  TINYINT,
  @v_test_custind10  TINYINT,
  @v_test_custint01  INT,
  @v_test_custint02  INT,
  @v_test_custint03  INT,
  @v_test_custint04  INT,
  @v_test_custint05  INT,
  @v_test_custint06  INT,
  @v_test_custint07  INT,
  @v_test_custint08  INT,
  @v_test_custint09  INT,
  @v_test_custint10  INT,  
  @v_test_discount  INT,
  @v_test_discountpercent FLOAT,
  @v_test_edition   INT,
  @v_test_editiondesc  VARCHAR(150),
  @v_test_editionnum INT,
  @v_test_estannouncedfirstprint  INT,
  @v_test_estinsertillus  VARCHAR(255),
  @v_test_estprojectedsales	INT,
  @v_test_estseasonkey  INT,
  @v_test_esttrimlength VARCHAR(10),
  @v_test_esttrimwidth  VARCHAR(10),
  @v_test_finalprice  FLOAT,
  @v_test_firstprintqty INT,
  @v_test_floatvalue  FLOAT,
  @v_test_formatchild INT, 
  @v_test_fullauthorkey INT,
  @v_test_fullauthorname  VARCHAR(255),
  @v_test_gradehigh  VARCHAR(4),
  @v_test_gradehighind TINYINT,
  @v_test_gradelow VARCHAR(4),
  @v_test_gradelowind  TINYINT,
  @v_test_language  INT,
  @v_test_language2 INT,
  @v_test_longvalue INT,
  @v_test_mediasubtype  INT,
  @v_test_mediatype   INT,
  @v_test_newtitleheading INT,
  @v_test_numcassettes  INT,
  @v_test_origin  INT,
  @v_test_originaldate  DATETIME,
  @v_test_pagecount INT,
  @v_test_platform  INT,
  @v_test_prodavailability  INT,
  @v_test_pricevalgroupcode INT,
  @v_test_pubmonth  DATETIME,
  @v_test_pubmonthcode  INT,
  @v_test_restriction INT,
  @v_test_return  INT,
  @v_test_salesdivision INT,
  @v_test_salesrestriction INT,
  @v_test_seasonkey INT,
  @v_test_series  INT,
  @v_test_settype INT,
  @v_test_simulpubind TINYINT,
  @v_test_slot  INT,
  @v_test_spinesize VARCHAR(15),
  @v_test_spine_UOM INT,
  @v_test_tentativepagecount  INT,
  @v_test_tentativeqty INT,      
  @v_test_territories INT,
  @v_test_textvalue VARCHAR(4000),
  @v_test_titleprefix VARCHAR(15),
  @v_test_titlestatus INT, 
  @v_test_titletype INT,
  @v_test_tmmactualtrimlength VARCHAR(10),
  @v_test_tmmactualtrimwidth  VARCHAR(10),
  @v_test_tmmpagecount  INT,
  @v_test_totalruntime  VARCHAR(10),
  @v_test_trimlength  VARCHAR(10),
  @v_test_trimwidth VARCHAR(10),  
  @v_test_trim_UOM  INT,
  @v_test_userlevel INT,
  @v_test_volume  INT,
  @v_textvalue  VARCHAR(4000),
  @v_title  VARCHAR(255),
  @v_titlerole  SMALLINT,
  @v_titlestatus  INT,
  @v_titletype  INT,
  @v_tmmpagecount INT,
  @v_tmmactualtrimlength  VARCHAR(10),
  @v_tmmactualtrimwidth VARCHAR(10),
  @v_totalruntime VARCHAR(10),
  @v_transaction_xml  VARCHAR(MAX),
  @v_trimlength VARCHAR(10),
  @v_trimwidth  VARCHAR(10),
  @v_trimsize_UOM INT,
  @v_userlevel  INT,
  @v_verifdesc  VARCHAR(120),
  @v_veriftype  INT,
  @v_volume INT,
  @v_warnings_str VARCHAR(4000),
  @v_websched_option TINYINT,
  @v_workrate FLOAT,
  @v_ytdpos INT,
  @v_keycount INT,
  @v_encoding_string VARCHAR(50),
  @v_work_projectrolecode INT,
  @v_comment_cnt INT,
  @v_csverifytype INT,
  @v_discoveryquestions_xml VARCHAR(MAX),
  @v_questioncommentkey  INT, 
  @v_answercommentkey  INT,
  @v_qsicode INT,
  @v_itemnumber VARCHAR(20),
  @v_startdate  DATETIME,
  @v_startdateactualind TINYINT,
  @v_lag  INT,
  @v_test_startdate DATETIME,
  @v_taqtaskkey INT,
  @taqprojecttaskoverride_rowcount INT,
  @o_taqtaskkey   INT,
  @o_returncode   INT,
  @o_restrictioncode INT,
  @v_restriction_value_title INT,
  @v_transactionkey INT,
  @v_bookproductdetail_xml  VARCHAR(MAX),
  @v_tableid  INT,
  @v_productdatadesc VARCHAR(120),
  @v_productdatasubdesc  VARCHAR(120),
  @v_productdatasub2desc VARCHAR(120),
  @v_productdatacode INT,
  @v_productdatasubcode  INT,
  @v_productdatasub2code INT,
  @v_jacketspecs_xml VARCHAR(2000),
  @v_textspecs_xml VARCHAR(2000),   
  @v_vendorkey INT,
  @o_jobnumberseq  CHAR(7),
  @v_generate_jobnumberalpha INT,
  @v_erroroutputind  INT,
  @v_bookkeywords_xml	VARCHAR(MAX),
  @v_keyword	VARCHAR(500),
  @v_keywordsortorder	INT,
  @v_standardind CHAR(1)


BEGIN

  SET @v_quote = CHAR(39)
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_action_count = 0
  SET @v_standardind = 'N'
  
  IF @i_bookkey IS NULL OR @i_bookkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to copy from title/template: to_bookkey is empty.'
    RETURN
  END 

  IF @i_printingkey IS NULL OR @i_printingkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to copy from title/template: to_printingkey is empty.'
    RETURN
  END 

  IF @i_templatebookkey IS NULL OR @i_templatebookkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to copy from title/template: from_bookkey is empty.'
    RETURN
  END 

  IF @i_templateprintingkey IS NULL OR @i_templateprintingkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to copy from title/template: from_printingkey is empty.'
    RETURN
  END
  
  IF @i_copydatagroups_list IS NULL	--default @i_copydatagroups_list to all if it is NULL
  BEGIN
	  SELECT @v_newkeycount = count(*)
	  FROM gentables
	  WHERE tableid = 592
	  AND COALESCE(gen2ind, 0) > 0 

	  SET @v_count = 1
	  SET @i_copydatagroups_list = ''

	   DECLARE crCopyDataGroups CURSOR FOR
		  SELECT qsicode
		  FROM gentables
		  WHERE tableid = 592 AND COALESCE(gen2ind, 0) > 0 AND COALESCE(qsicode, 0) > 0

	    OPEN crCopyDataGroups 
	    FETCH NEXT FROM crCopyDataGroups INTO @v_qsicode

	    WHILE (@@FETCH_STATUS <> -1)
	    BEGIN
		  IF @v_count < @v_newkeycount
			  SET @i_copydatagroups_list = @i_copydatagroups_list + rtrim(convert(varchar,@v_qsicode)) + ','
		  ELSE 
			  SET @i_copydatagroups_list = @i_copydatagroups_list + rtrim(convert(varchar,@v_qsicode))

			  SET @v_count = @v_count + 1
		  FETCH NEXT FROM crCopyDataGroups INTO @v_qsicode
	    END

	    CLOSE crCopyDataGroups 
	    DEALLOCATE crCopyDataGroups  
  END
  ELSE IF @i_copydatagroups_list = 'none'
  BEGIN
    SET @i_copydatagroups_list = ''
  END

  IF @i_cleardatagroups_list IS NULL
  BEGIN
	  SET @i_cleardatagroups_list = ''
  END
  
  -- Build transaction XML
  SET @v_encoding_string = '<' + char(63) + 'xml version="1.0"' + ' encoding="UTF-16"' + char(63) + '>'

  SET @v_transaction_xml = @v_encoding_string + '<Transaction><UserID>' + @i_userid + '</UserID><ManageTrans>1</ManageTrans>'
  
  /* BOOK */
  /* Note: book, bookorgentry and isbn records are inserted in AddNewTitle dialog's sections. */
  
  SELECT @v_territories = territoriescode, @v_titlestatus = titlestatuscode, @v_titletype = titletypecode, @v_hiddenstatus = hiddenstatuscode, @v_standardind = UPPER(COALESCE(standardind, 'N'))
  FROM book
  WHERE bookkey = @i_templatebookkey

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Unable to copy from title/template (book): from_bookkey=' + cast(@i_templatebookkey AS VARCHAR)
    RETURN
  END
  
  SELECT @v_count = COUNT(*)
  FROM book
  WHERE bookkey = @i_bookkey
  
  IF @v_count > 0
  BEGIN
    SELECT @v_test_territories = territoriescode, @v_test_titlestatus = titlestatuscode, @v_test_titletype = titletypecode
    FROM book
    WHERE bookkey = @i_bookkey

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'Unable to copy from title/template (book) - could not verify existing values.'
      RETURN
    END
  END
  
  SET @v_action_count = @v_action_count + 1
      
  SET @v_book_xml = '
  <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>update</ActionType><ActionTable>book</ActionTable>
    <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>'

  IF @v_hiddenstatus > 0
    SET @v_book_xml = @v_book_xml + '
     <DBItem><DBItemColumn>hiddenstatuscode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_hiddenstatus) + '</DBItemValue></DBItem>'
  ELSE
    SET @v_book_xml = @v_book_xml + '
     <DBItem><DBItemColumn>hiddenstatuscode</DBItemColumn><DBItemValue>NULL</DBItemValue></DBItem>'
  
	IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 9) = 'Y'  --Classification
	BEGIN
    IF @v_territories > 0 AND @v_test_territories IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 131 AND datacode = @v_territories
      
      SET @v_book_xml = @v_book_xml + '
       <DBItem><DBItemColumn>territoriescode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_territories) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
    
    IF @v_titletype > 0 AND @v_test_titletype IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 132 AND datacode = @v_titletype
    
      SET @v_book_xml = @v_book_xml + '
       <DBItem><DBItemColumn>titletypecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_titletype) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
  END
  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list,  7) = 'Y'   --Inventory
  BEGIN 
    IF @v_titlestatus > 0 AND @v_test_titlestatus IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 149 AND datacode = @v_titlestatus
      
      SET @v_book_xml = @v_book_xml + '
       <DBItem><DBItemColumn>titlestatuscode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_titlestatus) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
  END  
  
  SET @v_book_xml = @v_book_xml + '</DBAction>'
  
  SET @v_transaction_xml = @v_transaction_xml + @v_book_xml


  /* BOOKDETAIL */
  /* not overriding: titleprefix (set from passed value), publishtowebind, titleverifycode */      
  
  SELECT @v_mediatype = mediatypecode, @v_mediasubtype = mediatypesubcode, @v_origin = origincode, 
    @v_salesdivision = salesdivisioncode, @v_edition = editioncode, @v_language = languagecode, 
    @v_restriction = restrictioncode, @v_return = returncode, @v_series = seriescode, @v_volume = volumenumber, 
    @v_platform = platformcode, @v_userlevel = userlevelcode, @v_agelow = agelow, @v_agehigh = agehigh, 
    @v_gradelow = gradelow, @v_gradehigh = gradehigh, @v_agelowind = agelowupind, @v_agehighind = agehighupind, 
    @v_gradelowind = gradelowupind, @v_gradehighind = gradehighupind, @v_bisacstatus = bisacstatuscode, 
    @v_fullauthorname = fullauthordisplayname, @v_salesrestriction = canadianrestrictioncode, 
    @v_allagesind = allagesind, @v_discount = discountcode, @v_fullauthorkey = fullauthordisplaykey, 
    @v_newtitleheading = newtitleheading, @v_editiondesc = editiondescription, @v_editionnum = editionnumber, 
    @v_language2 = languagecode2, @v_prodavailability = prodavailability, @v_addtleditioninfo = additionaleditinfo,
    @v_simulpubind = simulpubind, @v_copyrightyear = copyrightyear, @v_pricevalgroupcode = pricevalidationgroupcode
  FROM bookdetail
  WHERE bookkey = @i_templatebookkey
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Unable to copy from title/template (bookdetail): from_bookkey=' + cast(@i_templatebookkey AS VARCHAR)
    RETURN
  END

  SELECT @v_count = COUNT(*)
  FROM bookdetail
  WHERE bookkey = @i_bookkey
    
  IF @v_count > 0
  BEGIN
    SELECT @v_test_mediatype = mediatypecode, @v_test_mediasubtype = mediatypesubcode, @v_test_origin = origincode, 
      @v_test_salesdivision = salesdivisioncode, @v_test_edition = editioncode, @v_test_language = languagecode, 
      @v_test_restriction = restrictioncode, @v_test_return = returncode, @v_test_series = seriescode, @v_test_volume = volumenumber, 
      @v_test_platform = platformcode, @v_test_userlevel = userlevelcode, @v_test_agelow = agelow, @v_test_agehigh = agehigh, 
      @v_test_gradelow = gradelow, @v_test_gradehigh = gradehigh, @v_test_agelowind = agelowupind, @v_test_agehighind = agehighupind, 
      @v_test_gradelowind = gradelowupind, @v_test_gradehighind = gradehighupind, @v_test_bisacstatus = bisacstatuscode, 
      @v_test_fullauthorname = fullauthordisplayname, @v_test_salesrestriction = canadianrestrictioncode, @v_test_titleprefix = titleprefix,
      @v_test_allagesind = allagesind, @v_test_discount = discountcode, @v_test_fullauthorkey = fullauthordisplaykey, 
      @v_test_newtitleheading = newtitleheading, @v_test_editiondesc = editiondescription, @v_test_editionnum = editionnumber, 
      @v_test_language2 = languagecode2, @v_test_prodavailability = prodavailability, @v_test_addtleditioninfo = additionaleditinfo,
      @v_test_simulpubind = simulpubind, @v_test_copyrightyear = copyrightyear, @v_test_pricevalgroupcode = pricevalidationgroupcode
    FROM bookdetail
    WHERE bookkey = @i_bookkey
    
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'Unable to copy from title/template (bookdetail) - could not verify existing values.'
      RETURN
    END
  END
  
  SET @v_action_count = @v_action_count + 1  
  SET @v_bookdetail_xml = '
  <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insertupdate</ActionType><ActionTable>bookdetail</ActionTable>
    <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>'
  
  /* bookdetail row must exist, so at least force titleprefix update, even if NULL */
  IF @v_test_titleprefix IS NULL OR LTRIM(RTRIM(@v_test_titleprefix)) = ''
  BEGIN
    IF LEN(@i_titleprefix) > 0
    BEGIN
      SET @i_titleprefix = LTRIM(RTRIM(REPLACE(REPLACE(@i_titleprefix, '&', '&amp;'), '''', '''''')))
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
        <DBItem><DBItemColumn>titleprefix</DBItemColumn><DBItemValue>' + @v_quote + @i_titleprefix + @v_quote + '</DBItemValue></DBItem>'
    END
    ELSE
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
        <DBItem><DBItemColumn>titleprefix</DBItemColumn><DBItemValue>NULL</DBItemValue></DBItem>'
  END
  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 8) = 'Y'  --Specification Details
  BEGIN
    IF @v_mediatype > 0 AND @v_test_mediatype IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 312 AND datacode = @v_mediatype
      
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>mediatypecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_mediatype) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
  
    IF @v_mediasubtype > 0 AND @v_test_mediasubtype IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM subgentables
      WHERE tableid = 312 AND datacode = @v_mediatype AND datasubcode = @v_mediasubtype
      
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
        <DBItem><DBItemColumn>mediatypesubcode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_mediasubtype) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
    
    IF @v_simulpubind IS NOT NULL AND @v_test_simulpubind IS NULL
    BEGIN
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
        <DBItem><DBItemColumn>simulpubind</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_simulpubind) + '</DBItemValue></DBItem>'
    END
    
    IF @v_platform > 0 AND @v_test_platform IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 321 AND datacode = @v_platform
    
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>platformcode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_platform) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
    
    IF @v_userlevel > 0 AND @v_test_userlevel IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 322 AND datacode = @v_userlevel
    
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>userlevelcode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_userlevel) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END    
  END

  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 9) = 'Y'  --Classification
  BEGIN
    IF @v_origin > 0 AND @v_test_origin IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 315 AND datacode = @v_origin
    
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>origincode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_origin) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
  
    IF @v_salesdivision > 0 AND @v_test_salesdivision IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 313 AND datacode = @v_salesdivision
    
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>salesdivisioncode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_salesdivision) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
    
    IF @v_language > 0 AND @v_test_language IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 318 AND datacode = @v_language

      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>languagecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_language) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
    
    IF @v_language2 > 0 AND @v_test_language2 IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 318 AND datacode = @v_language2
    
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>languagecode2</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_language2) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END    
    
    IF @v_restriction > 0 AND @v_test_restriction IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 320 AND datacode = @v_restriction
    
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>restrictioncode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_restriction) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
    
    IF @v_return > 0 AND @v_test_return IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 319 AND datacode = @v_return
    
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>returncode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_return) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
    
    IF @v_salesrestriction > 0 AND @v_test_salesrestriction IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 428 AND datacode = @v_salesrestriction
    
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>canadianrestrictioncode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_salesrestriction) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
    
    IF @v_discount > 0 AND @v_test_discount IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 459 AND datacode = @v_discount
    
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>discountcode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_discount) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END    
    
    IF @v_agelow > 0 AND @v_test_agelow IS NULL
    BEGIN
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>agelow</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_agelow) + '</DBItemValue></DBItem>'
    END
    
    IF @v_agehigh > 0 AND @v_test_agehigh IS NULL
    BEGIN
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>agehigh</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_agehigh) + '</DBItemValue></DBItem>'
    END
    
    IF @v_agelowind > 0 AND @v_test_agelowind IS NULL
    BEGIN
      SET @v_datadesc = 'Y'
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>agelowupind</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_agelowind) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
    
    IF @v_agehighind > 0 AND @v_test_agehighind IS NULL
    BEGIN
      SET @v_datadesc = 'Y'
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>agehighupind</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_agehighind) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
    
    IF @v_allagesind > 0 AND @v_test_allagesind IS NULL
    BEGIN
      SET @v_datadesc = 'Y'
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>allagesind</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_allagesind) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END    
    
    IF LEN(@v_gradelow) > 0 AND @v_test_gradelow IS NULL
    BEGIN
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>gradelow</DBItemColumn><DBItemValue>' + @v_quote + @v_gradelow + @v_quote + '</DBItemValue></DBItem>'
    END
    
    IF LEN(@v_gradehigh) > 0 AND @v_test_gradehigh IS NULL
    BEGIN
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>gradehigh</DBItemColumn><DBItemValue>' + @v_quote + @v_gradehigh + @v_quote + '</DBItemValue></DBItem>'
    END
    
    IF @v_gradelowind > 0 AND @v_test_gradelowind IS NULL
    BEGIN
      SET @v_datadesc = 'Y'
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>gradelowupind</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_gradelowind) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
    
    IF @v_gradehighind > 0 AND @v_test_gradehighind IS NULL
    BEGIN
      SET @v_datadesc = 'Y'
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>gradehighupind</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_gradehighind) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
 
    IF LEN(@v_copyrightyear) > 0 AND @v_test_copyrightyear IS NULL
    BEGIN
        SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>copyrightyear</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR,@v_copyrightyear) + '</DBItemValue></DBItem>'
    END
  END

  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 1) = 'Y'  --Title Information
  BEGIN  
    IF @v_series > 0 AND @v_test_series IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 327 AND datacode = @v_series
    
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>seriescode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_series) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
  
    IF @v_volume > 0 AND @v_test_volume IS NULL
    BEGIN
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>volumenumber</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_volume) + '</DBItemValue></DBItem>'
    END
    
    IF @v_newtitleheading > 0 AND @v_test_newtitleheading IS NULL
    BEGIN
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>newtitleheading</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_newtitleheading) + '</DBItemValue></DBItem>'
    END

    IF @v_edition > 0 AND @v_test_edition IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 200 AND datacode = @v_edition
    
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>editioncode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_edition) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
    
    IF LEN(@v_editiondesc) > 0 AND @v_test_editiondesc IS NULL
    BEGIN
      SET @v_editiondesc = LTRIM(RTRIM(REPLACE(REPLACE(@v_editiondesc, '&', '&amp;'), '''', '''''')))
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>editiondescription</DBItemColumn><DBItemValue>' + @v_quote + @v_editiondesc + @v_quote + '</DBItemValue></DBItem>'
    END
    
    IF @v_editionnum > 0 AND @v_test_editionnum IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 557 AND datacode = @v_editionnum
    
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>editionnumber</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_editionnum) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
    
    IF LEN(@v_addtleditioninfo) > 0 AND @v_test_addtleditioninfo IS NULL
    BEGIN
      SET @v_addtleditioninfo = LTRIM(RTRIM(REPLACE(REPLACE(@v_addtleditioninfo, '&', '&amp;'), '''', '''''')))
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>additionaleditinfo</DBItemColumn><DBItemValue>' + @v_quote + @v_addtleditioninfo + @v_quote + '</DBItemValue></DBItem>'
    END
  END
  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 7) = 'Y'  --Inventory
  BEGIN
    IF @v_bisacstatus > 0 AND @v_test_bisacstatus IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 314 AND datacode = @v_bisacstatus
    
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>bisacstatuscode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_bisacstatus) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
    
    IF @v_prodavailability > 0 AND @v_test_prodavailability IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', ''''''))), @v_expshipdate_req = subgen1ind
      FROM subgentables
      WHERE tableid = 314 AND datacode = @v_bisacstatus AND datasubcode = @v_prodavailability
    
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>prodavailability</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_prodavailability) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END    
  END
  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 2) = 'Y'  --Authors
  BEGIN
    IF LEN(@v_fullauthorname) > 0 AND @v_test_fullauthorname IS NULL
    BEGIN
      SET @v_fullauthorname = LTRIM(RTRIM(REPLACE(REPLACE(@v_fullauthorname, '&', '&amp;'), '''', '''''')))
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>fullauthordisplayname</DBItemColumn><DBItemValue>' + @v_quote + @v_fullauthorname + @v_quote + '</DBItemValue></DBItem>'
    END
    
    IF @v_fullauthorkey > 0 AND @v_test_fullauthorkey IS NULL
    BEGIN
      SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>fullauthordisplaykey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_fullauthorkey) + '</DBItemValue></DBItem>'
    END
  END

  --IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 3) = 'Y'  --Prices
  --BEGIN
    IF @v_test_pricevalgroupcode IS NULL
    BEGIN
			IF @v_pricevalgroupcode IS NULL OR @v_pricevalgroupcode <= 0 BEGIN
				--Get client default Price Validation Group (clientdefaultid 59)
				SELECT @v_pricevalgroupcode = clientdefaultvalue FROM clientdefaults WHERE clientdefaultid=59
			END
			SET @v_bookdetail_xml = @v_bookdetail_xml + '
       <DBItem><DBItemColumn>pricevalidationgroupcode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_pricevalgroupcode) + '</DBItemValue></DBItem>'
		END
  --END
    
  SET @v_bookdetail_xml = @v_bookdetail_xml + '</DBAction>'  
  SET @v_transaction_xml = @v_transaction_xml + @v_bookdetail_xml
 
  /* TAQPROJECTTASK/BOOKDATES */
  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 4) = 'Y'  --Tasks
  BEGIN  
  
    SET @v_dbitem_count = 0
    SET @v_bookdates_xml = ''  
    SET @v_taqprojecttask_xml = ''  
    SET @v_sortorder = 1
    SET @v_cleardata = dbo.find_integer_in_comma_delim_list(@i_cleardatagroups_list, 4)
    SET @v_copycontacts = dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 5)
    
    SELECT @v_count = COUNT(*)
    FROM datetype
    WHERE qsicode = 9
    
    IF @v_count > 0
      SELECT @v_expshipdate_code = datetypecode
      FROM datetype
      WHERE qsicode = 9 --Expected Ship Date
    ELSE
      SET @v_expshipdate_code = 0
    
	  SELECT @v_websched_option = optionvalue
	  FROM clientoptions
	  WHERE optionid = 72
    
    IF @v_websched_option = 1 --client uses web scheduling - update taqprojecttask
    BEGIN
	  SET @taqprojecttaskoverride_rowcount = 0
      DECLARE crTaqProjectTask CURSOR FOR
        SELECT scheduleind, datetypecode, keyind, activedate, originaldate, actualind,
          taqprojectkey, taqprojectformatkey, globalcontactkey, rolecode,
          globalcontactkey2, rolecode2, decisioncode, stagecode, 
          LTRIM(RTRIM(REPLACE(REPLACE(taqtasknote, '&', '&amp;'), '''', ''''''))),
          paymentamt, taqtaskqty, duration,
          startdate, startdateactualind, lag, taqtaskkey, transactionkey
        FROM taqprojecttask
        WHERE bookkey = @i_templatebookkey AND 
          printingkey = @i_templateprintingkey AND 
          taqelementkey IS NULL
        ORDER BY sortorder

      OPEN crTaqProjectTask 

      FETCH NEXT FROM crTaqProjectTask 
      INTO @v_scheduleind, @v_datetype, @v_keyind, @v_activedate, @v_originaldate, @v_actualind,
        @v_projectkey, @v_formatkey, @v_contactkey, @v_role, @v_contactkey2, @v_role2,
        @v_decisioncode, @v_stagecode, @v_note, @v_paymentamt, @v_taskqty, @v_duration,
        @v_startdate, @v_startdateactualind, @v_lag, @v_taqtaskkey, @v_transactionkey

      WHILE (@@FETCH_STATUS <> -1)
      BEGIN
	    select @taqprojecttaskoverride_rowcount = count(*)
	    from taqprojecttaskoverride
	    where taqtaskkey = @v_taqtaskkey

	    IF @taqprojecttaskoverride_rowcount = 0
	    BEGIN
			SELECT @v_count = COUNT(*)
			FROM taqprojecttask
			WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey AND taqelementkey IS NULL AND datetypecode = @v_datetype
	        
			IF (@i_bookkey IS NOT NULL AND @i_bookkey > 0 AND @v_datetype IS NOT NULL) BEGIN
			   exec dbo.qutl_check_for_restrictions @v_datetype, @i_bookkey, @i_printingkey, NULL, NULL, NULL, NULL,
                 @o_taqtaskkey output, @o_returncode output, @o_restrictioncode output, @o_error_code output, @o_error_desc output
			   IF @o_error_code <> 0 BEGIN
				  SET @o_error_code = -1
				  SET @o_error_desc = 'Unable to check for title task restrictions: ' + @o_error_desc
				  RETURN
			   END
			   IF (@o_returncode = 2 AND @v_restriction_value_title = 3 AND @v_keyind  = 0) BEGIN
					SET @o_returncode = 0
			   END
			END 

			IF (@v_count > 0 AND @o_returncode <> 0)
			BEGIN
			  SELECT @v_test_activedate = activedate, @v_test_originaldate = originaldate, @v_taskkey = taqtaskkey,
				@v_test_startdate = startdate
			  FROM taqprojecttask
			  WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey AND taqelementkey IS NULL AND datetypecode = @v_datetype
	            
			  IF @v_cleardata = 'N' AND @v_test_activedate IS NULL AND @v_test_originaldate IS NULL AND @v_test_startdate IS NULL 
			  BEGIN
				-- this task row exists, but the date value is null - update with value from template
				SET @v_action_count = @v_action_count + 1
	              
				SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				<DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>update</ActionType><ActionTable>taqprojecttask</ActionTable>
				  <Key><KeyColumn>taqtaskkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_taskkey) + '</KeyValue></Key>'

				IF @v_activedate IS NOT NULL
				  SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
					<DBItem><DBItemColumn>activedate</DBItemColumn><DBItemValue>CONVERT(DATETIME,' + @v_quote + CONVERT(VARCHAR, @v_activedate) + @v_quote + ', 101)</DBItemValue></DBItem>'
	                
				IF @v_originaldate IS NOT NULL
				  SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
					<DBItem><DBItemColumn>originaldate</DBItemColumn><DBItemValue>CONVERT(DATETIME,' + @v_quote + CONVERT(VARCHAR, @v_originaldate) + @v_quote + ', 101)</DBItemValue></DBItem>'
	               

				IF @v_startdate IS NOT NULL
				  SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
					<DBItem><DBItemColumn>startdate</DBItemColumn><DBItemValue>CONVERT(DATETIME,' + @v_quote + CONVERT(VARCHAR, @v_startdate) + @v_quote + ', 101)</DBItemValue></DBItem>'
	                                     
				SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '</DBAction>'
	                 
				SET @v_sortorder = @v_sortorder + 1
				SET @v_dbitem_count = @v_dbitem_count + 1            
			  END
			END
			ELSE  --@v_count = 0
			BEGIN
			  SET @v_action_count = @v_action_count + 1
	            
			  SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
			  <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>taqprojecttask</ActionTable>
				<Key><KeyColumn>taqtaskkey</KeyColumn><KeyValue>?</KeyValue></Key>'

			  SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				  <DBItem><DBItemColumn>bookkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @i_bookkey) + '</DBItemValue></DBItem>'
			  SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				  <DBItem><DBItemColumn>printingkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @i_printingkey) + '</DBItemValue></DBItem>'
			  SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				  <DBItem><DBItemColumn>datetypecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_datetype) + '</DBItemValue></DBItem>'
	              
			  IF @v_keyind = 1
				SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				  <DBItem><DBItemColumn>keyind</DBItemColumn><DBItemValue>1</DBItemValue></DBItem>'
			  ELSE
				SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				  <DBItem><DBItemColumn>keyind</DBItemColumn><DBItemValue>0</DBItemValue></DBItem>'
	          
			  SET @v_cleardates = @v_cleardata
			  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 7) = 'Y'  --Yes, copying Inventory (BISAC Status/Product Avail)
			  BEGIN
				-- When copying BISAC Status/Product Availability, and Product Availablity requires Expected Ship Date,
				-- don't clear Expected Ship Date if required by Product Availability, even when clearing all tasks
				IF @v_expshipdate_req = 1 AND @v_cleardata = 'Y' AND @v_datetype = @v_expshipdate_code
				  SET @v_cleardates = 'N'
			  END
	          
			  IF @v_cleardates = 'N'
			  BEGIN
				IF @v_actualind = 1
				  SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
					<DBItem><DBItemColumn>actualind</DBItemColumn><DBItemValue>1</DBItemValue></DBItem>'
				ELSE
				  SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
					<DBItem><DBItemColumn>actualind</DBItemColumn><DBItemValue>0</DBItemValue></DBItem>'
	          
				IF @v_activedate IS NOT NULL
				  SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
					<DBItem><DBItemColumn>activedate</DBItemColumn><DBItemValue>CONVERT(DATETIME,' + @v_quote + CONVERT(VARCHAR, @v_activedate) + @v_quote + ', 101)</DBItemValue></DBItem>'
	                
				 IF @v_originaldate IS NOT NULL
				  SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
					<DBItem><DBItemColumn>originaldate</DBItemColumn><DBItemValue>CONVERT(DATETIME,' + @v_quote + CONVERT(VARCHAR, @v_originaldate) + @v_quote + ', 101)</DBItemValue></DBItem>'             
			  END
	          
			  IF @v_projectkey IS NOT NULL          
				SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				  <DBItem><DBItemColumn>taqprojectkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_projectkey) + '</DBItemValue></DBItem>'
	              
			  IF @v_formatkey IS NOT NULL
				SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				  <DBItem><DBItemColumn>taqprojectformatkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_formatkey) + '</DBItemValue></DBItem>'
	              
			  IF @v_copycontacts = 'N'
			  BEGIN              
				IF @v_role > 0
				  SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
					<DBItem><DBItemColumn>rolecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_role) + '</DBItemValue></DBItem>'
				IF @v_role2 > 0
				  SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
					<DBItem><DBItemColumn>rolecode2</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_role2) + '</DBItemValue></DBItem>'                    
			  END
			  ELSE
			  BEGIN
				IF @v_contactkey IS NOT NULL
				BEGIN
				  SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
					<DBItem><DBItemColumn>globalcontactkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_contactkey) + '</DBItemValue></DBItem>'
				END
				IF @v_role > 0
				SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
					<DBItem><DBItemColumn>rolecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_role) + '</DBItemValue></DBItem>'
	          
				IF @v_contactkey2 IS NOT NULL
				BEGIN
				  SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
					<DBItem><DBItemColumn>globalcontactkey2</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_contactkey2) + '</DBItemValue></DBItem>'
				END
				IF @v_role2 > 0
				SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
					<DBItem><DBItemColumn>rolecode2</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_role2) + '</DBItemValue></DBItem>'
			  END
	          
			  IF @v_scheduleind = 1
				SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				  <DBItem><DBItemColumn>scheduleind</DBItemColumn><DBItemValue>1</DBItemValue></DBItem>'
	          
			  IF @v_decisioncode IS NOT NULL
				SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				  <DBItem><DBItemColumn>decisioncode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_decisioncode) + '</DBItemValue></DBItem>'
	              
			  IF @v_stagecode IS NOT NULL
				SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				  <DBItem><DBItemColumn>stagecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_stagecode) + '</DBItemValue></DBItem>'
	              
			  IF @v_note IS NOT NULL
				SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				  <DBItem><DBItemColumn>taqtasknote</DBItemColumn><DBItemValue>' + @v_quote + @v_note + @v_quote + '</DBItemValue></DBItem>'
	              
			  IF @v_paymentamt IS NOT NULL
				SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				  <DBItem><DBItemColumn>paymentamt</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_paymentamt) + '</DBItemValue></DBItem>'
	              
			  IF @v_taskqty IS NOT NULL
				SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				  <DBItem><DBItemColumn>taqtaskqty</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_taskqty) + '</DBItemValue></DBItem>'
	              
			  IF @v_duration IS NOT NULL
				SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				  <DBItem><DBItemColumn>duration</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_duration) + '</DBItemValue></DBItem>'
	              
			  SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				  <DBItem><DBItemColumn>sortorder</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_sortorder) + '</DBItemValue></DBItem>'

			  IF @v_cleardates = 'N'
			  BEGIN
				IF @v_startdate IS NOT NULL
				  SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
					<DBItem><DBItemColumn>startdate</DBItemColumn><DBItemValue>CONVERT(DATETIME,' + @v_quote + CONVERT(VARCHAR, @v_startdate) + @v_quote + ', 101)</DBItemValue></DBItem>'
			  END

			  IF @v_startdateactualind = 1
				SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				  <DBItem><DBItemColumn>startdateactualind</DBItemColumn><DBItemValue>1</DBItemValue></DBItem>'

			  IF @v_lag IS NOT NULL
				SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				  <DBItem><DBItemColumn>lag</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_lag) + '</DBItemValue></DBItem>'

			  IF @v_transactionkey IS NOT NULL
				SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '
				  <DBItem><DBItemColumn>transactionkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_transactionkey) + '</DBItemValue></DBItem>'

			  SET @v_taqprojecttask_xml = @v_taqprojecttask_xml + '</DBAction>'
	               
			  SET @v_sortorder = @v_sortorder + 1
			  SET @v_dbitem_count = @v_dbitem_count + 1
			END
        END

        FETCH NEXT FROM crTaqProjectTask 
        INTO @v_scheduleind, @v_datetype, @v_keyind, @v_activedate, @v_originaldate, @v_actualind,
          @v_projectkey, @v_formatkey, @v_contactkey, @v_role, @v_contactkey2, @v_role2,
          @v_decisioncode, @v_stagecode, @v_note, @v_paymentamt, @v_taskqty, @v_duration,
          @v_startdate, @v_startdateactualind, @v_lag, @v_taqtaskkey, @v_transactionkey
      END

      CLOSE crTaqProjectTask 
      DEALLOCATE crTaqProjectTask    
        
      IF @v_dbitem_count > 0
        SET @v_transaction_xml = @v_transaction_xml + @v_taqprojecttask_xml  
    END
    ELSE  --client uses tmm scheduling - update bookdates
    BEGIN
      DECLARE crBookDates CURSOR FOR
        SELECT d.datetypecode, d.activedate, d.actualind, d.estdate
        FROM bookdates d
        WHERE d.bookkey = @i_templatebookkey AND d.printingkey = @i_templateprintingkey
          AND d.datetypecode <> 387 -- Production Bound Book Date (trigger will add if needed)
        ORDER BY d.sortorder

      OPEN crBookDates 

      FETCH NEXT FROM crBookDates
      INTO @v_datetype, @v_activedate, @v_actualind, @v_estdate

      WHILE (@@FETCH_STATUS <> -1)
      BEGIN
        SELECT @v_count = COUNT(*)
        FROM bookdates
        WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey AND datetypecode = @v_datetype
        
        IF @v_count > 0
        BEGIN
          SELECT @v_test_activedate = activedate, @v_test_originaldate = estdate
          FROM bookdates
          WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey AND datetypecode = @v_datetype
            
          IF @v_cleardata = 'N' AND @v_test_activedate IS NULL AND @v_test_originaldate IS NULL
          BEGIN
            -- this task row exists, but the date value is null - update with value from template
            SET @v_action_count = @v_action_count + 1
            
            SET @v_bookdates_xml = @v_bookdates_xml + '
            <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>update</ActionType><ActionTable>bookdates</ActionTable>
              <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>
              <Key><KeyColumn>printingkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_printingkey) + '</KeyValue></Key>
              <Key><KeyColumn>datetypecode</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_datetype) + '</KeyValue></Key>'

            IF @v_activedate IS NOT NULL
              SET @v_bookdates_xml = @v_bookdates_xml + '
                <DBItem><DBItemColumn>activedate</DBItemColumn><DBItemValue>CONVERT(DATETIME,' + @v_quote + CONVERT(VARCHAR, @v_activedate) + @v_quote + ', 101)</DBItemValue>
                <DBItemDesc>' + @v_quote + CONVERT(VARCHAR, @v_activedate) + @v_quote +'</DBItemDesc></DBItem>'
                
            IF @v_estdate IS NOT NULL
              SET @v_bookdates_xml = @v_bookdates_xml + '
                <DBItem><DBItemColumn>estdate</DBItemColumn><DBItemValue>CONVERT(DATETIME,' + @v_quote + CONVERT(VARCHAR, @v_estdate) + @v_quote + ', 101)</DBItemValue>
                <DBItemDesc>' + @v_quote + CONVERT(VARCHAR, @v_estdate) + @v_quote +'</DBItemDesc></DBItem>'

            SET @v_bookdates_xml = @v_bookdates_xml + '</DBAction>'
                 
            SET @v_sortorder = @v_sortorder + 1
            SET @v_dbitem_count = @v_dbitem_count + 1
          END
        END
        ELSE  --@v_count = 0
        BEGIN
          SET @v_action_count = @v_action_count + 1
            
          SET @v_bookdates_xml = @v_bookdates_xml + '
          <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>bookdates</ActionTable>
            <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>
            <Key><KeyColumn>printingkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_printingkey) + '</KeyValue></Key>
            <Key><KeyColumn>datetypecode</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_datetype) + '</KeyValue></Key>'

          IF @v_cleardata = 'N'
          BEGIN
            IF @v_activedate IS NOT NULL
              SET @v_bookdates_xml = @v_bookdates_xml + '
                <DBItem><DBItemColumn>activedate</DBItemColumn><DBItemValue>CONVERT(DATETIME,' + @v_quote + CONVERT(VARCHAR, @v_activedate) + @v_quote + ', 101)</DBItemValue>
                <DBItemDesc>' + @v_quote + CONVERT(VARCHAR, @v_activedate) + @v_quote +'</DBItemDesc></DBItem>'
                
            IF @v_estdate IS NOT NULL
              SET @v_bookdates_xml = @v_bookdates_xml + '
                <DBItem><DBItemColumn>estdate</DBItemColumn><DBItemValue>CONVERT(DATETIME,' + @v_quote + CONVERT(VARCHAR, @v_estdate) + @v_quote + ', 101)</DBItemValue>
                <DBItemDesc>' + @v_quote + CONVERT(VARCHAR, @v_estdate) + @v_quote +'</DBItemDesc></DBItem>'
            
            IF @v_actualind = 1    
              SET @v_bookdates_xml = @v_bookdates_xml + '
                <DBItem><DBItemColumn>actualind</DBItemColumn><DBItemValue>1</DBItemValue></DBItem>'
            ELSE
              SET @v_bookdates_xml = @v_bookdates_xml + '
                <DBItem><DBItemColumn>actualind</DBItemColumn><DBItemValue>0</DBItemValue></DBItem>'
          END
          
          SET @v_bookdates_xml = @v_bookdates_xml + '
              <DBItem><DBItemColumn>sortorder</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_sortorder) + '</DBItemValue></DBItem>'

          SET @v_bookdates_xml = @v_bookdates_xml + '</DBAction>'
               
          SET @v_sortorder = @v_sortorder + 1
          SET @v_dbitem_count = @v_dbitem_count + 1
        END
        
        FETCH NEXT FROM crBookDates
        INTO @v_datetype, @v_activedate, @v_actualind, @v_estdate
      END

      CLOSE crBookDates 
      DEALLOCATE crBookDates    
        
      IF @v_dbitem_count > 0
        SET @v_transaction_xml = @v_transaction_xml + @v_bookdates_xml  
    END
  
  END --Tasks
  
  /* PRINTING */
  /* at least the basic columns (printingnum, issuenumber) will be updated, so no need to keep track of dbitem count */
  
  SELECT @v_tentativeqty = tentativeqty, @v_tentativepagecount = tentativepagecount, @v_pagecount = pagecount, 
    @v_trimwidth = trimsizewidth, @v_trimlength = trimsizelength, @v_esttrimwidth = esttrimsizewidth, 
    @v_esttrimlength = esttrimsizelength, @v_pubmonthcode = pubmonthcode, @v_pubmonth = pubmonth, 
    @v_slot = slotcode, @v_firstprintqty = firstprintingqty, @v_seasonkey = seasonkey, 
    @v_estseasonkey = estseasonkey, @v_bookbulk = bookbulk, @v_announcedfirstprint = announcedfirstprint, 
    @v_estinsertillus = estimatedinsertillus, @v_actualinsertillus = actualinsertillus, 
    @v_estannouncedfirstprint = estannouncedfirstprint, @v_spinesize = spinesize, 
    @v_tmmactualtrimwidth = tmmactualtrimwidth, @v_tmmactualtrimlength = tmmactualtrimlength,
    @v_tmmpagecount = tmmpagecount, @v_barcode1 = barcodeid1, @v_barcodepos1 = barcodeposition1, 
    @v_barcode2 = barcodeid2, @v_barcodepos2 = barcodeposition2, @v_estprojectedsales = estprojectedsales,
    @v_bookweight = bookweight, @v_trimsize_UOM = trimsizeunitofmeasure, 
    @v_spinesize_UOM = spinesizeunitofmeasure, @v_bookweight_UOM = bookweightunitofmeasure
  FROM printing
  WHERE bookkey = @i_templatebookkey AND printingkey = @i_templateprintingkey
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Unable to copy from title/template (printing): from_bookkey=' + CAST(@i_templatebookkey AS VARCHAR) +
      ', from_printingkey=' + CAST(@i_templateprintingkey AS VARCHAR)
    RETURN
  END
  
  SELECT @v_count = COUNT(*)
  FROM printing
  WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
  
  IF @v_count > 0
  BEGIN
    SELECT @v_test_tentativeqty = tentativeqty, @v_test_tentativepagecount = tentativepagecount, @v_test_pagecount = pagecount, 
      @v_test_trimwidth = trimsizewidth, @v_test_trimlength = trimsizelength, @v_test_esttrimwidth = esttrimsizewidth, 
      @v_test_esttrimlength = esttrimsizelength, @v_test_pubmonthcode = pubmonthcode, @v_test_pubmonth = pubmonth, 
      @v_test_slot = slotcode, @v_test_firstprintqty = firstprintingqty, @v_test_seasonkey = seasonkey, 
      @v_test_estseasonkey = estseasonkey, @v_test_bookbulk = bookbulk, @v_test_announcedfirstprint = announcedfirstprint, 
      @v_test_estinsertillus = estimatedinsertillus, @v_test_actualinsertillus = actualinsertillus, 
      @v_test_estannouncedfirstprint = estannouncedfirstprint, @v_test_spinesize = spinesize, 
      @v_test_tmmactualtrimwidth = tmmactualtrimwidth, @v_test_tmmactualtrimlength = tmmactualtrimlength,
      @v_test_tmmpagecount = tmmpagecount, @v_test_barcode1 = barcodeid1, @v_test_barcodepos1 = barcodeposition1, 
      @v_test_barcode2 = barcodeid2, @v_test_barcodepos2 = barcodeposition2, @v_test_estprojectedsales = estprojectedsales,
      @v_test_bookweight = bookweight, @v_test_trim_UOM = trimsizeunitofmeasure, 
      @v_test_spine_UOM = spinesizeunitofmeasure, @v_test_bookweight_UOM = bookweightunitofmeasure
    FROM printing
    WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
    
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'Unable to copy from title/template (printing) - could not verify existing values.'
      RETURN
    END
  END  
   
  SET @v_action_count = @v_action_count + 1   
  SET @v_printing_xml = '
  <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insertupdate</ActionType><ActionTable>printing</ActionTable>
    <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>
    <Key><KeyColumn>printingkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_printingkey) + '</KeyValue></Key>'
  
  -- these columns should always be updated
  SET @v_printing_xml = @v_printing_xml + '
      <DBItem><DBItemColumn>printingnum</DBItemColumn><DBItemValue>1</DBItemValue></DBItem>'
  SET @v_printing_xml = @v_printing_xml + '
      <DBItem><DBItemColumn>issuenumber</DBItemColumn><DBItemValue>1</DBItemValue></DBItem>'  
  SET @v_printing_xml = @v_printing_xml + '
      <DBItem><DBItemColumn>creationdate</DBItemColumn><DBItemValue>getdate()</DBItemValue></DBItem>'  
  SET @v_printing_xml = @v_printing_xml + '
      <DBItem><DBItemColumn>printingjob</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @i_printingkey) + '</DBItemValue></DBItem>'
  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 7) = 'Y'  --Inventory
  BEGIN
  
    IF dbo.find_integer_in_comma_delim_list(@i_cleardatagroups_list, 7) = 'N'
    BEGIN    
      IF @v_tentativeqty > 0 AND @v_test_tentativeqty IS NULL
        SET @v_printing_xml = @v_printing_xml + '
         <DBItem><DBItemColumn>tentativeqty</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_tentativeqty) + '</DBItemValue></DBItem>'
         
      IF @v_firstprintqty > 0 AND @v_test_firstprintqty IS NULL
        SET @v_printing_xml = @v_printing_xml + '
         <DBItem><DBItemColumn>firstprintingqty</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_firstprintqty) + '</DBItemValue></DBItem>'
         
      IF @v_announcedfirstprint > 0 AND @v_test_announcedfirstprint IS NULL
        SET @v_printing_xml = @v_printing_xml + '
         <DBItem><DBItemColumn>announcedfirstprint</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_announcedfirstprint) + '</DBItemValue></DBItem>'

      IF @v_estannouncedfirstprint > 0 AND @v_test_estannouncedfirstprint IS NULL
        SET @v_printing_xml = @v_printing_xml + '
         <DBItem><DBItemColumn>estannouncedfirstprint</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_estannouncedfirstprint) + '</DBItemValue></DBItem>'
         
      IF @v_estprojectedsales > 0 AND @v_test_estprojectedsales IS NULL
        SET @v_printing_xml = @v_printing_xml + '
         <DBItem><DBItemColumn>estprojectedsales</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_estprojectedsales) + '</DBItemValue></DBItem>'         
    END
  END  
  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 8) = 'Y'  --Specification Details
  BEGIN
    IF @v_tentativepagecount > 0 AND @v_test_tentativepagecount IS NULL
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>tentativepagecount</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_tentativepagecount) + '</DBItemValue></DBItem>'
  
    IF @v_pagecount > 0 AND @v_test_pagecount IS NULL
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>pagecount</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_pagecount) + '</DBItemValue></DBItem>'
  
    IF LEN(@v_trimwidth) > 0 AND @v_test_trimwidth IS NULL
    BEGIN
      SET @v_trimwidth = LTRIM(RTRIM(REPLACE(REPLACE(@v_trimwidth, '&', '&amp;'), '''', '''''')))
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>trimsizewidth</DBItemColumn><DBItemValue>' + @v_quote + @v_trimwidth + @v_quote + '</DBItemValue></DBItem>'
    END
    
    IF LEN(@v_trimlength) > 0 AND @v_test_trimlength IS NULL
    BEGIN
      SET @v_trimlength = LTRIM(RTRIM(REPLACE(REPLACE(@v_trimlength, '&', '&amp;'), '''', '''''')))
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>trimsizelength</DBItemColumn><DBItemValue>' + @v_quote + @v_trimlength + @v_quote + '</DBItemValue></DBItem>'
    END
    
    IF LEN(@v_esttrimwidth) > 0 AND @v_test_esttrimwidth IS NULL
    BEGIN
      SET @v_esttrimwidth = LTRIM(RTRIM(REPLACE(REPLACE(@v_esttrimwidth, '&', '&amp;'), '''', '''''')))
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>esttrimsizewidth</DBItemColumn><DBItemValue>' + @v_quote + @v_esttrimwidth + @v_quote + '</DBItemValue></DBItem>'
    END
    
    IF LEN(@v_esttrimlength) > 0 AND @v_test_esttrimlength IS NULL
    BEGIN
      SET @v_esttrimlength = LTRIM(RTRIM(REPLACE(REPLACE(@v_esttrimlength, '&', '&amp;'), '''', '''''')))
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>esttrimsizelength</DBItemColumn><DBItemValue>' + @v_quote + @v_esttrimlength + @v_quote + '</DBItemValue></DBItem>'
    END
    
    IF @v_bookweight > 0 AND @v_test_bookweight IS NULL
      SET @v_printing_xml = @v_printing_xml + '
        <DBItem><DBItemColumn>bookweight</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_bookweight) + '</DBItemValue></DBItem>'

    -- 10/15/09 Lisa added Units of Measure fields
    IF @v_bookweight_UOM > 0 AND @v_test_bookweight_UOM IS NULL
      SET @v_printing_xml = @v_printing_xml + '
        <DBItem><DBItemColumn>bookweightunitofmeasure</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_bookweight_UOM) + '</DBItemValue></DBItem>'
    
    IF @v_spinesize_UOM > 0 AND @v_test_spine_UOM IS NULL
      SET @v_printing_xml = @v_printing_xml + '
        <DBItem><DBItemColumn>spinesizeunitofmeasure</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_spinesize_UOM) + '</DBItemValue></DBItem>'

    IF @v_trimsize_UOM > 0 AND @v_test_trim_UOM IS NULL
      SET @v_printing_xml = @v_printing_xml + '
        <DBItem><DBItemColumn>trimsizeunitofmeasure</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_trimsize_UOM) + '</DBItemValue></DBItem>'
       
    IF LEN(@v_estinsertillus) > 0 AND @v_test_estinsertillus IS NULL
    BEGIN
      SET @v_estinsertillus = LTRIM(RTRIM(REPLACE(REPLACE(@v_estinsertillus, '&', '&amp;'), '''', '''''')))
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>estimatedinsertillus</DBItemColumn><DBItemValue>' + @v_quote + @v_estinsertillus + @v_quote + '</DBItemValue></DBItem>'
    END
    
    IF LEN(@v_actualinsertillus) > 0 AND @v_test_actualinsertillus IS NULL
    BEGIN
      SET @v_actualinsertillus = LTRIM(RTRIM(REPLACE(REPLACE(@v_actualinsertillus, '&', '&amp;'), '''', '''''')))
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>actualinsertillus</DBItemColumn><DBItemValue>' + @v_quote + @v_actualinsertillus + @v_quote + '</DBItemValue></DBItem>'
    END
    
    IF LEN(@v_spinesize) > 0 AND @v_test_spinesize IS NULL
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>spinesize</DBItemColumn><DBItemValue>' + @v_quote + @v_spinesize + @v_quote + '</DBItemValue></DBItem>'
       
    IF @v_bookbulk > 0 AND @v_test_bookbulk IS NULL
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>bookbulk</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_bookbulk) + '</DBItemValue></DBItem>'       

    IF LEN(@v_tmmactualtrimwidth) > 0 AND @v_test_tmmactualtrimwidth IS NULL
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>tmmactualtrimwidth</DBItemColumn><DBItemValue>' + @v_quote + @v_tmmactualtrimwidth + @v_quote + '</DBItemValue></DBItem>'

    IF LEN(@v_tmmactualtrimlength) > 0 AND @v_test_tmmactualtrimlength IS NULL
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>tmmactualtrimlength</DBItemColumn><DBItemValue>' + @v_quote + @v_tmmactualtrimlength + @v_quote + '</DBItemValue></DBItem>'

    IF @v_tmmpagecount > 0 AND @v_test_tmmpagecount IS NULL
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>tmmpagecount</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_tmmpagecount) + '</DBItemValue></DBItem>'

    IF @v_barcode1 > 0 AND @v_test_barcode1 IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 552 AND datacode = @v_barcode1
      
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>barcodeid1</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_barcode1) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END

    IF @v_barcodepos1 > 0 AND @v_test_barcodepos1 IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM subgentables
      WHERE tableid = 552 AND datacode = @v_barcode1 AND datasubcode = @v_barcodepos1
    
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>barcodeposition1</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_barcodepos1) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END

    IF @v_barcode2 > 0 AND @v_test_barcode2 IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 552 AND datacode = @v_barcode2
    
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>barcodeid2</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_barcode2) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END

    IF @v_barcodepos2 > 0 AND @v_test_barcodepos2 IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM subgentables
      WHERE tableid = 552 AND datacode = @v_barcode2 AND datasubcode = @v_barcodepos2
    
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>barcodeposition2</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_barcodepos2) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END    
  END

  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 1) = 'Y'  --Title Information
  BEGIN
    IF @v_pubmonthcode > 0 AND @v_test_pubmonthcode IS NULL
    BEGIN
      SET @v_datadesc =
      CASE @v_pubmonthcode
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
      
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>pubmonthcode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_pubmonthcode) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END

    IF @v_pubmonth IS NOT NULL AND @v_test_pubmonth IS NULL
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>pubmonth</DBItemColumn><DBItemValue>CONVERT(DATETIME,' + @v_quote + CONVERT(VARCHAR, @v_pubmonth) + @v_quote + ', 101)</DBItemValue></DBItem>'
       
    IF @v_seasonkey > 0 AND (@v_test_seasonkey IS NULL OR @v_test_seasonkey = 0)
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(seasondesc, '&', '&amp;'), '''', ''''''))) 
      FROM season 
      WHERE seasonkey = @v_seasonkey
    
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>seasonkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_seasonkey) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END

    IF @v_estseasonkey > 0 AND (@v_test_estseasonkey IS NULL OR @v_test_estseasonkey = 0)
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(seasondesc, '&', '&amp;'), '''', ''''''))) 
      FROM season 
      WHERE seasonkey = @v_estseasonkey

      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>estseasonkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_estseasonkey) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END       
  END
  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 9) = 'Y'  --Classification
  BEGIN  
    IF @v_slot > 0 AND @v_test_slot IS NULL
    BEGIN
      SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
      FROM gentables
      WHERE tableid = 102 AND datacode = @v_slot
      
      SET @v_printing_xml = @v_printing_xml + '
        <DBItem><DBItemColumn>slotcode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_slot) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    END
  END

  --- generate job number alpha value
 SELECT @v_generate_jobnumberalpha = COALESCE(gen2ind,0) FROM gentables WHERE tableid = 594 and qsicode = 14  
  IF @v_generate_jobnumberalpha = 1 
			 exec dbo.qprinting_get_next_jobnumber_alpha  @o_jobnumberseq output,@o_error_code output, @o_error_desc output
	ELSE
			  SET  @o_jobnumberseq = NULL  
  
  IF LEN(@o_jobnumberseq) > 0 AND @o_jobnumberseq IS NOT NULL
      SET @v_printing_xml = @v_printing_xml + '
       <DBItem><DBItemColumn>jobnumberalpha</DBItemColumn><DBItemValue>' + @v_quote + @o_jobnumberseq + @v_quote + '</DBItemValue></DBItem>'
  
  
  SET @v_printing_xml = @v_printing_xml + '</DBAction>'
  SET @v_transaction_xml = @v_transaction_xml + @v_printing_xml
  
    
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 8) = 'Y'  --Specification Details
  BEGIN
  
    /* AUDIOCASSETTESPECS */
  
    SELECT @v_count = COUNT(*)
    FROM audiocassettespecs
    WHERE bookkey = @i_templatebookkey AND printingkey = @i_templateprintingkey
    
    IF @v_count > 0
    BEGIN
      SELECT @v_numcassettes = numcassettes, @v_totalruntime = totalruntime 
      FROM audiocassettespecs 
      WHERE bookkey = @i_templatebookkey AND printingkey = @i_templateprintingkey
    
      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
        SET @o_error_code = 1
        SET @o_error_desc = 'Unable to copy from title/template (audiocassettespecs): from_bookkey=' + CAST(@i_templatebookkey AS VARCHAR)
        RETURN
      END
      
      SELECT @v_count = COUNT(*)
      FROM audiocassettespecs
      WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
      
      IF @v_count > 0
      BEGIN
        SELECT @v_test_numcassettes = numcassettes, @v_test_totalruntime = totalruntime 
        FROM audiocassettespecs 
        WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
      
        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          SET @o_error_code = 1
          SET @o_error_desc = 'Unable to copy from title/template (audiocassettespecs) - could not verify existing values.'
          RETURN
        END
      END
      
      SET @v_dbitem_count = 0
      SET @v_action_count = @v_action_count + 1      
      SET @v_audiocassettespecs_xml = '
      <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>audiocassettespecs</ActionTable>
        <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>
        <Key><KeyColumn>printingkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_printingkey) + '</KeyValue></Key>'
       
      IF @v_numcassettes > 0 AND @v_test_numcassettes IS NULL
      BEGIN     
        SET @v_audiocassettespecs_xml = @v_audiocassettespecs_xml + '
          <DBItem><DBItemColumn>numcassettes</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_numcassettes) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF LEN(@v_totalruntime) > 0 AND @v_test_totalruntime IS NULL
      BEGIN
        SET @v_totalruntime = LTRIM(RTRIM(REPLACE(REPLACE(@v_totalruntime, '&', '&amp;'), '''', '''''')))
        SET @v_audiocassettespecs_xml = @v_audiocassettespecs_xml + '
          <DBItem><DBItemColumn>totalruntime</DBItemColumn><DBItemValue>' + @v_quote + @v_totalruntime + @v_quote + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END  
      
      SET @v_audiocassettespecs_xml = @v_audiocassettespecs_xml + '</DBAction>'
        
      IF @v_dbitem_count > 0
        SET @v_transaction_xml = @v_transaction_xml + @v_audiocassettespecs_xml

    END --AUDIOCASSETTESPECS
        
    /* JACKETSPECS */
  
    SELECT @v_count = COUNT(*)
    FROM jacketspecs
    WHERE bookkey = @i_templatebookkey AND printingkey = @i_templateprintingkey
    
    IF @v_count > 0
    BEGIN
      SELECT @v_vendorkey = vendorkey
      FROM jacketspecs 
      WHERE bookkey = @i_templatebookkey AND printingkey = @i_templateprintingkey
    
      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
        SET @o_error_code = 1
        SET @o_error_desc = 'Unable to copy from title/template (jacketspecs): from_bookkey=' + CAST(@i_templatebookkey AS VARCHAR)
        RETURN
      END
      
      SELECT @v_count = COUNT(*)
      FROM jacketspecs
      WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
      
      IF @v_count > 0
      BEGIN
        SELECT @v_vendorkey = vendorkey
        FROM jacketspecs 
        WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
      
        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          SET @o_error_code = 1
          SET @o_error_desc = 'Unable to copy from title/template (jacketspecs) - could not verify existing values.'
          RETURN
        END
      END
      
      SET @v_dbitem_count = 0
      SET @v_action_count = @v_action_count + 1
      SET @v_jacketspecs_xml = '
      <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>jacketspecs</ActionTable>
        <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>
        <Key><KeyColumn>printingkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_printingkey) + '</KeyValue></Key>'
       
      IF @v_vendorkey > 0 AND @v_vendorkey IS NOT NULL
      BEGIN     
        SET @v_jacketspecs_xml = @v_jacketspecs_xml + '
          <DBItem><DBItemColumn>vendorkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_vendorkey) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      SET @v_jacketspecs_xml = @v_jacketspecs_xml + '</DBAction>'
        
      IF @v_dbitem_count > 0
        SET @v_transaction_xml = @v_transaction_xml + @v_jacketspecs_xml

    END --JACKETSPECS     
    
    /* TEXTSPECS */
  
    SELECT @v_count = COUNT(*)
    FROM textspecs
    WHERE bookkey = @i_templatebookkey AND printingkey = @i_templateprintingkey
    
    IF @v_count > 0
    BEGIN
      SELECT @v_vendorkey = vendorkey
      FROM textspecs 
      WHERE bookkey = @i_templatebookkey AND printingkey = @i_templateprintingkey
    
      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
        SET @o_error_code = 1
        SET @o_error_desc = 'Unable to copy from title/template (textspecs): from_bookkey=' + CAST(@i_templatebookkey AS VARCHAR)
        RETURN
      END
      
      SELECT @v_count = COUNT(*)
      FROM textspecs
      WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
      
      IF @v_count > 0
      BEGIN
        SELECT @v_vendorkey = vendorkey
        FROM textspecs 
        WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
      
        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          SET @o_error_code = 1
          SET @o_error_desc = 'Unable to copy from title/template (textspecs) - could not verify existing values.'
          RETURN
        END
      END
      
      SET @v_dbitem_count = 0
      SET @v_action_count = @v_action_count + 1      
      SET @v_textspecs_xml = '
      <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>textspecs</ActionTable>
        <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>
        <Key><KeyColumn>printingkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_printingkey) + '</KeyValue></Key>'
       
      IF @v_vendorkey > 0 AND @v_vendorkey IS NOT NULL
      BEGIN     
        SET @v_textspecs_xml = @v_textspecs_xml + '
          <DBItem><DBItemColumn>vendorkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_vendorkey) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      SET @v_textspecs_xml = @v_textspecs_xml + '</DBAction>'
        
      IF @v_dbitem_count > 0
        SET @v_transaction_xml = @v_transaction_xml + @v_textspecs_xml

    END --TEXTSPECS                 
  
    /* BOOKSIMON */
    
    SELECT @v_count = COUNT(*)
    FROM booksimon
    WHERE bookkey = @i_templatebookkey
    
    IF @v_count > 0
    BEGIN
      SELECT @v_formatchild = formatchildcode, @v_bookweight = bookweight
      FROM booksimon
      WHERE bookkey = @i_templatebookkey
      
      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
        SET @o_error_code = 1
        SET @o_error_desc = 'Unable to copy from title/template (booksimon): from_bookkey=' + CAST(@i_templatebookkey AS VARCHAR)
        RETURN
      END
      
      SELECT @v_count = COUNT(*)
      FROM booksimon
      WHERE bookkey = @i_bookkey
      
      IF @v_count > 0
      BEGIN
        SELECT @v_test_formatchild = formatchildcode --, @v_test_bookweight = bookweight
        FROM booksimon
        WHERE bookkey = @i_bookkey
        
        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          SET @o_error_code = 1
          SET @o_error_desc = 'Unable to copy from title/template (booksimon) - could not verify existing values.'
          RETURN
        END
      END
          
      SET @v_dbitem_count = 0
      SET @v_action_count = @v_action_count + 1      
      SET @v_booksimon_xml = '
      <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>booksimon</ActionTable>
        <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>'
       
      IF @v_formatchild > 0 AND @v_test_formatchild IS NULL
      BEGIN
        SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
        FROM gentables
        WHERE tableid = 300 AND datacode = @v_formatchild
        
        SET @v_booksimon_xml = @v_booksimon_xml + '
          <DBItem><DBItemColumn>formatchildcode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_formatchild) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      SET @v_booksimon_xml = @v_booksimon_xml + '</DBAction>'
        
      IF @v_dbitem_count > 0
        SET @v_transaction_xml = @v_transaction_xml + @v_booksimon_xml

    END --BOOKSIMON
  END -- Specification Details  
  
  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 10) = 'Y'  --Custom Fields
  BEGIN
  
    /* BOOKCUSTOM */
    
    SELECT @v_count = COUNT(*)
    FROM bookcustom
    WHERE bookkey = @i_templatebookkey

    IF @v_count > 0
    BEGIN  
      SELECT @v_custind01 = customind01, @v_custind02 = customind02, @v_custind03 = customind03, 
        @v_custind04 = customind04, @v_custind05 = customind05, @v_custind06 = customind06, @v_custind07 = customind07, 
        @v_custind08 = customind08, @v_custind09 = customind09, @v_custind10 = customind10, @v_custcode01 = customcode01,
        @v_custcode02 = customcode02, @v_custcode03 = customcode03, @v_custcode04 = customcode04,
        @v_custcode05 = customcode05, @v_custcode06 = customcode06, @v_custcode07 = customcode07, 
        @v_custcode08 = customcode08, @v_custcode09 = customcode09, @v_custcode10 = customcode10,
        @v_custint01 = customint01, @v_custint02 = customint02, @v_custint03 = customint03, @v_custint04 = customint04, 
        @v_custint05 = customint05, @v_custint06 = customint06, @v_custint07 = customint07, @v_custint08 = customint08,
        @v_custint09 = customint09, @v_custint10 = customint10, @v_custfloat01 = customfloat01, 
        @v_custfloat02 = customfloat02, @v_custfloat03 = customfloat03, @v_custfloat04 = customfloat04, 
        @v_custfloat05 = customfloat05, @v_custfloat06 = customfloat06, @v_custfloat07 = customfloat07, 
        @v_custfloat08 = customfloat08, @v_custfloat09 = customfloat09, @v_custfloat10 = customfloat10
      FROM bookcustom
      WHERE bookkey = @i_templatebookkey
        
      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        SET @o_error_code = 1
        SET @o_error_desc = 'Unable to copy from title/template (bookcustom): from_bookkey=' + cast(@i_templatebookkey AS VARCHAR)
        RETURN
      END
      
      SELECT @v_count = COUNT(*)
      FROM bookcustom
      WHERE bookkey = @i_bookkey
      
      IF @v_count > 0
      BEGIN
        SELECT @v_test_custind01 = customind01, @v_test_custind02 = customind02, @v_test_custind03 = customind03, 
          @v_test_custind04 = customind04, @v_test_custind05 = customind05, @v_test_custind06 = customind06, @v_test_custind07 = customind07, 
          @v_test_custind08 = customind08, @v_test_custind09 = customind09, @v_test_custind10 = customind10, @v_test_custcode01 = customcode01,
          @v_test_custcode02 = customcode02, @v_test_custcode03 = customcode03, @v_test_custcode04 = customcode04,
          @v_test_custcode05 = customcode05, @v_test_custcode06 = customcode06, @v_test_custcode07 = customcode07, 
          @v_test_custcode08 = customcode08, @v_test_custcode09 = customcode09, @v_test_custcode10 = customcode10,
          @v_test_custint01 = customint01, @v_test_custint02 = customint02, @v_test_custint03 = customint03, @v_test_custint04 = customint04, 
          @v_test_custint05 = customint05, @v_test_custint06 = customint06, @v_test_custint07 = customint07, @v_test_custint08 = customint08,
          @v_test_custint09 = customint09, @v_test_custint10 = customint10, @v_test_custfloat01 = customfloat01, 
          @v_test_custfloat02 = customfloat02, @v_test_custfloat03 = customfloat03, @v_test_custfloat04 = customfloat04, 
          @v_test_custfloat05 = customfloat05, @v_test_custfloat06 = customfloat06, @v_test_custfloat07 = customfloat07, 
          @v_test_custfloat08 = customfloat08, @v_test_custfloat09 = customfloat09, @v_test_custfloat10 = customfloat10
        FROM bookcustom
        WHERE bookkey = @i_bookkey
        
        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          SET @o_error_code = 1
          SET @o_error_desc = 'Unable to copy from title/template (bookcustom) - could not verify existing values.'
          RETURN
        END        
      END
        
      SET @v_dbitem_count = 0
      SET @v_action_count = @v_action_count + 1      
      SET @v_bookcustom_xml = '
      <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>bookcustom</ActionTable>
        <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>'
          
      IF @v_custcode01 > 0 AND @v_test_custcode01 IS NULL
      BEGIN
        SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
        FROM gentables
        WHERE tableid = 417 AND datacode = @v_custcode01
        
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customcode01</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custcode01) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custcode02 > 0 AND @v_test_custcode02 IS NULL
      BEGIN
        SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
        FROM gentables
        WHERE tableid = 418 AND datacode = @v_custcode02
        
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customcode02</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custcode02) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custcode03 > 0 AND @v_test_custcode03 IS NULL
      BEGIN
        SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
        FROM gentables
        WHERE tableid = 419 AND datacode = @v_custcode03
        
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customcode03</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custcode03) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custcode04 > 0 AND @v_test_custcode04 IS NULL
      BEGIN
        SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
        FROM gentables
        WHERE tableid = 420 AND datacode = @v_custcode04
        
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customcode04</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custcode04) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END

      IF @v_custcode05 > 0 AND @v_test_custcode05 IS NULL
      BEGIN
        SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
        FROM gentables
        WHERE tableid = 421 AND datacode = @v_custcode05
        
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customcode05</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custcode05) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custcode06 > 0 AND @v_test_custcode06 IS NULL
      BEGIN
        SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
        FROM gentables
        WHERE tableid = 422 AND datacode = @v_custcode06
        
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customcode06</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custcode06) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custcode07 > 0 AND @v_test_custcode07 IS NULL
      BEGIN
        SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
        FROM gentables
        WHERE tableid = 423 AND datacode = @v_custcode07
        
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customcode07</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custcode07) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custcode08 > 0 AND @v_test_custcode08 IS NULL
      BEGIN
        SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
        FROM gentables
        WHERE tableid = 424 AND datacode = @v_custcode08
        
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customcode08</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custcode08) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custcode09 > 0 AND @v_test_custcode09 IS NULL
      BEGIN
        SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
        FROM gentables
        WHERE tableid = 425 AND datacode = @v_custcode09
        
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customcode09</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custcode09) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custcode10 > 0 AND @v_test_custcode10 IS NULL
      BEGIN
        SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
        FROM gentables
        WHERE tableid = 426 AND datacode = @v_custcode10
        
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customcode10</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custcode10) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custind01 IS NOT NULL AND @v_test_custind01 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customind01</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custind01) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custind02 IS NOT NULL AND @v_test_custind02 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customind02</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custind02) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custind03 IS NOT NULL AND @v_test_custind03 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customind03</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custind03) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custind04 IS NOT NULL AND @v_test_custind04 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customind04</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custind04) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custind05 IS NOT NULL AND @v_test_custind05 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customind05</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custind05) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custind06 IS NOT NULL AND @v_test_custind06 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customind06</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custind06) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custind07 IS NOT NULL AND @v_test_custind07 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customind07</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custind07) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custind08 IS NOT NULL AND @v_test_custind08 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customind08</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custind08) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custind09 IS NOT NULL AND @v_test_custind09 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customind09</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custind09) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custind10 IS NOT NULL AND @v_test_custind10 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customind10</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custind10) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custint01 IS NOT NULL AND @v_test_custint01 IS NULL
      BEGIN
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customint01</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custint01) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custint02 IS NOT NULL AND @v_test_custint02 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customint02</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custint02) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custint03 IS NOT NULL AND @v_test_custint03 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customint03</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custint03) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custint04 IS NOT NULL AND @v_test_custint04 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customint04</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custint04) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custint05 IS NOT NULL AND @v_test_custint05 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customint05</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custint05) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custint06 IS NOT NULL AND @v_test_custint06 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customint06</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custint06) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custint07 IS NOT NULL AND @v_test_custint07 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customint07</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custint07) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custint08 IS NOT NULL AND @v_test_custint08 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customint08</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custint08) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custint09 IS NOT NULL AND @v_test_custint09 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customint09</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custint09) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custint10 IS NOT NULL AND @v_test_custint10 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customint10</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custint10) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custfloat01 IS NOT NULL AND @v_test_custfloat01 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customfloat01</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custfloat01) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custfloat02 IS NOT NULL AND @v_test_custfloat02 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customfloat02</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custfloat02) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custfloat03 IS NOT NULL AND @v_test_custfloat03 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customfloat03</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custfloat03) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custfloat04 IS NOT NULL AND @v_test_custfloat04 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customfloat04</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custfloat04) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custfloat05 IS NOT NULL AND @v_test_custfloat05 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customfloat05</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custfloat05) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custfloat06 IS NOT NULL AND @v_test_custfloat06 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customfloat06</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custfloat06) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custfloat07 IS NOT NULL AND @v_test_custfloat07 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customfloat07</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custfloat07) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custfloat08 IS NOT NULL AND @v_test_custfloat08 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customfloat08</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custfloat08) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custfloat09 IS NOT NULL AND @v_test_custfloat09 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customfloat09</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custfloat09) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      IF @v_custfloat10 IS NOT NULL AND @v_test_custfloat10 IS NULL
      BEGIN    
        SET @v_bookcustom_xml = @v_bookcustom_xml + '
          <DBItem><DBItemColumn>customfloat10</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_custfloat10) + '</DBItemValue></DBItem>'
        SET @v_dbitem_count = @v_dbitem_count + 1
      END  
        
      SET @v_bookcustom_xml = @v_bookcustom_xml + '</DBAction>'
        
      IF @v_dbitem_count > 0
        SET @v_transaction_xml = @v_transaction_xml + @v_bookcustom_xml

    END --BOOKCUSTOM
  END --Custom Fields
  
  
  /* BOOKVERIFICATION */
  
  SELECT @v_initial_status = COALESCE(datacode,0), @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
  FROM gentables
  WHERE tableid = 513 AND qsicode = 1

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @v_initial_status = 0
  END 

  SET @v_dbitem_count = 0
  SET @v_bookver_xml = ''

  DECLARE crBookVer CURSOR FOR
    SELECT datacode, LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
    FROM gentables
    WHERE tableid = 556
      AND LOWER(deletestatus) = 'n'

  OPEN crBookVer 

  FETCH NEXT FROM crBookVer INTO @v_veriftype, @v_verifdesc

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
    SET @v_action_count = @v_action_count + 1

    SET @v_bookver_xml = @v_bookver_xml + '
    <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>bookverification</ActionTable>
      <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>'
    
    SET @v_bookver_xml = @v_bookver_xml + '
      <Key><KeyColumn>verificationtypecode</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_veriftype) + '</KeyValue></Key>'
    
    SET @v_datadesc = @v_verifdesc + ' - ' + @v_datadesc
    SET @v_bookver_xml = @v_bookver_xml + '
      <DBItem><DBItemColumn>titleverifystatuscode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_initial_status) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
    
    SET @v_bookver_xml = @v_bookver_xml + '</DBAction>'
    
    SET @v_dbitem_count = @v_dbitem_count + 1
    
    FETCH NEXT FROM crBookVer INTO @v_veriftype, @v_verifdesc
  END

  CLOSE crBookVer 
  DEALLOCATE crBookVer    
    
  IF @v_dbitem_count > 0
    SET @v_transaction_xml = @v_transaction_xml + @v_bookver_xml
  
  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 11) = 'Y'  --Categories
  BEGIN  

    /* BOOKCATEGORY */
     
    SET @v_dbitem_count = 0
    SET @v_bookcategory_xml = ''  
    SET @v_sortorder = 1
    
    DECLARE crBookCategory CURSOR FOR
      SELECT b.categorycode, LTRIM(RTRIM(REPLACE(REPLACE(g.datadesc, '&', '&amp;'), '''', '''''')))
      FROM bookcategory b, gentables g
      WHERE b.categorycode = g.datacode AND
          g.tableid = 317 AND
          b.bookkey = @i_templatebookkey
      ORDER BY b.sortorder

    OPEN crBookCategory 

    FETCH NEXT FROM crBookCategory INTO @v_categorycode, @v_datadesc

    WHILE (@@FETCH_STATUS <> -1)
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM bookcategory
      WHERE bookkey = @i_bookkey AND categorycode = @v_categorycode
      
      IF @v_count = 0
      BEGIN    
        SET @v_action_count = @v_action_count + 1

        SET @v_bookcategory_xml = @v_bookcategory_xml + '
        <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>bookcategory</ActionTable><HistoryOrder>' + CONVERT(VARCHAR, @v_sortorder) + '</HistoryOrder><FieldDescDetail>' + @v_datadesc + '</FieldDescDetail>
          <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>'
        
        SET @v_bookcategory_xml = @v_bookcategory_xml + '
            <DBItem><DBItemColumn>categorycode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_categorycode) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
        SET @v_bookcategory_xml = @v_bookcategory_xml + '
            <DBItem><DBItemColumn>sortorder</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_sortorder) + '</DBItemValue></DBItem>'

        SET @v_bookcategory_xml = @v_bookcategory_xml + '</DBAction>'
        
        SET @v_sortorder = @v_sortorder + 1
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      FETCH NEXT FROM crBookCategory INTO @v_categorycode, @v_datadesc
    END

    CLOSE crBookCategory 
    DEALLOCATE crBookCategory    
      
    IF @v_dbitem_count > 0
      SET @v_transaction_xml = @v_transaction_xml + @v_bookcategory_xml
      

    /* BOOKBISACCATEGORY */
    
    SET @v_dbitem_count = 0
    SET @v_bookbisaccategory_xml = ''  
    SET @v_sortorder = 1
    
    DECLARE crBookBisacCategory CURSOR FOR
      SELECT b.bisaccategorycode, b.bisaccategorysubcode, LTRIM(RTRIM(REPLACE(REPLACE(g.datadesc, '&', '&amp;'), '''', ''''''))), 
        LTRIM(RTRIM(REPLACE(REPLACE(s.datadesc, '&', '&amp;'), '''', '''''')))
      FROM bookbisaccategory b, gentables g, subgentables s
      WHERE b.bisaccategorycode = s.datacode AND
        b.bisaccategorysubcode = s.datasubcode AND
        g.tableid = s.tableid AND
        g.datacode = s.datacode AND
        g.tableid = 339 AND
        b.bookkey = @i_templatebookkey AND
        b.printingkey = @i_templateprintingkey
      ORDER BY b.sortorder

    OPEN crBookBisacCategory 

    FETCH NEXT FROM crBookBisacCategory INTO @v_categorycode, @v_categorysubcode, @v_categorydesc, @v_categorysubdesc

    WHILE (@@FETCH_STATUS <> -1)
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM bookbisaccategory
      WHERE bookkey = @i_bookkey AND
        printingkey = @i_printingkey AND
        bisaccategorycode = @v_categorycode AND
        bisaccategorysubcode = @v_categorysubcode
        
      IF @v_count = 0
      BEGIN
        SET @v_action_count = @v_action_count + 1

        SET @v_bookbisaccategory_xml = @v_bookbisaccategory_xml + '
        <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>bookbisaccategory</ActionTable><HistoryOrder>' + CONVERT(VARCHAR, @v_sortorder) + '</HistoryOrder><FieldDescDetail>' + @v_categorydesc + '</FieldDescDetail>
          <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>
          <Key><KeyColumn>printingkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_printingkey) + '</KeyValue></Key>'
        
        SET @v_datadesc = @v_categorydesc + ' - ' + @v_categorysubdesc    
        SET @v_bookbisaccategory_xml = @v_bookbisaccategory_xml + '
            <DBItem><DBItemColumn>bisaccategorycode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_categorycode) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
        SET @v_bookbisaccategory_xml = @v_bookbisaccategory_xml + '
            <DBItem><DBItemColumn>bisaccategorysubcode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_categorysubcode) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_categorysubdesc + @v_quote + '</DBItemDesc></DBItem>'
        SET @v_bookbisaccategory_xml = @v_bookbisaccategory_xml + '
            <DBItem><DBItemColumn>sortorder</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_sortorder) + '</DBItemValue></DBItem>'

        SET @v_bookbisaccategory_xml = @v_bookbisaccategory_xml + '</DBAction>'
        
        SET @v_sortorder = @v_sortorder + 1
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      FETCH NEXT FROM crBookBisacCategory INTO @v_categorycode, @v_categorysubcode, @v_categorydesc, @v_categorysubdesc
    END

    CLOSE crBookBisacCategory 
    DEALLOCATE crBookBisacCategory    
      
    IF @v_dbitem_count > 0
      SET @v_transaction_xml = @v_transaction_xml + @v_bookbisaccategory_xml  


    /* BOOKSUBJECTCATEGORY */
    
    SET @v_dbitem_count = 0
    SET @v_booksubjectcategory_xml = ''
	SET @v_sortorder = 1  
    
    DECLARE crBookSubjectCategory CURSOR FOR
      SELECT b.categorytableid, b.categorycode, b.categorysubcode, b.categorysub2code, 
        LTRIM(RTRIM(REPLACE(REPLACE(g.datadesc, '&', '&amp;'), '''', ''''''))), 
        LTRIM(RTRIM(REPLACE(REPLACE(s.datadesc, '&', '&amp;'), '''', ''''''))),
        LTRIM(RTRIM(REPLACE(REPLACE(s2.datadesc, '&', '&amp;'), '''', '''''')))
      FROM booksubjectcategory b
        LEFT OUTER JOIN gentables g ON b.categorytableid = g.tableid AND b.categorycode = g.datacode
        LEFT OUTER JOIN subgentables s ON b.categorytableid = s.tableid AND b.categorycode = s.datacode AND b.categorysubcode = s.datasubcode
        LEFT OUTER JOIN sub2gentables s2 ON b.categorytableid = s2.tableid AND b.categorycode = s2.datacode AND b.categorysubcode = s2.datasubcode AND b.categorysub2code = s2.datasub2code
      WHERE bookkey = @i_templatebookkey
      ORDER BY b.categorytableid, b.sortorder

    OPEN crBookSubjectCategory 

    FETCH NEXT FROM crBookSubjectCategory 
    INTO @v_categorytableid, @v_categorycode, @v_categorysubcode, @v_categorysub2code, @v_categorydesc, @v_categorysubdesc, @v_categorysub2desc

    WHILE (@@FETCH_STATUS <> -1)
    BEGIN
	  IF @v_categorytableid <> @v_currentcategorytableid
	  BEGIN
		SET @v_sortorder = 1
        SET @v_dbitem_count = 1
	  END
      ELSE IF @v_categorysub2code > 0
        SELECT @v_count = COUNT(*)
        FROM booksubjectcategory
        WHERE bookkey = @i_bookkey AND
          categorycode = @v_categorycode AND
          categorysubcode = @v_categorysubcode AND
          categorysub2code = @v_categorysub2code
      ELSE IF @v_categorysubcode > 0
        SELECT @v_count = COUNT(*)
        FROM booksubjectcategory
        WHERE bookkey = @i_bookkey AND
          categorycode = @v_categorycode AND
          categorysubcode = @v_categorysubcode AND
          (categorysub2code = 0 OR categorysub2code IS NULL)
      ELSE
        SELECT @v_count = COUNT(*)
        FROM booksubjectcategory
        WHERE bookkey = @i_bookkey AND
          categorycode = @v_categorycode AND
          (categorysubcode = 0 OR categorysubcode IS NULL) AND
          (categorysub2code = 0 OR categorysub2code IS NULL)

      IF @v_count = 0
      BEGIN
        SET @v_action_count = @v_action_count + 1

        SET @v_fielddesc = @v_categorydesc
        IF @v_categorysubdesc IS NOT NULL
          SET @v_fielddesc = @v_fielddesc + ' - ' + @v_categorysubdesc
        IF @v_categorysub2desc IS NOT NULL
          SET @v_fielddesc = @v_fielddesc + ' - ' + @v_categorysub2desc

        SET @v_fielddesc = RTRIM(SUBSTRING(@v_fielddesc, 0, 116)) -- to handle edge case where string ends with a truncated &amp; and breaks XML parsing

        SET @v_booksubjectcategory_xml = @v_booksubjectcategory_xml + '
        <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>booksubjectcategory</ActionTable><HistoryOrder>' + CONVERT(VARCHAR, @v_sortorder) + '</HistoryOrder><FieldDescDetail>' + @v_fielddesc + '</FieldDescDetail>
          <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>
          <Key><KeyColumn>subjectkey</KeyColumn><KeyValue>?</KeyValue></Key>
          <Key><KeyColumn>categorytableid</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_categorytableid) + '</KeyValue></Key>'
        
        SET @v_datadesc = @v_fielddesc

        SET @v_booksubjectcategory_xml = @v_booksubjectcategory_xml + '
            <DBItem><DBItemColumn>categorycode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_categorycode) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
        
        IF @v_categorysubcode > 0
        BEGIN
          SET @v_datadesc = @v_categorysubdesc
          IF @v_categorysub2desc IS NOT NULL
            SET @v_datadesc = @v_datadesc + ' - ' + @v_categorysub2desc
        
          SET @v_datadesc = RTRIM(SUBSTRING(@v_datadesc, 0, 116)) -- to handle edge case where string ends with a truncated &amp; and breaks XML parsing

          SET @v_booksubjectcategory_xml = @v_booksubjectcategory_xml + '
            <DBItem><DBItemColumn>categorysubcode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_categorysubcode) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
        END
        
        IF @v_categorysub2code > 0
        BEGIN
          SET @v_booksubjectcategory_xml = @v_booksubjectcategory_xml + '
            <DBItem><DBItemColumn>categorysub2code</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_categorysub2code) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_categorysub2desc + @v_quote + '</DBItemDesc></DBItem>'
        END
        
        SET @v_booksubjectcategory_xml = @v_booksubjectcategory_xml + '
            <DBItem><DBItemColumn>sortorder</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_sortorder) + '</DBItemValue></DBItem>'

        SET @v_booksubjectcategory_xml = @v_booksubjectcategory_xml + '</DBAction>'

		SET @v_currentcategorytableid = @v_categorytableid
		SET @v_sortorder = @v_sortorder + 1
		SET @v_dbitem_count = @v_dbitem_count + 1
        
      END
      
      FETCH NEXT FROM crBookSubjectCategory 
      INTO @v_categorytableid, @v_categorycode, @v_categorysubcode, @v_categorysub2code, @v_categorydesc, @v_categorysubdesc, @v_categorysub2desc
    END

    CLOSE crBookSubjectCategory 
    DEALLOCATE crBookSubjectCategory    
      
    IF @v_dbitem_count > 0
      SET @v_transaction_xml = @v_transaction_xml + @v_booksubjectcategory_xml
      
  END --Categories
  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 21) = 'Y'  --Book Product Detail
  BEGIN  
    /* bookproductdetail */
    
    SET @v_dbitem_count = 0
    SET @v_bookproductdetail_xml = ''  
    SET @v_sortorder = 1
    
    DECLARE crBookProductDetail CURSOR FOR
      SELECT b.tableid, b.datacode, b.datasubcode, b.datasub2code, 
        LTRIM(RTRIM(REPLACE(REPLACE(g.datadesc, '&', '&amp;'), '''', ''''''))), 
        LTRIM(RTRIM(REPLACE(REPLACE(s.datadesc, '&', '&amp;'), '''', ''''''))),
        LTRIM(RTRIM(REPLACE(REPLACE(s2.datadesc, '&', '&amp;'), '''', '''''')))
      FROM bookproductdetail b
        LEFT OUTER JOIN gentables g ON b.tableid = g.tableid AND b.datacode = g.datacode
        LEFT OUTER JOIN subgentables s ON b.tableid = s.tableid AND b.datacode = s.datacode AND b.datasubcode = s.datasubcode
        LEFT OUTER JOIN sub2gentables s2 ON b.tableid = s2.tableid AND b.datacode = s2.datacode AND b.datasubcode = s2.datasubcode AND b.datasub2code = s2.datasub2code
      WHERE bookkey = @i_templatebookkey
      ORDER BY b.sortorder

    OPEN crBookProductDetail 

    FETCH NEXT FROM crBookProductDetail 
    INTO @v_tableid, @v_productdatacode, @v_productdatasubcode, @v_productdatasub2code, @v_productdatadesc, @v_productdatasubdesc, @v_productdatasub2desc

    WHILE (@@FETCH_STATUS <> -1)
    BEGIN
      IF @v_productdatasub2code > 0
        SELECT @v_count = COUNT(*)
        FROM bookproductdetail
        WHERE bookkey = @i_bookkey AND
          datacode = @v_productdatacode AND
          datasubcode = @v_productdatasubcode AND
          datasub2code = @v_productdatasub2code
      ELSE IF @v_productdatasubcode > 0
        SELECT @v_count = COUNT(*)
        FROM bookproductdetail
        WHERE bookkey = @i_bookkey AND
          datacode = @v_productdatacode AND
          datasubcode = @v_productdatasubcode AND
          (datasub2code = 0 OR datasub2code IS NULL)
      ELSE
        SELECT @v_count = COUNT(*)
        FROM bookproductdetail
        WHERE bookkey = @i_bookkey AND
          datacode = @v_productdatacode AND
          (datasubcode = 0 OR datasubcode IS NULL) AND
          (datasub2code = 0 OR datasub2code IS NULL)

      IF @v_count = 0
      BEGIN
        SET @v_action_count = @v_action_count + 1

        SET @v_fielddesc = @v_productdatadesc
        IF @v_productdatasubdesc IS NOT NULL
          SET @v_fielddesc = @v_fielddesc + ' - ' + @v_productdatasubdesc
        IF @v_productdatasub2desc IS NOT NULL
          SET @v_fielddesc = @v_fielddesc + ' - ' + @v_productdatasub2desc
          
        SET @v_bookproductdetail_xml = @v_bookproductdetail_xml + '
        <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>bookproductdetail</ActionTable><HistoryOrder>' + CONVERT(VARCHAR, @v_sortorder) + '</HistoryOrder><FieldDescDetail>' + @v_fielddesc + '</FieldDescDetail>
          <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>
          <Key><KeyColumn>productdetailkey</KeyColumn><KeyValue>?</KeyValue></Key>
          <Key><KeyColumn>tableid</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_tableid) + '</KeyValue></Key>'
        
        SET @v_productdatadesc = @v_productdatadesc
        IF @v_productdatasubdesc IS NOT NULL
          SET @v_productdatadesc = @v_productdatadesc + ' - ' + @v_productdatasubdesc
        IF @v_productdatasub2desc IS NOT NULL
          SET @v_productdatadesc = @v_productdatadesc + ' - ' + @v_productdatasub2desc
          
        SET @v_bookproductdetail_xml = @v_bookproductdetail_xml + '
            <DBItem><DBItemColumn>datacode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_productdatacode) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_productdatadesc + @v_quote + '</DBItemDesc></DBItem>'
        
        IF @v_productdatasubcode > 0
        BEGIN
          SET @v_productdatadesc = @v_productdatasubdesc
          IF @v_productdatasub2desc IS NOT NULL
            SET @v_productdatadesc = @v_productdatadesc + ' - ' + @v_productdatasub2desc
        
          SET @v_bookproductdetail_xml = @v_bookproductdetail_xml + '
            <DBItem><DBItemColumn>datasubcode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_productdatasubcode) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_productdatadesc + @v_quote + '</DBItemDesc></DBItem>'
        END
        
        IF @v_productdatasub2code > 0
        BEGIN
          SET @v_bookproductdetail_xml = @v_bookproductdetail_xml + '
            <DBItem><DBItemColumn>datasub2code</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_productdatasub2code) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_productdatasub2desc + @v_quote + '</DBItemDesc></DBItem>'
        END
        
        SET @v_bookproductdetail_xml = @v_bookproductdetail_xml + '
            <DBItem><DBItemColumn>sortorder</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_sortorder) + '</DBItemValue></DBItem>'

        SET @v_bookproductdetail_xml = @v_bookproductdetail_xml + '</DBAction>'
        
        SET @v_sortorder = @v_sortorder + 1
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      FETCH NEXT FROM crBookProductDetail 
      INTO @v_tableid, @v_productdatacode, @v_productdatasubcode, @v_productdatasub2code, @v_productdatadesc, @v_productdatasubdesc, @v_productdatasub2desc
    END

    CLOSE crBookProductDetail 
    DEALLOCATE crBookProductDetail    
      
    IF @v_dbitem_count > 0
      SET @v_transaction_xml = @v_transaction_xml + @v_bookproductdetail_xml
      
  END --Book Product Detail
  
  /* BOOKPRICE */

  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 3) = 'Y'  --Prices
  BEGIN  

    SET @v_dbitem_count = 0
    SET @v_bookprice_xml = ''
    SET @v_sortorder = 1
    SET @v_cleardata = dbo.find_integer_in_comma_delim_list(@i_cleardatagroups_list, 3)
    
    DECLARE crBookPrice CURSOR FOR
      SELECT p.pricetypecode, p.currencytypecode, p.activeind, p.budgetprice, p.finalprice, p.expirationdate, p.effectivedate,
        LTRIM(RTRIM(REPLACE(REPLACE(g1.datadesc, '&', '&amp;'), '''', ''''''))), 
        LTRIM(RTRIM(REPLACE(REPLACE(COALESCE(g1.datadescshort, g1.datadesc), '&', '&amp;'), '''', ''''''))),
        LTRIM(RTRIM(REPLACE(REPLACE(g2.datadesc, '&', '&amp;'), '''', ''''''))),
	      LTRIM(RTRIM(REPLACE(REPLACE(COALESCE(g2.datadescshort, g2.datadesc), '&', '&amp;'), '''', ''''''))), p.sortorder
      FROM bookprice p
        LEFT OUTER JOIN gentables g1 ON p.pricetypecode = g1.datacode AND g1.tableid = 306
        LEFT OUTER JOIN gentables g2 ON p.currencytypecode = g2.datacode AND g2.tableid = 122
      WHERE bookkey = @i_templatebookkey
      ORDER BY p.history_order    

    OPEN crBookPrice 

    FETCH NEXT FROM crBookPrice 
    INTO @v_pricetype, @v_currencytype, @v_activeind, @v_budgetprice, @v_finalprice, @v_expdate, @v_effectivedate,
      @v_pricetypedesc, @v_pricetypeshort, @v_currencydesc, @v_currencyshort, @v_sortorder_price

    WHILE (@@FETCH_STATUS <> -1)
    BEGIN           
      SELECT @v_count = COUNT(*)
      FROM bookprice
      WHERE bookkey = @i_bookkey AND
        pricetypecode = @v_pricetype AND
        currencytypecode = @v_currencytype AND
        activeind = @v_activeind
        
      IF @v_count > 0
      BEGIN
        SELECT @v_test_budgetprice = budgetprice, @v_test_finalprice = finalprice, @v_pricekey = pricekey, @v_historyorder = history_order
        FROM bookprice
        WHERE bookkey = @i_bookkey AND
          pricetypecode = @v_pricetype AND
          currencytypecode = @v_currencytype AND
          activeind = @v_activeind
        
        IF @v_cleardata = 'N' AND @v_test_budgetprice IS NULL AND @v_test_finalprice IS NULL
        BEGIN
          -- this price row exists, but the price value is null - update with value from template
          SET @v_action_count = @v_action_count + 1

          SET @v_fielddesc = isnull(@v_pricetypeshort,'')
            
          SET @v_bookprice_xml = @v_bookprice_xml + '
          <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>update</ActionType><ActionTable>bookprice</ActionTable><HistoryOrder>' + CONVERT(VARCHAR, @v_historyorder) + '</HistoryOrder><FieldDescDetail>' + @v_fielddesc + '</FieldDescDetail>
            <Key><KeyColumn>pricekey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_pricekey) + '</KeyValue></Key>' +
            '<Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>'
          
          IF @v_budgetprice IS NOT NULL
          BEGIN
            SET @v_datadesc = CONVERT(VARCHAR, CONVERT(MONEY, @v_budgetprice, 1))
            SET @v_datadesc = @v_datadesc + ' ' + @v_currencyshort
            SET @v_bookprice_xml = @v_bookprice_xml + '
              <DBItem><DBItemColumn>budgetprice</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_budgetprice) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'      
          END
          
          IF @v_finalprice IS NOT NULL
          BEGIN
            SET @v_datadesc = CONVERT(VARCHAR, CONVERT(MONEY, @v_finalprice, 1))
            SET @v_datadesc = @v_datadesc + ' ' + @v_currencyshort
            SET @v_bookprice_xml = @v_bookprice_xml + '
              <DBItem><DBItemColumn>finalprice</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_finalprice) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
          END
          
          IF @v_budgetprice IS NOT NULL OR @v_finalprice IS NOT NULL
          BEGIN
            IF ( isNull(@v_effectivedate,'') != '' )
            BEGIN
					SET @v_bookprice_xml = @v_bookprice_xml + '
					  <DBItem><DBItemColumn>effectivedate</DBItemColumn><DBItemValue>'+ @v_quote + CONVERT(VARCHAR,@v_effectivedate) + @v_quote +' </DBItemValue></DBItem>'   
            END ELSE
            BEGIN
					SET @v_bookprice_xml = @v_bookprice_xml + '
					  <DBItem><DBItemColumn>effectivedate</DBItemColumn><DBItemValue>' + @v_quote + CONVERT(VARCHAR,GETDATE()) + @v_quote + '</DBItemValue></DBItem>'   
            END
            IF ( isNull(@v_expdate,'') != '' )
            BEGIN
					SET @v_bookprice_xml = @v_bookprice_xml + '
					  <DBItem><DBItemColumn>expirationdate</DBItemColumn><DBItemValue>'+ @v_quote + CONVERT(VARCHAR,@v_expdate) + @v_quote +' </DBItemValue></DBItem>'   
            END 
          END ELSE
          BEGIN
            SET @v_bookprice_xml = @v_bookprice_xml + '
               <DBItem><DBItemColumn>effectivedate</DBItemColumn><DBItemValue>' + @v_quote + CONVERT(VARCHAR,GETDATE()) + @v_quote + '</DBItemValue></DBItem>'   
          END

		  IF @v_sortorder_price IS NOT NULL
            SET @v_bookprice_xml = @v_bookprice_xml + '
                <DBItem><DBItemColumn>sortorder</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_sortorder_price) + '</DBItemValue></DBItem>'   

          SET @v_bookprice_xml = @v_bookprice_xml + '</DBAction>'
          
          SET @v_dbitem_count = @v_dbitem_count + 1          
        END
      END
      ELSE  --@v_count = 0
      BEGIN
        SET @v_action_count = @v_action_count + 1

        SET @v_fielddesc = isnull(@v_pricetypeshort, '')
        
        EXEC qtitle_get_next_history_order @i_bookkey, 0, 'bookprice', @i_userid, 
          @v_historyorder OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT        
          
        SET @v_bookprice_xml = @v_bookprice_xml + '
        <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>bookprice</ActionTable><HistoryOrder>' + CONVERT(VARCHAR, @v_historyorder) + '</HistoryOrder><FieldDescDetail>' + @v_fielddesc + '</FieldDescDetail>
          <Key><KeyColumn>pricekey</KeyColumn><KeyValue>?</KeyValue></Key>
          <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>'
              
        SET @v_bookprice_xml = @v_bookprice_xml + '
            <DBItem><DBItemColumn>pricetypecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_pricetype) + '</DBItemValue><DBItemDesc>' + @v_quote + isnull(@v_pricetypedesc,'') + @v_quote + '</DBItemDesc></DBItem>'
        SET @v_bookprice_xml = @v_bookprice_xml + '
            <DBItem><DBItemColumn>currencytypecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_currencytype) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_currencydesc + @v_quote + '</DBItemDesc></DBItem>'

        IF @v_cleardata = 'N'
        BEGIN
          IF @v_budgetprice IS NOT NULL
          BEGIN
            SET @v_datadesc = CONVERT(VARCHAR, CONVERT(MONEY, @v_budgetprice, 1))
            SET @v_datadesc = @v_datadesc + ' ' + @v_currencyshort
            SET @v_bookprice_xml = @v_bookprice_xml + '
              <DBItem><DBItemColumn>budgetprice</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_budgetprice) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'      
          END
          
          IF @v_finalprice IS NOT NULL
          BEGIN
            SET @v_datadesc = CONVERT(VARCHAR, CONVERT(MONEY, @v_finalprice, 1))
            SET @v_datadesc = @v_datadesc + ' ' + @v_currencyshort
            SET @v_bookprice_xml = @v_bookprice_xml + '
              <DBItem><DBItemColumn>finalprice</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_finalprice) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
          END
        
          IF @v_budgetprice IS NOT NULL OR @v_finalprice IS NOT NULL
          BEGIN
		    IF ( isNull(@v_effectivedate,'') != '' )
            BEGIN
					SET @v_bookprice_xml = @v_bookprice_xml + '
					  <DBItem><DBItemColumn>effectivedate</DBItemColumn><DBItemValue>' + @v_quote + CONVERT(VARCHAR,@v_effectivedate) + @v_quote + '</DBItemValue></DBItem>'   
            END ELSE
            BEGIN
					SET @v_bookprice_xml = @v_bookprice_xml + '
					  <DBItem><DBItemColumn>effectivedate</DBItemColumn><DBItemValue>' + @v_quote + CONVERT(VARCHAR,GETDATE()) + @v_quote + '</DBItemValue></DBItem>'   
            END
            IF ( isNull(@v_expdate,'') != '' )
            BEGIN
					SET @v_bookprice_xml = @v_bookprice_xml + '
					  <DBItem><DBItemColumn>expirationdate</DBItemColumn><DBItemValue>' + @v_quote + CONVERT(VARCHAR,@v_expdate) + @v_quote + '</DBItemValue></DBItem>'   
            END
          END ELSE
          BEGIN
            SET @v_bookprice_xml = @v_bookprice_xml + '
               <DBItem><DBItemColumn>effectivedate</DBItemColumn><DBItemValue>' + @v_quote + CONVERT(VARCHAR,GETDATE()) + @v_quote + '</DBItemValue></DBItem>'   
          END
        END
        
        IF @v_activeind = 1
         BEGIN
          SET @v_datadesc = 'Y'
          SET @v_bookprice_xml = @v_bookprice_xml + '
            <DBItem><DBItemColumn>activeind</DBItemColumn><DBItemValue>1</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'     
         END
        ELSE
         BEGIN
          SET @v_datadesc = 'N'
          SET @v_bookprice_xml = @v_bookprice_xml + '
            <DBItem><DBItemColumn>activeind</DBItemColumn><DBItemValue>0</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'     
         END   
		 
		 IF @v_sortorder_price IS NULL BEGIN
			SET @v_sortorder_price = @v_sortorder
		 END 
		 ELSE BEGIN
			SET @v_sortorder = @v_sortorder_price
		 END  
        
        SET @v_bookprice_xml = @v_bookprice_xml + '
            <DBItem><DBItemColumn>sortorder</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_sortorder_price) + '</DBItemValue></DBItem>'
        SET @v_bookprice_xml = @v_bookprice_xml + '
            <DBItem><DBItemColumn>history_order</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_historyorder) + '</DBItemValue></DBItem>'

        SET @v_bookprice_xml = @v_bookprice_xml + '</DBAction>'
        
        SET @v_sortorder = @v_sortorder + 1
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      FETCH NEXT FROM crBookPrice 
      INTO @v_pricetype, @v_currencytype, @v_activeind, @v_budgetprice, @v_finalprice, @v_expdate,@v_effectivedate,
        @v_pricetypedesc, @v_pricetypeshort, @v_currencydesc, @v_currencyshort, @v_sortorder_price
    END

    CLOSE crBookPrice 
    DEALLOCATE crBookPrice    
      
    IF @v_dbitem_count > 0
      SET @v_transaction_xml = @v_transaction_xml + @v_bookprice_xml
  
  END --Prices
  
  /* BOOKAUTHOR */
  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 2) = 'Y'  --Authors
  BEGIN
      
    SET @v_dbitem_count = 0
    SET @v_bookauthor_xml = ''
    SET @v_sortorder = 1
    
    DECLARE crBookAuthor CURSOR FOR
      SELECT b.authorkey, b.authortypecode, b.reportind, b.primaryind, 
        LTRIM(RTRIM(REPLACE(REPLACE(a.displayname, '&', '&amp;'), '''', ''''''))), 
        LTRIM(RTRIM(REPLACE(REPLACE(g.datadesc, '&', '&amp;'), '''', '''''')))
      FROM bookauthor b, author a, gentables g
      WHERE b.authorkey = a.authorkey AND
	      b.authortypecode = g.datacode AND
	      g.tableid = 134 AND
        b.bookkey = @i_templatebookkey
      ORDER BY b.sortorder, b.history_order

    OPEN crBookAuthor 

    FETCH NEXT FROM crBookAuthor 
    INTO @v_authorkey, @v_authortype, @v_reportind, @v_primaryind, @v_datadesc, @v_authortypedesc

    WHILE (@@FETCH_STATUS <> -1)
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM bookauthor
      WHERE bookkey = @i_bookkey AND
        authorkey = @v_authorkey AND
        authortypecode = @v_authortype
        
      IF @v_count = 0
      BEGIN
        SET @v_action_count = @v_action_count + 1

        SET @v_fielddesc = @v_datadesc
          
        SET @v_bookauthor_xml = @v_bookauthor_xml + '
        <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>bookauthor</ActionTable><HistoryOrder>' + CONVERT(VARCHAR, @v_sortorder) + '</HistoryOrder><FieldDescDetail>' + @v_fielddesc + '</FieldDescDetail>
          <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>'
              
        SET @v_bookauthor_xml = @v_bookauthor_xml + '
            <DBItem><DBItemColumn>authorkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_authorkey) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
        SET @v_bookauthor_xml = @v_bookauthor_xml + '
            <DBItem><DBItemColumn>authortypecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_authortype) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_authortypedesc + @v_quote + '</DBItemDesc></DBItem>'
        SET @v_bookauthor_xml = @v_bookauthor_xml + '
            <DBItem><DBItemColumn>primaryind</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_primaryind) + '</DBItemValue></DBItem>'
        SET @v_bookauthor_xml = @v_bookauthor_xml + '
            <DBItem><DBItemColumn>reportind</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_reportind) + '</DBItemValue></DBItem>'
        SET @v_bookauthor_xml = @v_bookauthor_xml + '
            <DBItem><DBItemColumn>sortorder</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_sortorder) + '</DBItemValue></DBItem>'
        SET @v_bookauthor_xml = @v_bookauthor_xml + '
            <DBItem><DBItemColumn>history_order</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_sortorder) + '</DBItemValue></DBItem>'

        SET @v_bookauthor_xml = @v_bookauthor_xml + '</DBAction>'
        
        SET @v_action_count = @v_action_count + 1
        
        SET @v_bookauthor_xml = @v_bookauthor_xml + '
        <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>storedprocedure</ActionType>
        <ProcedureName>qcontact_verify_or_add_author_role_xml</ProcedureName>
        <Parameters>&lt;Parameters&gt;' +
          '&lt;ContactKey&gt;' + CONVERT(VARCHAR, @v_authorkey) + '&lt;/ContactKey&gt;' +
          '&lt;AuthorRoleType&gt;' + CONVERT(VARCHAR, @v_authortype) + '&lt;/AuthorRoleType&gt;' +
          '&lt;/Parameters&gt;' +
        '</Parameters></DBAction>'
        
        SET @v_action_count = @v_action_count + 1
        
        SET @v_bookauthor_xml = @v_bookauthor_xml + '
        <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>storedprocedure</ActionType>
        <ProcedureName>qauthor_contact_to_author_xml</ProcedureName>
        <Parameters>&lt;Parameters&gt;' +
          '&lt;ContactKey&gt;' + CONVERT(VARCHAR, @v_authorkey) + '&lt;/ContactKey&gt;' +
          '&lt;UserID&gt;' + CONVERT(VARCHAR, @i_userid) + '&lt;/UserID&gt;' +
          '&lt;/Parameters&gt;' +
        '</Parameters></DBAction>'    
        
        SET @v_sortorder = @v_sortorder + 1
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      FETCH NEXT FROM crBookAuthor 
      INTO @v_authorkey, @v_authortype, @v_reportind, @v_primaryind, @v_datadesc, @v_authortypedesc
    END

    CLOSE crBookAuthor 
    DEALLOCATE crBookAuthor    
      
    IF @v_dbitem_count > 0
      SET @v_transaction_xml = @v_transaction_xml + @v_bookauthor_xml

  END --Authors

  /* BOOKMISC */

  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 12) = 'Y'  --Misc Items
  BEGIN
    
    SET @v_dbitem_count = 0
    SET @v_bookmisc_xml = ''
    
	IF @v_standardind = 'Y' BEGIN
		DECLARE crBookMisc CURSOR FOR
		  SELECT m.misckey, m.longvalue, m.floatvalue, 
			LTRIM(RTRIM(REPLACE(REPLACE(m.textvalue, '&', '&amp;'), '''', ''''''))), 
			m.sendtoeloquenceind, 
			LTRIM(RTRIM(REPLACE(REPLACE(i.miscname, '&', '&amp;'), '''', ''''''))),
			i.misctype, i.datacode
		  FROM bookmisc m, bookmiscitems i
		  WHERE m.misckey = i.misckey AND
			m.bookkey = @i_templatebookkey
     END
	 ELSE BEGIN
		DECLARE crBookMisc CURSOR FOR
		  SELECT m.misckey, m.longvalue, m.floatvalue, 
			LTRIM(RTRIM(REPLACE(REPLACE(m.textvalue, '&', '&amp;'), '''', ''''''))), 
			m.sendtoeloquenceind, 
			LTRIM(RTRIM(REPLACE(REPLACE(i.miscname, '&', '&amp;'), '''', ''''''))),
			i.misctype, i.datacode
		  FROM bookmisc m, bookmiscitems i
		  WHERE m.misckey = i.misckey AND
			i.copymiscitemind = 1 AND
			m.bookkey = @i_templatebookkey		
	 END 

    OPEN crBookMisc 

    FETCH NEXT FROM crBookMisc 
    INTO @v_misckey, @v_longvalue, @v_floatvalue, @v_textvalue, @v_sendtoeloind, @v_fielddesc, @v_misctype, @v_datacode

    WHILE (@@FETCH_STATUS <> -1)
    BEGIN    
      SELECT @v_count = COUNT(*)
      FROM bookmisc
      WHERE bookkey = @i_bookkey AND misckey = @v_misckey
      
      IF @v_count > 0
        SELECT @v_test_longvalue = longvalue, @v_test_floatvalue = floatvalue, @v_test_textvalue = textvalue
        FROM bookmisc
        WHERE bookkey = @i_bookkey AND misckey = @v_misckey
      ELSE
        BEGIN
          SET @v_test_longvalue = NULL
          SET @v_test_floatvalue = NULL
          SET @v_test_textvalue = NULL
        END
        
      SET @v_fielddesc = LTRIM(RTRIM(REPLACE(REPLACE(@v_fielddesc, '<', '&lt;'), '''', '''''')))
      SET @v_fielddesc = LTRIM(RTRIM(REPLACE(REPLACE(@v_fielddesc, '>', '&gt;'), '''', '''''')))
      
      SET @v_textvalue = LTRIM(RTRIM(REPLACE(REPLACE(@v_textvalue, '<', '&lt;'), '''', '''''')))
      SET @v_textvalue = LTRIM(RTRIM(REPLACE(REPLACE(@v_textvalue, '>', '&gt;'), '''', '''''')))      
        
      SET @v_action_count = @v_action_count + 1
    
      SET @v_bookmisc_xml = @v_bookmisc_xml + '
      <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insertupdate</ActionType><ActionTable>bookmisc</ActionTable><HistoryOrder>0</HistoryOrder><FieldDescDetail>' + @v_fielddesc + '</FieldDescDetail>
        <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>
        <Key><KeyColumn>misckey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_misckey) + '</KeyValue></Key>'
      
      IF @v_longvalue IS NOT NULL AND @v_test_longvalue IS NULL
      BEGIN
        IF @v_misctype = 5  --gentable
         BEGIN
          SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
          FROM subgentables
          WHERE tableid = 525 AND datacode = @v_datacode AND datasubcode = @v_longvalue
          
    	  IF @v_datadesc IS NOT NULL
            SET @v_bookmisc_xml = @v_bookmisc_xml + '
              <DBItem><DBItemColumn>longvalue</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_longvalue) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
         END
        ELSE --checkbox or long
         BEGIN
          SET @v_bookmisc_xml = @v_bookmisc_xml + '
           <DBItem><DBItemColumn>longvalue</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_longvalue) + '</DBItemValue></DBItem>'
         END
          
        SET @v_dbitem_count = @v_dbitem_count + 1  
      END
      
      IF @v_floatvalue IS NOT NULL AND @v_test_floatvalue IS NULL
      BEGIN
        SET @v_bookmisc_xml = @v_bookmisc_xml + '
          <DBItem><DBItemColumn>floatvalue</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_floatvalue) + '</DBItemValue></DBItem>'
      
        SET @v_dbitem_count = @v_dbitem_count + 1    
      END
      
      IF @v_textvalue IS NOT NULL AND @v_test_textvalue IS NULL
      BEGIN
        SET @v_bookmisc_xml = @v_bookmisc_xml + '
          <DBItem><DBItemColumn>textvalue</DBItemColumn><DBItemValue>' + @v_quote + @v_textvalue + @v_quote + '</DBItemValue></DBItem>'
      
        SET @v_dbitem_count = @v_dbitem_count + 1    
      END
      
      IF (@v_longvalue IS NOT NULL AND @v_test_longvalue IS NULL) OR 
        (@v_floatvalue IS NOT NULL AND @v_test_floatvalue IS NULL) OR (@v_textvalue IS NOT NULL AND @v_test_textvalue IS NULL)
      BEGIN
        SET @v_bookmisc_xml = @v_bookmisc_xml + '
          <DBItem><DBItemColumn>sendtoeloquenceind</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_sendtoeloind) + '</DBItemValue></DBItem>' 
      END
      
      SET @v_bookmisc_xml = @v_bookmisc_xml + '</DBAction>'
          
      FETCH NEXT FROM crBookMisc 
      INTO @v_misckey, @v_longvalue, @v_floatvalue, @v_textvalue, @v_sendtoeloind, @v_fielddesc, @v_misctype, @v_datacode
    END

    CLOSE crBookMisc 
    DEALLOCATE crBookMisc    
      
    IF @v_dbitem_count > 0
      SET @v_transaction_xml = @v_transaction_xml + @v_bookmisc_xml
    
  END --Misc Fields    
  
  /* TAQPROJECTTITLE */
  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 14) = 'Y'  --Related Projects
  BEGIN
    
    SET @v_dbitem_count = 0
    SET @v_taqprojecttitle_xml = ''
    SET @v_sortorder = 1
    
    SELECT @v_work_projectrolecode = datacode
      FROM gentables 
     WHERE tableid = 604 
       and qsicode = 1
             
    if @v_work_projectrolecode is null begin
      SET @v_work_projectrolecode = 0
    end
    
    DECLARE crTaqProjectTitle CURSOR FOR
		SELECT tpt.taqprojectkey, tpt.titlerolecode, tpt.projectrolecode, 
			LTRIM(RTRIM(REPLACE(REPLACE(tpt.taqprojectformatdesc, '&', '&amp;'), '''', ''''''))), 
			tpt.keyind, tpt.quantity1, tpt.quantity2, tpt.indicator1, tpt.indicator2, tpt.sortorder,
			LTRIM(RTRIM(REPLACE(REPLACE(tpt.relateditem2name, '&', '&amp;'), '''', ''''''))),
			LTRIM(RTRIM(REPLACE(REPLACE(tpt.relateditem2status, '&', '&amp;'), '''', ''''''))),
			LTRIM(RTRIM(REPLACE(REPLACE(tpt.relateditem2participants, '&', '&amp;'), '''', '''''')))
		FROM taqprojecttitle tpt
		LEFT OUTER JOIN taqproject tp ON tpt.taqprojectkey = tp.taqprojectkey
		WHERE tpt.bookkey = @i_templatebookkey
		AND COALESCE(tpt.projectrolecode,0) <> @v_work_projectrolecode -- do not copy work relationships
		AND tpt.taqprojectkey NOT IN (SELECT taqprojectkey FROM taqproject AS tp1 WHERE (COALESCE(tp1.searchitemcode, 0) IN (select datacode FROM subgentables where tableid = 550 AND qsicode = 1))
									AND (COALESCE(tp1.usageclasscode, 0) IN (select datasubcode FROM subgentables where tableid = 550 AND qsicode = 1)))

    OPEN crTaqProjectTitle 

    FETCH NEXT FROM crTaqProjectTitle 
    INTO @v_projectkey, @v_titlerole, @v_projectrole,
      @v_formatdesc, @v_keyind, @v_qty1, @v_qty2, @v_ind1, @v_ind2, @v_sortorder,
      @v_relateditemname, @v_relateditemstatus, @v_relateditemparticipants

    WHILE (@@FETCH_STATUS <> -1)
    BEGIN
      IF @v_projectrole IS NULL
        IF @v_titlerole IS NULL
          SELECT @v_count = COUNT(*)
          FROM taqprojecttitle
          WHERE bookkey = @i_bookkey AND taqprojectkey = @v_projectkey AND projectrolecode IS NULL AND titlerolecode IS NULL
        ELSE
          SELECT @v_count = COUNT(*)
          FROM taqprojecttitle
          WHERE bookkey = @i_bookkey AND taqprojectkey = @v_projectkey AND projectrolecode IS NULL AND titlerolecode = @v_titlerole
      ELSE
        IF @v_titlerole IS NULL
          SELECT @v_count = COUNT(*)
          FROM taqprojecttitle
          WHERE bookkey = @i_bookkey AND taqprojectkey = @v_projectkey AND projectrolecode = @v_projectrole AND titlerolecode IS NULL
        ELSE
          SELECT @v_count = COUNT(*)
          FROM taqprojecttitle
          WHERE bookkey = @i_bookkey AND taqprojectkey = @v_projectkey AND projectrolecode = @v_projectrole AND titlerolecode = @v_titlerole
      
      IF @v_count = 0
      BEGIN
        SET @v_action_count = @v_action_count + 1
          
        SET @v_taqprojecttitle_xml = @v_taqprojecttitle_xml + '
        <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>taqprojecttitle</ActionTable>
          <Key><KeyColumn>taqprojectformatkey</KeyColumn><KeyValue>?</KeyValue></Key>
          <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>
          <Key><KeyColumn>printingkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_printingkey) + '</KeyValue></Key>'
        
        IF @v_projectkey IS NOT NULL
          SET @v_taqprojecttitle_xml = @v_taqprojecttitle_xml + '
            <DBItem><DBItemColumn>taqprojectkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_projectkey) + '</DBItemValue></DBItem>'

        SET @v_taqprojecttitle_xml = @v_taqprojecttitle_xml + '
            <DBItem><DBItemColumn>primaryformatind</DBItemColumn><DBItemValue>0</DBItemValue></DBItem>'
            
        IF @v_titlerole IS NOT NULL
          SET @v_taqprojecttitle_xml = @v_taqprojecttitle_xml + '
            <DBItem><DBItemColumn>titlerolecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_titlerole) + '</DBItemValue></DBItem>'
            
        IF @v_projectrole IS NOT NULL
          SET @v_taqprojecttitle_xml = @v_taqprojecttitle_xml + '
            <DBItem><DBItemColumn>projectrolecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_projectrole) + '</DBItemValue></DBItem>'
        
        IF @v_formatdesc IS NOT NULL
          SET @v_taqprojecttitle_xml = @v_taqprojecttitle_xml + '
            <DBItem><DBItemColumn>taqprojectformatdesc</DBItemColumn><DBItemValue>' + @v_quote + @v_formatdesc + @v_quote + '</DBItemValue></DBItem>'
        
        IF @v_keyind = 1
          SET @v_taqprojecttitle_xml = @v_taqprojecttitle_xml + '
            <DBItem><DBItemColumn>keyind</DBItemColumn><DBItemValue>1</DBItemValue></DBItem>'
        ELSE
          SET @v_taqprojecttitle_xml = @v_taqprojecttitle_xml + '
            <DBItem><DBItemColumn>keyind</DBItemColumn><DBItemValue>0</DBItemValue></DBItem>'
            
        IF @v_qty1 IS NOT NULL
          SET @v_taqprojecttitle_xml = @v_taqprojecttitle_xml + '
            <DBItem><DBItemColumn>quantity1</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_qty1) + '</DBItemValue></DBItem>'
        
        IF @v_qty2 IS NOT NULL
          SET @v_taqprojecttitle_xml = @v_taqprojecttitle_xml + '
            <DBItem><DBItemColumn>quantity2</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_qty2) + '</DBItemValue></DBItem>'
        
        IF @v_ind1 IS NOT NULL
          SET @v_taqprojecttitle_xml = @v_taqprojecttitle_xml + '
            <DBItem><DBItemColumn>indicator1</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_ind1) + '</DBItemValue></DBItem>'
        
        IF @v_ind2 IS NOT NULL
          SET @v_taqprojecttitle_xml = @v_taqprojecttitle_xml + '
            <DBItem><DBItemColumn>indicator2</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_ind2) + '</DBItemValue></DBItem>'
        
        IF @v_sortorder IS NOT NULL
          SET @v_taqprojecttitle_xml = @v_taqprojecttitle_xml + '
            <DBItem><DBItemColumn>sortorder</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_sortorder) + '</DBItemValue></DBItem>'

        IF @v_relateditemname IS NOT NULL
          SET @v_taqprojecttitle_xml = @v_taqprojecttitle_xml + '
            <DBItem><DBItemColumn>relateditem2name</DBItemColumn><DBItemValue>' + @v_quote + @v_relateditemname + @v_quote + '</DBItemValue></DBItem>'

        IF @v_relateditemstatus IS NOT NULL
          SET @v_taqprojecttitle_xml = @v_taqprojecttitle_xml + '
            <DBItem><DBItemColumn>relateditem2status</DBItemColumn><DBItemValue>' + @v_quote + @v_relateditemstatus + @v_quote + '</DBItemValue></DBItem>'

        IF @v_relateditemparticipants IS NOT NULL
          SET @v_taqprojecttitle_xml = @v_taqprojecttitle_xml + '
            <DBItem><DBItemColumn>relateditem2participants</DBItemColumn><DBItemValue>' + @v_quote + @v_relateditemparticipants + @v_quote + '</DBItemValue></DBItem>'
            
        SET @v_taqprojecttitle_xml = @v_taqprojecttitle_xml + '</DBAction>'
            
        SET @v_sortorder = @v_sortorder + 1
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      FETCH NEXT FROM crTaqProjectTitle 
      INTO @v_projectkey, @v_titlerole, @v_projectrole,
        @v_formatdesc, @v_keyind, @v_qty1, @v_qty2, @v_ind1, @v_ind2, @v_sortorder,
        @v_relateditemname, @v_relateditemstatus, @v_relateditemparticipants
    END

    CLOSE crTaqProjectTitle 
    DEALLOCATE crTaqProjectTitle    
      
    IF @v_dbitem_count > 0
      SET @v_transaction_xml = @v_transaction_xml + @v_taqprojecttitle_xml
    
  END --Related Projects
  
  
  /* BOOKSETS */
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 1) = 'Y'  --Title Information
  BEGIN
    
    SELECT @v_count = COUNT(*)
    FROM booksets
    WHERE bookkey = @i_templatebookkey
    
    IF @v_count > 0
    BEGIN
      SELECT @v_numtitles = numtitles, @v_settype = settypecode, @v_discountpercent = discountpercent
      FROM booksets
      WHERE bookkey = @i_templatebookkey
      
      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
        SET @o_error_code = 1
        SET @o_error_desc = 'Unable to copy from title/template (booksets): from_bookkey=' + CAST(@i_templatebookkey AS VARCHAR)
        RETURN
      END
      
      SELECT @v_count = COUNT(*)
      FROM booksets
      WHERE bookkey = @i_bookkey
      
      IF @v_count > 0
      BEGIN
        SELECT @v_test_settype = settypecode, @v_test_discountpercent = discountpercent
        FROM booksets
        WHERE bookkey = @i_bookkey
        
        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          SET @o_error_code = 1
          SET @o_error_desc = 'Unable to copy from title/template (booksets) - could not verify existing values.'
          RETURN
        END
      END
          
      SET @v_action_count = @v_action_count + 1
      SET @v_booksets_xml = '
      <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>booksets</ActionTable>
        <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>
        <Key><KeyColumn>printingkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_printingkey) + '</KeyValue></Key>
        <Key><KeyColumn>issuenumber</KeyColumn><KeyValue>1</KeyValue></Key>'
      
      IF @v_numtitles > 0
        SET @v_booksets_xml = @v_booksets_xml + '
          <DBItem><DBItemColumn>numtitles</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_numtitles) + '</DBItemValue></DBItem>'
      ELSE
        SET @v_booksets_xml = @v_booksets_xml + '
          <DBItem><DBItemColumn>numtitles</DBItemColumn><DBItemValue>0</DBItemValue></DBItem>'

      IF @v_settype > 0 AND @v_test_settype IS NULL
      BEGIN
        SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
        FROM gentables
        WHERE tableid = 481 AND datacode = @v_settype
        
        SET @v_booksets_xml = @v_booksets_xml + '
          <DBItem><DBItemColumn>settypecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_settype) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
      END
      
      IF @v_discountpercent > 0 AND @v_test_discountpercent IS NULL
      BEGIN       
        SET @v_booksets_xml = @v_booksets_xml + '
          <DBItem><DBItemColumn>discountpercent</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_discountpercent) + '</DBItemValue></DBItem>'
      END      
       
      SET @v_booksets_xml = @v_booksets_xml + '</DBAction>'
        
      SET @v_transaction_xml = @v_transaction_xml + @v_booksets_xml

    END --BOOKSETS
  END
  
    
  /* BINDINGSPECS */

  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 7) = 'Y'  --Inventory
  BEGIN
    SET @v_test_cartonqty = 0
    SET @v_bindingspecs_xml = ''
    
    SELECT @v_cartonqty = cartonqty1
    FROM bindingspecs
    WHERE bookkey = @i_templatebookkey AND
      printingkey = @i_templateprintingkey

    SELECT @v_count = COUNT(*)
    FROM bindingspecs
    WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
      
    IF @v_count > 0
    BEGIN
      SELECT @v_test_cartonqty = isnull(cartonqty1,0)
      FROM bindingspecs
      WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
      
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_code = 1
        SET @o_error_desc = 'Unable to copy from title/template (bindingspecs) - could not verify existing values.'
        RETURN
      END
    END

    SET @v_action_count = @v_action_count + 1

    SET @v_dbitem_count = 0

    SET @v_bindingspecs_xml = '
      <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>bindingspecs</ActionTable>
        <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>
        <Key><KeyColumn>printingkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_printingkey) + '</KeyValue></Key>'
      
    IF @v_cartonqty IS NOT NULL AND @v_test_cartonqty = 0
    BEGIN
      SET @v_bindingspecs_xml = @v_bindingspecs_xml + '
        <DBItem><DBItemColumn>cartonqty1</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_cartonqty) + '</DBItemValue></DBItem>'
      SET @v_dbitem_count = @v_dbitem_count + 1
    END

    SET @v_bindingspecs_xml = @v_bindingspecs_xml + '</DBAction>'  
      
    IF @v_dbitem_count > 0
      SET @v_transaction_xml = @v_transaction_xml + @v_bindingspecs_xml

  END --Inventory
  

  /* BOOKAUDIENCE */

  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 9) = 'Y'  --Classification
  BEGIN  
   
    SET @v_dbitem_count = 0
    SET @v_bookaudience_xml = ''
    SET @v_sortorder = 1
    
    DECLARE crBookAudience CURSOR FOR
      SELECT a.audiencecode, g.datadesc
      FROM bookaudience a, gentables g
      WHERE a.audiencecode = g.datacode AND
        g.tableid = 460 AND
        a.bookkey = @i_templatebookkey
      ORDER BY a.sortorder  

    OPEN crBookAudience 

    FETCH NEXT FROM crBookAudience INTO @v_audiencecode, @v_datadesc

    WHILE (@@FETCH_STATUS <> -1)
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM bookaudience
      WHERE bookkey = @i_bookkey AND audiencecode = @v_audiencecode
      
      IF @v_count = 0
      BEGIN
        SET @v_action_count = @v_action_count + 1
        SET @v_bookaudience_xml = @v_bookaudience_xml + '
        <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>bookaudience</ActionTable>
          <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>'

        SET @v_bookaudience_xml = @v_bookaudience_xml + '
            <DBItem><DBItemColumn>audiencecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_audiencecode) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'

        SET @v_bookaudience_xml = @v_bookaudience_xml + '
            <DBItem><DBItemColumn>sortorder</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_sortorder) + '</DBItemValue></DBItem>'

        SET @v_bookaudience_xml = @v_bookaudience_xml + '</DBAction>'

        SET @v_dbitem_count = @v_dbitem_count + 1
        SET @v_sortorder = @v_sortorder + 1
      END
              
      FETCH NEXT FROM crBookAudience INTO @v_audiencecode, @v_datadesc
    END

    CLOSE crBookAudience 
    DEALLOCATE crBookAudience    
      
    IF @v_dbitem_count > 0
      SET @v_transaction_xml = @v_transaction_xml + @v_bookaudience_xml  
      
  END --Classification

  /* FILELOCATION */

  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 16) = 'Y'  --File Locations
  BEGIN  

    SET @v_dbitem_count = 0
    SET @v_filelocation_xml = ''
    SET @v_sortorder = 1
    SET @v_cleardata = dbo.find_integer_in_comma_delim_list(@i_cleardatagroups_list, 16)
    
    DECLARE crFileLocation CURSOR FOR
      SELECT filetypecode, fileformatcode, filelocationkey, filestatuscode, 
        LTRIM(RTRIM(REPLACE(REPLACE(pathname, '&', '&amp;'), '''', ''''''))),
        LTRIM(RTRIM(REPLACE(REPLACE(CONVERT(VARCHAR, notes), '&', '&amp;'), '''', ''''''))),
        sendtoeloquenceind, taqprojectkey, globalcontactkey, locationtypecode, stagecode,
        LTRIM(RTRIM(REPLACE(REPLACE(filedescription, '&', '&amp;'), '''', '''''')))
      FROM filelocation
      WHERE bookkey = @i_templatebookkey AND printingkey = @i_templateprintingkey AND taqelementkey IS NULL
      ORDER BY sortorder, filelocationgeneratedkey

    OPEN crFileLocation 

    FETCH NEXT FROM crFileLocation 
    INTO @v_filetype, @v_fileformat, @v_filelocationkey, @v_filestatus, @v_path, @v_note,
      @v_sendtoeloind, @v_projectkey, @v_globalcontactkey, @v_locationtype, @v_stagecode, @v_filedesc

    WHILE (@@FETCH_STATUS <> -1)
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM filelocation
      WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey AND taqelementkey IS NULL AND
        filetypecode = @v_filetype AND pathname = @v_path
        
      IF @v_count = 0
      BEGIN
        SET @v_action_count = @v_action_count + 1
        
        SET @v_filelocation_xml = @v_filelocation_xml + '
        <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>filelocation</ActionTable><HistoryOrder>' + CONVERT(VARCHAR, @v_sortorder) + '</HistoryOrder>
          <Key><KeyColumn>filelocationgeneratedkey</KeyColumn><KeyValue>?</KeyValue></Key>'
          
        SET @v_filelocation_xml = @v_filelocation_xml + '
          <DBItem><DBItemColumn>bookkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @i_bookkey) + '</DBItemValue></DBItem>'        
        SET @v_filelocation_xml = @v_filelocation_xml + '
          <DBItem><DBItemColumn>printingkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @i_printingkey) + '</DBItemValue></DBItem>'

        IF @v_filetype > 0
        BEGIN
          SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
          FROM gentables
          WHERE tableid = 354 AND datacode = @v_filetype
          
          SET @v_filelocation_xml = @v_filelocation_xml + '
            <DBItem><DBItemColumn>filetypecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_filetype) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
        END
        
        IF @v_fileformat > 0
        BEGIN
          SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(datadesc, '&', '&amp;'), '''', '''''')))
          FROM gentables
          WHERE tableid = 355 AND datacode = @v_fileformat
          
          SET @v_filelocation_xml = @v_filelocation_xml + '
            <DBItem><DBItemColumn>fileformatcode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_fileformat) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
        END      
        
        IF @v_filelocationkey IS NOT NULL
          SET @v_filelocation_xml = @v_filelocation_xml + '
            <DBItem><DBItemColumn>filelocationkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_filelocationkey) + '</DBItemValue></DBItem>'
        
        IF @v_filestatus IS NOT NULL
          SET @v_filelocation_xml = @v_filelocation_xml + '
            <DBItem><DBItemColumn>filestatuscode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_filestatus) + '</DBItemValue></DBItem>'
        
        IF @v_cleardata = 'N' AND @v_path IS NOT NULL
          SET @v_filelocation_xml = @v_filelocation_xml + '
            <DBItem><DBItemColumn>pathname</DBItemColumn><DBItemValue>' + @v_quote + @v_path + @v_quote + '</DBItemValue></DBItem>'      
        
        IF @v_note IS NOT NULL
          SET @v_filelocation_xml = @v_filelocation_xml + '
            <DBItem><DBItemColumn>notes</DBItemColumn><DBItemValue>' + @v_quote + @v_note + @v_quote + '</DBItemValue></DBItem>'      
        
        IF @v_sendtoeloind = 1
          SET @v_filelocation_xml = @v_filelocation_xml + '
            <DBItem><DBItemColumn>sendtoeloquenceind</DBItemColumn><DBItemValue>1</DBItemValue></DBItem>'
        ELSE
          SET @v_filelocation_xml = @v_filelocation_xml + '
            <DBItem><DBItemColumn>sendtoeloquenceind</DBItemColumn><DBItemValue>0</DBItemValue></DBItem>'      
        
        IF @v_projectkey IS NOT NULL
          SET @v_filelocation_xml = @v_filelocation_xml + '
            <DBItem><DBItemColumn>taqprojectkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_projectkey) + '</DBItemValue></DBItem>'

        IF @v_globalcontactkey IS NOT NULL
          SET @v_filelocation_xml = @v_filelocation_xml + '
            <DBItem><DBItemColumn>globalcontactkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_globalcontactkey) + '</DBItemValue></DBItem>'

        IF @v_locationtype IS NOT NULL
          SET @v_filelocation_xml = @v_filelocation_xml + '
            <DBItem><DBItemColumn>locationtypecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_locationtype) + '</DBItemValue></DBItem>'
        
        IF @v_stagecode IS NOT NULL
          SET @v_filelocation_xml = @v_filelocation_xml + '
            <DBItem><DBItemColumn>stagecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_stagecode) + '</DBItemValue></DBItem>'
        
        IF @v_filedesc IS NOT NULL
          SET @v_filelocation_xml = @v_filelocation_xml + '
            <DBItem><DBItemColumn>filedescription</DBItemColumn><DBItemValue>' + @v_quote + @v_filedesc + @v_quote + '</DBItemValue></DBItem>'      
        
        SET @v_filelocation_xml = @v_filelocation_xml + '
            <DBItem><DBItemColumn>sortorder</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_sortorder) + '</DBItemValue></DBItem>'

        SET @v_filelocation_xml = @v_filelocation_xml + '</DBAction>'
        
        SET @v_sortorder = @v_sortorder + 1
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      FETCH NEXT FROM crFileLocation 
      INTO @v_filetype, @v_fileformat, @v_filelocationkey, @v_filestatus, @v_path, @v_note,
        @v_sendtoeloind, @v_projectkey, @v_globalcontactkey, @v_locationtype, @v_stagecode, @v_filedesc
    END

    CLOSE crFileLocation 
    DEALLOCATE crFileLocation
      
    IF @v_dbitem_count > 0
      SET @v_transaction_xml = @v_transaction_xml + @v_filelocation_xml
  
  END --File Location  


  /* BOOKCOMMENTS */
  /* NOTE: The only purpose of bookcomments copy here is titlehistory (commentstring).
  Comments are deleted and reinserted in qtitle_copy_title_addtl_info stored procedure called at the end here because of HTML tag issues. */
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 13) = 'Y'  --Comments
  BEGIN
  
    SET @v_dbitem_count = 0
    SET @v_bookcomments_xml = ''  
    
    DECLARE crBookComments CURSOR FOR
      SELECT b.commenttypecode, b.commenttypesubcode, COALESCE(b.commentstring,''), b.releasetoeloquenceind, 
        LTRIM(RTRIM(REPLACE(REPLACE(s.datadesc, '&', '&amp;'), '''', '''''')))
      FROM bookcomments b, subgentables s
      WHERE b.commenttypecode = s.datacode AND
        b.commenttypesubcode = s.datasubcode AND
        s.tableid = 284 AND
        b.bookkey = @i_templatebookkey AND
        b.printingkey = @i_templateprintingkey

    OPEN crBookComments 

    FETCH NEXT FROM crBookComments
    INTO @v_commenttype, @v_commentsubtype, @v_commentstring, @v_reltoeloind, @v_datadesc
      
    WHILE (@@FETCH_STATUS <> -1)
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM bookcomments
      WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey AND
        commenttypecode = @v_commenttype AND commenttypesubcode = @v_commentsubtype
                
      IF @v_count = 0
      BEGIN
        SET @v_action_count = @v_action_count + 1
        
        IF @v_commenttype = 1
          SET @v_datadesc = '(M) ' + @v_datadesc
        IF @v_commenttype = 3
          SET @v_datadesc = '(E) ' + @v_datadesc
        IF @v_commenttype = 4
          SET @v_datadesc = '(T) ' + @v_datadesc
        IF @v_commenttype = 5
          SET @v_datadesc = '(P) ' + @v_datadesc

        SET @v_bookcomments_xml = @v_bookcomments_xml + '
        <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>bookcomments</ActionTable><HistoryOrder>' + CONVERT(VARCHAR, @v_commenttype) + '</HistoryOrder><FieldDescDetail>' + @v_datadesc + '</FieldDescDetail>
          <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>
          <Key><KeyColumn>printingkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_printingkey) + '</KeyValue></Key>
          <Key><KeyColumn>commenttypecode</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_commenttype) + '</KeyValue></Key>
          <Key><KeyColumn>commenttypesubcode</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_commentsubtype) + '</KeyValue></Key>'
        
        IF @v_reltoeloind > 0
        BEGIN
          SET @v_bookcomments_xml = @v_bookcomments_xml + '
            <DBItem><DBItemColumn>releasetoeloquenceind</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_reltoeloind) + '</DBItemValue></DBItem>'
        END
               
        SET @v_commentstring = LTRIM(RTRIM(@v_commentstring))
        SET @v_commentstring = REPLACE(@v_commentstring, '<', '|||lt;')
        SET @v_commentstring = REPLACE(@v_commentstring, '>', '|||gt;')
        SET @v_commentstring = REPLACE(@v_commentstring, '&', '|||amp;')
        SET @v_commentstring = REPLACE(@v_commentstring, '''', '''''')
		SET @v_commentstring = REPLACE(@v_commentstring, char(0), '')
                    
        SET @v_bookcomments_xml = @v_bookcomments_xml + '
            <DBItem><DBItemColumn>commentstring</DBItemColumn><DBItemValue>' + @v_quote + @v_commentstring + @v_quote + '</DBItemValue></DBItem>'
            
        SET @v_bookcomments_xml = @v_bookcomments_xml + '</DBAction>'
        
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      FETCH NEXT FROM crBookComments
      INTO @v_commenttype, @v_commentsubtype, @v_commentstring, @v_reltoeloind, @v_datadesc
    END

    CLOSE crBookComments 
    DEALLOCATE crBookComments    
      
    IF @v_dbitem_count > 0 AND @v_bookcomments_xml is not null AND ltrim(rtrim(@v_bookcomments_xml)) <> ''
      SET @v_transaction_xml = @v_transaction_xml + @v_bookcomments_xml    
  
  END --Comments

  /* ASSOCIATEDTITLES */
  /* Exclude all Supply Chain titles (gentable 440, qsicode=1) */
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 15) = 'Y'  --Title Positioning
  BEGIN  
  SET @v_dbitem_count = 0
  SET @v_assotitles_xml = ''  
  SET @v_comment_cnt = 0
  
  DECLARE crAssoTitles CURSOR FOR
    SELECT g.gen1ind, a.associationtypecode, a.associationtypesubcode, a.associatetitlebookkey, a.sortorder, a.isbn, a.title, a.authorname, 
      a.bisacstatus, a.origpubhousecode, a.mediatypecode, a.mediatypesubcode, a.price, a.pubdate, a.salesunitgross, a.salesunitnet, 
      a.authorkey, a.productidtype, a.bookpos, a.lifetodatepointofsale, a.yeartodatepointofsale, a.previousyearpointofsale, a.reportind,
      a.pagecount, a.illustrations, a.quantity, a.volumenumber, a.commentkey1, a.commentkey2, a.editiondescription, LTRIM(RTRIM(a.itemnumber))
    FROM associatedtitles a, gentables g
    WHERE a.associationtypecode = g.datacode AND 
      g.tableid = 440 AND 
      a.bookkey = @i_templatebookkey AND
      g.qsicode <> 1 AND 
	  g.qsicode <> 16

  OPEN crAssoTitles 

  FETCH NEXT FROM crAssoTitles
  INTO @v_iselotab, @v_assotype, @v_assosubtype, @v_assobookkey, @v_sortorder, @v_isbn, @v_title, @v_fullauthorname, 
    @v_bisacstatus, @v_origpubhouse, @v_mediatype, @v_mediasubtype, @v_price, @v_pubdate, @v_salesunitgross, @v_salesunitnet, 
    @v_authorkey, @v_productidtype, @v_bookpos, @v_ltdpos, @v_ytdpos, @v_prevyrpos, @v_reportind,
    @v_pagecount, @v_illustrations, @v_qty1, @v_volume, @v_commentkey, @v_commentkey2, @v_editiondesc, @v_itemnumber

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
    SET @v_action_count = @v_action_count + 1

    SET @v_datadesc = LTRIM(RTRIM(dbo.get_subgentables_desc(440, @v_assotype, @v_assosubtype, 'long')))
    SET @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(@v_datadesc, '&', '&amp;'), '''', '''''')))
    SET @v_assotitles_xml = @v_assotitles_xml + '
    <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>associatedtitles</ActionTable><FieldDescDetail>' + @v_datadesc + '</FieldDescDetail>
      <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>
      <Key><KeyColumn>associationtypecode</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_assotype) + '</KeyValue></Key>
      <Key><KeyColumn>associationtypesubcode</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_assosubtype) + '</KeyValue></Key>
      <Key><KeyColumn>associatetitlebookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_assobookkey) + '</KeyValue></Key>'
        
    IF @v_assobookkey = 0
    BEGIN
      IF LEN(@v_title) > 0
      BEGIN
        SET @v_title = LTRIM(RTRIM(REPLACE(REPLACE(@v_title, '&', '&amp;'), '''', '''''')))
        SET @v_assotitles_xml = @v_assotitles_xml + '
          <DBItem><DBItemColumn>title</DBItemColumn><DBItemValue>' + @v_quote + @v_title + @v_quote + '</DBItemValue></DBItem>'
      END
          
      IF @v_mediatype > 0
        SET @v_assotitles_xml = @v_assotitles_xml + '
          <DBItem><DBItemColumn>mediatypecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_mediatype) + '</DBItemValue></DBItem>'
      
      IF @v_mediasubtype > 0
        SET @v_assotitles_xml = @v_assotitles_xml + '
          <DBItem><DBItemColumn>mediatypesubcode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_mediasubtype) + '</DBItemValue></DBItem>'
          
      IF @v_bisacstatus > 0
        SET @v_assotitles_xml = @v_assotitles_xml + '
          <DBItem><DBItemColumn>bisacstatus</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_bisacstatus) + '</DBItemValue></DBItem>'
          
      IF @v_origpubhouse > 0
        SET @v_assotitles_xml = @v_assotitles_xml + '
          <DBItem><DBItemColumn>origpubhousecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_origpubhouse) + '</DBItemValue></DBItem>'
          
      IF @v_pubdate IS NOT NULL
        SET @v_assotitles_xml = @v_assotitles_xml + '
          <DBItem><DBItemColumn>pubdate</DBItemColumn><DBItemValue>CONVERT(DATETIME,' + @v_quote + CONVERT(VARCHAR, @v_pubdate) + @v_quote + ', 101)</DBItemValue></DBItem>'
          
      IF @v_price IS NOT NULL
        SET @v_assotitles_xml = @v_assotitles_xml + '
          <DBItem><DBItemColumn>price</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_price) + '</DBItemValue></DBItem>'
      
      IF LEN(@v_editiondesc) > 0
      BEGIN
        SET @v_editiondesc = LTRIM(RTRIM(REPLACE(REPLACE(@v_editiondesc, '&', '&amp;'), '''', '''''')))
        SET @v_assotitles_xml = @v_assotitles_xml + '
          <DBItem><DBItemColumn>editiondescription</DBItemColumn><DBItemValue>' + @v_quote + @v_editiondesc + @v_quote + '</DBItemValue></DBItem>'
      END
                
      IF @v_pagecount > 0
        SET @v_assotitles_xml = @v_assotitles_xml + '
            <DBItem><DBItemColumn>pagecount</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_pagecount) + '</DBItemValue></DBItem>'

      IF LEN(@v_illustrations) > 0
      BEGIN
        SET @v_illustrations = LTRIM(RTRIM(REPLACE(REPLACE(@v_illustrations, '&', '&amp;'), '''', '''''')))
        SET @v_assotitles_xml = @v_assotitles_xml + '
          <DBItem><DBItemColumn>illustrations</DBItemColumn><DBItemValue>' + @v_quote + @v_illustrations + @v_quote + '</DBItemValue></DBItem>'
      END
    END
    
    IF LEN(@v_isbn) > 0
      SET @v_assotitles_xml = @v_assotitles_xml + '
        <DBItem><DBItemColumn>isbn</DBItemColumn><DBItemValue>' + @v_quote + @v_isbn + @v_quote + '</DBItemValue></DBItem>'
    
    IF @v_itemnumber IS NOT NULL
      SET @v_assotitles_xml = @v_assotitles_xml + '
        <DBItem><DBItemColumn>itemnumber</DBItemColumn><DBItemValue>' + @v_quote + @v_itemnumber + @v_quote + '</DBItemValue></DBItem>'          
    
    IF @v_authorkey > 0
      SET @v_assotitles_xml = @v_assotitles_xml + '
        <DBItem><DBItemColumn>authorkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_authorkey) + '</DBItemValue></DBItem>'
    ELSE
      SET @v_authorkey = 0

    IF LEN(@v_fullauthorname) > 0
    BEGIN
      SET @v_fullauthorname = LTRIM(RTRIM(REPLACE(REPLACE(@v_fullauthorname, '&', '&amp;'), '''', '''''')))
      SET @v_assotitles_xml = @v_assotitles_xml + '
        <DBItem><DBItemColumn>authorname</DBItemColumn><DBItemValue>' + @v_quote + @v_fullauthorname + @v_quote + '</DBItemValue></DBItem>'
    END
      
    IF @v_productidtype > 0
      SET @v_assotitles_xml = @v_assotitles_xml + '
        <DBItem><DBItemColumn>productidtype</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_productidtype) + '</DBItemValue></DBItem>'
    ELSE
      SET @v_productidtype = 0
  
    IF @v_bookpos > 0
      SET @v_assotitles_xml = @v_assotitles_xml + '
        <DBItem><DBItemColumn>bookpos</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_bookpos) + '</DBItemValue></DBItem>'

    IF @v_ltdpos > 0
      SET @v_assotitles_xml = @v_assotitles_xml + '
        <DBItem><DBItemColumn>lifetodatepointofsale</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_ltdpos) + '</DBItemValue></DBItem>'

    IF @v_ytdpos > 0
      SET @v_assotitles_xml = @v_assotitles_xml + '
        <DBItem><DBItemColumn>yeartodatepointofsale</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_ytdpos) + '</DBItemValue></DBItem>'

    IF @v_prevyrpos > 0
      SET @v_assotitles_xml = @v_assotitles_xml + '
        <DBItem><DBItemColumn>previousyearpointofsale</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_prevyrpos) + '</DBItemValue></DBItem>'
    
    IF @v_reportind > 0
      SET @v_assotitles_xml = @v_assotitles_xml + '
        <DBItem><DBItemColumn>reportind</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_reportind) + '</DBItemValue></DBItem>'

    IF @v_qty1 > 0
      SET @v_assotitles_xml = @v_assotitles_xml + '
        <DBItem><DBItemColumn>quantity</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_qty1) + '</DBItemValue></DBItem>'

    IF @v_volume > 0
      SET @v_assotitles_xml = @v_assotitles_xml + '
        <DBItem><DBItemColumn>volumenumber</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_volume) + '</DBItemValue></DBItem>'
        
    IF @v_salesunitgross > 0
      SET @v_assotitles_xml = @v_assotitles_xml + '
          <DBItem><DBItemColumn>salesunitgross</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_salesunitgross) + '</DBItemValue></DBItem>'
        
    IF @v_salesunitnet > 0
      SET @v_assotitles_xml = @v_assotitles_xml + '
          <DBItem><DBItemColumn>salesunitnet</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_salesunitnet) + '</DBItemValue></DBItem>'
          
    IF @v_sortorder IS NOT NULL
      SET @v_assotitles_xml = @v_assotitles_xml + '
          <DBItem><DBItemColumn>sortorder</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_sortorder) + '</DBItemValue></DBItem>'

    -- If neither Comment1 or Comment2 exist, we are done    
    IF IsNull(@v_commentkey,0) = 0 AND IsNull(@v_commentkey2,0) = 0
    BEGIN
      SET @v_assotitles_xml = @v_assotitles_xml + '</DBAction>'
    END
    ELSE  -- Either Comment1 or Comment2 have been entered - generate new comment keys and add qsicomments update
    BEGIN
      IF @v_commentkey > 0 --Comment1
        SELECT @v_count = COUNT(*)
        FROM qsicomments
        WHERE commentkey = @v_commentkey
      ELSE
        SET @v_count = 0
        
      IF @v_commentkey2 > 0 --Comment2
        SELECT @v_count2 = COUNT(*)
        FROM qsicomments
        WHERE commentkey = @v_commentkey2
      ELSE
        SET @v_count2 = 0
      
      -- If for some reason, neither comment exists on qsicomments, we are done
      IF @v_count = 0 AND @v_count2 = 0
        SET @v_assotitles_xml = @v_assotitles_xml + '</DBAction>'
      ELSE
      BEGIN
        -- Complete the DBAction for associatedtitles
        SET @v_comment_cnt = @v_comment_cnt + 1
        IF @v_count > 0
          SET @v_assotitles_xml = @v_assotitles_xml + '
            <Key><KeyColumn>commentkey1</KeyColumn><KeyValue>?comment1_key' + CONVERT(VARCHAR, @v_comment_cnt) + '</KeyValue></Key>'
        
        IF @v_count2 > 0
          SET @v_assotitles_xml = @v_assotitles_xml + '
            <Key><KeyColumn>commentkey2</KeyColumn><KeyValue>?comment2_key' + CONVERT(VARCHAR, @v_comment_cnt) + '</KeyValue></Key>'
        
        SET @v_assotitles_xml = @v_assotitles_xml + '</DBAction>'
      
        -- Add DBAction for Associated Titles Comment1 QSIComments record
        -- NOTE: This row will be deleted and reinserted in qtitle_copy_title_addtl_info becuase of HTML tag issues
        IF @v_count > 0
        BEGIN
          SELECT @v_qsicomments_typecode = commenttypecode, @v_qsicomments_subtypecode = commenttypesubcode
          FROM qsicomments
          WHERE commentkey = @v_commentkey
          
          SET @v_action_count = @v_action_count + 1          
          SET @v_assotitles_xml = @v_assotitles_xml + '
            <DBAction><ActionSequence>' + convert(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>qsicomments</ActionTable><HistoryOrder>' + CONVERT(VARCHAR, @v_sortorder) + '</HistoryOrder>
            <Key><KeyColumn>commentkey</KeyColumn><KeyValue>?comment1_key' + CONVERT(VARCHAR, @v_comment_cnt) + '</KeyValue></Key>
            <Key><KeyColumn>commenttypecode</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_qsicomments_typecode) + '</KeyValue></Key>
            <Key><KeyColumn>commenttypesubcode</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_qsicomments_subtypecode) + '</KeyValue></Key>'
            
          SET @v_assotitles_xml = @v_assotitles_xml + '</DBAction>'            
        END --@v_count > 0
        
        -- Add DBAction for Associated Titles Comment2 QSIComments record
        -- NOTE: This row will be deleted and reinserted in qtitle_copy_title_addtl_info becuase of HTML tag issues
        IF @v_count2 > 0
        BEGIN
          SELECT @v_qsicomments_typecode = commenttypecode, @v_qsicomments_subtypecode = commenttypesubcode
          FROM qsicomments
          WHERE commentkey = @v_commentkey2
          
          SET @v_action_count = @v_action_count + 1          
          SET @v_assotitles_xml = @v_assotitles_xml + '
            <DBAction><ActionSequence>' + convert(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>qsicomments</ActionTable><HistoryOrder>' + CONVERT(VARCHAR, @v_sortorder) + '</HistoryOrder>
            <Key><KeyColumn>commentkey</KeyColumn><KeyValue>?comment2_key' + CONVERT(VARCHAR, @v_comment_cnt) + '</KeyValue></Key>
            <Key><KeyColumn>commenttypecode</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_qsicomments_typecode) + '</KeyValue></Key>
            <Key><KeyColumn>commenttypesubcode</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_qsicomments_subtypecode) + '</KeyValue></Key>'
            
          SET @v_assotitles_xml = @v_assotitles_xml + '</DBAction>'            
        END --@v_count > 0
                
      END --@v_count>0 OR @v_count2>0
    END --Commentkey1>0 OR commentkey2>0
    
    SET @v_dbitem_count = @v_dbitem_count + 1
    
    IF @v_iselotab = 1 AND @v_assobookkey > 0
    BEGIN
      SET @v_action_count = @v_action_count + 1
    
      SET @v_assotitles_xml = @v_assotitles_xml + '
      <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>storedprocedure</ActionType>
      <ProcedureName>qtitle_reciprocal_relationship_xml</ProcedureName>
      <Parameters>&lt;Parameters&gt;' + 
        '&lt;BookKey&gt;' + CONVERT(VARCHAR, @i_bookkey) + '&lt;/BookKey&gt;' +
        '&lt;AssociateTitleBookKey&gt;' + CONVERT(VARCHAR, @v_assobookkey) + '&lt;/AssociateTitleBookKey&gt;' + 
        '&lt;AssociationTypeCode&gt;' + CONVERT(VARCHAR, @v_assotype) + '&lt;/AssociationTypeCode&gt;' +
        '&lt;AssociationTypeSubCode&gt;' + CONVERT(VARCHAR, @v_assosubtype) + '&lt;/AssociationTypeSubCode&gt;' +
        '&lt;ProductIdType&gt;' + CONVERT(VARCHAR, @v_productidtype) + '&lt;/ProductIdType&gt;' +
        '&lt;Action&gt;A&lt;/Action&gt;' +
        '&lt;AuthorKey&gt;' + CONVERT(VARCHAR, @v_authorkey) + '&lt;/AuthorKey&gt;' +
        '&lt;UserID&gt;' + @v_quote + @i_userid + @v_quote + '&lt;/UserID&gt;' +
        '&lt;/Parameters&gt;' +
      '</Parameters></DBAction>'
    END
    
    FETCH NEXT FROM crAssoTitles
    INTO @v_iselotab, @v_assotype, @v_assosubtype, @v_assobookkey, @v_sortorder, @v_isbn, @v_title, @v_fullauthorname, 
      @v_bisacstatus, @v_origpubhouse, @v_mediatype, @v_mediasubtype, @v_price, @v_pubdate, @v_salesunitgross, @v_salesunitnet, 
      @v_authorkey, @v_productidtype, @v_bookpos, @v_ltdpos, @v_ytdpos, @v_prevyrpos, @v_reportind,
      @v_pagecount, @v_illustrations, @v_qty1, @v_volume, @v_commentkey, @v_commentkey2, @v_editiondesc, @v_itemnumber
  END

  CLOSE crAssoTitles 
  DEALLOCATE crAssoTitles    
    
  IF @v_dbitem_count > 0
    SET @v_transaction_xml = @v_transaction_xml + @v_assotitles_xml  
END --ASSOCIATEDTITLES 

  /* BOOKCONTACT */
  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 5) = 'Y'  --Contacts
  BEGIN
  
    SET @v_dbitem_count = 0
    SET @v_bookcontact_xml = ''
    SET @v_keycount = 1  --used as row counter to form key request
    
    DECLARE crParticipants CURSOR FOR
      SELECT bookcontactkey, globalcontactkey, participantnote, keyind, sortorder
      FROM bookcontact
      WHERE bookkey = @i_templatebookkey AND printingkey = @i_templateprintingkey 
    
    OPEN crParticipants 

    FETCH NEXT FROM crParticipants
    INTO @v_bookcontactkey, @v_globalcontactkey, @v_participantnote, @v_keyind, @v_sortorder

    WHILE (@@FETCH_STATUS <> -1)
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM bookcontact
      WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey AND
        globalcontactkey = @v_globalcontactkey
        
      IF @v_count = 0
      BEGIN
        SET @v_action_count = @v_action_count + 1

        SET @v_bookcontact_xml = @v_bookcontact_xml + '
        <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>bookcontact</ActionTable>
          <Key><KeyColumn>bookcontactkey</KeyColumn><KeyValue>?bookcontactkey' + CONVERT(VARCHAR, @v_keycount) + '</KeyValue></Key>
          <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>
          <Key><KeyColumn>printingkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_printingkey) + '</KeyValue></Key>'    

        SELECT @v_count = COUNT(*)
        FROM globalcontact
        WHERE globalcontactkey = @v_globalcontactkey
        
        IF @v_count > 0
          BEGIN
            SELECT @v_datadesc = LTRIM(RTRIM(REPLACE(REPLACE(displayname, '&', '&amp;'), '''', '''''')))
            FROM globalcontact
            WHERE globalcontactkey = @v_globalcontactkey
          END
        ELSE
          SET @v_datadesc = CONVERT(VARCHAR, @v_globalcontactkey)
        
        SET @v_bookcontact_xml = @v_bookcontact_xml + '
            <DBItem><DBItemColumn>globalcontactkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_globalcontactkey) + '</DBItemValue><DBItemDesc>' + @v_quote + @v_datadesc + @v_quote + '</DBItemDesc></DBItem>'
          
        IF LEN(@v_participantnote) > 0
        BEGIN
          SET @v_participantnote = LTRIM(RTRIM(REPLACE(REPLACE(@v_participantnote, '&', '&amp;'), '''', '''''')))
          SET @v_bookcontact_xml = @v_bookcontact_xml + '
            <DBItem><DBItemColumn>participantnote</DBItemColumn><DBItemValue>' + @v_quote + @v_participantnote + @v_quote + '</DBItemValue></DBItem>'
        END

        IF @v_keyind > 0
          SET @v_bookcontact_xml = @v_bookcontact_xml + '
            <DBItem><DBItemColumn>keyind</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_keyind) + '</DBItemValue></DBItem>'
              
        IF @v_sortorder IS NOT NULL
          SET @v_bookcontact_xml = @v_bookcontact_xml + '
            <DBItem><DBItemColumn>sortorder</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_sortorder) + '</DBItemValue></DBItem>'
        
        SET @v_bookcontact_xml = @v_bookcontact_xml + '</DBAction>'


        /* BOOKCONTACTROLE */
               
        DECLARE crParticipantRole CURSOR FOR
          SELECT rolecode, activeind, workrate, ratetypecode, departmentcode
          FROM bookcontactrole
          WHERE bookcontactkey = @v_bookcontactkey 
        
        OPEN crParticipantRole 

        FETCH NEXT FROM crParticipantRole
        INTO @v_role, @v_activeind, @v_workrate, @v_ratetype, @v_department

        WHILE (@@FETCH_STATUS <> -1)
        BEGIN
          SET @v_action_count = @v_action_count + 1

          SET @v_bookcontact_xml = @v_bookcontact_xml + '
          <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>bookcontactrole</ActionTable>
            <Key><KeyColumn>bookcontactkey</KeyColumn><KeyValue>?bookcontactkey' + CONVERT(VARCHAR, @v_keycount) + '</KeyValue></Key>
            <Key><KeyColumn>rolecode</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_role) + '</KeyValue></Key>'

          IF @v_activeind > 0
            SET @v_bookcontact_xml = @v_bookcontact_xml + '
              <DBItem><DBItemColumn>activeind</DBItemColumn><DBItemValue>1</DBItemValue></DBItem>'
          ELSE
            SET @v_bookcontact_xml = @v_bookcontact_xml + '
              <DBItem><DBItemColumn>activeind</DBItemColumn><DBItemValue>0</DBItemValue></DBItem>'
          
          IF @v_workrate IS NOT NULL    
            SET @v_bookcontact_xml = @v_bookcontact_xml + '
              <DBItem><DBItemColumn>workrate</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_workrate) + '</DBItemValue></DBItem>'
     
          IF @v_ratetype > 0
            SET @v_bookcontact_xml = @v_bookcontact_xml + '
              <DBItem><DBItemColumn>ratetypecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_ratetype) + '</DBItemValue></DBItem>'

          IF @v_department > 0
            SET @v_bookcontact_xml = @v_bookcontact_xml + '
              <DBItem><DBItemColumn>departmentcode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_department) + '</DBItemValue></DBItem>'

          SET @v_bookcontact_xml = @v_bookcontact_xml + '</DBAction>'
        
          FETCH NEXT FROM crParticipantRole
          INTO @v_role, @v_activeind, @v_workrate, @v_ratetype, @v_department
        END

        CLOSE crParticipantRole 
        DEALLOCATE crParticipantRole
           
        /* end BOOKCONTACTROLE */
        
        SET @v_action_count = @v_action_count + 1             
        SET @v_keycount = @v_keycount + 1
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      FETCH NEXT FROM crParticipants
      INTO @v_bookcontactkey, @v_globalcontactkey, @v_participantnote, @v_keyind, @v_sortorder
    END

    CLOSE crParticipants 
    DEALLOCATE crParticipants    
      
    IF @v_dbitem_count > 0
      SET @v_transaction_xml = @v_transaction_xml + @v_bookcontact_xml

    /* end BOOKCONTACT */

  END --Contacts

  /* CITATIONS */
  /* NOTE: Comments are deleted and reinserted in qtitle_copy_title_addtl_info stored procedure called at the end here because of HTML tag issues. */  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 18) = 'Y'  --Citations
  BEGIN
    SET @v_dbitem_count = 0
    SET @v_sortorder = 1
    SET @v_citations_xml = ''  
    
    DECLARE crCitations CURSOR FOR
        SELECT  C.citationsource, C.citationauthor, C.citationdate, C.releasetoeloquenceind, C.sortorder, 
                C.citationdesc, C.citationtypecode, C.proofedind, C.webind, C.qsiobjectkey, C.history_order, 
                C.citationexternaltypecode,
                Q.commenttypecode, Q.commenttypesubcode, Q.parenttable, Q.invalidhtmlind, 
                Q.releasetoeloquenceind, Q.commentkey                   
        FROM Citation C
        JOIN ( SELECT G.datacode, S.datasubcode from gentables G
               JOIN subgentables S on G.tableid = S.tableid AND G.datacode = S.Datacode
               WHERE G.tableid = 534 and LTRIM(RTRIM(G.datadesc)) = 'Citation' ) as Gen on 1 = 1
        LEFT OUTER JOIN qsicomments Q on C.qsiobjectkey = Q.commentkey 
         AND q.commenttypecode = Gen.datacode 
         AND q.commenttypesubcode = Gen.datasubcode
       WHERE bookkey = @i_templatebookkey

    OPEN crCitations 

    FETCH NEXT FROM crCitations
    INTO @v_citation_source, @v_citation_author, @v_citation_date, @v_citation_reltoeloq, @v_citation_sortorder,
         @v_citation_desc, @v_citation_typecode, @v_citation_proofedind, @v_citation_webind, @v_citation_qsiobjectkey, @v_citation_historyorder,
         @v_citation_externaltypecode,
         @v_qsicomments_typecode, @v_qsicomments_subtypecode, @v_qsicomments_parenttable, @v_qsicomments_invalidhtmlind, 
         @v_qsicomments_reltoeloq, @v_commentkey
      
    WHILE (@@FETCH_STATUS <> -1)
    BEGIN
        SET @v_citation_source = LTRIM(RTRIM(@v_citation_source))
        SET @v_citation_source = REPLACE(@v_citation_source, '<', '&lt;')
        SET @v_citation_source = REPLACE(@v_citation_source, '>', '&gt;')
        SET @v_citation_source = REPLACE(@v_citation_source, '&', '&amp;')
        SET @v_citation_source = REPLACE(@v_citation_source, '''', '''''')

        SET @v_citation_author = LTRIM(RTRIM(@v_citation_author))
        SET @v_citation_author = REPLACE(@v_citation_author, '<', '&lt;')
        SET @v_citation_author = REPLACE(@v_citation_author, '>', '&gt;')
        SET @v_citation_author = REPLACE(@v_citation_author, '&', '&amp;')
        SET @v_citation_author = REPLACE(@v_citation_author, '''', '''''')

        SET @v_citation_desc = LTRIM(RTRIM(@v_citation_desc))
        SET @v_citation_desc = REPLACE(@v_citation_desc, '<', '&lt;')
        SET @v_citation_desc = REPLACE(@v_citation_desc, '>', '&gt;')
        SET @v_citation_desc = REPLACE(@v_citation_desc, '&', '&amp;')
        SET @v_citation_desc = REPLACE(@v_citation_desc, '''', '''''')
        SET @v_action_count = @v_action_count + 1
        
        SET @v_citations_xml = @v_citations_xml + '
        <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>citation</ActionTable><HistoryOrder>' + CONVERT(VARCHAR, @v_sortorder) + '</HistoryOrder> 
          <Key><KeyColumn>citationkey</KeyColumn><KeyValue>?citationkey' + convert(VARCHAR, @v_sortorder) + '</KeyValue></Key>' + '
          <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>'

        IF ( isnull(@v_citation_source,'') != '' )
        BEGIN
          SET @v_citations_xml = @v_citations_xml + '
            <DBItem><DBItemColumn>citationsource</DBItemColumn><DBItemValue>' + @v_quote + @v_citation_source + @v_quote + '</DBItemValue></DBItem>'
        END

        IF ( isnull(@v_citation_author,'') != '' )
        BEGIN
          SET @v_citations_xml = @v_citations_xml + '
            <DBItem><DBItemColumn>citationauthor</DBItemColumn><DBItemValue>' + @v_quote + @v_citation_author + @v_quote + '</DBItemValue></DBItem>'
        END

        IF ( isNull(@v_citation_desc,'') != '' )
        BEGIN
          SET @v_citations_xml = @v_citations_xml + '
            <DBItem><DBItemColumn>citationdesc</DBItemColumn><DBItemValue>' + @v_quote + @v_citation_desc + @v_quote + '</DBItemValue></DBItem>'
        END

        IF ( isNull(@v_citation_date,'') != '' )
        BEGIN
          SET @v_citations_xml = @v_citations_xml + '
            <DBItem><DBItemColumn>citationdate</DBItemColumn><DBItemValue>' + @v_quote + convert(VARCHAR, @v_citation_date) + @v_quote + '</DBItemValue></DBItem>'
        END

        IF ( isNull(@v_citation_typecode,0) != 0 )
        BEGIN
          SET @v_citations_xml = @v_citations_xml + '
            <DBItem><DBItemColumn>citationtypecode</DBItemColumn><DBItemValue>' + convert(VARCHAR, @v_citation_typecode) + '</DBItemValue></DBItem>'
        END

        IF ( isNull(@v_citation_externaltypecode,0) != 0 )
        BEGIN
          SET @v_citations_xml = @v_citations_xml + '
            <DBItem><DBItemColumn>citationexternaltypecode</DBItemColumn><DBItemValue>' + convert(VARCHAR, @v_citation_externaltypecode) + '</DBItemValue></DBItem>'
        END
        
        IF ( isNull(@v_citation_sortorder,0) != 0 )
        BEGIN
          SET @v_citations_xml = @v_citations_xml + '
            <DBItem><DBItemColumn>sortorder</DBItemColumn><DBItemValue>' + convert(VARCHAR, @v_citation_sortorder) + '</DBItemValue></DBItem>'
        END
        
        IF ( isNull(@v_citation_historyorder,0) != 0 )
        BEGIN
          SET @v_citations_xml = @v_citations_xml + '
            <DBItem><DBItemColumn>history_order</DBItemColumn><DBItemValue>' + convert(VARCHAR, @v_citation_historyorder) + '</DBItemValue></DBItem>'
        END        
        
        IF ( isNull(@v_citation_proofedind,0) > 0 )
        BEGIN
          SET @v_citations_xml = @v_citations_xml + '
            <DBItem><DBItemColumn>proofedind</DBItemColumn><DBItemValue>' + convert(VARCHAR, @v_citation_proofedind) + '</DBItemValue></DBItem>'
        END

        IF ( isNull(@v_citation_webind,0) > 0 )
        BEGIN
          SET @v_citations_xml = @v_citations_xml + 
            '<DBItem><DBItemColumn>webind</DBItemColumn><DBItemValue>' + convert(VARCHAR, @v_citation_webind) + '</DBItemValue></DBItem>'
        END

        --IF ( isNull(@v_citation_reltoeloq,0) > 0 ) -- Case 25165 task 004, The release to elo ind should not copy over.
        --BEGIN
        --  SET @v_citations_xml = @v_citations_xml + '
        --    <DBItem><DBItemColumn>releasetoeloquenceind</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_citation_reltoeloq) + '</DBItemValue></DBItem>'
        --END

        IF ( isnull(@v_citation_qsiobjectkey,0) > 0 )  -- this citation had a comment entered add the qsicomments record
        BEGIN
          SET @v_citations_xml = @v_citations_xml + 
             '<Key><KeyColumn>qsiobjectkey</KeyColumn><KeyValue>?citationkey' + convert(VARCHAR, @v_sortorder) + '</KeyValue></Key>'
        END
        
        SET @v_citations_xml = @v_citations_xml + '</DBAction>'
        
        -- Now generate the QSIComments record        
        IF ( isnull(@v_citation_qsiobjectkey,0) > 0 AND isnull(@v_commentkey,0) > 0)  -- this citation had a comment entered add the qsicomments record
        BEGIN         
          SET @v_action_count = @v_action_count + 1          
          SET @v_citations_xml = @v_citations_xml + 
            '<DBAction><ActionSequence>' + convert(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>qsicomments</ActionTable><HistoryOrder>' + CONVERT(VARCHAR, @v_sortorder) + '</HistoryOrder>' +
            '<Key><KeyColumn>commentkey</KeyColumn><KeyValue>?citationkey' + convert(VARCHAR, @v_sortorder) + '</KeyValue></Key>' 

          IF ( isNull(@v_qsicomments_typecode,0) > 0 )
          BEGIN
            SET @v_citations_xml = @v_citations_xml + 
              '<Key><KeyColumn>commenttypecode</KeyColumn><KeyValue>' + convert(VARCHAR, @v_qsicomments_typecode) + '</KeyValue></Key>'
          END
          
          IF ( isNull(@v_qsicomments_subtypecode,0) > 0 )
          BEGIN
            SET @v_citations_xml = @v_citations_xml + 
              '<Key><KeyColumn>commenttypesubcode</KeyColumn><KeyValue>' + convert(VARCHAR, @v_qsicomments_subtypecode) + '</KeyValue></Key>'
          END 

          IF ( isNull(@v_qsicomments_parenttable,'') != '' )
          BEGIN
            SET @v_citations_xml = @v_citations_xml + '
              <DBItem><DBItemColumn>parenttable</DBItemColumn><DBItemValue>' + @v_quote + @v_qsicomments_parenttable + @v_quote + '</DBItemValue></DBItem>'
          END
          
          IF ( isNull(@v_qsicomments_reltoeloq,0) > 0 )
          BEGIN
            SET @v_citations_xml = @v_citations_xml + '
              <DBItem><DBItemColumn>releasetoeloquenceind</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_qsicomments_reltoeloq) + '</DBItemValue></DBItem>'
          END

          IF ( isNull(@v_qsicomments_invalidhtmlind,0) > 0 )
          BEGIN
            SET @v_citations_xml = @v_citations_xml + '
              <DBItem><DBItemColumn>invalidhtmlind</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_qsicomments_invalidhtmlind) + '</DBItemValue></DBItem>'
          END
          
          SET @v_citations_xml = @v_citations_xml + '</DBAction>'        
          
        END
        
        SET @v_dbitem_count = @v_dbitem_count + 1
        SET @v_sortorder = @v_sortorder + 1
        
        
      FETCH NEXT FROM crCitations
      INTO @v_citation_source, @v_citation_author, @v_citation_date, @v_citation_reltoeloq, @v_citation_sortorder,
           @v_citation_desc, @v_citation_typecode, @v_citation_proofedind, @v_citation_webind, @v_citation_qsiobjectkey, @v_citation_historyorder,
           @v_citation_externaltypecode,
           @v_qsicomments_typecode, @v_qsicomments_subtypecode, @v_qsicomments_parenttable, @v_qsicomments_invalidhtmlind, 
           @v_qsicomments_reltoeloq, @v_commentkey
    END

    CLOSE crCitations 
    DEALLOCATE crCitations    
      
    IF @v_dbitem_count > 0 AND @v_citations_xml is not null AND ltrim(rtrim(@v_citations_xml)) <> ''
      SET @v_transaction_xml = @v_transaction_xml + @v_citations_xml    
      
  END --Citations

  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 19) = 'Y'  --Discovery Questions
  BEGIN
    SET @v_dbitem_count = 0
    SET @v_sortorder = 0
    SET @v_discoveryquestions_xml = '' 
    SET @v_comment_cnt = 0

    DECLARE crDiscoveryQuestions CURSOR FOR
		SELECT D.questioncommentkey, D.answercommentkey, D.sortorder
		FROM discoveryquestions D
		WHERE bookkey = @i_templatebookkey

    OPEN crDiscoveryQuestions 

    FETCH NEXT FROM crDiscoveryQuestions
    INTO @v_questioncommentkey, @v_answercommentkey, @v_sortorder

    WHILE (@@FETCH_STATUS <> -1)
    BEGIN
          SELECT @v_qsicomments_typecode = commenttypecode, @v_qsicomments_subtypecode = commenttypesubcode
          FROM qsicomments
          WHERE commentkey = @v_questioncommentkey
          
          SET @v_action_count = @v_action_count + 1    
          SET @v_comment_cnt = @v_comment_cnt + 1                   
          SET @v_discoveryquestions_xml = @v_discoveryquestions_xml + '
            <DBAction><ActionSequence>' + convert(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>qsicomments</ActionTable>
			<HistoryOrder>' + CONVERT(VARCHAR, @v_sortorder) + '</HistoryOrder>
            <Key><KeyColumn>commentkey</KeyColumn><KeyValue>?newQuestionCommentKey' + CONVERT(VARCHAR, @v_comment_cnt) + '</KeyValue></Key>
            <Key><KeyColumn>commenttypecode</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_qsicomments_typecode) + '</KeyValue></Key>
            <Key><KeyColumn>commenttypesubcode</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_qsicomments_subtypecode) + '</KeyValue></Key>'

          SET @v_discoveryquestions_xml = @v_discoveryquestions_xml + '</DBAction>' 

          SELECT @v_qsicomments_typecode = commenttypecode, @v_qsicomments_subtypecode = commenttypesubcode
          FROM qsicomments
          WHERE commentkey = @v_answercommentkey

          SET @v_action_count = @v_action_count + 1          
          SET @v_discoveryquestions_xml = @v_discoveryquestions_xml + '
            <DBAction><ActionSequence>' + convert(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>qsicomments</ActionTable>
			<HistoryOrder>' + CONVERT(VARCHAR, @v_sortorder) + '</HistoryOrder>
            <Key><KeyColumn>commentkey</KeyColumn><KeyValue>?newAnswerCommentKey' + CONVERT(VARCHAR, @v_comment_cnt) + '</KeyValue></Key>
            <Key><KeyColumn>commenttypecode</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_qsicomments_typecode) + '</KeyValue></Key>
            <Key><KeyColumn>commenttypesubcode</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @v_qsicomments_subtypecode) + '</KeyValue></Key>'
            
          SET @v_discoveryquestions_xml = @v_discoveryquestions_xml + '</DBAction>'    
		  SET @v_action_count = @v_action_count + 1

          SET @v_discoveryquestions_xml = @v_discoveryquestions_xml + '
            <DBAction><ActionSequence>' + convert(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>discoveryquestions</ActionTable>
			<HistoryOrder>' + CONVERT(VARCHAR, @v_sortorder) + '</HistoryOrder>
            <Key><KeyColumn>discoverykey</KeyColumn><KeyValue>?DiscoveryKey' + CONVERT(VARCHAR, @v_comment_cnt) + '</KeyValue></Key>
            <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>
            <Key><KeyColumn>questioncommentKey</KeyColumn><KeyValue>?newQuestionCommentKey' + CONVERT(VARCHAR, @v_comment_cnt) + '</KeyValue></Key>
            <Key><KeyColumn>answercommentkey</KeyColumn><KeyValue>?newAnswerCommentKey' + CONVERT(VARCHAR, @v_comment_cnt) + '</KeyValue></Key>
            <DBItem><DBItemColumn>sortorder</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_sortorder) + '</DBItemValue></DBItem>'
          SET @v_discoveryquestions_xml = @v_discoveryquestions_xml + '</DBAction>' 
  
      SET @v_dbitem_count = @v_dbitem_count + 1
      FETCH NEXT FROM crDiscoveryQuestions
      INTO @v_questioncommentkey, @v_answercommentkey, @v_sortorder
    END

    CLOSE crDiscoveryQuestions 
    DEALLOCATE crDiscoveryQuestions    
      
    IF @v_dbitem_count > 0 AND @v_discoveryquestions_xml is not null AND ltrim(rtrim(@v_discoveryquestions_xml)) <> ''
      SET @v_transaction_xml = @v_transaction_xml + @v_discoveryquestions_xml    
      
  END --Discovery Questions
  
  
  /* TERRITORYRIGHTS/TERRITORYRIGHTCOUNTRIES */  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 20) = 'Y'  --Territorial Rights
  BEGIN
  
    SET @v_dbitem_count = 0
    SET @v_territorialrights_xml = ''
    SET @v_keycount = 1
    
    DECLARE cur_territoryrights CURSOR FOR
      SELECT territoryrightskey, itemtype, taqprojectkey, rightskey, currentterritorycode, contractterritorycode,
        description, autoterritorydescind, exclusivecode, singlecountrycode, singlecountrygroupcode, note
      FROM territoryrights
      WHERE bookkey = @i_templatebookkey
    
    OPEN cur_territoryrights 

    FETCH NEXT FROM cur_territoryrights
    INTO @v_territoryrightskey, @v_itemtype, @v_projectkey, @v_rightskey, @v_curterritorycode, @v_contractterritorycode,
      @v_description, @v_autodescind, @v_exclusivecode, @v_countrycode, @v_countrygroupcode, @v_note

    WHILE (@@FETCH_STATUS <> -1)
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM territoryrights
      WHERE bookkey = @i_bookkey AND currentterritorycode = @v_curterritorycode
        
      IF @v_count = 0
      BEGIN
        SET @v_action_count = @v_action_count + 1

        SET @v_territorialrights_xml = @v_territorialrights_xml + '
        <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>territoryrights</ActionTable>
          <Key><KeyColumn>territoryrightskey</KeyColumn><KeyValue>?territoryrightskey' + CONVERT(VARCHAR, @v_keycount) + '</KeyValue></Key>
          <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>'
  
        IF @v_itemtype IS NOT NULL
          SET @v_territorialrights_xml = @v_territorialrights_xml + '
            <DBItem><DBItemColumn>itemtype</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_itemtype) + '</DBItemValue></DBItem>'
            
        IF @v_projectkey IS NOT NULL
          SET @v_territorialrights_xml = @v_territorialrights_xml + '
            <DBItem><DBItemColumn>taqprojectkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_projectkey) + '</DBItemValue></DBItem>'

        IF @v_rightskey IS NOT NULL
          SET @v_territorialrights_xml = @v_territorialrights_xml + '
            <DBItem><DBItemColumn>rightskey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_rightskey) + '</DBItemValue></DBItem>'
            
        IF @v_curterritorycode IS NOT NULL
          SET @v_territorialrights_xml = @v_territorialrights_xml + '
            <DBItem><DBItemColumn>currentterritorycode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_curterritorycode) + '</DBItemValue></DBItem>'

        IF @v_contractterritorycode IS NOT NULL
          SET @v_territorialrights_xml = @v_territorialrights_xml + '
            <DBItem><DBItemColumn>contractterritorycode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_contractterritorycode) + '</DBItemValue></DBItem>'

        IF LEN(@v_description) > 0
        BEGIN
          SET @v_description = LTRIM(RTRIM(REPLACE(REPLACE(@v_description, '&', '&amp;'), '''', '''''')))
          SET @v_territorialrights_xml = @v_territorialrights_xml + '
            <DBItem><DBItemColumn>description</DBItemColumn><DBItemValue>' + @v_quote + @v_description + @v_quote + '</DBItemValue></DBItem>'
        END
        
        IF @v_autodescind > 0
          SET @v_territorialrights_xml = @v_territorialrights_xml + '
            <DBItem><DBItemColumn>autoterritorydescind</DBItemColumn><DBItemValue>1</DBItemValue></DBItem>'
        ELSE
          SET @v_territorialrights_xml = @v_territorialrights_xml + '
            <DBItem><DBItemColumn>autoterritorydescind</DBItemColumn><DBItemValue>0</DBItemValue></DBItem>'                        
        
        IF @v_exclusivecode IS NOT NULL
          SET @v_territorialrights_xml = @v_territorialrights_xml + '
            <DBItem><DBItemColumn>exclusivecode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_exclusivecode) + '</DBItemValue></DBItem>'
        
        IF @v_countrycode IS NOT NULL
          SET @v_territorialrights_xml = @v_territorialrights_xml + '
            <DBItem><DBItemColumn>singlecountrycode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_countrycode) + '</DBItemValue></DBItem>'
        
        IF @v_countrygroupcode IS NOT NULL
          SET @v_territorialrights_xml = @v_territorialrights_xml + '
            <DBItem><DBItemColumn>singlecountrygroupcode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_countrygroupcode) + '</DBItemValue></DBItem>'
        
        IF LEN(@v_note) > 0
        BEGIN
          SET @v_note = LTRIM(RTRIM(REPLACE(REPLACE(@v_note, '&', '&amp;'), '''', '''''')))
          SET @v_territorialrights_xml = @v_territorialrights_xml + '
            <DBItem><DBItemColumn>note</DBItemColumn><DBItemValue>' + @v_quote + @v_note + @v_quote + '</DBItemValue></DBItem>'
        END
                
        SET @v_territorialrights_xml = @v_territorialrights_xml + '</DBAction>'

        /* TERRITORYRIGHTCOUNTRIES */
               
        DECLARE cur_territoryrightcountries CURSOR FOR
          SELECT countrycode, forsaleind, contractexclusiveind
          FROM territoryrightcountries
          WHERE territoryrightskey = @v_territoryrightskey
        
        OPEN cur_territoryrightcountries 

        FETCH NEXT FROM cur_territoryrightcountries
        INTO @v_countrycode, @v_forsaleind, @v_contractexclusiveind

        WHILE (@@FETCH_STATUS <> -1)
        BEGIN
          SET @v_action_count = @v_action_count + 1

          SET @v_territorialrights_xml = @v_territorialrights_xml + '
          <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>territoryrightcountries</ActionTable>
            <Key><KeyColumn>territoryrightskey</KeyColumn><KeyValue>?territoryrightskey' + CONVERT(VARCHAR, @v_keycount) + '</KeyValue></Key>
            <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>'

          IF @v_itemtype IS NOT NULL
            SET @v_territorialrights_xml = @v_territorialrights_xml + '
              <DBItem><DBItemColumn>itemtype</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_itemtype) + '</DBItemValue></DBItem>'
              
          IF @v_projectkey IS NOT NULL
            SET @v_territorialrights_xml = @v_territorialrights_xml + '
              <DBItem><DBItemColumn>taqprojectkey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_projectkey) + '</DBItemValue></DBItem>'

          IF @v_rightskey IS NOT NULL
            SET @v_territorialrights_xml = @v_territorialrights_xml + '
              <DBItem><DBItemColumn>rightskey</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_rightskey) + '</DBItemValue></DBItem>'
              
          IF @v_countrycode IS NOT NULL
            SET @v_territorialrights_xml = @v_territorialrights_xml + '
              <DBItem><DBItemColumn>countrycode</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_countrycode) + '</DBItemValue></DBItem>'
              
          IF @v_forsaleind IS NOT NULL
            SET @v_territorialrights_xml = @v_territorialrights_xml + '
              <DBItem><DBItemColumn>forsaleind</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_forsaleind) + '</DBItemValue></DBItem>'
 
           IF @v_contractexclusiveind IS NOT NULL
            SET @v_territorialrights_xml = @v_territorialrights_xml + '
              <DBItem><DBItemColumn>contractexclusiveind</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_contractexclusiveind) + '</DBItemValue></DBItem>
              <DBItem><DBItemColumn>currentexclusiveind</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_contractexclusiveind) + '</DBItemValue></DBItem>'
             
          SET @v_territorialrights_xml = @v_territorialrights_xml + '</DBAction>'
        
          FETCH NEXT FROM cur_territoryrightcountries
          INTO @v_countrycode, @v_forsaleind, @v_contractexclusiveind
        END

        CLOSE cur_territoryrightcountries 
        DEALLOCATE cur_territoryrightcountries
        
        SET @v_keycount = @v_keycount + 1
        SET @v_dbitem_count = @v_dbitem_count + 1
      END
      
      FETCH NEXT FROM cur_territoryrights
      INTO @v_territoryrightskey, @v_itemtype, @v_projectkey, @v_rightskey, @v_curterritorycode, @v_contractterritorycode,
        @v_description, @v_autodescind, @v_exclusivecode, @v_countrycode, @v_countrygroupcode, @v_note
    END

    CLOSE cur_territoryrights 
    DEALLOCATE cur_territoryrights    
      
    IF @v_dbitem_count > 0
      SET @v_transaction_xml = @v_transaction_xml + @v_territorialrights_xml

  END --Territorial Rights

  /* BOOKKEYWORDS */  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 22) = 'Y'  --Bookkeywords
  BEGIN
	SET @v_dbitem_count = 0
	SET @v_bookkeywords_xml = ''

	DECLARE cur_bookkeywords CURSOR FOR
	SELECT LTRIM(RTRIM(REPLACE(REPLACE(keyword, '&', '&amp;'), '''', ''''''))), sortorder
	FROM bookkeywords
	WHERE bookkey = @i_templatebookkey
	ORDER BY sortorder ASC, keyword
    
    OPEN cur_bookkeywords 

    FETCH NEXT FROM cur_bookkeywords
    INTO @v_keyword, @v_keywordsortorder

    WHILE (@@FETCH_STATUS <> -1)
    BEGIN
	  SELECT @v_count = COUNT(*)
      FROM bookkeywords
      WHERE bookkey = @i_bookkey AND
        keyword = @v_keyword
        
      IF @v_count = 0
      BEGIN
        SET @v_action_count = @v_action_count + 1

        SET @v_fielddesc = @v_keyword
          
        SET @v_bookkeywords_xml = @v_bookkeywords_xml + '
        <DBAction><ActionSequence>' + CONVERT(VARCHAR, @v_action_count) + '</ActionSequence><ActionType>insert</ActionType><ActionTable>bookkeywords</ActionTable><HistoryOrder>' + CONVERT(VARCHAR, @v_keywordsortorder) + '</HistoryOrder><FieldDescDetail>' + @v_fielddesc + '</FieldDescDetail>
          <Key><KeyColumn>bookkey</KeyColumn><KeyValue>' + CONVERT(VARCHAR, @i_bookkey) + '</KeyValue></Key>'
              
        SET @v_bookkeywords_xml = @v_bookkeywords_xml + '
            <DBItem><DBItemColumn>keyword</DBItemColumn><DBItemValue>' + @v_quote + @v_keyword + @v_quote + '</DBItemValue></DBItem>'
        SET @v_bookkeywords_xml = @v_bookkeywords_xml + '
            <DBItem><DBItemColumn>sortorder</DBItemColumn><DBItemValue>' + CONVERT(VARCHAR, @v_keywordsortorder) + '</DBItemValue></DBItem>'

        SET @v_bookkeywords_xml = @v_bookkeywords_xml + '</DBAction>' 
        
        SET @v_dbitem_count = @v_dbitem_count + 1
      END

	  FETCH NEXT FROM cur_bookkeywords
	  INTO @v_keyword, @v_keywordsortorder
	END

	CLOSE cur_bookkeywords
	DEALLOCATE cur_bookkeywords

	IF @v_dbitem_count > 0
	BEGIN
      SET @v_transaction_xml = @v_transaction_xml + @v_bookkeywords_xml
	END

  END --Bookkeywords
            
  PRINT 'Final XML:'
  PRINT '<Transaction><UserID>' + @i_userid + '</UserID><ManageTrans>1</ManageTrans>'
  PRINT COALESCE(@v_book_xml,'@v_book_xml NULL')
  PRINT COALESCE(@v_bookdetail_xml,'@v_bookdetail_xml NULL')
  PRINT COALESCE(@v_printing_xml,'@v_printing_xml NULL')
  PRINT COALESCE(@v_audiocassettespecs_xml,'@v_audiocassettespecs_xml NULL') 
  PRINT COALESCE(@v_jacketspecs_xml,'@v_jacketspecs_xml NULL')   
  PRINT COALESCE(@v_textspecs_xml,'@v_textspecs_xml NULL')     
  PRINT COALESCE(@v_booksets_xml,'@v_booksets_xml NULL')
  PRINT COALESCE(@v_booksimon_xml,'@v_booksimon_xml NULL')
  PRINT COALESCE(@v_bookcustom_xml,'@v_bookcustom_xml NULL')
  PRINT COALESCE(@v_bookver_xml,'@v_bookver_xml NULL')
  PRINT COALESCE(@v_bookcategory_xml,'@v_bookcategory_xml NULL')
  PRINT COALESCE(@v_bookbisaccategory_xml,'@v_bookbisaccategory_xml NULL')
  PRINT COALESCE(@v_booksubjectcategory_xml,'@v_booksubjectcategory_xml NULL')
  PRINT COALESCE(@v_bookproductdetail_xml,'@@v_bookproductdetail_xml NULL')
  PRINT COALESCE(@v_bookprice_xml,'@v_bookprice_xml NULL')
  PRINT COALESCE(@v_bookauthor_xml,'@v_bookauthor_xml NULL')
  PRINT COALESCE(@v_bookmisc_xml,'@v_bookmisc_xml NULL')
  IF @v_websched_option = 1
    PRINT COALESCE(@v_taqprojecttask_xml,'@v_taqprojecttask_xml NULL')
  ELSE
    PRINT COALESCE(@v_bookdates_xml,'@v_bookdates_xml NULL')
  PRINT COALESCE(@v_taqprojecttitle_xml,'@v_taqprojecttitle_xml NULL')
  PRINT COALESCE(@v_bindingspecs_xml,'@v_bindingspecs_xml NULL')
  PRINT COALESCE(@v_bookaudience_xml,'@v_bookaudience_xml NULL')
  PRINT COALESCE(@v_filelocation_xml,'@v_filelocation_xml NULL')
  PRINT COALESCE(@v_bookcomments_xml,'@v_bookcomments_xml NULL')
  PRINT COALESCE(@v_assotitles_xml,'@v_assotitles_xml NULL')
  PRINT COALESCE(@v_bookcontact_xml,'@v_bookcontact_xml NULL')
  PRINT COALESCE(@v_citations_xml,'@v_citations_xml NULL')
  PRINT COALESCE(@v_discoveryquestions_xml,'@v_discoveryquestions_xml NULL')
  PRINT COALESCE(@v_territorialrights_xml, '@v_territorialrights_xml NULL')
  PRINT COALESCE(@v_bookkeywords_xml, '@v_bookkeywords_xml NULL')
  PRINT '</Transaction>'
  
  SET @v_transaction_xml = @v_transaction_xml + '</Transaction>'

  IF @v_transaction_xml is null OR rtrim(ltrim(@v_transaction_xml)) = '' BEGIN
    print '@v_transaction_xml is NULL'
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to copy from title/template: @v_transaction_xml is NULL.'
    return
  END

  EXEC qutl_dbchange_request @v_transaction_xml, @v_newkeys_str OUTPUT, @v_warnings_str OUTPUT,
    @o_error_code OUTPUT, @o_error_desc OUTPUT
   
  IF @o_error_code <> 0 BEGIN  
    print '@o_error_desc: ' + @o_error_desc
    RETURN
  END

  -- Case 49769. Used by a custom trigger
  UPDATE book SET copyfrombookkey = @i_templatebookkey
  WHERE bookkey = @i_bookkey
  
  /* Additional inserts to any table that does not track titlehistory */
  EXEC qtitle_copy_title_addtl_info @i_bookkey, @i_printingkey, @i_templatebookkey, @i_templateprintingkey, 
      @i_copydatagroups_list, @i_cleardatagroups_list, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT

	select @v_client_option = optionvalue
	from clientoptions
	where optionid = 71
		
	if @v_client_option = 1 begin
	  SET @v_csverifytype = 0
  
    SELECT @v_count = COUNT(*)
    FROM gentables
    WHERE tableid = 556 AND qsicode = 3 AND LOWER(deletestatus) = 'n'
    
    IF @v_count > 0 BEGIN
      SELECT @v_csverifytype = datacode
      FROM gentables
      WHERE tableid = 556 AND qsicode = 3
    END
	
		declare verify_cur cursor for
		select datacode, alternatedesc1
		from gentables 
		where tableid = 556 AND LOWER(deletestatus) = 'n'

		open verify_cur
		fetch next from verify_cur INTO @v_datacode, @v_prox_name
		while (@@FETCH_STATUS <> -1)
  		begin	

		  SELECT @v_erroroutputind = COALESCE(gen3ind,0)
		  FROM gentables_ext
		  WHERE tableid = 556 AND datacode=@v_datacode  	
		    		
          IF @v_erroroutputind = 1 OR @v_datacode = @v_csverifytype BEGIN
            SET @v_sql = N'exec ' + @v_prox_name + 
              ' @i_bookkey, @i_printingkey, @i_verificationtypecode, @i_username, @v_error_code OUTPUT, @v_error_desc OUTPUT'
                
            EXECUTE sp_executesql @v_sql, 
              N'@i_bookkey int, @i_printingkey int, @i_verificationtypecode int,
                @i_username varchar(15), @v_error_code INT OUTPUT, @v_error_desc VARCHAR(2000) OUTPUT', 
              @i_bookkey = @i_bookkey, 
              @i_printingkey = @i_printingkey, 
              @i_verificationtypecode = @v_datacode, 
              @i_username = @i_userid,
              @v_error_code = @o_error_code OUTPUT,
              @v_error_desc = @o_error_desc OUTPUT
            
            IF @o_error_code = -1 BEGIN
				RETURN
			END
			ELSE BEGIN
			  SET @o_error_code = 0
			  SET @o_error_desc = ''
			END
          
          END
          ELSE BEGIN
		      set @v_sql = N'exec ' + @v_prox_name + ' ' +  cast(@i_bookkey as varchar) + ',' + cast(@i_printingkey as varchar) + ',' + cast(@v_datacode as varchar) + ',' + @v_quote + @i_userid + @v_quote
	    	  execute sp_executesql @v_sql	
		  END

          fetch next from verify_cur into @v_datacode, @v_prox_name
		end
		close verify_cur
		deallocate verify_cur 
	end	
END
GO

GRANT EXEC ON qtitle_copy_title TO PUBLIC
GO
