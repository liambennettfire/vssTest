/* 6/2/04 - PV - Expand title to 255 chars (CRM 1373) */
/* ware_title (80 to 255), ware_titleprefix (100 to 275), */
/* ware_titleprefixandtitle (100 to 275) */

PRINT 'STORED PROCEDURE : dbo.datawarehouse_bookinfo'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_bookinfo') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_bookinfo
end

GO

CREATE  proc dbo.datawarehouse_bookinfo
@ware_bookkey int, @ware_logkey int, @ware_warehousekey int,
@ware_system_date datetime

AS

DECLARE @ware_count int 
declare @ware_booknet_ver_desc varchar(40)
declare @ware_bna_plus_ver_desc varchar(40)
declare @ware_eloquence_basic_5_ver_desc varchar(40)
declare @ware_customer_ver_desc varchar(40)
declare @ware_titleverifystatuscode int
declare @ware_barcodeposition1_desc varchar(40)
declare @ware_barcodeposition1 int
declare @ware_barcodeid1 int
declare @ware_barcodeid1_desc varchar(40)
declare @ware_barcodeposition2_desc varchar(40)
declare @ware_barcodeposition2 int
declare @ware_barcodeid2 int
declare @ware_barcodeid2_desc varchar(40)
declare @ware_edistatuscode int
declare @ware_neversendtoelo char(1)
DECLARE @ware_prodavailability int
DECLARE @ware_prodavailability_short varchar(20)
DECLARE @ware_company 		varchar(20) 
DECLARE @ware_titlestatus_long 	varchar(40) 
DECLARE @ware_titlestatus_short varchar(20) 
DECLARE @ware_territory_long 	varchar(40) 
DECLARE @ware_territory_short 	varchar(20) 
DECLARE @ware_titletype_long  	varchar(40) 
DECLARE @ware_titletype_short  	varchar(20) 
DECLARE @ware_shorttitle	varchar(50) 
DECLARE @ware_subtitle  	varchar(255) 
DECLARE @ware_title		varchar(255) 
DECLARE @ware_titlestatuscode  	int 
DECLARE @ware_territoriescode  	int 
DECLARE @ware_titletypecode    	int 
DECLARE @ware_mediatypecode	int 
DECLARE @ware_mediatypesubcode 	int
DECLARE @ware_fullauthordisplayname  varchar(255) 
DECLARE @ware_titleprefix 	varchar(275) 
DECLARE @ware_agehighupind 	int 
DECLARE @ware_agelowupind 	int
DECLARE @ware_gradelowupind 	int 
DECLARE @ware_gradehighupind 	int 
DECLARE @ware_bisacstatuscode 	int  
DECLARE @ware_editioncode 	int  
DECLARE @ware_agelow   		int 
DECLARE @ware_agehigh 		int 
DECLARE @ware_gradelow 		varchar(10) 
DECLARE @ware_gradehigh 	varchar(10) 
DECLARE @ware_languagecode 	int 
DECLARE @ware_origincode 	int  
DECLARE @ware_platformcode 	int 
DECLARE @ware_restrictioncode 	int 
DECLARE @ware_returncode 	int 
DECLARE @ware_seriescode 	int 
DECLARE @ware_userlevelcode 	int 
DECLARE @ware_volumenumber 	int 
DECLARE @ware_salesdivisioncode int 
DECLARE @ware_format 		varchar(120) 
DECLARE @ware_formatshort 	varchar(20) 
DECLARE @ware_media 		varchar(40) 
DECLARE @ware_mediashort 	varchar(20) 
DECLARE @prefix  		varchar(15) 
DECLARE @ware_titleprefixandtitle varchar(275) 
DECLARE @bisacstatus_long 	varchar(40) 
DECLARE @bisacstatus_short 	varchar(20) 
DECLARE @edition_long 		varchar(40) 
DECLARE @edition_short 		varchar(20) 
DECLARE @language_long 		varchar(40) 
DECLARE @language_short 	varchar(20) 
DECLARE @origin_long 		varchar(40) 
DECLARE @origin_short 		varchar(20) 
DECLARE @platform_long 		varchar(40) 
DECLARE @platform_short 	varchar(20) 
DECLARE @restrictions_long 	varchar(40) 
DECLARE @restrictions_short 	varchar(20) 
DECLARE @ware_returndesc 	varchar(40) 
DECLARE @ware_returnshort 	varchar(20) 
DECLARE @salesdivision_long 	varchar(40) 
DECLARE @salesdivision_short  	varchar(20) 
DECLARE @series_long 		varchar(40) 
DECLARE @series_short 		varchar(20) 
DECLARE @userlevel_long 	varchar(40) 
DECLARE @userlevel_short 	varchar(20) 
DECLARE @ware_productnumber  	varchar(20) 

DECLARE @agelowstr 		varchar(10) 
DECLARE @agehighstr 		varchar(10) 
DECLARE @agerange   		varchar(25) 
DECLARE @gradelowstr 		varchar(15) 
DECLARE @gradehighstr 		varchar(15) 
DECLARE @graderange   		varchar(15) 

/* 1/28/05 - PM - CRM# 2212 */
DECLARE @CanadianRestriction_short varchar(20)
DECLARE @CanadianRestriction_long varchar(40)

DECLARE @ware_isbn  		varchar(13) 
DECLARE @ware_upc   		varchar(50) /*8-12-04 update upc,ean,lccn to 50*/
DECLARE @ware_ean   		varchar(50) 
DECLARE @ware_lccn  		varchar(50) 
DECLARE @ware_isbn10  		varchar(10) 
DECLARE @ware_itemnumber	varchar(20)

DECLARE @ware_ean13  		varchar(13) 
DECLARE @ware_ean5 		varchar(5) 
DECLARE @ware_upc12 		varchar(12) 
DECLARE @ware_upc17 		varchar(17) 

DECLARE @ware_announcedfirstprint  int 
DECLARE @ware_estimatedinsertillus varchar(255) 
DECLARE @ware_actualinsertillus varchar(255) 
DECLARE @ware_tentativepagecount int 
DECLARE @ware_pagecount   int    
DECLARE @ware_projectedsales  float
DECLARE @ware_tentativeqty   int 
DECLARE @ware_firstprintingqty  int 
DECLARE @ware_seasonkey  int 
DECLARE @ware_estseasonkey  int 
DECLARE @ware_trimsizelength varchar(25) 
DECLARE @ware_trimsizewidth  varchar(25) 
DECLARE @ware_esttrimsizewidth varchar(25) 
DECLARE @ware_esttrimsizelength varchar(25) 
DECLARE @ware_issuenumber   int 
DECLARE @ware_pubmonth   datetime
DECLARE @ware_slotcode    int 
DECLARE @ware_estannouncedfirstprint  int 
DECLARE @ware_estprojectedsales  float 

DECLARE @ware_audionumberunits int
DECLARE @ware_audiototalruntime varchar(10)

DECLARE @ware_best int 
DECLARE @ware_best2 varchar(255) 
DECLARE @ware_best3 int 
DECLARE @ware_best4 float 
DECLARE @ware_best5  float

DECLARE @eststr  varchar(25) 
DECLARE @actstr varchar(25) 
DECLARE @beststr varchar(25) 
DECLARE @eststr2 varchar(40) 
DECLARE @actstr2 varchar(40) 
DECLARE @beststr2 varchar(40) 
DECLARE @ware_seasontype int 
DECLARE @ware_seasondesc varchar(40) 
DECLARE @ware_seasonyear int 

DECLARE @ware_slot_long  varchar(40) 
DECLARE @ware_slot_short varchar(20) 
DECLARE @ware_discountcode int
DECLARE @ware_allagesind tinyint
DECLARE @ware_discount_long  varchar(40) 
DECLARE @ware_discount_short varchar(20) 
DECLARE @ware_allages varchar(1) 
DECLARE @ware_totalvolume  int
DECLARE @ware_pubmonthddyymm  varchar(10) 
DECLARE @ware_authorkey int
DECLARE @ware_lastname varchar(75) 
DECLARE @ware_displayname varchar(80)
DECLARE @ware_allauthorlast varchar(1000) 
DECLARE @ware_allauthdisp varchar(2000) 
DECLARE @ware_allauthcomp varchar(2000) 
DECLARE @ware_allauthcomp2 varchar(2000) 
DECLARE @ware_bestdisplay varchar(2000) 
DECLARE @i_authorstatus2 int
DECLARE @lv_titlereleasedtoeloquenceind varchar(1)
DECLARE @ware_spinesize varchar(15) /* added 8-27-03*/

/* 1/20/05 - KB - CRM# 2339 */
DECLARE @ware_projectisbn varchar(19) 
DECLARE @ware_alternateprojectisbn varchar(19)
DECLARE @ware_nextisbn varchar(19) 
DECLARE @ware_nexteditionisbn varchar(19) 
DECLARE @ware_previouseditionisbn varchar(19) 
DECLARE @ware_copyrightyear smallint
DECLARE @ware_primaryeditionworkkey INT
DECLARE @ware_primaryeditionisbn10 varchar(10)
DECLARE @ware_primaryeditionean13 varchar(13)
DECLARE @ware_editionnumber integer
DECLARE @ware_editiondescription varchar(150)
DECLARE @ware_additionaleditinfo varchar(100)

/* 1/28/05 - PM - CRM# 2212 */
DECLARE @ware_Canadian_Restriction_Code smallint

DECLARE @ware_elocustomerkey	INT,
  @ware_elocustomer_long  VARCHAR(100),
  @ware_elocustomer_short VARCHAR(30)

BEGIN

  /*book*/
  select @ware_count = 0

  SELECT @ware_count = count(*)
  FROM book
  WHERE bookkey = @ware_bookkey

  IF @ware_count > 0
    BEGIN
      SELECT @ware_shorttitle = shorttitle, @ware_subtitle = subtitle, @ware_title = title,
        @ware_titlestatuscode = titlestatuscode, @ware_territoriescode = territoriescode,
        @ware_titletypecode = titletypecode, @ware_elocustomerkey = elocustomerkey, @ware_primaryeditionworkkey = workkey
      FROM book
      WHERE bookkey = @ware_bookkey

    select @ware_primaryeditionisbn10 = isbn10, @ware_primaryeditionean13 = ean13
    from isbn 
    where bookkey = @ware_primaryeditionworkkey

      if @ware_shorttitle is null 
        begin 
          select @ware_shorttitle = ''
        end
      if @ware_subtitle is null 
        begin
          select @ware_subtitle = ''
        end
      if @ware_titlestatuscode is null
        begin
          select @ware_titlestatuscode = 0
        end
      if @ware_territoriescode is null
        begin
          select @ware_territoriescode = 0
        end

      if @ware_titlestatuscode > 0 
        begin
          exec gentables_longdesc 149,@ware_titlestatuscode,@ware_titlestatus_long OUTPUT
          exec  gentables_shortdesc 149,@ware_titlestatuscode,@ware_titlestatus_short OUTPUT
          select @ware_titlestatus_short  = substring(@ware_titlestatus_short,1,20)
        end
      else
        begin
          select @ware_titlestatus_long  = ''
          select @ware_titlestatus_short = ''
        end

      if @ware_territoriescode > 0 
        begin
          exec gentables_longdesc 131,@ware_territoriescode,@ware_territory_long OUTPUT
          exec gentables_shortdesc 131,@ware_territoriescode,@ware_territory_short OUTPUT
          select @ware_territory_short = substring(@ware_territory_short,1,20)
        end
      else
        begin
          select @ware_territory_long = ''
          select @ware_territory_short = ''
        end

      if @ware_titletypecode> 0
        begin
          exec gentables_longdesc 132,@ware_titletypecode,@ware_titletype_long OUTPUT
          exec gentables_shortdesc 132,@ware_titletypecode,@ware_titletype_short OUTPUT 
        select @ware_titletype_short = substring(@ware_titletype_short,1,20)
        end
      else
        begin
          select @ware_titletype_long = ''
          select @ware_titletype_short = ''
        end

      IF @ware_elocustomerkey > 0
        BEGIN
          SELECT @ware_elocustomer_long = customerlongname, @ware_elocustomer_short = customershortname
          FROM customer
          WHERE customerkey = @ware_elocustomerkey
        END
      ELSE
        BEGIN
          SET @ware_elocustomer_long = ''
          SET @ware_elocustomer_short = ''
        END

    END  /* END @ware_count > 0*/
	ELSE  
    BEGIN
      INSERT INTO wherrorlog (logkey, warehousekey, 
        errordesc, errorseverity, 
        errorfunction, lastuserid, lastmaintdate)
      VALUES (convert(varchar,@ware_logkey), convert(varchar,@ware_warehousekey), 
      'No book rows for this title', ('Warning/data error bookkey ' + convert(varchar,@ware_bookkey)), 
      'Stored procedure datawarehouse_bisac', 'WARE_STORED_PROC', @ware_system_date)
    END
    
/**else
	INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
	         errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (to_char(@ware_logkey)  ,to_char(@ware_warehousekey),
		'No book rows for this title',
		('Warning/data error bookkey '||to_char(@ware_bookkey)),
		'Stored procedure datawarehouse_bisac','WARE_STORED_PROC', @ware_system_date)
	commit
end if
**/
 end

INSERT into whtitleinfo
	(bookkey, shorttitle,subtitle,title,lastuserid,lastmaintdate, primaryeditionworkkey, primaryeditionisbn10, primaryeditionean13)
VALUES (@ware_bookkey, @ware_shorttitle,@ware_subtitle,@ware_title,
	'WARE_STORED_PROC',@ware_system_date, @ware_primaryeditionworkkey, @ware_primaryeditionisbn10, @ware_primaryeditionean13)

/**if SQL%ROWCOUNT > 0 then
	commit
else
	INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
     	    errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (to_char(@ware_logkey)  ,to_char(@ware_warehousekey),
		'Unable to insert whtitleinfo table - for book',
		('Warning/data error bookkey '||to_char(@ware_bookkey)),
		'Stored procedure datawarehouse_bookinfo','WARE_STORED_PROC',
		@ware_system_date)
	commit
end if
**/
	INSERT INTO whtitleclass
		(bookkey, internalstatus, internalstatusshort,
		territories, territoriesshort, titletype, titletypeshort,
		elocustomer, elocustomershort, lastuserid, lastmaintdate)
	VALUES 
	  (@ware_bookkey, @ware_titlestatus_long, @ware_titlestatus_short,
		@ware_territory_long, @ware_territory_short, @ware_titletype_long, @ware_titletype_short,
		@ware_elocustomer_long, @ware_elocustomer_short, 'WARE_STORED_PROC', @ware_system_date)

/**if SQL%ROWCOUNT > 0 then
	commit
else
	INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
     	    errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (to_char(@ware_logkey)  ,to_char(@ware_warehousekey),
		'Unable to insert whtitleclass table - for book',
		('Warning/data error bookkey '||to_char(@ware_bookkey)),
		'Stored procedure datawarehouse_bookinfo','WARE_STORED_PROC', @ware_system_date)
	commit
end if
**/

/*bookdetail*/
select @ware_count = 0

  select @ware_count = count(*)
	FROM bookdetail
  		WHERE bookkey = @ware_bookkey
if @ware_count>0 
  begin
		SELECT  @ware_mediatypecode = mediatypecode,@ware_mediatypesubcode = mediatypesubcode,
		@ware_fullauthordisplayname = fullauthordisplayname,@ware_titleprefix = titleprefix,
		@ware_agehighupind = agehighupind,@ware_agelowupind = agelowupind,@ware_gradelowupind= gradelowupind,
		@ware_gradehighupind =gradehighupind, @ware_bisacstatuscode =bisacstatuscode,@ware_editioncode=editioncode,
		@ware_agelow = agelow,@ware_agehigh = agehigh,@ware_gradelow=gradelow,@ware_gradehigh = gradehigh,
		@ware_languagecode=languagecode,@ware_origincode=origincode,@ware_platformcode = platformcode,
		@ware_restrictioncode = restrictioncode,@ware_returncode=returncode,@ware_seriescode =seriescode,
		@ware_userlevelcode =userlevelcode,@ware_volumenumber= volumenumber,@ware_salesdivisioncode=salesdivisioncode,
		@ware_discountcode=discountcode,@ware_allagesind=allagesind,
		@ware_projectisbn = vistaprojectnumber,@ware_alternateprojectisbn = alternateprojectisbn,
		@ware_nextisbn = nextisbn,@ware_nexteditionisbn = nexteditionisbn,
  	        @ware_previouseditionisbn = preveditionisbn,@ware_copyrightyear = copyrightyear, 
		@ware_Canadian_Restriction_Code = canadianrestrictioncode, @ware_editiondescription = editiondescription,
		@ware_editionnumber = editionnumber, @ware_additionaleditinfo = additionaleditinfo,
		@ware_prodavailability = prodavailability
			FROM bookdetail
			  	WHERE bookkey = @ware_bookkey

		if @ware_editionnumber is null
		  begin
			select @ware_editionnumber = 0
		  end
		if @ware_mediatypecode is null
		  begin
			select @ware_mediatypecode = 0
		  end
		if @ware_mediatypesubcode is null
		  begin
			select @ware_mediatypesubcode  = 0
		  end
		if @ware_bisacstatuscode is null
		  begin
			select @ware_bisacstatuscode  = 0
		  end
		if @ware_editioncode is null
		  begin
			select @ware_editioncode  = 0
		  end
		if @ware_languagecode is null
		  begin
			select @ware_languagecode = 0
		  end
		if @ware_origincode is null
		  begin
			select @ware_origincode= 0
		  end
		if @ware_platformcode is null
		  begin
			select  @ware_platformcode = 0
		  end

		if @ware_restrictioncode is null
		  begin
			select @ware_restrictioncode = 0
		  end
		if @ware_restrictioncode is null
		  begin
			select @ware_restrictioncode = 0
		  end
		if @ware_returncode is null
		  begin
			select @ware_returncode = 0
		  end
		if @ware_salesdivisioncode is null
		  begin
			select @ware_salesdivisioncode = 0
		  end

		if @ware_seriescode is null
		  begin
			select @ware_seriescode = 0
		  end

		if @ware_userlevelcode is null
		  begin
			select @ware_userlevelcode = 0
		  end

		set @ware_prodavailability_short = null
		if @ware_bisacstatuscode > 0 and @ware_prodavailability > 0
		  begin
			exec subgent_shortdesc 314,@ware_bisacstatuscode,@ware_prodavailability,@ware_prodavailability_short OUTPUT
		  end

		if @ware_mediatypecode > 0  and @ware_mediatypesubcode > 0 
		  begin
			exec subgent_longdesc 312,@ware_mediatypecode,@ware_mediatypesubcode,@ware_format OUTPUT
			exec subgent_shortdesc 312,@ware_mediatypecode,@ware_mediatypesubcode,@ware_formatshort OUTPUT
			select @ware_formatshort = substring(@ware_formatshort,1,20)
		  end
		else
		  begin
			select @ware_format = ''
			select @ware_formatshort = ''
		  end

		if @ware_mediatypecode > 0 
		  begin
			exec gentables_longdesc 312,@ware_mediatypecode,@ware_media OUTPUT
			exec gentables_shortdesc 312,@ware_mediatypecode,@ware_mediashort OUTPUT
			select @ware_mediashort = substring(@ware_mediashort,1,20)
		  end
		else
		  begin
			select @ware_media  = ''
			select @ware_mediashort = ''
		  end

		select @prefix = rtrim(substring(@ware_titleprefix,1,15))
		select @ware_titleprefix = @ware_title

		/*8-27 remove blank sapce*/
		if datalength(@prefix)> 0 
		  begin
			select @ware_titleprefixandtitle = @prefix + ' ' + @ware_title
		  end
		else
		  begin
			select @ware_titleprefixandtitle =  @ware_title
		  end

		if datalength(@prefix) > 0 
	  	  begin
			select @ware_titleprefix = @ware_titleprefix + ', ' + @prefix
		  end

		if @ware_bisacstatuscode > 0 
		  begin
			exec gentables_longdesc 314,@ware_bisacstatuscode,@bisacstatus_long OUTPUT
			exec gentables_shortdesc 314,@ware_bisacstatuscode,@bisacstatus_short OUTPUT
			select @bisacstatus_short = substring(@bisacstatus_short,1,20)
		  end
		else
		  begin
			select @bisacstatus_long = ''
			select @bisacstatus_short = ''
		  end
		if @ware_editioncode > 0 
		  begin
			exec gentables_longdesc 200,@ware_editioncode,@edition_long OUTPUT
			exec gentables_shortdesc 200,@ware_editioncode,@edition_short OUTPUT
			select @edition_short = substring(@edition_short,1,20)
		  end
		else
		  begin
			select @edition_long = ''
			select @edition_short = ''
		  end
		if @ware_languagecode > 0
		  begin
			exec gentables_longdesc 318,@ware_languagecode,@language_long OUTPUT
			exec gentables_shortdesc 318,@ware_languagecode,@language_short OUTPUT 
			select @language_short = substring(@language_short,1,20)
		  end
		else
		  begin
			select @language_long  = ''
			select @language_short = ''
		  end
		if @ware_origincode > 0 
		  begin
			exec gentables_longdesc 315,@ware_origincode,@origin_long OUTPUT
			exec gentables_shortdesc 315,@ware_origincode,@origin_short OUTPUT
			select @origin_short = substring(@origin_short,1,20)
		  end
		else
		  begin
			select @origin_long  = ''
			select @origin_short = ''
		  end 
		if @ware_platformcode > 0 
		  begin
			exec gentables_longdesc 321,@ware_platformcode,@platform_long OUTPUT
			exec gentables_shortdesc 321,@ware_platformcode,@platform_short OUTPUT
			select @platform_short = substring(@platform_short,1,20)
		  end
		else
		  begin
			select @platform_long  = ''
			select @platform_short = ''
		  end
		if @ware_restrictioncode> 0 
		  begin
			exec gentables_longdesc 320,@ware_restrictioncode,@restrictions_long OUTPUT
			exec gentables_shortdesc 320,@ware_restrictioncode,@restrictions_short OUTPUT
			select @restrictions_short = substring(@restrictions_short,1,20)
		  end
		else
		  begin
			select @restrictions_long  = ''
			select @restrictions_short = ''
		  end
		if @ware_returncode> 0
		  begin
			exec gentables_longdesc 319,@ware_returncode,@ware_returndesc OUTPUT
			exec gentables_shortdesc 319,@ware_returncode,@ware_returnshort OUTPUT
			select @ware_returnshort = substring(@ware_returnshort,1,20)
		  end
		else
		  begin
			select @ware_returndesc = ''
			select @ware_returnshort = ''
		  end
		if @ware_salesdivisioncode> 0 
		  begin
			exec gentables_longdesc 313,@ware_salesdivisioncode,@salesdivision_long OUTPUT
			exec gentables_shortdesc 313,@ware_salesdivisioncode,@salesdivision_short OUTPUT
			select @salesdivision_short = substring(@salesdivision_short,1,20)
		  end
		else
		  begin
			select @salesdivision_long = '' 
			select @salesdivision_short  = '' 
		  end
		if @ware_seriescode > 0 
		  begin
			exec gentables_longdesc 327,@ware_seriescode,@series_long OUTPUT
			exec gentables_shortdesc 327,@ware_seriescode,@series_short OUTPUT
			select @series_short = substring(@series_short,1,20)
		  end
		else
		  begin
			select @series_long  = ''
			select @series_short = ''
		  end
		if @ware_userlevelcode > 0
		  begin
			exec gentables_longdesc 322,@ware_userlevelcode,@userlevel_long OUTPUT
			exec gentables_shortdesc 322,@ware_userlevelcode,@userlevel_short OUTPUT
			select @userlevel_short = substring(@userlevel_short,1,20)
		  end
		else
		  begin
			select @userlevel_long  = ''
			select @userlevel_short = ''
		  end
		if @ware_discountcode > 0 
		  begin
			exec  gentables_longdesc 459,@ware_discountcode,@ware_discount_long OUTPUT
			exec gentables_shortdesc 459,@ware_discountcode,@ware_discount_short OUTPUT
			select @ware_discount_short = substring(@ware_discount_short,1,20)
		  end
		else
		  begin
			select @ware_discount_long = ''
			select @ware_discount_short = ''
		  end

		if @ware_allagesind = 0 
		  begin
		 	select @ware_allages = 'N'
		 end
		if @ware_allagesind = 1 
		  begin
			select @ware_allages = 'Y'
		  end

/*6-18-04  rework  age and grade range old way overwritting high and low ind*/
		if @ware_agelow is null
		  begin
			select @ware_agelow  = 0
		  end
		if @ware_agehigh is null
		  begin
			select @ware_agehigh  = 0
		  end
		if @ware_agehighupind  is null
		  begin
			select @ware_agehighupind  = 0
		  end
		if @ware_agelowupind  is null
		  begin
			select @ware_agelowupind  = 0
		  end

		if @ware_gradelow is null
		  begin
			select @ware_gradelow  = 0
		  end
		if @ware_gradehigh is null
		  begin
			select @ware_gradehigh  = 0
		  end
		if @ware_gradehighupind  is null
		  begin
			select @ware_gradehighupind  = 0
		  end
		if @ware_gradelowupind  is null
		  begin
			select @ware_gradelowupind  = 0
		  end
		select @agerange = ''

		select @agehighstr = convert(varchar,@ware_agehigh)
		if @agehighstr = '0' 
		  begin
			select @agehighstr = ''
	 	  end

		select @agelowstr = convert(varchar,@ware_agelow)
		if @agelowstr = '0' 
		  begin
			select @agelowstr = ''
	 	  end

		if @ware_agelowupind > 0 
		  begin
			if @agehighstr = '' 
			  begin 
				select @agerange = ''
			  end
			else
			  begin
				select @agerange = 'UP to ' + @agehighstr
			  end
		  end
		
		if @ware_agehighupind > 0 
		  begin
			if @agelowstr = '' 
			  begin
				select @agerange = ''
			  end
			else
			  begin
				select @agerange = @agelowstr + ' and UP'
			end
		 end


		if @agehighstr = '' and @agerange = ''
		  begin
			select @agerange = @agelowstr
		  end

		if @agelowstr = '' and @agerange = ''
		  begin
			select @agerange = @agehighstr
		  end

		if @agelowstr <> '' and  @agehighstr <> ''
		  begin
			select @agerange = @agelowstr + ' to ' + @agehighstr
		  end

		if @agerange = '0 to 0' 
		  begin
			select @agerange = ''
		  end

		select @gradehighstr = ''

		select @gradehighstr = convert(varchar,@ware_gradehigh)
		if @gradehighstr = '0' 
		  begin
			select @gradehighstr = ''
	 	  end

		select @gradelowstr = convert(varchar,@ware_gradelow)
		if @gradelowstr = '0' 
		  begin
			select @gradelowstr = ''
	 	  end

		if @ware_gradelowupind > 0 
		  begin
		   if @gradehighstr = '' 
		     begin
		      select @graderange = ''
		     end
		   else
		     begin
		      select @graderange = 'UP to ' + @gradehighstr
		     end 
		  end
		   if @ware_gradehighupind > 0 
		     begin
		      if @gradelowstr = '' 
			 begin
		         	select @graderange = ''
			  end
		      else
		        begin
				select @graderange = @gradelowstr + ' and UP'
		        end
		     end
		    
		if @gradehighstr = '' and @graderange = ''
		  begin
			select @graderange = @gradelowstr
		  end

		if @gradelowstr = '' and @graderange = ''
		  begin
			select @graderange = @gradehighstr
		  end

		if @gradelowstr <> '' and  @gradehighstr <> ''
		  begin
			select @graderange = @gradelowstr + ' to ' + @gradehighstr
		  end

		if @graderange = '0 to 0' 
		  begin
			select @graderange = ''
		  end
		
      if @ware_projectisbn is null
			begin
           select @ware_projectisbn = ''
			end

		if @ware_alternateprojectisbn is null
			begin
           select @ware_alternateprojectisbn = ''
			end

		if @ware_nextisbn is null
			begin
           select @ware_nextisbn = ''
			end

		if @ware_nexteditionisbn is null
			begin
           select @ware_nexteditionisbn = ''
			end

		if @ware_previouseditionisbn is null
			begin
           select @ware_previouseditionisbn = ''
			end

		if @ware_copyrightyear is null
			begin
           select @ware_copyrightyear = 0
			end
	 end
	
	set @ware_edistatuscode = null
	select @ware_edistatuscode = edistatuscode
	from bookedistatus 
	where bookkey = @ware_bookkey and 
	printingkey = 1

	if @ware_edistatuscode = 8 begin
		set @ware_neversendtoelo = 'Y'
	end else begin
		set @ware_neversendtoelo = 'N'
	end

	set @ware_barcodeid1 = null
	set @ware_barcodeposition1 = null
	set @ware_barcodeid2 = null
	set @ware_barcodeposition2 = null
	select @ware_barcodeid1 = barcodeid1, @ware_barcodeposition1 = barcodeposition1,
		   @ware_barcodeid2 = barcodeid2, @ware_barcodeposition2 = barcodeposition2
	from printing 
	where bookkey = @ware_bookkey
	and printingkey = 1

	if @ware_barcodeid1 > 0 begin
		exec gentables_longdesc 552,@ware_barcodeid1,@ware_barcodeid1_desc  OUTPUT
	end

	if @ware_barcodeid1 > 0 and @ware_barcodeposition1 > 0  begin
		exec subgent_longdesc 552,@ware_barcodeid1,@ware_barcodeposition1,@ware_barcodeposition1_desc OUTPUT
	 end

	if @ware_barcodeid2 > 0 begin
		exec gentables_longdesc 552,@ware_barcodeid2,@ware_barcodeid2_desc  OUTPUT
	end

	if @ware_barcodeid2 > 0 and @ware_barcodeposition2 > 0  begin
		exec subgent_longdesc 552,@ware_barcodeid2,@ware_barcodeposition2,@ware_barcodeposition2_desc OUTPUT
	end

   --customer verification
	set @ware_titleverifystatuscode = null
	select @ware_titleverifystatuscode = titleverifystatuscode
	from bookverification 
	where bookkey = @ware_bookkey
	and verificationtypecode = 1

	set @ware_customer_ver_desc = null
	if @ware_titleverifystatuscode > 0 begin
		exec gentables_longdesc 513,@ware_titleverifystatuscode, @ware_customer_ver_desc  OUTPUT
	end

	--Eloquence Basic 5 varification
	set @ware_titleverifystatuscode = null
	select @ware_titleverifystatuscode = titleverifystatuscode
	from bookverification 
	where bookkey = @ware_bookkey
	and verificationtypecode = 2

	set @ware_eloquence_basic_5_ver_desc = null
	if @ware_titleverifystatuscode > 0 begin
		exec gentables_longdesc 513,@ware_titleverifystatuscode, @ware_eloquence_basic_5_ver_desc  OUTPUT
	end

	--B&N A+ varification
	set @ware_titleverifystatuscode = null
	select @ware_titleverifystatuscode = titleverifystatuscode
	from bookverification 
	where bookkey = @ware_bookkey
	and verificationtypecode = 3

	set @ware_bna_plus_ver_desc = null
	if @ware_titleverifystatuscode > 0 begin
		exec gentables_longdesc 513,@ware_titleverifystatuscode, @ware_bna_plus_ver_desc  OUTPUT
	end

	--BookNet varification
	set @ware_titleverifystatuscode = null
	select @ware_titleverifystatuscode = titleverifystatuscode
	from bookverification 
	where bookkey = @ware_bookkey
	and verificationtypecode = 4

	set @ware_booknet_ver_desc = null
	if @ware_titleverifystatuscode > 0 begin
		exec gentables_longdesc 513,@ware_titleverifystatuscode, @ware_booknet_ver_desc  OUTPUT
	end
--hren

BEGIN tran
		/* 6/2/04 - PV - Changed from 80 to 255 */
		update whtitleinfo
	     	  set format = @ware_format,
			formatshort = @ware_formatshort,
			media = @ware_media,
			mediashort = @ware_mediashort,
			fullauthordisplayname = @ware_fullauthordisplayname,
			titleprefix = @prefix,
			titleandtitleprefix = rtrim(substring(@ware_titleprefix,1,255)),
			titleprefixandtitle = ltrim(rtrim(substring(@ware_titleprefixandtitle,1,255))),
			prodavailability = @ware_prodavailability_short,
			neversendtoelo = @ware_neversendtoelo,
			barcodeid1 = @ware_barcodeid1_desc	,
			barcodeposition1 = @ware_barcodeposition1_desc,
			barcodeid2 = @ware_barcodeid2_desc	,
			barcodeposition2 = @ware_barcodeposition2_desc,
			booknet_ver = @ware_booknet_ver_desc,
			bna_plus_ver = @ware_bna_plus_ver_desc,
			eloquence_basic_5_ver = @ware_eloquence_basic_5_ver_desc,
			customer_ver = @ware_customer_ver_desc
			where bookkey = @ware_bookkey

/**			if SQL%ROWCOUNT > 0 then
				commit
			else
				INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
      		    errorseverity, errorfunction,lastuserid, lastmaintdate)
				 VALUES (to_char(@ware_logkey)  ,to_char(@ware_warehousekey),
					'Unable to update whtitleinfo table - for bookdetail',
					('Warning/data error bookkey '||to_char(@ware_bookkey)),
					'Stored procedure datawarehouse_bookinfo','WARE_STORED_PROC', @ware_system_date)
				commit
			end if
**/
		update whtitleclass
			set bisacstatus = @bisacstatus_long,
			bisacstatusshort = @bisacstatus_short,
			edition = @edition_long,
			editionshort = @edition_short,
			language = @language_long,
			languageshort = @language_short,
			origin = @origin_long,
			originshort = @origin_short,
			platform  = @platform_long,
			platformshort = @platform_short,
			restrictions = @restrictions_long,
			restrictionsshort = @restrictions_short,
			returndesc = @ware_returndesc,
			returnshort = @ware_returnshort,
			salesdivision = @salesdivision_long,
			salesdivisionshort = @salesdivision_short,
			series = @series_long,
			seriesshort = @series_short,
			userlevel = @userlevel_long,
			userlevelshort = @userlevel_short,
			volume = @ware_volumenumber,
			ages = @agerange,
			grades = @graderange,
			discount = @ware_discount_long,
			discountshort = @ware_discount_short,
			allagesind = @ware_allages,
			totalvolume = @ware_totalvolume,
		         projectisbn = @ware_projectisbn,
		         alternateprojectisbn = @ware_alternateprojectisbn,
		         nextisbn = @ware_nextisbn,
		         nexteditionisbn = @ware_nexteditionisbn,
		         previouseditionisbn = @ware_previouseditionisbn,
		         copyrightyear = @ware_copyrightyear,
			 editiondescription = @ware_editiondescription,
			 editionnumber = @ware_editionnumber,
			 additionaleditinfo = @ware_additionaleditinfo
				where bookkey = @ware_bookkey
commit tran

/*productnumber*/
select @ware_count  = 0

select @ware_count = count(*)
	    FROM productnumber p, productnumlocation pl
		   WHERE p.productnumlockey = pl.productnumlockey
			AND p.bookkey = @ware_bookkey 

if @ware_count > 0 
  begin

 	SELECT @ware_productnumber = productnumber
		    FROM productnumber p, productnumlocation pl
			   WHERE p.productnumlockey = pl.productnumlockey
				AND p.bookkey = @ware_bookkey 

	BEGIN tran
			update whtitleinfo
     			set productnumber = @ware_productnumber
				where bookkey = @ware_bookkey
	commit tran
  end

/*isbn*/
 SELECT @ware_count = count(*)
   	 FROM isbn
   		WHERE bookkey = @ware_bookkey 

	if @ware_count = 0 
	  begin
		INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
		  	errorseverity, errorfunction,lastuserid, lastmaintdate)
		VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_warehousekey),
			'No isbn table row ',
			('Warning/data error bookkey ' + convert(varchar,@ware_bookkey)),
			'Stored procedure datawarehouse_bookinfo','WARE_STORED_PROC', @ware_system_date)
	  end
	if @ware_count > 1 
	  begin
		INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
	  		errorseverity, errorfunction,lastuserid, lastmaintdate)
		VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_warehousekey),
			'No more than one isbn table row ',
			('Warning/data error bookkey ' + convert(varchar,@ware_bookkey)),
			'Stored procedure datawarehouse_bookinfo','WARE_STORED_PROC', @ware_system_date)
	  end
	if @ware_count = 1 
	  begin
		/* 6/9/04 - PV- Added itemnumber */
		/* 2/7/06 - BL: added ean13 and commented out SS specific code as they have their own procs*/
 		SELECT @ware_isbn =isbn, @ware_upc = upc, @ware_ean = ean,@ware_lccn = lccn,@ware_isbn10 = isbn10,
			@ware_itemnumber = itemnumber, @ware_ean13 =  ean13
			   	 FROM isbn
   					WHERE bookkey = @ware_bookkey 
	  end
	 select @ware_company = upper(orgleveldesc)
		from orglevel
			where orglevelkey= 1

	/*if @ware_company = 'CONSUMER' 
	  begin
		select @ware_count = 0
		select @ware_count= count(*)  
			from eanupc
				where bookkey= @ware_bookkey
		if  @ware_count > 0 
	          begin
			select @ware_ean13 = ean13,@ware_ean5= ean5, @ware_upc12= upc12,@ware_upc17=upc17
				from eanupc
					where bookkey= @ware_bookkey
		 	if datalength(rtrim(@ware_ean5)) > 0
			  begin
				select @ware_ean = @ware_ean13 + @ware_ean5
			  end
			else
			  begin
				select @ware_ean = @ware_ean13
			  end
			if datalength(rtrim(@ware_upc12)) > 0 
			  begin
				select @ware_upc = @ware_upc12
			  end	
			else
			  begin
				select @ware_upc = @ware_upc17
			  end
		  end
	 end*/
BEGIN tran
	update whtitleinfo
     		set isbn = @ware_isbn,
			upc = @ware_upc,
			ean = @ware_ean,
			lccn = @ware_lccn,
			isbn10 = @ware_isbn10,
			itemnumber = @ware_itemnumber,
			ean13 = @ware_ean13
			where bookkey = @ware_bookkey
commit tran

/*audiocassettespecs*/
select @ware_count  = 0

SELECT @ware_count = count(*)
  FROM audiocassettespecs a
 WHERE a.bookkey = @ware_bookkey 

if @ware_count > 0 
  begin
    SELECT @ware_audionumberunits = numcassettes,
	   @ware_audiototalruntime = totalruntime
      FROM audiocassettespecs a
     WHERE a.bookkey = @ware_bookkey 

    BEGIN tran
      update whtitleinfo
       	 set audionumberunits = @ware_audionumberunits,
             audiototalruntime = @ware_audiototalruntime
       where bookkey = @ware_bookkey
    commit tran
  end  /* end audiocassettespecs */

/*printing key = 1*/

select @ware_count = 0

select @ware_count = count(*)
	FROM printing
		 WHERE bookkey = @ware_bookkey
			 AND  printingkey = 1 
if @ware_count > 0  /*tmm trim size*/
  begin
	select @ware_count = 0

	select @ware_count = optionvalue from clientoptions
		where optionid = 4  /*9-9-03 clientoptions pagecount*/
	if @ware_count = 1
	  begin
		select @ware_pagecount = tmmpagecount 
		FROM printing
		 WHERE bookkey = @ware_bookkey
			AND  printingkey = 1 
	  end
	else
	  begin	
		select @ware_pagecount = pagecount 
		FROM printing
		 WHERE bookkey = @ware_bookkey
		AND  printingkey = 1 
	end

	select @ware_count = 0

	select @ware_count = optionvalue from clientoptions
		where optionid = 7  /*9-9-03 clientoptions trim*/
	if @ware_count = 1
	  begin
		select @ware_trimsizelength = tmmactualtrimlength,@ware_trimsizewidth =tmmactualtrimwidth
		FROM printing
		 WHERE bookkey = @ware_bookkey
			AND  printingkey = 1 
	  end
	else
	  begin	
		select @ware_trimsizelength = trimsizelength,@ware_trimsizewidth = trimsizewidth
		FROM printing
		 WHERE bookkey = @ware_bookkey
		AND  printingkey = 1 
	end

	SELECT @ware_announcedfirstprint =announcedfirstprint, @ware_estimatedinsertillus=estimatedinsertillus,
		@ware_actualinsertillus =actualinsertillus, @ware_tentativepagecount = tentativepagecount,
		@ware_projectedsales = projectedsales,@ware_tentativeqty =tentativeqty,
		@ware_firstprintingqty = firstprintingqty,@ware_seasonkey = seasonkey,@ware_estseasonkey = estseasonkey,
		@ware_esttrimsizewidth = esttrimsizewidth,@ware_esttrimsizelength =esttrimsizelength,
		@ware_issuenumber =issuenumber,@ware_pubmonth =pubmonth,@ware_slotcode=slotcode,
		@ware_estannouncedfirstprint = estannouncedfirstprint,@ware_estprojectedsales = estprojectedsales,
		@ware_spinesize= spinesize 
				FROM printing
					 WHERE bookkey = @ware_bookkey
						 AND  printingkey = 1 

	if @ware_announcedfirstprint > 0 
	  begin   
		select @ware_best =  @ware_announcedfirstprint
	  end		
	else
	  begin
		select @ware_best = @ware_estannouncedfirstprint
	  end

	if @ware_actualinsertillus is null 
	  begin
		select @ware_actualinsertillus =''
	  end
	 if @ware_estimatedinsertillus is null 
	  begin
		select @ware_estimatedinsertillus = ''
	  end

	if datalength(rtrim(@ware_actualinsertillus)) > 0 
	  begin
		select @ware_best2 =  @ware_actualinsertillus
	  end
	else
	  begin
		 select @ware_best2 = @ware_estimatedinsertillus
	   end
	if @ware_pagecount > 0
	  begin
		select @ware_best3 =  @ware_pagecount
	  end
	else
	  begin
		select @ware_best3 = @ware_tentativepagecount
	  end
	if @ware_projectedsales > 0 
	  begin
		select @ware_best4 =  @ware_projectedsales
	  end
	else
	  begin
		select @ware_best4 = @ware_estprojectedsales
	  end
	if @ware_firstprintingqty > 0 
	  begin
		select @ware_best5 =  @ware_firstprintingqty
	  end	
	else
	  begin
		select @ware_best5 = @ware_tentativeqty
	  end 
	if @ware_trimsizewidth is null
	 begin
		select @ware_trimsizewidth  = ''
	  end
	if @ware_esttrimsizelength is null 
	  begin
		select @ware_esttrimsizelength = ''
	  end

	if @ware_esttrimsizewidth is null 
	  begin
		select @ware_esttrimsizewidth  = ''
	  end
	if @ware_trimsizelength is null 
	  begin
		 select @ware_trimsizelength  = ''
	  end

/*		1-31-02 this is not working for whatever reason  so change the logic to below

	if datalength(rtrim(@ware_trimsizewidth) = 0 and datalength(rtrim(@ware_trimsizelength)) = 0
	  begin
		select @ actstr  = ''
		if datalength(rtrim(@ware_esttrimsizewidth)) = 0 and datalength(rtrim(@ware_esttrimsizelength)) = 0
		  begin
			select @eststr  = ''
			select @beststr  = ''
		  end
		else
		  begin
			select @eststr = @ware_esttrimsizewidth + ' x ' +  @ware_esttrimsizelength
			select @beststr = @ware_esttrimsizewidth + ' x ' + @ware_esttrimsizelength
		  end
	  end
	 else
	  begin
		select @actstr = @ware_trimsizewidth + ' x ' + @ware_trimsizelength
		select @beststr = actstr
		if datalength(rtrim(@ware_esttrimsizewidth)) = 0 and datalength(rtrim(@ware_esttrimsizelength)) = 0
		 begin
			select @eststr =''
		  end
		else
		  begin
			select @eststr = @ware_esttrimsizewidth + ' x ' + @ware_esttrimsizelength
		  end
	  end 
*/

	if datalength(rtrim(@ware_trimsizewidth)) > 0 and datalength(rtrim(@ware_trimsizelength)) > 0 
	  begin
		select @actstr = @ware_trimsizewidth + ' x ' + @ware_trimsizelength
		select @beststr = @actstr
		select @eststr = @ware_esttrimsizewidth + ' x ' + @ware_esttrimsizelength
	  end
	else
	  begin
		select @eststr = @ware_esttrimsizewidth + ' x ' + @ware_esttrimsizelength
		select @beststr = @eststr
	  end
		
	if rtrim(ltrim(@eststr)) = 'x' 
  	  begin
		select @eststr = ''
	  end
	if rtrim(ltrim(@actstr)) = 'x' 
	  begin
		select @actstr = ''
	  end
	if  rtrim(ltrim(@beststr)) = 'x'
	  begin
		select @beststr = '' 
	  end

	if @ware_slotcode > 0
	  begin
		exec gentables_longdesc 102,@ware_slotcode, @ware_slot_long OUTPUT
		exec	gentables_shortdesc 102,@ware_slotcode,@ware_slot_short  OUTPUT
		select @ware_slot_short  = substring(@ware_slot_short,1,20)
	  end
	else
	  begin
		select @ware_slot_long  =''
		select @ware_slot_short = ''
	  end
	if  @ware_estseasonkey > 0
	  begin
		select @ware_seasondesc = seasondesc
			from season
				where seasonkey = @ware_estseasonkey

		if @ware_seasondesc is null 
		  begin
			select @ware_seasondesc  = ''
		  end
		if datalength(rtrim(@ware_seasondesc)) > 0
	   	  begin
			select @eststr2 = @ware_seasondesc
			select @beststr2  = @eststr2
	 	  end
		else
		  begin
			select @eststr2  = ''
		  end
 	  end

	if @ware_seasonkey > 0 
	  begin
		select @ware_seasondesc = seasondesc
			from season
				where seasonkey = @ware_seasonkey

		if @ware_seasondesc is null 
		  begin
			select @ware_seasondesc  = ''
		  end
		if datalength(rtrim(@ware_seasondesc)) > 0 
		  begin
			select @actstr2 = @ware_seasondesc
			select @beststr2 = @actstr2
		  end
		else
	  	  begin
			select @actstr2  = ''
		  end
	  end

 end
/*new author columns 11-12-02*/
select @ware_allauthorlast = ''
select @ware_allauthcomp = ''
select @ware_bestdisplay  = ''
select @ware_allauthdisp = ''

DECLARE warehouseauthor2 INSENSITIVE CURSOR
   FOR 
	SELECT a.authorkey,displayname, lastname
		    FROM bookauthor b, author a
		   	WHERE  b.authorkey=a.authorkey
				AND bookkey = @ware_bookkey
					 ORDER BY  b.primaryind DESC ,b.sortorder ASC, authortypecode
	FOR READ ONLY

		OPEN  warehouseauthor2 
		FETCH NEXT FROM warehouseauthor2
			INTO @ware_authorkey,@ware_displayname,@ware_lastname
		
		select @i_authorstatus2  = @@FETCH_STATUS

		while (@i_authorstatus2 <>-1 )
		   begin

			IF (@i_authorstatus2  <>-2)
			  begin

				select @ware_allauthorlast = @ware_allauthorlast + rtrim(@ware_lastname) + ', '
				select @ware_allauthdisp = @ware_allauthdisp + rtrim(@ware_displayname) + '; '	
				exec  authorextra_sp @ware_authorkey,4, @ware_allauthcomp2 OUTPUT
				select @ware_allauthcomp = @ware_allauthcomp + @ware_allauthcomp2  + '; '
			  end 
		FETCH NEXT FROM warehouseauthor2
			INTO @ware_authorkey,@ware_displayname,@ware_lastname

			select @i_authorstatus2 = @@FETCH_STATUS
		end
		close warehouseauthor2 
		deallocate warehouseauthor2

		select @ware_allauthorlast =  rtrim(@ware_allauthorlast)
		select @ware_count = 0
		select @ware_count = datalength(@ware_allauthorlast)
		if substring(@ware_allauthorlast,@ware_count,1) = ',' 
		 begin
			select @ware_count = @ware_count-1
			select @ware_allauthorlast = substring(@ware_allauthorlast,1,@ware_count)
		  end
		select @ware_allauthdisp =  rtrim(@ware_allauthdisp)
		select @ware_count = 0
		select @ware_count = datalength(@ware_allauthdisp)
		if substring(@ware_allauthdisp,@ware_count,1) = ';' 
		 begin
			select @ware_count = @ware_count-1
			select @ware_allauthdisp = substring(@ware_allauthdisp,1,@ware_count)
		  end
		select @ware_count = 0
		select @ware_allauthcomp =  rtrim(@ware_allauthcomp)
		select @ware_count = datalength(@ware_allauthcomp)
		if substring(@ware_allauthcomp,@ware_count,1) = ';' 
		 begin
			select @ware_count = @ware_count-1
			select @ware_allauthcomp = substring(@ware_allauthcomp,1,@ware_count)
		  end

		if datalength(ltrim(rtrim(@ware_fullauthordisplayname))) > 0 
		  begin
			select @ware_bestdisplay = @ware_fullauthordisplayname
		  end
		else
		  begin
			select @ware_bestdisplay = @ware_allauthcomp
		end

/* 11-26-02 add titlereleasedtoeloquenceind Y or N value*/
		select @ware_count = 0

		select @ware_count = count(*) from bookedipartner where printingkey = 1 and 
			bookkey = @ware_bookkey
		if @ware_count > 0 
		  begin
			select @lv_titlereleasedtoeloquenceind = 'Y'
		  end
		else
		  begin
			select @lv_titlereleasedtoeloquenceind = 'N'
		 end
/* 01-10-03	 add childformat and short desc*/
	select @ware_mediatypecode = 0
	select @ware_count = 0
	
	/* 11/18/03 - PV - Initialize these variables so that */
	/* Format is not saved in Childformat if no row exists on */
	/* booksimon for the bookkey */
	SELECT @ware_format = ''
	SELECT @ware_formatshort = ''

	SELECT  @ware_count  = count(*) 
			FROM booksimon
			  	WHERE bookkey = @ware_bookkey

	if @ware_count > 0  
	  begin
		SELECT  @ware_mediatypecode = formatchildcode
			FROM booksimon
			  	WHERE bookkey = @ware_bookkey
			
		if @ware_mediatypecode is null
		  begin
			select @ware_mediatypecode = 0
		  end	
		if @ware_mediatypecode > 0  
		  begin
			exec gentables_longdesc 300,@ware_mediatypecode,@ware_format  OUTPUT
			exec gentables_shortdesc 300,@ware_mediatypecode,@ware_formatshort  OUTPUT
		  end
		else
		  begin
			select @ware_format = ''
			select @ware_formatshort = ''
		end
	end
	/* 11-6-03 get pubmonth only from printing 
	if @ware_pubmonth is null  	
	  begin
		select @ware_count = 0
		
		select  @ware_count = count(*) from bookdates where datetypecode=8 and
		  printingkey=1 and bookkey= @ware_bookkey
		if @ware_count > 0
		  begin
			select  @ware_pubmonth = bestdate from bookdates where datetypecode=8 and
			  printingkey=1 and bookkey= @ware_bookkey
		end
	 end
*/
/* 1/28/05 - PM - CRM# 2212 */
if @ware_Canadian_Restriction_Code > 0 
	begin
		exec gentables_longdesc 428, @ware_Canadian_Restriction_Code, @canadianrestriction_long OUTPUT
		exec gentables_shortdesc 428, @ware_Canadian_Restriction_Code, @canadianrestriction_short OUTPUT
	end
	

BEGIN tran
		update whtitleinfo
	     	  set announcedfirstprintact = @ware_announcedfirstprint,
			announcedfirstprintest = @ware_estannouncedfirstprint,
			announcedfirstprintbest = @ware_best,
			insertillusest = @ware_estimatedinsertillus,
			insertillusact = @ware_actualinsertillus,
			insertillusbest = @ware_best2,
			pagecountest = @ware_tentativepagecount,
			pagecountact = @ware_pagecount,
			pagecountbest = @ware_best3,
			projectedsalesest = @ware_estprojectedsales,
			projectedsalesact = @ware_projectedsales,
			projectedsalesbest = @ware_best4,
			quantityest = @ware_tentativeqty,
			quantityact = @ware_firstprintingqty,
			quantitybest = @ware_best5,
			trimsizeest = @eststr,
			trimsizeact = @actstr,
			trimsizebest = @beststr,
			seasonyearest = @eststr2,
			seasonyearact = @actstr2,
			seasonyearbest = @beststr2,
			allauthorlastname = 	@ware_allauthorlast,
			allauthordisplayname = 	@ware_allauthdisp,
			allauthorcompletename = @ware_allauthcomp,
			bestauthordisplayname = @ware_bestdisplay,
			titlereleasedtoeloquenceind = @lv_titlereleasedtoeloquenceind,
			childformat = @ware_format,
			childformatshort = @ware_formatshort,
			spinesize = @ware_spinesize,
			canadian_restriction_long = @canadianrestriction_long,
			canadian_restriction_short = @canadianrestriction_short
		where bookkey = @ware_bookkey

		if @ware_pubmonth is not null 	
		  begin
			 /*11-5-03 add pubyear*/
			UPDATE whtitleinfo
		     	  set pubmonth = datename(month,@ware_pubmonth),  /*6-14-04 entire spelling*/
				pubmonthshort = substring(convert(varchar ,@ware_pubmonth,100),1,3), /*Mon*/
				pubmonthmmddyy  = convert(datetime,(substring(convert(varchar,@ware_pubmonth,101),1,2) + '/01/' + substring(convert(varchar,@ware_pubmonth,101),7,4)),101),
				pubyear =substring(convert(varchar,@ware_pubmonth,101),7,4)
					where bookkey = @ware_bookkey

		 end	
		
		update whtitleclass
			set   slot = @ware_slot_long,
				slotshort = @ware_slot_short
					where bookkey = @ware_bookkey
commit tran


GO

