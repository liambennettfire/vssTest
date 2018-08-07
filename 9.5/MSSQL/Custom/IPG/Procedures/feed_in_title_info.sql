if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[feed_in_title_info]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[feed_in_title_info]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

create proc dbo.feed_in_title_info 
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

/*9-22-04 CRM 01901: missing agerange comment update and 2 and 4 color check box not always updating
  add error checking for prices not numeric and output isbn prefix not on gentables*/

DECLARE @titlestatusmessage varchar (255)
DECLARE @statusmessage varchar (255)
DECLARE @c_outputmessage varchar (255)
DECLARE @c_output varchar (255)
DECLARE @titlecount int
DECLARE @titlecountremainder int
DECLARE @err_msg varchar (100)
DECLARE @d_currentdate datetime
DECLARE @bookwasupdatedind int
DECLARE @bookwasinsertind int
DECLARE @bookwasrejectedind int
DECLARE @c_lastuserid varchar (30)
DECLARE @c_grouplevel1 varchar(40)

DECLARE @feedin_bookkey  int

DECLARE @feed_isbn varchar(10)

DECLARE @i_id int
DECLARE @c_incatalog varchar (10)
DECLARE @c_onorderform varchar (10)
DECLARE @c_catalog varchar (10)
DECLARE @c_fnb  varchar (50)  
DECLARE @c_season	VARCHAR(50)
DECLARE @c_status   varchar (50)
DECLARE @i_publication_year Int 
DECLARE @c_slot varchar (40)  
DECLARE @c_title varchar (80)  
DECLARE @c_titleprefix  varchar (20)
DECLARE @c_subtitle varchar (255)  
DECLARE @c_edition varchar (50)  
DECLARE @i_volume int
DECLARE @c_seriestitle  varchar (255)  
DECLARE @c_author1firstname varchar (100)  
DECLARE @c_author1lastname varchar (100)  
DECLARE @c_author1city varchar (100)  
DECLARE @c_author1state varchar (100)  
DECLARE @c_author2firstname varchar (100)  
DECLARE @c_author2lastname varchar (100)  
DECLARE @c_author2city varchar (100)  
DECLARE @c_author2state varchar (100)  
DECLARE @c_author3firstname varchar (100)  
DECLARE @c_author3lastname varchar (100)  
DECLARE @c_author3city varchar (100)  
DECLARE @c_author3state varchar (100)  
DECLARE @c_author4firstname varchar (100)  
DECLARE @c_author4lastname varchar (100)  
DECLARE @c_author4city varchar (100)  
DECLARE @c_author4state varchar (100)  
DECLARE @c_editor1firstname   varchar (50)  	
DECLARE @c_editor1lastname	 varchar (255)  
DECLARE @c_editor1city varchar (100)  
DECLARE @c_editor1state varchar (100)  
DECLARE @c_editor2firstname varchar (50)  		
DECLARE @c_editor2lastname	varchar (255)  
DECLARE @c_editor2city varchar (100)  	
DECLARE @c_editor2state varchar (100)  	
DECLARE @c_forewordfirstname varchar (50)  		
DECLARE @c_forewordlastname varchar (255)  	
DECLARE @c_forewordcity varchar (100)  	
DECLARE @c_forewordstate varchar (100)  	
DECLARE @c_prefacefirstname varchar (50)  		
DECLARE @c_prefacelastname	 varchar (255)  
DECLARE @c_prefacecity varchar (100)  	
DECLARE @c_prefacestate varchar (100)  	
DECLARE @c_afterwordfirstname varchar (50)  		
DECLARE @c_afterwordlastname varchar (255)  	
DECLARE @c_afterwordcity varchar (100)  	
DECLARE @c_afterwordstate	varchar (100)  
DECLARE @c_translatorfirstname varchar (50)  	
DECLARE @c_translatorlastname varchar (255)  	
DECLARE @c_translatorcity	varchar (100)  
DECLARE @c_translatorstate	 varchar (100)  
DECLARE @c_photographerfirstname varchar (50)  	
DECLARE @c_photographerlastname varchar (255)  	
DECLARE @c_photographercity varchar (100)  	
DECLARE @c_photographerstate varchar (100)  	
DECLARE @c_illustratorfirstname varchar (50)  	
DECLARE @c_illustratorlastname varchar (255)  	
DECLARE @c_illustratorcity	varchar (100)  
DECLARE @c_illustratorstate varchar (100)  	
DECLARE @c_otherfirstname	varchar (50)  
DECLARE @c_otherlastname	varchar (255)  
DECLARE @c_othercity varchar (100)  	
DECLARE @c_otherstate varchar (100)  
DECLARE @c_publishername varchar (40)  
DECLARE @c_imprintname varchar (40)  
DECLARE @c_binding varchar (50)  
DECLARE @c_pagecount varchar (20)   
DECLARE @c_trimsize varchar (25)  
DECLARE @i_colorphotos float 
DECLARE @i_colorillustrations float 
DECLARE @i_bandwphotos float 
DECLARE @i_bandwillustrations float 
DECLARE @i_linedrawings int 
DECLARE @i_watercolorillustrations float 
DECLARE @i_charts int 
DECLARE @i_tables int 
DECLARE @i_graphs int 
DECLARE @i_diagrams  int 
DECLARE @i_maps int 
DECLARE @i_screenshots int 
DECLARE @i_codesamples int 
DECLARE @c_agerange varchar (50)  
DECLARE @c_includesdisk varchar (50)  
DECLARE @c_includescdrom varchar (50)  
DECLARE @c_includesaudiocd varchar (50)  
DECLARE @c_twocolorinterior varchar (50)  
DECLARE @c_fourcolorinterior varchar (50)  
DECLARE @c_isbn10 varchar (50)  
DECLARE @c_price  varchar (20) 
DECLARE @c_canadianprice varchar (20) 
DECLARE @c_publicationmonth varchar (50)  
DECLARE @c_subjectcategorya varchar (50)  	
DECLARE @c_subjectcategoryb varchar (50)  
DECLARE @c_copylong varchar(4000)  
DECLARE @c_toc varchar(4000) 
DECLARE @c_quote varchar(4000)  
DECLARE @c_authbio varchar(4000)  
DECLARE @c_rights varchar (255)  
DECLARE @c_oldisbn varchar (50)   
DECLARE @c_entrycode varchar (50)  
DECLARE @c_othertitle1 varchar (255)  
DECLARE @c_otherpub1 varchar (255)  
DECLARE @c_otherisbn1 varchar (50)  
DECLARE @c_otherprice1 varchar (50)  
DECLARE @c_otherdate1 varchar (50)  
DECLARE @c_othertitle2 varchar (255)  
DECLARE @c_otherpub2 varchar (255)  
DECLARE @c_otherisbn2 varchar (50)  
DECLARE @c_otherprice2 varchar (50)  
DECLARE @c_otherdate2 varchar (50)  
DECLARE @c_othertitle3 varchar (255)  
DECLARE @c_otherpub3 varchar (255)  
DECLARE @c_otherisbn3 varchar (50)  
DECLARE @c_otherprice3 varchar (50)  
DECLARE @c_otherdate3 varchar (50)  
DECLARE @c_differences varchar(4000) 
DECLARE @c_translation varchar(4000) 
DECLARE @c_origtitle  varchar(4000)  
DECLARE @c_otherinseries2  varchar(4000)  
DECLARE @c_seriestitles varchar(4000)  
DECLARE @c_keybenefit1	 varchar(4000)  
DECLARE @c_keybenefit2	varchar(4000)  
DECLARE @c_keybenefit3	varchar(4000)  
DECLARE @c_about_technology varchar(4000) 
DECLARE @c_define_audience	varchar(4000) 
DECLARE @c_clothisbn	varchar(4000)  
DECLARE @c_clothinprint varchar(4000) 
DECLARE @c_origlangisbn varchar(4000)
DECLARE @c_pricelastsold varchar(4000)  

DECLARE @i_ti_cursor_status int
DECLARE @c_trimwidth varchar(10)
DECLARE @i_count int
DECLARE @c_trimtrimsize varchar(20)
DECLARE @c_isbn13 varchar(13)
DECLARE @c_ean VARCHAR(17)
DECLARE @c_ean13 VARCHAR(13)
DECLARE @c_gtin VARCHAR(19)
DECLARE @c_gtin14 VARCHAR(14)
DECLARE @i_slotcode int
DECLARE @i_titletypecode int
DECLARE @i_editioncode int
DECLARE @i_seriescode int
DECLARE @d_pubyear_to_date  datetime
DECLARE @i_orglevelkey_2 int
DECLARE @i_orglevelkey_3 int
DECLARE @i_rejected int
DECLARE @i_mediatypecode int
DECLARE @i_mediatypesubcode int
DECLARE @page_opt int
DECLARE @trim_opt int
DECLARE @c_illus  varchar (255)
DECLARE @i_twocolor int
DECLARE @i_fourcolor int
DECLARE @f_usprice float
DECLARE @f_canadianprice float
DECLARE @c_trimlength varchar (20)
DECLARE @i_subjectacode int
DECLARE @i_subjectbcode int
DECLARE @i_territorycode int
DECLARE @i_bisacstatuscode int
DECLARE @i_incat int
DECLARE @i_onorderform int
DECLARE @i_fnbcode int
DECLARE @i_seasonkey int
DECLARE @i_orglevel1key int
DECLARE @i_pages int
DECLARE @i_oldcode int
DECLARE @i_oldcode2 int
DECLARE @c_oldchar varchar (1000)
DECLARE @f_oldfloat float
DECLARE @i_pricecode int
DECLARE @i_currencycode int
DECLARE @nextkey  int
DECLARE @titlehistory_newvalue varchar (100)
DECLARE @feedin_temp_isbn varchar(10)
DECLARE @feedin_isbn_prefix varchar(10)
DECLARE @c_bisacsubjectcode varchar(255) 
DECLARE @c_bisacdesc VARCHAR(40)
DECLARE @c_bisacsubdesc VARCHAR(120)
DECLARE @c_audience  varchar(255)  
DECLARE @c_discount varchar(255)  
DECLARE @c_barcodetype varchar(255)  
DECLARE @c_barcodeposition  varchar(255)  
DECLARE @c_cartonqty  int
DECLARE @c_bookweight  float
DECLARE @i_audiencecode int  
DECLARE @i_subcode int 
DECLARE @i_code int 
DECLARE @i_discountcode int 
DECLARE @i_barcodetypecode int 
SELECT @d_currentdate = getdate()
SELECT @c_lastuserid = 'feedin'
SELECT @c_grouplevel1 = 'Independent Publishers Group'
select @i_orglevel1key = 1

select @statusmessage = 'BEGIN VISTA FEED IN AT ' + convert (char,getdate())
print @statusmessage


select @titlecount=0
select @titlecountremainder=0

select @i_rejected = 0
SELECT @d_currentdate = getdate()

begin tran

insert into feederror (batchnumber,processdate,errordesc,detailtype)
     	 values ('3',@d_currentdate,'Feed Summary: Inserts',0)

insert into feederror (batchnumber,processdate,errordesc,detailtype)
     	 values('3',@d_currentdate,'Feed Summary: Updates',0)

insert into feederror (batchnumber,processdate,errordesc,detailtype)
     	 values ('3',@d_currentdate,'Feed Summary: Rejected',0)

	delete from feedin_titles 
	where title = NULL or isbn = NULL

	update feedin_titles
	set pagecount = replace(pagecount,',','')

	update feedin_titles
	set pagecount = replace(pagecount,'i+','')

	update feedin_titles
	set pagecount = replace(pagecount,'ii+','')	

	update feedin_titles
	set pagecount = replace(pagecount,'iii+','')

	update feedin_titles
	set pagecount = replace(pagecount,'iv+','')

	update feedin_titles
	set pagecount = replace(pagecount,'v+','')

	update feedin_titles
	set pagecount = replace(pagecount,'vi+','')

	update feedin_titles
	set pagecount = replace(pagecount,'vii+','')

	update feedin_titles
	set pagecount = replace(pagecount,'viii+','')

	update feedin_titles
	set pagecount = replace(pagecount,'ix+','')

	update feedin_titles
	set pagecount = replace(pagecount,'x+','')

	update feedin_titles
	set pagecount = replace(pagecount,'xi+','')

	update feedin_titles
	set pagecount = replace(pagecount,'xii+','')

	update feedin_titles
	set pagecount = replace(pagecount,'xiii+','')

	update feedin_titles
	set pagecount = replace(pagecount,'xiv+','')

	update feedin_titles
	set pagecount = replace(pagecount,'xv+','')

	update feedin_titles
	set pagecount = replace(pagecount,'xvi+','')

	update feedin_titles
	set pagecount = replace(pagecount,'xvii+','') 

	update feedin_titles
	set pagecount = replace(pagecount,'xviii+','')

	update feedin_titles
	set pagecount = replace(pagecount,'xix+','')

	update feedin_titles
	set pagecount = replace(pagecount,'xx+','')

	update feedin_titles
	set pagecount = replace(pagecount,'v','')

	update feedin_titles
	set pagecount = replace(pagecount,'vi','')

	update feedin_titles
	set pagecount = replace(pagecount,'vii','')

	update feedin_titles
	set pagecount = replace(pagecount,'x','')

	update feedin_titles
	set pagecount = replace(pagecount,'xv','')

	update feedin_titles
	set pagecount = replace(pagecount,'xvii','')

	update feedin_titles
	set pagecount = replace(pagecount,'ii','')

	update feedin_titles
	set pagecount = replace(pagecount,'in 2 ol.','')

	update feedin_titles
	set pagecount = replace(pagecount,'each','')

	update feedin_titles
	set pagecount = replace(pagecount,'380/400','380')

	update feedin_titles
	set pagecount = ltrim(pagecount)


	update feedin_titles
	set trimsize = replace(trimsize,'¼',' 1/2')

	update feedin_titles
	set trimsize = replace(trimsize,'½',' 1/2') 

	update feedin_titles
	set trimsize = replace(trimsize,'¾',' 3/4') 

	update feedin_titles
	set trimsize = replace(trimsize, '  ',' ')

	update feedin_titles
	set isbn = replace(isbn,'x','X')

	update feedin_titles
	set errormessages = 'INVALID ISBN'
	where isbn in ('034793190','078317766','08801008X','094598xxxx','09459xxxx',
				'09459xxxxx','096156970','853155836','delete','na1','na2','na3','na4','XXX1897417','0945984xxx') 
				OR len(isbn) <> 10

/*9-28-04  change empty values to null here so no change required to syntax below*/

	update feedin_titles
	set colorphotos = null
	  where colorphotos = ''

	update feedin_titles
	set colorillustrations = null
	  where colorillustrations = ''

	update feedin_titles
	set bandwphotos = null
	  where bandwphotos = ''

	update feedin_titles
	set bandwillustrations = null
	  where bandwillustrations = ''

	update feedin_titles
	set linedrawings = null
	  where linedrawings = ''

	update feedin_titles
	set watercolorillustrations = null
	  where watercolorillustrations = ''

	update feedin_titles
	set charts = null
	  where charts = ''

	update feedin_titles
	set tables = null
	  where tables = ''

	update feedin_titles
	set graphs = null
	  where graphs = ''

	update feedin_titles
	set diagrams = null
	  where diagrams = ''

	update feedin_titles
	set maps = null
	  where maps = ''

	update feedin_titles
	set screenshots = null
	  where screenshots = ''

 	update feedin_titles
	set codesamples = null
	  where codesamples = ''

	update feedin_titles
	set twocolorinterior = null
	  where twocolorinterior = ''

	update feedin_titles
	set fourcolorinterior = null
	  where fourcolorinterior = ''

	update feedin_titles
	set incatalog = null
	  where incatalog = ''

	update feedin_titles
	set onorderform = null
	  where onorderform = ''

/*get default page count*/
	select @i_count = 0

	select @i_count = optionvalue from clientoptions
		where optionid = 4  /*9-9-03 clientoptions pagecount*/
	if @i_count = 1
	  begin
		select @page_opt = 1 /* 1 tmmpagecount otherwise pagecount*/  
	 end

/*get default trim*/
	select @i_count = 0

	select @i_count = optionvalue from clientoptions
		where optionid = 7  /*9-9-03 clientoptions trim*/

	if @i_count = 1
	  begin
		select @trim_opt = 1 /* 1 tmmactualtrimlength/width otherwise trimsizelength/width*/  
	 end

/*get default currency and pricetypecode*/
	select @i_count = 0
	select @i_count = count(*) from filterpricetype
		where filterkey = 5 /*currency and price types*/

	if @i_count > 0 
	 begin
		select @i_pricecode= pricetypecode, @i_currencycode = currencytypecode
			 from filterpricetype
			where filterkey = 5 /*currency and price types*/
	 end

/* convert columns from colorphotos to codesamples to int or float*/

DECLARE feed_titles INSENSITIVE CURSOR
FOR
	SELECT id,incatalog,onorderform,fnb,season,status,catalog,publication_year,slot,titleprefix,
title,subtitle,edition,volume,seriestitle,  
author1firstname,author1lastname,author1city,author1state,author2firstname,  
author2lastname,author2city,author2state,author3firstname,author3lastname,  
author3city,author3state,author4firstname,author4lastname,author4city,author4state,  
editor1firstname,editor1lastname,editor1city,editor1state,editor2firstname,editor2lastname,  
editor2city,editor2state,forewordfirstname,forewordlastname,forewordcity,forewordstate,  	
prefacefirstname,prefacelastname,prefacecity,prefacestate,afterwordfirstname,afterwordlastname,  	
afterwordcity,afterwordstate,translatorfirstname,translatorlastname,translatorcity,translatorstate,  
photographerfirstname,photographerlastname,photographercity,photographerstate,illustratorfirstname,  	
illustratorlastname,illustratorcity,illustratorstate,otherfirstname,otherlastname,othercity,  	
otherstate,publishername,imprintname,binding,pagecount,trimsize,convert(float,colorphotos) colorphotos,
convert(float,colorillustrations)colorillustrations,convert(float,bandwphotos) bandwphotos,
convert(float,bandwillustrations) bandwillustrations,convert(float,linedrawings) linedrawings,
convert(float,watercolorillustrations) watercolorillustrations,convert(int,charts) charts,
convert(int,tables) tables,convert(int,graphs) graphs,convert(int,diagrams) diagrams,  
convert(int,maps) maps,convert(int,screenshots) screenshots, convert(int,codesamples) codesamples,
agerange,includesdisk,includescdrom,includesaudiocd,twocolorinterior,fourcolorinterior,
isbn,price,canadianprice,publicationmonth,subjectcategorya,subjectcategoryb,copylong,toc,
quote,authbio,rights,oldisbn,othertitle1,otherpub1,otherisbn1,otherprice1,otherdate1,othertitle2,otherpub2,  
otherisbn2,otherprice2,otherdate2,othertitle3,otherpub3,otherisbn3,otherprice3,otherdate3,  
differences,translation,origtitle,otherinseries2,seriestitles,keybenefit1,keybenefit2,  
keybenefit3,about_technology,define_audience,clothisbn,clothinprint,origlangisbn,pricelastsold,
bisacsubjectcode, audience, discount, barcodetype, barcodeposition, convert(int, cartonqty), convert(float, bookweight)
	FROM feedin_titles
	WHERE errormessages is NULL 

FOR READ ONLY

OPEN feed_titles


FETCH NEXT FROM feed_titles
into @i_id,@c_incatalog,@c_onorderform,@c_fnb,@c_season,@c_status,@c_catalog,@i_publication_year,@c_slot,
@c_titleprefix,@c_title, @c_subtitle,@c_edition,@i_volume,@c_seriestitle,  
@c_author1firstname,@c_author1lastname,@c_author1city,@c_author1state,@c_author2firstname,  
@c_author2lastname,@c_author2city,@c_author2state,@c_author3firstname,@c_author3lastname,  
@c_author3city,@c_author3state,@c_author4firstname,@c_author4lastname,@c_author4city,@c_author4state,  
@c_editor1firstname,@c_editor1lastname,@c_editor1city,@c_editor1state,@c_editor2firstname,@c_editor2lastname,  
@c_editor2city,@c_editor2state,@c_forewordfirstname,@c_forewordlastname,@c_forewordcity,@c_forewordstate,  	
@c_prefacefirstname,@c_prefacelastname,@c_prefacecity,@c_prefacestate,@c_afterwordfirstname,@c_afterwordlastname,  	
@c_afterwordcity,@c_afterwordstate,@c_translatorfirstname,@c_translatorlastname,@c_translatorcity,@c_translatorstate,  
@c_photographerfirstname,@c_photographerlastname,@c_photographercity,@c_photographerstate,@c_illustratorfirstname,  	
@c_illustratorlastname,@c_illustratorcity,@c_illustratorstate,@c_otherfirstname,@c_otherlastname,@c_othercity,  	
@c_otherstate,@c_publishername,@c_imprintname,@c_binding,@c_pagecount,@c_trimsize,@i_colorphotos,@i_colorillustrations, 
@i_bandwphotos,@i_bandwillustrations,@i_linedrawings,@i_watercolorillustrations,@i_charts,@i_tables,@i_graphs,@i_diagrams,  
@i_maps,@i_screenshots,@i_codesamples,@c_agerange,@c_includesdisk,@c_includescdrom,@c_includesaudiocd,@c_twocolorinterior,  
@c_fourcolorinterior,@c_isbn10,@c_price,@c_canadianprice,@c_publicationmonth,@c_subjectcategorya,@c_subjectcategoryb,  
@c_copylong,@c_toc,@c_quote,@c_authbio,@c_rights,@c_oldisbn, 
@c_othertitle1,@c_otherpub1,@c_otherisbn1,@c_otherprice1,@c_otherdate1,@c_othertitle2,@c_otherpub2,  
@c_otherisbn2,@c_otherprice2,@c_otherdate2,@c_othertitle3,@c_otherpub3,@c_otherisbn3,@c_otherprice3,@c_otherdate3,  
@c_differences,@c_translation,@c_origtitle,@c_otherinseries2,@c_seriestitles,@c_keybenefit1,@c_keybenefit2,  
@c_keybenefit3,@c_about_technology,@c_define_audience,@c_clothisbn,@c_clothinprint,@c_origlangisbn,@c_pricelastsold,
@c_bisacsubjectcode, @c_audience, @c_discount, @c_barcodetype, @c_barcodeposition, @c_cartonqty, @c_bookweight

SELECT  @i_ti_cursor_status = @@FETCH_STATUS

if @i_ti_cursor_status<> 0 /*no titles*/
begin	
	insert into feederror 										
		(batchnumber,processdate,errordesc)
		values ('3',@d_currentdate,'NO ROWS to PROCESS')
end
WHILE (@i_ti_cursor_status <> -1)
	BEGIN 
		IF (@i_ti_cursor_status <> -2)
			BEGIN
/*clear variables*/
			select @feedin_bookkey = 0
			select @c_trimwidth = ''
			select @i_count = 0
			select @c_trimtrimsize = ''
			select @c_trimlength  = ''
			select @c_trimwidth = ''
			select @c_isbn13 = ''
			select @i_slotcode = 0
			select @i_titletypecode = 0
			select @d_pubyear_to_date = ''
			select @i_editioncode = 0
			select @i_seriescode = 0
			select @i_orglevelkey_2 = 0
			select @i_orglevelkey_3 = 0
			select @i_rejected = 0
			select @i_mediatypecode = 0
			select @i_mediatypesubcode = 0
			select @c_illus = ''
			select @i_twocolor = 0
			select @i_fourcolor = 0
			select @f_usprice = 0
			select @f_canadianprice = 0
			select @i_subjectacode = 0
			select @i_subjectbcode = 0
			select @i_territorycode = 0
			select @i_bisacstatuscode = 0
			select @i_incat = null
			select @i_onorderform = null
			select @i_fnbcode = 0
			select @i_seasonkey = 0
			select @i_pages = 0
			select @feedin_temp_isbn = ''
			select @feedin_isbn_prefix = ''
 			select @bookwasupdatedind = 0
			select @bookwasinsertind = 0
			select @bookwasrejectedind = 0
			select @i_audiencecode = 0
			select @i_subcode = 0
			select @i_discountcode = 0


	/** Increment Title Count, Print Status every 500 rows **/
				select @titlecount=@titlecount + 1
				select @titlecountremainder=0
				select @titlecountremainder = @titlecount % 500
				if(@titlecountremainder = 0)
				  begin
					select @titlestatusmessage =  convert (varchar (50),getdate()) + '   ' + convert (varchar (10),@titlecount) + '   Rows Processed'
					print @titlestatusmessage
					insert into feederror 										
					  (batchnumber,processdate,errordesc)
					values ('3',@d_currentdate,@titlestatusmessage)
				end 
				
/*get isbn 13*/

        SET @c_isbn10 = RTRIM(LTRIM(@c_isbn10))
        SET @feed_isbn = @c_isbn10
				
				if len(@feed_isbn) = 0 
				 begin
					select @feed_isbn = 'NO ISBN'

					insert into feederror 							
					  (isbn,batchnumber,processdate,errordesc)
					values (@feed_isbn,'3',@d_currentdate,('NO ISBN ENTERED ' + @feed_isbn))
			
					update feederror 
					set detailtype = (detailtype + 1)
					where batchnumber='3'
						  and processdate > = @d_currentdate
						 and errordesc LIKE 'Feed Summary: Rejected%'
	 			  end	
				else
				  begin

          -- 1/4/07 - KW - The isbn_13 procedure name is misleading - it returns ISBN-10 with dashes, not ISBN-13.
          -- NOTE: Beginning w/version 6.3 there is no need for isbn_13 function - call validate_product procedure instead.
					EXEC isbn_13 @c_isbn10, @c_isbn13 OUTPUT

					if len(@c_isbn13) = 0 
					 begin

						insert into feederror 			
						 (isbn,batchnumber,processdate,errordesc)
						values (@feed_isbn,'3',@d_currentdate,('NO ISBN ENTERED ' + @feed_isbn))

						update feederror 
						  set detailtype = (detailtype + 1)
						    where batchnumber='3'
							and processdate > = @d_currentdate
						 	and errordesc LIKE 'Feed Summary: Rejected%'
					 end
					end

					if len(@c_isbn13) = 13 
					  begin

/*-------------- intialize data for new or old ------------------------------------------------------*/
						select @feedin_bookkey = bookkey 
						from isbn 
						where isbn10 = @c_isbn10
						
						if @feedin_bookkey is null
						  begin
							select @feedin_bookkey = 0	/*new title title*/
						  end


/* publisher->orgentry.orglevelkey=2*/
					if @c_publishername is null 
	 			  	  begin
						select @c_publishername = ''
				 	 end
					if len(@c_publishername) > 0
					  begin
						 select @i_count = 0

						select @i_count = count(*)
						  from orgentry
							where rtrim(upper(orgentrydesc))= rtrim(upper(@c_publishername))
							  and orglevelkey=2
						if @i_count > 0 
						  begin
							select @i_orglevelkey_2 = orgentrykey
						  	 from orgentry
							   where rtrim(upper(orgentrydesc) )= rtrim(upper(@c_publishername))
							     and orglevelkey=2
						  end
						else
						  begin	
							insert into feederror 
							  (isbn,batchnumber,processdate,errordesc)
							values (@feed_isbn,'3',@d_currentdate,'Publisher missing title will not be added if this is a new title ' + @c_publishername)
							
						  end
					  end
					else
					    begin	
						insert into feederror 
						  (isbn,batchnumber,processdate,errordesc)
						values (@feed_isbn,'3',@d_currentdate,'Publisher missing title will not be added if this is a new title ' + @c_publishername)
							
					 end
/* imprint->orgentry.orglevelkey=3*/			
					if @c_imprintname is null 
	 			  	  begin
						select @c_imprintname = ''
				 	 end
					if len(@c_imprintname) > 0
					  begin
					 	select @i_count = 0

						select @i_count = count(*)
						  from orgentry
							where rtrim(upper(orgentrydesc) )= rtrim(upper(@c_imprintname))
							  and orglevelkey=3
						if @i_count > 0 
						  begin
							select @i_orglevelkey_3 = orgentrykey
						  	 from orgentry
							   where rtrim(upper(orgentrydesc) )= rtrim(upper(@c_imprintname))
							     and orglevelkey=3
						end	
					 end

					 if  @i_orglevelkey_3 = 0 and @i_orglevelkey_2 > 0
					    begin /* no imprint see if only 1 imprint row exists for this publisher and use*/
					 		
						select @i_count = 0
						select @i_count = count(*) from orgentry where orgentryparentkey = @i_orglevelkey_2 and orglevelkey=3
						if @i_count = 1
						  begin
							select @i_orglevelkey_3 = orgentrykey from orgentry where orgentryparentkey = @i_orglevelkey_2 and orglevelkey=3
						  end	
						 else
						  begin	
							insert into feederror 
							  (isbn,batchnumber,processdate,errordesc)
							values (@feed_isbn,'3',@d_currentdate,'Imprint missing title will not be added if this is a new title ' + @c_imprintname)
						end						
					end	
					
					if  @i_orglevelkey_3 >0
					  begin  /*make sure relationship correct*/
						if @i_orglevelkey_2 > 0
						  begin
							select  @i_oldcode = 0
							select @i_oldcode = orgentryparentkey from orgentry where  orgentrykey=  @i_orglevelkey_3
 
							if @i_oldcode <> @i_orglevelkey_2 and @i_oldcode > 0
							    begin
								insert into feederror 
								  (isbn,batchnumber,processdate,errordesc)
								values (@feed_isbn,'3',@d_currentdate,'WARNING  Publisher/imprint for title does not match ORGENTRY TABLE imprint = ' + @c_imprintname)
							
								select  @i_orglevelkey_2 = 0
								select  @i_orglevelkey_3  =0
							   end
						  end
						else
						  begin  /*publisher not given so make sure use parent of imprint*/
							select @i_orglevelkey_2 = @i_oldcode
						  end
					  end

/*incatalog yes/no*/
						if upper(rtrim(ltrim(@c_incatalog))) = 'YES'
						  begin
							select @i_incat = 1
						  end
						if upper(rtrim(ltrim(@c_incatalog))) = 'NO'
						  begin
							select @i_incat = 0
						  end
						if @c_incatalog is null
						  begin
							select @i_incat = null
						  end

/*onorderform*/
						if upper(rtrim(ltrim(@c_onorderform))) = 'YES'
						  begin
							select @i_onorderform = 1
						  end
						if upper(rtrim(ltrim(@c_onorderform))) = 'NO'
						  begin
							select @i_onorderform = 0
						  end
						if @c_onorderform is null
						  begin
							select @i_onorderform = null
						  end

/*fnb=417*/

						if @c_fnb is null 
						  begin
							select @c_fnb = ''
						  end
						if len(@c_fnb) > 0
						  begin
							select @i_count = 0

							select @i_count = count(*)
							  from gentables
								where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_fnb)),1,40)
								and tableid=417 

							if @i_count > 0 
							  begin
								select @i_fnbcode  = datacode
								  from gentables
								   where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_fnb)),1,40)
								   and tableid=417 
							  end
							else
							 begin
							  	EXEC feed_insert_gentables 417, @c_fnb,@c_lastuserid,@i_fnbcode OUTPUT  
							  end
						  end
 			
/*season update printing.seasonkey*/	
						if @c_season is null 
						  begin
							select @c_season = ''
						  end
						if len(@c_season) > 0
						  begin
							select @i_count = 0

							select @i_count = count(*)
							  from season
								where rtrim(upper(seasondesc) )= substring(rtrim(upper(@c_season)),1,80)

							if @i_count > 0 
							  begin
								select @i_seasonkey = seasonkey
								  from season
								   where rtrim(upper(seasondesc) )= substring(rtrim(upper(@c_season)),1,80)
							  end
							else
							 begin
							  	insert into feederror 
						 		 (isbn,batchnumber,processdate,errordesc)
								values (@feed_isbn,'3',@d_currentdate,'Season not on Season table, seasonkey not updated')
							  end
						end
/* catalog -- titletype 132*/

						if @c_catalog is null 
						  begin
							select @c_catalog = ''
						  end
						if len(@c_catalog) > 0
						  begin
							select @i_count = 0

							select @i_count = count(*)
							  from gentables
								where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_catalog)),1,40)
								and tableid=132 

							if @i_count > 0 
							  begin
								select @i_titletypecode  = datacode
								  from gentables
								   where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_catalog)),1,40)
								   and tableid=132 
							  end
							else
							 begin
							  	EXEC feed_insert_gentables 132, @c_catalog,@c_lastuserid,@i_titletypecode OUTPUT  
							  end
 					 	end

/* publication year and month will -- update printing.pubmonth*/
						if @i_publication_year is null 
						  begin
							select @i_publication_year = 0
						  end
						if @c_publicationmonth is null 
						  begin
							select @c_publicationmonth = ''
						  end
						if @i_publication_year > 0 and len(@c_publicationmonth)> 0
						  begin
							select @d_pubyear_to_date = convert(datetime,(@c_publicationmonth + ' 01 '+ convert(varchar,@i_publication_year)),110)
						  end
 /*slot=102*/

						if @c_slot is null 
						  begin
							select @c_slot = ''
						  end
						if len(@c_slot) > 0
						  begin
							select @i_count = 0

							select @i_count = count(*)
							  from gentables
								where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_slot)),1,40)
								and tableid=102 

							if @i_count > 0 
							  begin
								select @i_slotcode  = datacode
								  from gentables
								   where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_slot)),1,40)
								   and tableid=102 
							  end
							else
							 begin
							  	EXEC feed_insert_gentables 102, @c_slot,@c_lastuserid,@i_slotcode OUTPUT  
							  end
						  end
 					
 /*edition=200*/		
						if @c_edition is null 
						  begin
							select @c_edition = ''
						  end
						if len(@c_edition) > 0
						  begin
							select @i_count = 0

							select @i_count = count(*)
							  from gentables
								where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_edition)),1,40)
								and tableid=200 

							if @i_count > 0 
							  begin
								select @i_editioncode  = datacode
								  from gentables
								   where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_edition)),1,40)
								   and tableid=200 
							  end
							else
							 begin
							  	EXEC feed_insert_gentables 200, @c_edition,@c_lastuserid,@i_editioncode OUTPUT  
							  end
						  end				
/*series=327*/		
						if @c_seriestitle is null 
						  begin
							select @c_seriestitle = ''
						  end
						if len(@c_seriestitle) > 0
						  begin
							select @i_count = 0

							select @i_count = count(*)
							  from gentables
								where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_seriestitle)),1,40)
								and tableid=327 

							if @i_count > 0 
							  begin
								select @i_seriescode  = datacode
								  from gentables
								   where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_seriestitle)),1,40)
								   and tableid=327 
							  end
							else
							 begin
							  	EXEC feed_insert_gentables 327, @c_seriestitle,@c_lastuserid,@i_seriescode OUTPUT  
							  end	
						  end
/* trim separate length and width*/
					if @c_trimsize  is not null
					  begin   
						select @i_count = 0
						select @i_count = charindex('X',upper(@c_trimsize))
						if @i_count >0
			  			 begin
							select @c_trimwidth = substring(@c_trimsize,1,(@i_count -1))
							select @c_trimlength = substring(@c_trimsize,(@i_count + 1),20)
						end
			   		  end
					else
		  			  begin
						select @c_trimwidth = substring(@c_trimsize,1,10)
			  		 end
/*bisacstatus -- 314*/
					if @c_status is null 
		 			  begin
						select @c_status = ''
					  end
					if len(@c_status) > 0
					  begin
						select @i_count = 0
	
						select @i_count = count(*)
						  from gentables
							where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_status)),1,40)
							and tableid=314 
	
							if @i_count > 0 
							 begin
								select @i_bisacstatuscode  = datacode
								 from gentables
								 where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_status)),1,40)
								 and tableid=314 
							 end
							else
							 begin
								  EXEC feed_insert_gentables 314, @c_status,@c_lastuserid,@i_bisacstatuscode OUTPUT  
							 end	
					end
/*audiencecode -- 460*/
					if @c_audience is null 
		 			  begin
						select @c_audience = ''
					  end
					if len(@c_audience) > 0
					  begin
						select @i_count = 0
	
						select @i_count = count(*)
						  from gentables
							where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_audience)),1,40)
							and tableid=460
	
							if @i_count > 0 
							 begin
								select @i_audiencecode  = datacode
								 from gentables
								 where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_audience)),1,40)
								 and tableid=460 
							 end
							else
							 begin
								  EXEC feed_insert_gentables 460, @c_audience,@c_lastuserid,@i_audiencecode OUTPUT  
							 end	
					end
/*discountcode -- 459*/
					if @c_discount is null 
		 			  begin
						select @c_discount = ''
					  end
					if len(@c_discount) > 0
					  begin
						select @i_count = 0
	
						select @i_count = count(*)
						  from gentables
							where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_discount)),1,40)
							and tableid=459
	
							if @i_count > 0 
							 begin
								select @i_discountcode = datacode
								 from gentables
								 where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_discount)),1,40)
								 and tableid=459 
							 end
							else
							 begin
								  EXEC feed_insert_gentables 460, @c_discount,@c_lastuserid,@i_discountcode OUTPUT  
							 end	
					end




/*author information will be done in the stored procedure feed_load_contributors_updates_sp*/
 


/* binding->media/format*/
					if @c_binding is null
					  begin
						select @c_binding = ''
					  end

					if len(@c_binding) > 0
					  begin
						select @i_count = 0
						select @i_count = count(*)
						  from subgentables
							where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_binding)),1,120)
							 and tableid=312 
						if @i_count >0
						  begin
							select @i_mediatypecode  = datacode, @i_mediatypesubcode  = datasubcode
							  from subgentables
								where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_binding)),1,120)
								 and tableid=312 
						  end
						else
						  begin  /*default to other*/
							select @i_mediatypecode = 10
							select @i_mediatypesubcode = null
	
							insert into feederror 
							  (isbn,batchnumber,processdate,errordesc)
							values (@feed_isbn,'3',@d_currentdate,'Binding/Format missing, default to other')
						 end
					 end
			
/*illus act -> combine includesdisk,includescdrom,includesaudiocd*/

					if @c_includesdisk is null
					  begin
						select @c_includesdisk = ''
					  end

					if @c_includescdrom is null
					  begin
						select @c_includescdrom = ''
					  end
					if @c_includesaudiocd is null
					  begin
						select @c_includesaudiocd = ''
					  end
				   	if len(@c_includesdisk) > 0
					  begin
						select @c_illus = 'includesaudiocd '+ @c_includesdisk + ' '
					  end 
					if len(@c_includescdrom) > 0
					  begin
						select @c_illus = @c_illus + ' includescdrom ' + @c_includescdrom + ' '
					  end 
					if len(@c_includesaudiocd) > 0
					  begin
						select @c_illus = @c_illus +  ' includesaudiocd ' +@c_includesaudiocd + ' '
					  end 
				
					if len(@c_illus) > 0
					  begin
						select @c_illus = rtrim(ltrim(@c_illus))
					  end	
/*colors*/
					if upper(rtrim(ltrim(@c_twocolorinterior))) = 'YES'
					  begin
						select @i_twocolor = 1
					  end
					if upper(rtrim(ltrim(@c_twocolorinterior))) = 'NO'
					  begin
						select @i_twocolor = 0
					  end
					if @c_twocolorinterior is null
					  begin
						select @i_twocolor = null
					  end
					if upper(rtrim(ltrim(@c_fourcolorinterior))) = 'YES' 
					  begin
						select @i_fourcolor= 1
					  end
					if upper(rtrim(ltrim(@c_fourcolorinterior))) = 'NO' 
					  begin
						select @i_fourcolor= 0
					  end
					if @c_fourcolorinterior is null 
					  begin
						select @i_fourcolor=  null
					  end
/* prices*/
					if len(@c_price) > 0 
					  begin
						select @i_count = 0
						select @c_price = replace(@c_price,'$','')
						select @i_count = ISNUMERIC(@c_price)
						if @i_count > 0
						  begin
							select @f_usprice = rtrim(convert(float,@c_price))
						  end
						else
						  begin
							select @f_usprice = 0
							insert into feederror 							
							  (isbn,batchnumber,processdate,errordesc)
							values (@feed_isbn,'3',@d_currentdate,('List Price not numeric ' + @c_price))
				
						  end
					  end 

					if len(@c_canadianprice) > 0 
					  begin
						select @i_count = 0
						select @c_canadianprice = replace(@c_canadianprice,'$','')
						select @i_count = ISNUMERIC(@c_canadianprice)
						if @i_count > 0
						  begin
							select @f_canadianprice = rtrim(convert(float,@c_canadianprice))
						  end
						else
						  begin
							select @f_canadianprice = 0
							insert into feederror (isbn,batchnumber,processdate,errordesc)
							values (@feed_isbn,'3',@d_currentdate,('Canadian Price not numeric ' + @c_canadianprice))
						  end
					end	
/*subjecta=423 subjectb = 424*/
					if @c_subjectcategorya is null 
					  begin
						select @c_subjectcategorya = ''
					  end
					if len(@c_subjectcategorya) > 0
				  	  begin
						select @i_count = 0

						select @i_count = count(*)
						  from gentables
							where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_subjectcategorya)),1,40)
							and tableid=423 
						if @i_count > 0 
						  begin
							select @i_subjectacode  = datacode
							  from gentables
							   where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_subjectcategorya)),1,40)
							   and tableid=423 
						  end
						else
						 begin
						  	EXEC feed_insert_gentables 423, @c_subjectcategorya,@c_lastuserid,@i_subjectacode OUTPUT  
						  end
					  end

					if @c_subjectcategoryb is null 
					  begin
						select @c_subjectcategoryb = ''
					  end
					if len(@c_subjectcategoryb) > 0
				  	  begin
						select @i_count = 0

						select @i_count = count(*)
						  from gentables
							where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_subjectcategoryb)),1,40)
							and tableid=424 
						if @i_count > 0 
						  begin
							select @i_subjectbcode  = datacode
							  from gentables
							   where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_subjectcategoryb)),1,40)
							   and tableid=424
						  end
						else
						 begin
						  	EXEC feed_insert_gentables 424, @c_subjectcategoryb,@c_lastuserid,@i_subjectbcode OUTPUT  
						  end
					  end
/*territory = 131*/
					if @c_rights is null 
					  begin
						select @c_rights = ''
					  end
					if len(@c_rights) > 0
				  	  begin
						select @i_count = 0

						select @i_count = count(*)
						  from gentables
							where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_rights)),1,40)
							and tableid=131 
						if @i_count > 0 
						  begin
							select @i_territorycode  = datacode
							  from gentables
							   where rtrim(upper(datadesc) )= substring(rtrim(upper(@c_rights)),1,40)
							   and tableid=131
						  end
						else
						 begin
						  	EXEC feed_insert_gentables 131, @c_rights,@c_lastuserid,@i_territorycode OUTPUT  
						  end
					  end


/* --------------start updating existing title  record --update all fields--------------------------------------------*/					
	if @feedin_bookkey = 0 and @i_orglevel1key > 0 and @i_orglevelkey_2 > 0 and @i_orglevelkey_3 > 0 and len(@c_isbn13) = 13 
	  begin  
	/* before insert make sure all these fields have valid data orglevels etc*/

		select @bookwasinsertind=1

        	UPDATE keys SET generickey = generickey+1, 
			 lastuserid = 'QSIADMIN', 
			lastmaintdate = getdate()

		select @feedin_bookkey = generickey from Keys

/* get isbn prefix code by stripping off values to the second '-'*/
		select @i_count = 0
		select @i_count = charindex('-', @c_isbn13)
		select @i_count = @i_count + 1
		select @feedin_temp_isbn = substring(@c_isbn13,@i_count,13)
		select @i_oldcode = 0
		select @i_oldcode = charindex('-', @feedin_temp_isbn)
		select @i_count = @i_count + @i_oldcode
		select @i_count = @i_count -2
		select @feedin_temp_isbn = substring(@c_isbn13,1,@i_count)

		select @feedin_isbn_prefix= datacode  
			from subgentables
			where datadesc = @feedin_temp_isbn
				and tableid=138 and datacode=1
		
		if @feedin_isbn_prefix is null
		  begin
			select @feedin_isbn_prefix = 0
		  end
		if @feedin_isbn_prefix = 0
		  begin
         		insert into feederror 							
			  (isbn,batchnumber,processdate,errordesc)
			values (@feed_isbn,'3',@d_currentdate,('No Prefix code on Gentables ' + @feed_isbn))			
		  end
				
	  SET @c_ean = NULL
	  SET @c_gtin = NULL
	  SET @c_ean13 = NULL
	  SET @c_gtin14 = NULL
				
	  -- 1/4/07 - KW - Generate EAN/ISBN-13 for ISBN-10 value
	  SET @c_ean = dbo.ean_from_isbn(@c_isbn13)
	  	  
	  IF LEN(@c_ean) > 0
	    BEGIN	  
	      SET @c_gtin = '0-' + @c_ean
	      SET @c_ean13 = REPLACE(@c_ean, '-', '')
	      SET @c_gtin14 = REPLACE(@c_gtin, '-', '')
	    END
	  ELSE
	    INSERT INTO feederror (isbn,batchnumber,processdate,errordesc)
	    VALUES (@feed_isbn,'3',@d_currentdate,'Could not generate EAN/ISBN-13 and GTIN')
	    
	  -- 1/4/07 - KW - Insert to titlehistory for ISBN-10 (43), EAN/ISBN-13 (45) and GTIN (228) columns
		EXEC dbo.titlehistory_insert 43, @feedin_bookkey, 0, '', @c_isbn13, 1
		IF LEN(@c_ean) > 0 BEGIN
		  EXEC dbo.titlehistory_insert 45, @feedin_bookkey, 0, '', @c_ean, 1
		  EXEC dbo.titlehistory_insert 228, @feedin_bookkey, 0, '', @c_gtin, 1
		END

    insert into isbn
      (bookkey, isbnkey, eanprefixcode, isbnprefixcode, 
      isbn, isbn10, ean, ean13, gtin, gtin14, lastuserid, lastmaintdate)
    values 
      (@feedin_bookkey, @feedin_bookkey, 1, @feedin_isbn_prefix,
      @c_isbn13, @c_isbn10, @c_ean, @c_ean13, @c_gtin, @c_gtin14, @c_lastuserid, @d_currentdate)

		
		-- 1/5/07 - KW - Write titlehistory for group levels (bookorgentry records)
    EXEC dbo.titlehistory_insert 23, @feedin_bookkey, 0, '1', @c_grouplevel1, 1

    insert into bookorgentry 
      (bookkey, orglevelkey, orgentrykey, lastuserid, lastmaintdate)
    values 
      (@feedin_bookkey, 1, @i_orglevel1key, @c_lastuserid, @d_currentdate)

    EXEC dbo.titlehistory_insert 23, @feedin_bookkey, 0, '2', @c_publishername, 1

    insert into bookorgentry 
      (bookkey, orglevelkey, orgentrykey, lastuserid, lastmaintdate)
    values 
      (@feedin_bookkey, 2, @i_orglevelkey_2, @c_lastuserid, @d_currentdate)

		EXEC dbo.titlehistory_insert 23, @feedin_bookkey, 0, '3', @c_imprintname, 1

    insert into bookorgentry 
      (bookkey, orglevelkey, orgentrykey, lastuserid, lastmaintdate)
    values 
      (@feedin_bookkey, 3, @i_orglevelkey_3, @c_lastuserid, @d_currentdate)

   /*  make workkey the same as bookkey*/
        	 insert into book
           	 (bookkey,lastmaintdate,titlestatuscode,standardind,titlesourcecode,creationdate,lastuserid,workkey)
          	 values (@feedin_bookkey,@d_currentdate,2,'N',3,@d_currentdate,@c_lastuserid,@feedin_bookkey)

  		insert into printing 
		 (bookkey,printingkey,seasonkey,creationdate,specind,lastuserid,lastmaintdate,
		  printingnum,jobnum, printingjob,pubmonth,pubmonthcode) 
   		values (@feedin_bookkey,1,@i_seasonkey,@d_currentdate,0,@c_lastuserid,@d_currentdate,1,1,'1',
          	   @d_pubyear_to_date,convert(int,substring(convert(varchar,@d_pubyear_to_date,110),1,2))) 

		insert into bookcustom (bookkey) values (@feedin_bookkey)
		insert into bookdetail (bookkey) values (@feedin_bookkey)
		insert into booksimon (bookkey) values (@feedin_bookkey)
		insert into bindingspecs (bookkey,printingkey,vendorkey) values (@feedin_bookkey,1,0)

	end  /*bookkey= 0*/

	if @feedin_bookkey > 0 
	  begin

/* make sure bookdetail,bookcustom,book and printing exists*/

		select @i_count = 0
		select @i_count = count(*) from book where bookkey = @feedin_bookkey
		if @i_count = 0
		  begin
			insert into book (bookkey) values (@feedin_bookkey)
		  end
		select @i_count = 0
		select @i_count = count(*) from bookdetail where bookkey = @feedin_bookkey
		if @i_count = 0
		  begin
			insert into bookdetail (bookkey) values (@feedin_bookkey)
		  end

		select @i_count = 0
		select @i_count = count(*) from bookcustom where bookkey = @feedin_bookkey
		if @i_count = 0
		  begin
			insert into bookcustom (bookkey) values (@feedin_bookkey)
		  end
		select @i_count = 0
		select @i_count = count(*) from printing where printingkey = 1 and bookkey = @feedin_bookkey
		if @i_count = 0
		  begin
			insert into printing (bookkey,printingkey,printingnum,jobnum, printingjob) values (@feedin_bookkey,1,1,1,'1')
		  end

		select @i_count = 0
		select @i_count = count(*) from bindingspecs where printingkey = 1 and bookkey = @feedin_bookkey
		if @i_count = 0 and len(@c_cartonqty) > 0
		  begin
			insert into bindingspecs (bookkey,printingkey,vendorkey) values (@feedin_bookkey,1,0)
		  end

		select @i_count = 0
		select @i_count = count(*) from booksimon where bookkey = @feedin_bookkey
		if @i_count = 0
		  begin
			insert into booksimon (bookkey) values (@feedin_bookkey)
		  end

/*bisacsubjectcode*/
    if len(@c_bisacsubjectcode) > 0 begin
      SELECT @i_count = COUNT(*) FROM subgentables 
      WHERE tableid=339 AND UPPER(LTRIM(RTRIM(bisacdatacode))) = UPPER(LTRIM(RTRIM(@c_bisacsubjectcode)))
      
      IF @i_count > 0
        BEGIN
          SELECT @i_code = datacode, @i_subcode = datasubcode, @c_bisacsubdesc = LTRIM(RTRIM(datadesc))
          FROM subgentables 
          WHERE tableid=339 AND UPPER(LTRIM(RTRIM(bisacdatacode))) = UPPER(LTRIM(RTRIM(@c_bisacsubjectcode)))
          
          if len(@i_code) > 0 begin
            SELECT @i_count = COUNT(*) FROM bookbisaccategory 
            WHERE bookkey = @feedin_bookkey and printingkey = 1 and bisaccategorycode = @i_code and bisaccategorysubcode = @i_subcode
            if @i_count = 0 begin
              SELECT @c_bisacdesc = LTRIM(RTRIM(datadesc)) FROM gentables
              WHERE tableid = 339 AND datacode = @i_code
                            
              EXEC dbo.titlehistory_insert 38, @feedin_bookkey, 0, '', @c_bisacdesc, 1
              
              SET @c_bisacsubdesc = @c_bisacdesc + ' - ' + @c_bisacsubdesc                           
              EXEC dbo.titlehistory_insert 39, @feedin_bookkey, 0, '', @c_bisacsubdesc, 1
              
              insert into bookbisaccategory 
              values (@feedin_bookkey, 1, @i_code, @i_subcode, 0, @c_lastuserid, @d_currentdate)
            end
          end
        END
      ELSE
        BEGIN
          INSERT INTO feederror (isbn, batchnumber, processdate, errordesc)
          VALUES (@feed_isbn,'3',@d_currentdate,'BISAC Subject ' + @c_bisacsubjectcode + ' does not exist on subgentables 339 - could not be added to title')        
        END
    end

/*audience*/
		select @i_count = count(*) from bookaudience where bookkey = @feedin_bookkey and audiencecode = @i_audiencecode
 		if @i_count = 0 and @i_audiencecode > 0 begin
		   EXEC dbo.titlehistory_insert 91, @feedin_bookkey, 0, '', @c_audience, 1
		   
		   insert into bookaudience values (@feedin_bookkey, @i_audiencecode, 0, @c_lastuserid, @d_currentdate)
		end
		
/*discount*/
		select @i_count = count(*) from bookdetail where bookkey = @feedin_bookkey
 		if @i_count > 0  and @i_discountcode > 0 begin
		   EXEC dbo.titlehistory_insert 90, @feedin_bookkey, 0, '', @c_discount, 1
		   
		   update bookdetail 
		   set discountcode = @i_discountcode, lastmaintdate = @d_currentdate, lastuserid = @c_lastuserid
		   where bookkey = @feedin_bookkey
		end
		
/*barcodetype*/
    if len(@c_barcodetype) > 0 begin
      select @i_barcodetypecode = datacode from gentables 
      where tableid = 552 and 
        upper(ltrim(rtrim(datadesc))) = upper(ltrim(rtrim(@c_barcodetype)))
      
      if len(@i_barcodetypecode) > 0 begin
        select @i_count = count(*) from printing where bookkey = @feedin_bookkey and printingkey = 1
        if @i_count > 0 begin
          EXEC dbo.titlehistory_insert 236, @feedin_bookkey, 0, '', @c_barcodetype, 1
          
          update printing 
          set barcodeid1 = @i_barcodetypecode, lastmaintdate = @d_currentdate, lastuserid = @c_lastuserid 
          where bookkey = @feedin_bookkey and printingkey = 1
        end
      end
    end
    
/*barcodeposition*/
    if len(@c_barcodeposition) > 0 begin
      select @i_subcode = datasubcode from subgentables 
      where tableid = 552 and 
        datacode = @i_barcodetypecode and 
        upper(ltrim(rtrim(datadesc))) = upper(ltrim(rtrim(@c_barcodeposition)))
      
      if len(@i_subcode) > 0 begin
        select @i_count = count(*) from printing where bookkey = @feedin_bookkey and printingkey = 1
        if @i_count > 0 begin
          EXEC dbo.titlehistory_insert 237, @feedin_bookkey, 0, '', @c_barcodeposition, 1
          
          update printing 
          set barcodeposition1 = @i_subcode, lastmaintdate = @d_currentdate, lastuserid = @c_lastuserid 
          where bookkey = @feedin_bookkey and printingkey = 1
        end
      end
    end
    
/*cartonqty*/
		if len(@c_cartonqty) > 0 begin
		  EXEC dbo.titlehistory_insert 89, @feedin_bookkey, 0, '', @c_cartonqty, 1
		
		  update bindingspecs 
		  set cartonqty1 = @c_cartonqty, lastmaintdate = @d_currentdate, lastuserid = @c_lastuserid 
		  where bookkey = @feedin_bookkey and printingkey = 1
		end
		
/*bookweight*/
		if len(@c_bookweight) > 0 begin
		  EXEC dbo.titlehistory_insert 96, @feedin_bookkey, 0, '', @c_bookweight, 1
		  
		  update booksimon 
		  set bookweight = @c_bookweight, lastmaintdate = @d_currentdate, lastuserid = @c_lastuserid  
		  where bookkey = @feedin_bookkey		  
		end

/*book info title,subtitle,titleprefix*/
		select @c_title = ltrim(rtrim(@c_title))

	  	if len(@c_title) > 0 
		  begin
			select @c_oldchar = ''
			select @c_oldchar = upper(ltrim(rtrim(title)))
			from book
			where bookkey=@feedin_bookkey 
			
			if (@c_oldchar is null)
			begin
			    select @c_oldchar = ''
			end

			if (upper(@c_title) <>  @c_oldchar)
			begin
				select @bookwasupdatedind=1

				select @titlehistory_newvalue=NULL
				EXEC dbo.titlehistory_insert 1, @feedin_bookkey, 0, '', @c_title, 0

				update book
				  set title = @c_title,					
					lastuserid = @c_lastuserid,
					lastmaintdate = @d_currentdate
					where bookkey = @feedin_bookkey
		  end
		if len(ltrim(rtrim(@c_subtitle))) > 0 
		  begin
			select @c_subtitle = ltrim(rtrim(@c_subtitle))
			
			select @c_oldchar = ''
			select @c_oldchar = upper(ltrim(rtrim(subtitle)))
			from book
			where bookkey=@feedin_bookkey 
			
			if (@c_oldchar is null)
			 begin
			    select @c_oldchar = ''
			 end

			if (upper(@c_subtitle) <>  @c_oldchar)
			 begin
				select @bookwasupdatedind=1

				select @titlehistory_newvalue=NULL
				EXEC dbo.titlehistory_insert 3, @feedin_bookkey, 0, '', @c_subtitle, 0


				update book
				  set subtitle = @c_subtitle,
					lastuserid = @c_lastuserid,
					lastmaintdate = @d_currentdate
					where bookkey = @feedin_bookkey
			  end
		  end
		
		if len(ltrim(rtrim(@c_titleprefix))) > 0 
		  begin
			select @c_titleprefix = ltrim(rtrim(@c_titleprefix))
			
			select @c_oldchar = ''
			select @c_oldchar = upper(ltrim(rtrim(@c_titleprefix)))
			from bookdetail
			where bookkey=@feedin_bookkey 
			
			if (@c_oldchar is null)
			 begin
			    select @c_oldchar = ''
			 end

			if (upper(@c_titleprefix) <>  @c_oldchar)
			 begin
				select @bookwasupdatedind=1

				EXEC dbo.titlehistory_insert 42, @feedin_bookkey, 0, '', @c_titleprefix, 0


				update bookdetail
			 	 set titleprefix = @c_titleprefix,
					lastuserid = @c_lastuserid,
					lastmaintdate = @d_currentdate
					where bookkey = @feedin_bookkey

			end
		  end
/*orgentry*/
		if @i_orglevelkey_2 > 0 and  @i_orglevelkey_3 >0
		  begin
			select @i_oldcode = 0
			select @i_oldcode = orgentrykey
			from bookorgentry
			where bookkey=@feedin_bookkey and orglevelkey=2
			
			if (@i_oldcode is null)
			begin
			    select @i_oldcode = 0
			end

			if (@i_orglevelkey_2 <>  @i_oldcode)
			  begin
				select @bookwasupdatedind=1

				select @titlehistory_newvalue=NULL
				select @titlehistory_newvalue = convert (char (100),@i_orglevelkey_2)
				EXEC dbo.titlehistory_insert 23, @feedin_bookkey, 0, '2', @titlehistory_newvalue, 0


				update bookorgentry
				 set orgentrykey = @i_orglevelkey_2,
					lastuserid = @c_lastuserid,
					lastmaintdate = @d_currentdate
					where bookkey = @feedin_bookkey and orglevelkey=2
			  end
		
			select @i_oldcode = 0
			select @i_oldcode = orgentrykey
			from bookorgentry
			where bookkey=@feedin_bookkey and orglevelkey=3
			
			if (@i_oldcode is null)
			begin
			    select @i_oldcode = 0
			end

			if (@i_orglevelkey_3 <>  @i_oldcode)
			  begin
				select @bookwasupdatedind=1

				select @titlehistory_newvalue=NULL
				select @titlehistory_newvalue = convert (char (100),@i_orglevelkey_3)
				EXEC dbo.titlehistory_insert 23, @feedin_bookkey, 0, '3', @titlehistory_newvalue, 0

				update bookorgentry
				  set orgentrykey = @i_orglevelkey_3,
					lastuserid = @c_lastuserid,
					lastmaintdate = @d_currentdate
					where bookkey = @feedin_bookkey and orglevelkey=3
			end
		   end

/*printing season,page,trim,illus, pubmonth*/

		if @i_seasonkey > 0
		  begin
			select @bookwasupdatedind=1
			select @titlehistory_newvalue=NULL
				select @titlehistory_newvalue = convert (char (100),@i_seasonkey)
				EXEC dbo.titlehistory_insert 13, @feedin_bookkey, 0, '', @titlehistory_newvalue, 0

				update printing
				  set seasonkey= @i_seasonkey,
					lastuserid = @c_lastuserid,
					lastmaintdate = @d_currentdate
					where bookkey = @feedin_bookkey and printingkey =1
			end

		select @i_pages = convert(int,@c_pagecount)
		  if @i_pages > 0 
		    begin
			select @i_oldcode = 0
			if @page_opt = 1 
			  begin
				select @i_oldcode = tmmpagecount
				from printing
				where bookkey=@feedin_bookkey and printingkey=1
			  end
			else
			  begin
				select @i_oldcode = pagecount
				from printing
				where bookkey=@feedin_bookkey and printingkey=1
			  end
		
			if (@i_oldcode is null)
			 begin
			    select @i_oldcode = 0
			 end

			if (@i_pages <>  @i_oldcode)
			  begin
				select @bookwasupdatedind=1

				select @titlehistory_newvalue=NULL
				select @titlehistory_newvalue = convert (char (100),@i_pages)
				if @page_opt = 1
				  begin
					EXEC dbo.titlehistory_insert 88, @feedin_bookkey, 0, '', @titlehistory_newvalue, 0

					update printing
					 set tmmpagecount = @i_pages,
						lastuserid = @c_lastuserid,
						lastmaintdate = @d_currentdate
						where bookkey = @feedin_bookkey and printingkey = 1
				  end
				else
				  begin
					EXEC dbo.titlehistory_insert 16, @feedin_bookkey, 0, '', @titlehistory_newvalue, 0

					update printing
					set pagecount = @i_pages,
					lastuserid = @c_lastuserid,
					lastmaintdate = @d_currentdate
					where bookkey = @feedin_bookkey and printingkey = 1
				  end
				end
			  end

  		if len(@c_trimwidth)  > 0 
		    begin
			select @c_oldchar = ''
			if @trim_opt = 1 
			  begin
				select @c_oldchar = tmmactualtrimwidth
				from printing
				where bookkey=@feedin_bookkey and printingkey=1
			  end
			else
			  begin
				select @c_oldchar = trimsizewidth
				from printing
				where bookkey=@feedin_bookkey and printingkey=1
			  end
		
			if (@c_oldchar is null)
			 begin
			    select @c_oldchar = ''
			 end

			if (@c_trimwidth  <>  @c_oldchar)
			  begin
				select @bookwasupdatedind=1

				select @titlehistory_newvalue=NULL
				if @trim_opt = 1
				  begin
					EXEC dbo.titlehistory_insert 86, @feedin_bookkey, 0, '', @c_trimwidth, 0

					update printing
					 set tmmactualtrimwidth = @c_trimwidth,
						lastuserid = @c_lastuserid,
						lastmaintdate = @d_currentdate
						where bookkey = @feedin_bookkey and printingkey = 1
				  end
				else
				  begin
					EXEC dbo.titlehistory_insert 21, @feedin_bookkey, 0, '', @c_trimwidth, 0

					update printing
					set trimsizewidth = @c_trimwidth,
					lastuserid = @c_lastuserid,
					lastmaintdate = @d_currentdate
					where bookkey = @feedin_bookkey and printingkey = 1
				  end
				end
			  end

		if len(@c_trimlength)   > 0
		    begin
			select @c_oldchar = ''
			if @trim_opt = 1 
			  begin
				select @c_oldchar = tmmactualtrimlength
				from printing
				where bookkey=@feedin_bookkey and printingkey=1
			  end
			else
			  begin
				select @c_oldchar = trimsizelength
				from printing
				where bookkey=@feedin_bookkey and printingkey=1
			  end
		
			if (@c_oldchar is null)
			 begin
			    select @c_oldchar = ''
			 end

			if (@c_trimlength  <>  @c_oldchar)
			  begin
				select @bookwasupdatedind=1

				select @titlehistory_newvalue=NULL
				if @trim_opt = 1
				  begin
					EXEC dbo.titlehistory_insert 87, @feedin_bookkey, 0, '', @c_trimlength, 0

					update printing
					 set tmmactualtrimlength = @c_trimlength,
						lastuserid = @c_lastuserid,
						lastmaintdate = @d_currentdate
						where bookkey = @feedin_bookkey and printingkey = 1
				  end
				else
				  begin
					EXEC dbo.titlehistory_insert 22, @feedin_bookkey, 0, '', @c_trimlength, 0

					update printing
					set trimsizelength = @c_trimlength,
					lastuserid = @c_lastuserid,
					lastmaintdate = @d_currentdate
					where bookkey = @feedin_bookkey and printingkey = 1
				  end
				end
			  end

			if len(@c_illus) > 0 
		   	 begin
				select @c_oldchar = ''
				select @c_oldchar = actualinsertillus
				from printing
				where bookkey=@feedin_bookkey and printingkey=1
			
				if (@c_oldchar is null)
				 begin
			 	   select @c_oldchar = ''
				 end

				if (@c_illus <>  @c_oldchar)
			 	 begin
				
					select @bookwasupdatedind=1
					EXEC dbo.titlehistory_insert 83, @feedin_bookkey, 0, '', @c_illus, 0

					update printing
					set actualinsertillus = @c_illus,
					lastuserid = @c_lastuserid,
					lastmaintdate = @d_currentdate
					where bookkey = @feedin_bookkey and printingkey = 1
				  end
				end
			  end

			if len(@d_pubyear_to_date)  > 0 
		   	 begin
				select @i_oldcode = 0
				select @i_oldcode2 = 0

				select @i_oldcode = convert(int,substring(convert(varchar,pubmonth,110),1,2))
				from printing
				where bookkey=@feedin_bookkey and printingkey=1
			
				if (@i_oldcode is null)
				 begin
			 	   select @i_oldcode = 0
				 end

				select @i_oldcode2 = convert(int,substring(convert(varchar,@d_pubyear_to_date,110),1,2))
				if ( @i_oldcode2 <>  @i_oldcode)
			 	 begin
				
					select @bookwasupdatedind=1
					select @titlehistory_newvalue=NULL
					select @titlehistory_newvalue = convert (char (100),@i_oldcode2)
					EXEC dbo.titlehistory_insert 76, @feedin_bookkey, 0, '', @titlehistory_newvalue, 0

					update printing
					set pubmonth = @d_pubyear_to_date,
					  pubmonthcode = @i_oldcode2,
					lastuserid = @c_lastuserid,
					lastmaintdate = @d_currentdate
					where bookkey = @feedin_bookkey and printingkey = 1
				  end
			  end

/*bookdates only do if no row present*/
			select @i_oldcode = 0
			select @i_oldcode = count(*) from bookdates where bookkey=@feedin_bookkey and printingkey=1 and
				datetypecode= 8
			if @i_oldcode = 0
			  begin
					select @bookwasupdatedind=1
					select @titlehistory_newvalue=NULL
					select @titlehistory_newvalue = convert (char (100),@d_pubyear_to_date)
					EXEC dbo.titlehistory_insert 36, @feedin_bookkey, 1, '8', @titlehistory_newvalue, 0

				insert into bookdates (bookkey,printingkey,datetypecode,activedate,lastuserid,lastmaintdate)
				  values (@feedin_bookkey,1,8,@d_pubyear_to_date,@c_lastuserid,@d_currentdate)
			  end
	
/*bookprice*/
			if @f_usprice > 0
			  begin
				select @f_oldfloat = 0
				select @i_count = 0

				select @i_count = count(*)
				from bookprice
				where bookkey=@feedin_bookkey and currencytypecode = @i_currencycode and pricetypecode= @i_pricecode
				
				if @i_count > 0
				  begin
					select @f_oldfloat = rtrim(finalprice)
					from bookprice
					where bookkey=@feedin_bookkey  and currencytypecode = @i_currencycode and pricetypecode= @i_pricecode
			
					if (@f_oldfloat is null)
					 begin
				 	   select @f_oldfloat = 0
					 end
		
					if ( rtrim(@f_oldfloat) <>  rtrim(@f_usprice))
				 	 begin
						select @bookwasupdatedind=1
						select @titlehistory_newvalue=NULL
						select @titlehistory_newvalue = convert (varchar (100),rtrim(@f_usprice))
						EXEC dbo.titlehistory_insert 9, @feedin_bookkey, 0, @i_currencycode, @titlehistory_newvalue, 0
	
						update bookprice
						  set finalprice = rtrim(@f_usprice),
						    lastuserid = @c_lastuserid,
						    lastmaintdate = @d_currentdate
						   where bookkey = @feedin_bookkey and currencytypecode = @i_currencycode and pricetypecode= @i_pricecode
					  end
				   end
				  else
				   begin
					select @bookwasupdatedind=1

					UPDATE keys SET generickey = generickey+1, 
					 lastuserid = 'QSIADMIN', 
					lastmaintdate = getdate()

					select @nextkey = generickey from Keys
					
					select @titlehistory_newvalue=NULL
					select @titlehistory_newvalue = convert (varchar (100),rtrim(@f_usprice))
					EXEC dbo.titlehistory_insert 9, @feedin_bookkey, 0, @i_currencycode, @titlehistory_newvalue, 0
										
					insert into bookprice  (pricekey,bookkey,pricetypecode,
						currencytypecode,activeind,finalprice,
						effectivedate,lastuserid,lastmaintdate)
					values (@nextkey,@feedin_bookkey,@i_pricecode,@i_currencycode,1,
						rtrim(@f_usprice),@d_currentdate,@c_lastuserid,@d_currentdate)
				end
			end

			
			if @f_canadianprice > 0
			  begin
				select @f_oldfloat = 0
				select @i_count = 0

				select @i_count = count(*)
				from bookprice
				where bookkey=@feedin_bookkey and currencytypecode = 11 and pricetypecode= @i_pricecode
				
				if @i_count > 0
				  begin
					select @f_oldfloat = rtrim(finalprice)
					from bookprice
					where bookkey=@feedin_bookkey and currencytypecode = 11 and pricetypecode= @i_pricecode
			
					if (@f_oldfloat is null)
					 begin
				 	   select @f_oldfloat = 0
					 end
		
					if ( rtrim(@f_oldfloat) <>  rtrim(@f_canadianprice))
				 	 begin
						select @bookwasupdatedind=1
						select @titlehistory_newvalue=NULL
						select @titlehistory_newvalue = convert (varchar (100),rtrim(@f_canadianprice))
						EXEC dbo.titlehistory_insert 9, @feedin_bookkey, 0, '11', @titlehistory_newvalue, 0
	
						update bookprice
						  set finalprice = rtrim(@f_canadianprice),
						    lastuserid = @c_lastuserid,
						    lastmaintdate = @d_currentdate
						   where bookkey = @feedin_bookkey and currencytypecode = 11 and pricetypecode= @i_pricecode
					  end
				   end
				  else
				   begin
					select @bookwasupdatedind=1

					UPDATE keys SET generickey = generickey+1, 
					 lastuserid = 'QSIADMIN', 
					lastmaintdate = getdate()

					select @nextkey = generickey from Keys
					
					select @titlehistory_newvalue=NULL
					select @titlehistory_newvalue = convert (varchar (100),rtrim(@f_canadianprice))
					EXEC dbo.titlehistory_insert 9, @feedin_bookkey, 0, '11', @titlehistory_newvalue, 0
										
					insert into bookprice  (pricekey,bookkey,pricetypecode,
						currencytypecode,activeind,finalprice,
						effectivedate,lastuserid,lastmaintdate)
					values (@nextkey,@feedin_bookkey,@i_pricecode,11,1,
						rtrim(@f_canadianprice),@d_currentdate,@c_lastuserid,@d_currentdate)
				 end
			end

/*gentable updates*/
		if @i_fnbcode > 0 
		 begin
			select @i_oldcode = 0
			select @i_oldcode = customcode01
			from bookcustom
			where bookkey=@feedin_bookkey
			
			if (@i_oldcode is null)
			begin
			    select @i_oldcode = 0
			end

			if (@i_fnbcode <>  @i_oldcode) 
			begin
				select @bookwasupdatedind=1

				select @titlehistory_newvalue=NULL
				select @titlehistory_newvalue = convert (char (100),@i_fnbcode)
				--EXEC dbo.titlehistory_insert ,@feedin_bookkey,0,'',@titlehistory_newvalue

				update bookcustom
				set customcode01 =@i_fnbcode,
				lastuserid=@c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey
			end

		end		
		if @i_bisacstatuscode > 0 
		 begin
			select @i_oldcode = 0
			select @i_oldcode = bisacstatuscode 
			from bookdetail b
			where b.bookkey=@feedin_bookkey
			
			if @i_oldcode is null
			begin
				select @i_oldcode = 0
			end

			if @i_bisacstatuscode <> @i_oldcode
			  begin
				select @bookwasupdatedind = 1

			
				select @titlehistory_newvalue=NULL
				select @titlehistory_newvalue = convert (char (100),@i_bisacstatuscode)
				EXEC dbo.titlehistory_insert 4, @feedin_bookkey, 0, '', @titlehistory_newvalue, 0
			
				update bookdetail
				set bisacstatuscode = @i_bisacstatuscode,
				lastuserid= @c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey

				
			end 
		end 

		if @i_titletypecode > 0 
		begin
			select @i_oldcode = 0
			select @i_oldcode = titletypecode
			from book
			where bookkey=@feedin_bookkey
			
			if (@i_oldcode is null)
			begin
			    select @i_oldcode = 0
			end

			if (@i_titletypecode <>  @i_oldcode) 
			begin
				select @bookwasupdatedind=1

				select @titlehistory_newvalue=NULL
				select @titlehistory_newvalue = convert (char (100),@i_titletypecode )
				EXEC dbo.titlehistory_insert 54, @feedin_bookkey, 0, '', @titlehistory_newvalue, 0
			

				update book
				set titletypecode = @i_titletypecode,
				lastuserid=@c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey
			end
		end


		if @i_slotcode > 0 
		begin
			select @i_oldcode = 0
			select @i_oldcode = slotcode 
			from printing
			where printingkey = 1 and bookkey=@feedin_bookkey 
			
			if (@i_oldcode is null)
			begin
			    select @i_oldcode = 0
			end

			if (@i_slotcode <>  @i_oldcode) 
			begin
				select @bookwasupdatedind=1

				select @titlehistory_newvalue=NULL
				select @titlehistory_newvalue = convert (char (100),@i_slotcode)
				--EXEC dbo.titlehistory_insert ,@feedin_bookkey,0,'',@titlehistory_newvalue
			

				update printing
				set slotcode  = @i_slotcode,
				lastuserid=@c_lastuserid,
				lastmaintdate = @d_currentdate
				where printingkey = 1 and bookkey = @feedin_bookkey
			end
		end

		if @i_editioncode > 0 
		begin
			select @i_oldcode = 0
			select @i_oldcode = editioncode 
			from bookdetail
			where bookkey=@feedin_bookkey 
			
			if (@i_oldcode is null)
			begin
			    select @i_oldcode = 0
			end

			if (@i_editioncode <>  @i_oldcode) 
			begin
				select @bookwasupdatedind=1

				select @titlehistory_newvalue=NULL
				select @titlehistory_newvalue = convert (char (100),@i_editioncode)
				EXEC dbo.titlehistory_insert 47, @feedin_bookkey, 0, '', @titlehistory_newvalue, 0
			

				update bookdetail
				set editioncode  = @i_editioncode,
				lastuserid=@c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey
			end
		end

		if @i_seriescode > 0 
		 begin
			select @i_oldcode = 0
			select @i_oldcode2 = 0
			select @i_oldcode = seriescode, @i_oldcode2 = volumenumber
			from bookdetail
			where bookkey=@feedin_bookkey 
			
			if (@i_oldcode is null)
			begin
			    select @i_oldcode = 0
			end

			if (@i_seriescode <>  @i_oldcode)  or(@i_oldcode2<> @i_volume)
			begin
				select @bookwasupdatedind=1

				select @titlehistory_newvalue=NULL
				select @titlehistory_newvalue = convert (char (100),@i_seriescode)
				EXEC dbo.titlehistory_insert 50, @feedin_bookkey, 0, '', @titlehistory_newvalue, 0

				select @titlehistory_newvalue=NULL
				select @titlehistory_newvalue = convert (char (100),@i_volume)
				EXEC dbo.titlehistory_insert 52, @feedin_bookkey, 0, '', @titlehistory_newvalue, 0

				update bookdetail
				set seriescode = @i_seriescode,
				  volumenumber = @i_volume,
				lastuserid=@c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey
			end
		end

		if @i_mediatypecode > 0 
		 begin
			select @i_oldcode = 0
			select @i_oldcode2 = 0
			select @i_oldcode = mediatypecode, @i_oldcode2 = mediatypesubcode
			from bookdetail
			where bookkey=@feedin_bookkey 
			
			if (@i_oldcode is null)
			begin
			    select @i_oldcode = 0
			end

			if (@i_mediatypecode <>  @i_oldcode)  or (@i_oldcode2<> @i_mediatypesubcode)
			begin
				select @bookwasupdatedind=1

				select @titlehistory_newvalue=NULL
				select @titlehistory_newvalue = convert (char (100),@i_mediatypesubcode)
				EXEC dbo.titlehistory_insert 11, @feedin_bookkey, 0, @i_mediatypecode, @titlehistory_newvalue, 0
			

				update bookdetail
				set mediatypecode = @i_mediatypecode,
				  mediatypesubcode = @i_mediatypesubcode,
				lastuserid=@c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey
			end
		end

		if @i_subjectacode > 0 or @i_subjectbcode > 0 
		 begin
			select @i_oldcode = 0
			select @i_oldcode2 = 0
			select @i_oldcode = customcode07,@i_oldcode2 = customcode08
			from bookcustom
			where bookkey=@feedin_bookkey 
			
			if (@i_oldcode is null)
			begin
			    select @i_oldcode = 0
			end

			if (@i_subjectacode <>  @i_oldcode)  or (@i_oldcode2<> @i_subjectbcode)
			begin
				select @bookwasupdatedind=1

				update bookcustom
				set customcode07 = @i_subjectacode,
				  customcode08 = @i_subjectbcode,
				lastuserid=@c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey
			end
		end

		if @i_territorycode> 0 
		 begin
			select @i_oldcode = 0
			select @i_oldcode = territoriescode
			from book
			where bookkey=@feedin_bookkey 
			
			if (@i_oldcode is null)
			begin
			    select @i_oldcode = 0
			end

			if (@i_territorycode <>  @i_oldcode)
			begin
				select @bookwasupdatedind=1

				select @titlehistory_newvalue=NULL
				select @titlehistory_newvalue = convert (char (100),@i_territorycode)
				EXEC dbo.titlehistory_insert 55, @feedin_bookkey, 0, '', @titlehistory_newvalue, 0

				update book
				set territoriescode = @i_territorycode,
				lastuserid=@c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey
			end
		end

/*custom yesno  remove null check just update*/

			update bookcustom
			  set customind04 = @i_incat,
				lastuserid = @c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey

			update bookcustom
			  set customind08 =  @i_onorderform,
				lastuserid = @c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey


			update bookcustom
			  set customind09 = @i_twocolor,
				lastuserid = @c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey

			update bookcustom
			  set customind10 = @i_fourcolor,
				lastuserid = @c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey

/*custom float and int*/

			update bookcustom
			  set customfloat01 = @i_colorphotos,
				lastuserid = @c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey

			update bookcustom
			  set customfloat02 = @i_colorillustrations,
				lastuserid = @c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey

			update bookcustom
			  set customfloat03 = @i_bandwphotos,
				lastuserid = @c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey

			update bookcustom
			  set customfloat04 = @i_bandwillustrations,
				lastuserid = @c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey

			update bookcustom
			  set customfloat05 = @i_watercolorillustrations,
				lastuserid = @c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey

			update bookcustom
			  set customint01 = @i_linedrawings,
				lastuserid = @c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey

			update bookcustom
			  set customint02 = @i_charts,
				lastuserid = @c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey

			update bookcustom
			  set customint03 = @i_tables,
				lastuserid = @c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey

			update bookcustom
			  set customint04 = @i_graphs,
				lastuserid = @c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey

			update bookcustom
			  set customint05 = @i_diagrams,
				lastuserid = @c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey

			update bookcustom
			  set customint06 = @i_maps,
				lastuserid = @c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey

			update bookcustom
			  set customint07 = @i_screenshots,
				lastuserid = @c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey

			update bookcustom
			  set customint08 = @i_codesamples,
				lastuserid = @c_lastuserid,
				lastmaintdate = @d_currentdate
				where bookkey = @feedin_bookkey

/* comments --  45 */
	if len(@c_copylong) > 0
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_copylong,16, @bookwasupdatedind OUTPUT
	  end
	if len(@c_toc) > 0
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_toc,32, @bookwasupdatedind OUTPUT
	  end
	if len(@c_quote) > 0
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_quote,23, @bookwasupdatedind OUTPUT
	  end
	if len(@c_authbio) > 0
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_authbio,2, @bookwasupdatedind OUTPUT
	  end
	if len(@c_oldisbn) > 0
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_oldisbn,45, @bookwasupdatedind OUTPUT
	  end	
 	if len(@c_othertitle1) > 0 
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_othertitle1,54, @bookwasupdatedind OUTPUT
	  end	
	if len(@c_otherpub1) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_otherpub1,55, @bookwasupdatedind OUTPUT
	  end	
	if len(@c_otherisbn1) > 0 
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_otherisbn1,56, @bookwasupdatedind OUTPUT
	  end	
	if len(@c_otherprice1) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_otherprice1,57, @bookwasupdatedind OUTPUT
	  end	
	if len(@c_otherdate1) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_otherdate1,58, @bookwasupdatedind OUTPUT
	  end	
	if len(@c_othertitle2) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_othertitle2,59, @bookwasupdatedind OUTPUT
	  end	
	if len(@c_otherpub2) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_otherpub2,60, @bookwasupdatedind OUTPUT
	  end	
	if len(@c_otherisbn2) > 0
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_otherisbn2,61, @bookwasupdatedind OUTPUT
	  end	
	if len(@c_otherprice2) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_otherprice2,62, @bookwasupdatedind OUTPUT
	  end	
	if len(@c_otherdate2) > 0 
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_otherdate2,63, @bookwasupdatedind OUTPUT
	  end	
	if len(@c_othertitle3) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_othertitle3,64, @bookwasupdatedind OUTPUT
	  end	
	if len(@c_otherpub3) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_otherpub3,65, @bookwasupdatedind OUTPUT
	  end	
	if len(@c_otherisbn3) > 0 
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_otherisbn3,66, @bookwasupdatedind OUTPUT
	  end	
	if len(@c_otherprice3) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_otherprice3,67, @bookwasupdatedind OUTPUT
	  end	
	if len(@c_otherdate3) > 0 
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_otherdate3,68, @bookwasupdatedind OUTPUT
	  end	
  	if len(@c_differences) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_differences,46, @bookwasupdatedind OUTPUT
	  end
/*@c_translation not used*/
	if len(@c_origtitle) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_origtitle,41, @bookwasupdatedind OUTPUT
	  end
	if len(@c_otherinseries2) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_otherinseries2,47, @bookwasupdatedind OUTPUT
	  end
	if len(@c_seriestitles) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_seriestitles,48, @bookwasupdatedind OUTPUT
	  end
	if len(@c_keybenefit1) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_keybenefit1,49, @bookwasupdatedind OUTPUT
	  end
	if len(@c_keybenefit2) > 0  
	  begin
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_keybenefit2,50, @bookwasupdatedind OUTPUT
	  end
 	if len(@c_keybenefit3) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_keybenefit3,51, @bookwasupdatedind OUTPUT
	  end
  	if len(@c_about_technology) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_about_technology,52, @bookwasupdatedind OUTPUT
	  end
  	if len(@c_define_audience) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_define_audience,53, @bookwasupdatedind OUTPUT
	  end
  	if len(@c_clothisbn) > 0 
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_clothisbn,69, @bookwasupdatedind OUTPUT
	  end
  	if len(@c_clothinprint) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_clothinprint,70, @bookwasupdatedind OUTPUT
	  end
  	if len(@c_origlangisbn) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_origlangisbn,71, @bookwasupdatedind OUTPUT
	  end
	if len(@c_pricelastsold) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_pricelastsold,72, @bookwasupdatedind OUTPUT
	  end  
	if len(@c_agerange) > 0  
	  begin  
		EXEC feed_in_load_comments_updates_sp @feedin_bookkey,@c_agerange,39, @bookwasupdatedind OUTPUT
	  end  


/* all contributors*/
	if len(@c_author1lastname) > 0  /* sortorder 1 authortypecode 12*/
	  begin  
		EXEC feed_in_load_contributors_updates_sp @feedin_bookkey,@c_author1firstname,@c_author1lastname,
		   @c_author1city,@c_author1state,12,1, @bookwasupdatedind OUTPUT
	  end  
	if len(@c_author2lastname) > 0  /* sortorder 2 authortypecode 12*/
	  begin  
		EXEC feed_in_load_contributors_updates_sp @feedin_bookkey,@c_author2firstname,@c_author2lastname,
		   @c_author2city,@c_author2state,12,2, @bookwasupdatedind OUTPUT
	  end  
 	if len(@c_author3lastname) > 0  /* sortorder 3 authortypecode 12*/
	  begin  
		EXEC feed_in_load_contributors_updates_sp @feedin_bookkey,@c_author3firstname,@c_author3lastname,
		   @c_author3city,@c_author3state,12,3, @bookwasupdatedind OUTPUT
	  end  
	if len(@c_author4lastname) > 0  /* sortorder 4 authortypecode 12*/
	  begin  
		EXEC feed_in_load_contributors_updates_sp @feedin_bookkey,@c_author4firstname,@c_author4lastname,
		   @c_author4city,@c_author4state,12,4, @bookwasupdatedind OUTPUT
	  end  
	if len(@c_editor1lastname) > 0  /* sortorder 5 authortypecode 16*/
	  begin  
		EXEC feed_in_load_contributors_updates_sp @feedin_bookkey,@c_editor1firstname,@c_editor1lastname,
		   @c_editor1city,@c_editor1state,16,5, @bookwasupdatedind OUTPUT
	  end 
	if len(@c_editor2lastname) > 0  /* sortorder 6 authortypecode 16*/
	  begin  
		EXEC feed_in_load_contributors_updates_sp @feedin_bookkey,@c_editor2firstname,@c_editor2lastname,
		   @c_editor2city,@c_editor2state,16,6, @bookwasupdatedind OUTPUT
	  end 
	if len(@c_photographerlastname) > 0  /* sortorder 7 authortypecode 27*/
	  begin  
		EXEC feed_in_load_contributors_updates_sp @feedin_bookkey,@c_photographerfirstname,@c_photographerlastname,
		   @c_photographercity,@c_photographerstate,27,7, @bookwasupdatedind OUTPUT
	  end 
 	if len(@c_illustratorlastname) > 0  /* sortorder 8 authortypecode 20*/
	  begin  
		EXEC feed_in_load_contributors_updates_sp @feedin_bookkey,@c_illustratorfirstname,@c_illustratorlastname,
		   @c_illustratorcity,@c_illustratorstate,20,7, @bookwasupdatedind OUTPUT
	  end 
	if len(@c_prefacelastname) > 0  /* sortorder 10 authortypecode 1*/
	  begin  
		EXEC feed_in_load_contributors_updates_sp @feedin_bookkey,@c_prefacefirstname,@c_prefacelastname,
		   @c_prefacecity,@c_prefacestate,1,10, @bookwasupdatedind OUTPUT
	  end 
	if len(@c_forewordlastname) > 0  /* sortorder 11 authortypecode 32*/
	  begin  
		EXEC feed_in_load_contributors_updates_sp @feedin_bookkey,@c_forewordfirstname,@c_forewordlastname,
		   @c_forewordcity,@c_forewordstate,32,11, @bookwasupdatedind OUTPUT
	  end 
	if len(@c_afterwordlastname) > 0  /* sortorder 12 authortypecode 15*/
	  begin  
		EXEC feed_in_load_contributors_updates_sp @feedin_bookkey,@c_afterwordfirstname,@c_afterwordlastname,
		   @c_afterwordcity,@c_afterwordstate,15,12, @bookwasupdatedind OUTPUT
	  end 
	if len(@c_translatorlastname) > 0  /* sortorder 13 authortypecode 31*/
	  begin  
		EXEC feed_in_load_contributors_updates_sp @feedin_bookkey,@c_translatorfirstname,@c_translatorlastname,
		   @c_translatorcity,@c_translatorstate,31,13, @bookwasupdatedind OUTPUT
	  end  	
	if len(@c_otherlastname) > 0  /* sortorder 14 authortypecode 11*/
	  begin  
		EXEC feed_in_load_contributors_updates_sp @feedin_bookkey,@c_otherfirstname,@c_otherlastname,
		   @c_othercity,@c_otherstate,11,14, @bookwasupdatedind OUTPUT
	  end  	

/*create full authordisplayname */	
	exec fulldisplayname @feedin_bookkey

	end   /* end bookkey > 0*/

if @feedin_bookkey = 0 
 begin
	select @bookwasrejectedind =1  /*rejected*/
  end

/*end  ISBN Record*/

if @i_incat is not null or @i_onorderform is not null or @i_twocolor is not null or
   @i_fourcolor is not null or @i_colorphotos is not null or @i_colorillustrations
   is not null or @i_bandwphotos is not null or @i_bandwillustrations is not null or
   @i_watercolorillustrations is not null or @i_linedrawings is not null or @i_charts
   is not null or @i_tables is not null or @i_graphs is not null or @i_diagrams is not null or
   @i_maps is not null or @i_screenshots is not null or @i_codesamples is not null
  begin
 	select @bookwasupdatedind=1
  end

if @bookwasupdatedind=1 or @bookwasinsertind=1  /** Output the Necessary Update Flags**/
  begin
	if @bookwasinsertind=1
	  begin
		update feederror 
		set detailtype = detailtype + 1
		where batchnumber='3'
		and processdate >= @d_currentdate
		and errordesc LIKE 'Feed Summary: Inserts%'
	end

  	if @bookwasupdatedind=1 and @bookwasinsertind=0
	  begin
		update feederror 
		set detailtype = detailtype + 1
		where batchnumber='3'
		and processdate >= @d_currentdate
		and errordesc LIKE 'Feed Summary: Updates%'
	end

	
	/** Datawarehouse Update **/
	select  @i_count = count(*) 
	from bookwhupdate 
	where bookkey = @feedin_bookkey

	if @i_count = 0 
	begin
		insert into bookwhupdate 
		(bookkey,lastmaintdate,lastuserid)
		values (@feedin_bookkey,getdate(),@c_lastuserid)
	end

	/** Eloquence Update **/

 /** update the record for the title - although it may not exist **/
	select 	@i_count = 0 

	select @i_count = count(*) from bookedipartner
		where bookkey =@feedin_bookkey

	if @i_count > 0 
	begin 
		update bookedipartner 
			set sendtoeloquenceind=1,
			lastuserid=@c_lastuserid,
			lastmaintdate = @d_currentdate
				where bookkey=@feedin_bookkey
	end
end 
	if @bookwasrejectedind = 1
	  begin
		update feederror 
		set detailtype = detailtype + 1
		where batchnumber='3'
		and processdate >= @d_currentdate
		and errordesc LIKE 'Feed Summary: Rejected%'
	end


  end /* isbn 13 */

if len(@c_isbn13) <> 13 and @bookwasrejectedind =0 and @bookwasupdatedind=0 and @bookwasinsertind=0
  begin
	update feederror 
		set detailtype = detailtype + 1
		where batchnumber='3'
		and processdate >= @d_currentdate
		and errordesc LIKE 'Feed Summary: Rejected%'

		insert into feederror 							
		(isbn,batchnumber,processdate,errordesc)
			values (@feed_isbn,'3',@d_currentdate,('NO ISBN ENTERED or ISBN Prefix not on Gentables ' + @feed_isbn))
  end		
	
end /* status 2*/



FETCH NEXT FROM feed_titles
INTO @i_id,@c_incatalog,@c_onorderform,@c_fnb,@c_season,@c_status,@c_catalog,@i_publication_year,@c_slot,
@c_titleprefix,@c_title, @c_subtitle,@c_edition,@i_volume,@c_seriestitle,  
@c_author1firstname,@c_author1lastname,@c_author1city,@c_author1state,@c_author2firstname,  
@c_author2lastname,@c_author2city,@c_author2state,@c_author3firstname,@c_author3lastname,  
@c_author3city,@c_author3state,@c_author4firstname,@c_author4lastname,@c_author4city,@c_author4state,  
@c_editor1firstname,@c_editor1lastname,@c_editor1city,@c_editor1state,@c_editor2firstname,@c_editor2lastname,  
@c_editor2city,@c_editor2state,@c_forewordfirstname,@c_forewordlastname,@c_forewordcity,@c_forewordstate,  	
@c_prefacefirstname,@c_prefacelastname,@c_prefacecity,@c_prefacestate,@c_afterwordfirstname,@c_afterwordlastname,  	
@c_afterwordcity,@c_afterwordstate,@c_translatorfirstname,@c_translatorlastname,@c_translatorcity,@c_translatorstate,  
@c_photographerfirstname,@c_photographerlastname,@c_photographercity,@c_photographerstate,@c_illustratorfirstname,  	
@c_illustratorlastname,@c_illustratorcity,@c_illustratorstate,@c_otherfirstname,@c_otherlastname,@c_othercity,  	
@c_otherstate,@c_publishername,@c_imprintname,@c_binding,@c_pagecount,@c_trimsize,@i_colorphotos,@i_colorillustrations, 
@i_bandwphotos,@i_bandwillustrations,@i_linedrawings,@i_watercolorillustrations,@i_charts,@i_tables,@i_graphs,@i_diagrams,  
@i_maps,@i_screenshots,@i_codesamples,@c_agerange,@c_includesdisk,@c_includescdrom,@c_includesaudiocd,@c_twocolorinterior,  
@c_fourcolorinterior,@c_isbn10,@c_price,@c_canadianprice,@c_publicationmonth,@c_subjectcategorya,@c_subjectcategoryb,  
@c_copylong,@c_toc,@c_quote,@c_authbio,@c_rights,@c_oldisbn, 
@c_othertitle1,@c_otherpub1,@c_otherisbn1,@c_otherprice1,@c_otherdate1,@c_othertitle2,@c_otherpub2,  
@c_otherisbn2,@c_otherprice2,@c_otherdate2,@c_othertitle3,@c_otherpub3,@c_otherisbn3,@c_otherprice3,@c_otherdate3,  
@c_differences,@c_translation,@c_origtitle,@c_otherinseries2,@c_seriestitles,@c_keybenefit1,@c_keybenefit2,  
@c_keybenefit3,@c_about_technology,@c_define_audience,@c_clothisbn,@c_clothinprint,@c_origlangisbn,@c_pricelastsold,
@c_bisacsubjectcode, @c_audience, @c_discount, @c_barcodetype, @c_barcodeposition, @c_cartonqty, @c_bookweight

select @i_ti_cursor_status  = @@FETCH_STATUS

end /*isbn status 1*/


insert into feederror (batchnumber,processdate,errordesc)
 values ('3',@d_currentdate,'Titles Completed')
commit tran

close feed_titles
deallocate feed_titles

select @statusmessage = 'END VISTA FEED IN AT ' + convert (char,getdate())
print @statusmessage

return 0

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

