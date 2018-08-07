SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[create_est_statistics]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[create_est_statistics]
GO

create proc dbo.create_est_statistics
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

DECLARE @feed_system_date datetime

/* inputs */
/* estbook table 

	[estkey] [int] NOT NULL ,
	[bookkey] [int] NOT NULL ,
	[printingkey] [int] NULL ,
	[lastuserid] [varchar] (30) NULL ,
	[lastmaintdate] [datetime] NULL ,
	[estimatename] [varchar] (50) NULL ,
	[mediatypecode] [smallint] NULL ,
	[mediatypesubcode] [smallint] NULL ,
	[templateind] [tinyint] NULL ,
	[referencefield] [varchar] (30) NULL ,
	[ratecategorycode] [int] NULL ,
	[estimatorcode] [int] NULL ,
	[editorcode] [int] NULL ,
	[authorillustrator] [varchar] (50) NULL ,
	[formatchildcode] [int] NULL ,
	[pubdate] [datetime] NULL ,
	[customercontactname] [varchar] (80) NULL ,
	[customeraddress1] [varchar] (50) NULL ,
	[customeraddress2] [varchar] (50) NULL ,
	[customercity] [varchar] (50) NULL ,
	[customerstate] [varchar] (10) NULL ,
	[customerzipcode] [varchar] (10) NULL ,
	[customerphone] [varchar] (50) NULL ,
	[customerfax] [varchar] (50) NULL ,
	[customercontactemail] [varchar] (80) NULL ,
	[codenumber] [varchar] (50) NULL ,
	[quotenumber] [varchar] (50) NULL ,
	[requestdatetime] [datetime] NULL ,
	[requestedbyname] [varchar] (100) NULL ,
	[requestid] [varchar] (30) NULL ,
	[requestcomment] [text] NULL ,
	[requeststatuscode] [tinyint] NULL ,
	[estimatetypecode] [tinyint] NULL 
*/
	DECLARE @estbook_estkey int 
	DECLARE @estbook_estimatename varchar (50) 
	DECLARE @estbook_mediatypesubcode smallint 
	DECLARE @estbook_templateind tinyint 
	DECLARE @estbook_referencefield varchar (30) 
	DECLARE @estbook_authorillustrator varchar (50) 
	DECLARE @estbook_codenumber varchar (50) 
	DECLARE @estbook_quotenumber varchar (50) 
	DECLARE @estbook_requestdatetime datetime 
	DECLARE @estbook_requestedbyname varchar (100) 
	DECLARE @estbook_requestid varchar (30) 
	DECLARE @estbook_requeststatuscode tinyint 
	DECLARE @estbook_estimatetypecode tinyint 

/* estbookorgentry table

	[estkey] [int] NOT NULL ,
	[orgentrykey] [int] NOT NULL ,
	[orglevelkey] [int] NOT NULL ,
	[lastuserid] [varchar] (30) NULL ,
	[lastmaintdate] [datetime] NULL
*/
	DECLARE @estbookorg_orgentrykey int 
/* estspecs table
	[estkey] [int] NOT NULL ,
	[versionkey] [int] NOT NULL ,
	[mediatypecode] [smallint] NULL ,
	[mediatypesubcode] [smallint] NULL ,
	[pagecount] [smallint] NULL ,
	[trimfamilycode] [int] NULL ,
	[trimsizelength] [varchar] (10) NULL ,
	[trimsizewidth] [varchar] (10) NULL ,
	[film] [int] NULL ,
	[covertypecode] [int] NULL ,
	[endpapertype] [varchar] (1) NULL ,
	[foilamt] [float] NULL ,
	[colorcount] [int] NULL ,
	[firstprinting] [char] (1) NULL ,
	[bluesind] [char] (1) NULL ,
	[plateavailind] [char] (1) NULL ,
	[filmavailind] [char] (1) NULL ,
	[alternatebindpagecount] [int] NULL ,
	[alternateplatepagecount] [int] NULL ,
	[notekey] [int] NULL ,
	[sigforprepressind] [tinyint] NULL ,
	[sigforpresswkind] [tinyint] NULL ,
	[sigforbindind] [tinyint] NULL ,
	[sigforpaperind] [tinyint] NULL ,
	[lastuserid] [varchar] (30) NULL ,
	[lastmaintdate] [datetime] NULL ,
	[defaultinks] [int] NULL ,
	[defaultbindmethod] [int] NULL ,
	[defaultprintmethod] [int] NULL ,
	[alternateprintpagecount] [int] NULL 
*/

	DECLARE @estspecs_mediatypesubcode smallint 
	DECLARE @estspecs_pagecount smallint 
	DECLARE @estspecs_trimfamilycode int 
	DECLARE @estspecs_film int 
	DECLARE @estspecs_covertypecode int 
	DECLARE @estspecs_endpapertype varchar (1) 
	DECLARE @estspecs_firstprinting char (1) 
	DECLARE @estspecs_bluesind char (1) 


/* estversion table
	[estkey] [int] NOT NULL ,
	[versionkey] [int] NOT NULL ,
	[finishedgoodqty] [int] NULL ,
	[finishedgoodvendorcode] [int] NULL ,
	[lastuserid] [varchar] (30) NULL ,
	[lastmaintdate] [datetime] NULL ,
	[description] [varchar] (100) NULL ,
	[scaleorgentrykey] [int] NULL ,
	[selectedversionind] [tinyint] NULL ,
	[requestdatetime] [datetime] NULL ,
	[requestedbyname] [varchar] (100) NULL ,
	[requestid] [varchar] (30) NULL ,
	[requestcomment] [varchar] (255) NULL ,
	[requestbatchid] [varchar] (30) NULL ,
	[requeststatuscode] [tinyint] NULL ,
	[approvedind] [int] NULL ,
	[jobnumber] [varchar] (50) NULL ,
	[specialinstructions1] [varchar] (300) NULL ,
	[specialinstructions2] [varchar] (300) NULL ,
	[specialinstructions3] [varchar] (300) NULL ,
	[versiontypecode] [tinyint] NULL ,
	[statuscode] [smallint] NULL ,
	[creationdate] [datetime] NULL ,
	[createdbyuserid] [varchar] (30) NULL 
*/

	DECLARE @estversion_estkey int
	DECLARE @estversion_versionkey int
	DECLARE @estversion_finishedgoodqty int
	DECLARE @estversion_description varchar (100) 
	DECLARE @estversion_scaleorgentrykey int 
	DECLARE @estversion_jobnumber varchar (50) 
	DECLARE @estversion_versiontypecode tinyint 


/* estcomp table
	[estkey] [int] NOT NULL ,
	[versionkey] [int] NOT NULL ,
	[compkey] [int] NOT NULL ,
	[groupnum] [int] NOT NULL ,
	[compvendorcode] [int] NULL ,
	[compqty] [int] NULL ,
	[methodcode] [int] NULL ,
	[stockcode] [int] NULL ,
	[film] [int] NULL ,
	[finishcode] [int] NULL ,
	[inks] [int] NULL ,
	[firstcovinks] [int] NULL ,
	[secondcovinks] [int] NULL ,
	[thirdcovinks] [int] NULL ,
	[fourthcovinks] [int] NULL ,
	[calcspoilage] [char] (1) NULL ,
	[cartonqty] [int] NULL ,
	[insertpagecnt] [smallint] NULL ,
	[maxnumbercolors] [varchar] (4) NULL ,
	[minnumbersheets] [int] NULL ,
	[numberout] [int] NULL ,
	[spoilagepercent] [float] NULL ,
	[costgenerateoption] [smallint] NULL ,
	[stocksource] [smallint] NULL ,
	[offlineind] [char] (1) NULL ,
	[comptypecode] [int] NULL ,
	[manualentryind] [char] (1) NULL ,
	[comments] [varchar] (255) NULL ,
	[lastuserid] [varchar] (30) NULL ,
	[lastmaintdate] [datetime] NULL ,
	[manualsheetsind] [char] (1) NULL ,
	[totalnumbersheets] [int] NULL ,
	[cartontype] [tinyint] NULL ,
	[palletlaborind] [char] (1) NULL ,
	[palletmaterialind] [char] (1) NULL 
*/
	DECLARE @estcomp_estkey int 
	DECLARE @estcomp_versionkey int 
	DECLARE @estcomp_compkey int 
	DECLARE @estcomp_groupnum int 
	DECLARE @estcomp_compqty int 
	DECLARE @estcomp_methodcode int 
	DECLARE @estcomp_stockcode int 
	DECLARE @estcomp_film int 
	DECLARE @estcomp_finishcode int 
	DECLARE @estcomp_inks int 

/* output eststatistics table */
DECLARE @eststats_estkey int /** from estbook **/
DECLARE @eststats_estimatedescr varchar (255) /** estimatename+referencefield+authorillustrator+codenumber **/
DECLARE @eststats_bindformat varchar (30)   /** use mediatypesub_view (datacode=2) to resolve hardcover or paperback **/
DECLARE @eststats_customername varchar (50) /** from estbookorgentry level 2 **/
DECLARE @eststats_customerdivisionname varchar (50) /** from estbookorgentry level 3 **/
DECLARE @eststats_quotenumber varchar (50) 
DECLARE @eststats_quoteind varchar (10) /** if quotenumber is null, 'Estimate', else 'Quote' **/
DECLARE @eststats_createdatetime datetime  /** from Requestdatetime  **/
DECLARE @eststats_estimatorname varchar (50) /** use requestedbyname against users table to get name **/
DECLARE @eststats_requestoriginator varchar (30) /** from requestid (no reformatting) **/
DECLARE @eststats_requeststatus varchar (30) /** resolve requeststatuscode against gentableid = 394  **/
DECLARE @eststats_estimatetype varchar (30) /** if null, 'Single Title', if 1, 'Common Form'  **/ 
DECLARE @eststats_estcount int /** =1 for each estimate  **/

DECLARE @eststats_versionkey int /** from estversion **/
DECLARE @eststats_finishedgoodqty int 
DECLARE @eststats_finishedgoodqtyrange varchar (20) /** based on finishedgoodqty **/
DECLARE @eststats_versiondescr varchar (100) /** from estversion.description **/
DECLARE @eststats_scalecustomer varchar (50) /** use scaleorgentrykey against orgentry table to get orgentrydesc **/
DECLARE @eststats_jobnumber varchar (50) 
DECLARE @eststats_jobind varchar (10) /** if jobnumber is null, 'non-Job', else 'Job' **/
DECLARE @eststats_versiontype varchar (20) /** if null, 'Normal', 0 = 'Common Form', 1 = 'C/F Edition' **/

DECLARE @eststats_pagecount smallint /** from estspecs **/
DECLARE @eststats_pagecountrange varchar (20) /** based on pagecount **/
DECLARE @eststats_trimfamily varchar (20) /** resolve trimfamilycode against gentableid = 29  to get datadesc **/
DECLARE @eststats_filmtype varchar (20) /** resolve film (datacode) against gentableid = 50  to get datadesc **/
DECLARE @eststats_covertype varchar (20) /** resolve covertypecode against gentableid = 11  to get datadesc **/
DECLARE @eststats_endpapertype varchar (20) /** select endpapertypedesc from endpaper where endpapertypekey=endpapertype (null='N') **/
DECLARE @eststats_printingtype varchar (20) /** if estspecs.firstprinting = 'Y', 'First Print', else 'Reprint' **/
DECLARE @eststats_bluesind char (1) 
DECLARE @eststats_printbindonlyind char (1) /** whether or not estimate version has more than just print & bind components**/
DECLARE @eststats_bindmethod varchar (20) /** if methodcode is not null, if compkey=2 resolve bindmethod (tblid=3) **/
DECLARE @eststats_printnumcolors int /** select numcolors from ink where inkkey=estcomp.inks  **/
DECLARE @eststats_printcolordesc varchar (20) /** select inkdescshort from ink where inkkey=estcomp.inks **/
DECLARE @eststats_versionunitcost float /** sum of print-bind costs  for this version**/
DECLARE @eststats_versionrunpermcost float /** sum of print-bind costs  for this version **/
DECLARE @eststats_versiontotalcost float /** sum of print-bind costs  for this version **/
DECLARE @eststats_versioncount int /** sum for each version of estimate  **/

DECLARE @eststats_componenttype varchar (20) /** select compdesc from comptype where compkey=estcomp.compkey **/
DECLARE @eststats_compqty int 
DECLARE @eststats_method varchar (20) /** if methodcode is not null, if compkey=2 resolve bindmethod (tblid=3), else resolve printmethod (tableid=20) **/
DECLARE @eststats_stock varchar (20) /** if stockcode is not null, resolve stocktype (tblid=26) **/ 
DECLARE @eststats_finish varchar (20) /** resolve finishcode against gentableid = 15  to get datadesc **/ 
DECLARE @eststats_numcolors int /** select numcolors from ink where inkkey=estcomp.inks  **/
DECLARE @eststats_colordesc varchar (20) /** select inkdescshort from ink where inkkey=estcomp.inks **/
DECLARE @eststats_compunitcost float /** sum of charge codes for this component **/
DECLARE @eststats_comprunpermcost float /** sum of charge codes for this component **/
DECLARE @eststats_comptotalcost float /** sum of charge codes for this component **/
DECLARE @eststats_compcount int /** sum for each component of version  **/



DECLARE @estbook_fetch_status int
DECLARE @estversion_fetch_status int
DECLARE @estcomp_fetch_status int
DECLARE @eval_job varchar(4)
DECLARE @eval_comp_edition_cost float

BEGIN tran 
delete from ESTSTATS
delete from ESTVERSIONSTATS
delete from ESTCOMPSTATS

DECLARE header_estimates INSENSITIVE CURSOR
FOR
select	 eb.estkey ,
	 eb.estimatename, 
	 eb.mediatypesubcode, 
	 eb.templateind ,
	 eb.referencefield ,
	 eb.authorillustrator, 
	 eb.codenumber ,
	 eb.quotenumber ,
	 eb.requestdatetime ,
	 eb.requestedbyname,
	 eb.requestid ,
	 eb.requeststatuscode, 
	 eb.estimatetypecode ,
	 ebo.orgentrykey
from estbook eb, estbookorgentry ebo
where  (eb.lastuserid <> 'QSIADMIN' and eb.customercontactname <> 'Heidi Maxwell'
and eb.estimatename NOT LIKE '%TEST%')
and eb.requestdatetime > '2001-09-01 00:00:00.000'
and eb.estkey=ebo.estkey
and ebo.orglevelkey=2
order by eb.estkey

FOR READ ONLY
		
OPEN header_estimates 

FETCH NEXT FROM header_estimates 
INTO 	 @estbook_estkey ,
	 @estbook_estimatename ,
	 @estbook_mediatypesubcode ,
	 @estbook_templateind ,
	 @estbook_referencefield ,
	 @estbook_authorillustrator ,
	 @estbook_codenumber ,
	 @estbook_quotenumber ,
	 @estbook_requestdatetime ,
	 @estbook_requestedbyname,
	 @estbook_requestid ,
	 @estbook_requeststatuscode, 
	 @estbook_estimatetypecode ,
	 @estbookorg_orgentrykey

select @estbook_fetch_status  = @@FETCH_STATUS


while (@estbook_fetch_status=0 )  
begin
	select @eststats_estkey = @estbook_estkey
	select @eststats_quotenumber = @estbook_quotenumber
	select @eststats_createdatetime = @estbook_requestdatetime
	select @eststats_requestoriginator = @estbook_requestid
	select @eststats_estimatetype = 'Single Title'
	select @eststats_estcount = 1

	/** estimatename+referencefield+authorillustrator+codenumber **/
	select @eststats_estimatedescr = ''

	if @estbook_estimatename is not NULL
  	  begin
		select @eststats_estimatedescr = @estbook_estimatename
	  end

	if @estbook_referencefield is not NULL
	  begin
		if @eststats_estimatedescr is not NULL
		  begin
			select @eststats_estimatedescr = @eststats_estimatedescr + '/' + @estbook_referencefield
		  end
		else
		  begin
			select @eststats_estimatedescr = @estbook_referencefield
		  end
	  end

	if @estbook_authorillustrator is not NULL
	  begin
		if @eststats_estimatedescr is not NULL
		  begin
			select @eststats_estimatedescr = @eststats_estimatedescr + '/' + @estbook_authorillustrator
		  end
		else
		  begin
			select @eststats_estimatedescr = @estbook_authorillustrator
		  end
	  end

	if @estbook_codenumber is not NULL
	  begin
		if @eststats_estimatedescr is not NULL
		  begin
			select @eststats_estimatedescr = @eststats_estimatedescr + '/' + @estbook_codenumber
		  end
		else
		  begin
			select @eststats_estimatedescr = @estbook_codenumber
		  end
	  end

	/** use mediatypesub_view (datacode=2) to resolve hardcover or paperback **/

	select @eststats_bindformat = ''	
	if @estbook_mediatypesubcode  is null  
	 begin
		select @estbook_mediatypesubcode  = 0
	 end 
	if @estbook_mediatypesubcode > 0 
   	  begin
		select @eststats_bindformat  = datadesc
		  from mediatypesub_view
			where datacode = 2
				and datasubcode=@estbook_mediatypesubcode 
	  end

	/** if quotenumber is null, 'Estimate', else 'Quote' **/

	select @eststats_quoteind =''
	if @eststats_quotenumber is Null
	  begin
		select @eststats_quoteind = 'Estimate'
	  end
	else
	  begin
		select @eststats_quoteind = 'Quote'
	  end


	/** use requestedbyname against users table to get name **/

	select @eststats_estimatorname = ''
	if @estbook_requestedbyname is not NULL 
   	  begin
		select @eststats_estimatorname =  firstname + ' ' + lastname
		  from users
		where userid=@estbook_requestedbyname 
	  end

	/** resolve requeststatuscode against gentableid = 394  **/
	select @eststats_requeststatus = ''
	if @estbook_requeststatuscode  is null  
	 begin
		select @estbook_requeststatuscode  = 0
	 end 
	if @estbook_requeststatuscode > 0 
   	  begin
		select @eststats_requeststatus  = datadesc
		  from gentables
			where datacode = @estbook_requeststatuscode
			and tableid=394 
	  end

	/** if null, 'Single Title', if 1, 'Common Form'  **/ 
	if @estbook_estimatetypecode = 1
	  begin
		select @eststats_estimatetype = 'Common Form'
	  end


	select @eststats_customername = ''
	select @eststats_customerdivisionname = ''
	if @estbookorg_orgentrykey  is null  
	 begin
		select @estbookorg_orgentrykey  = 0
	 end 
	if @estbookorg_orgentrykey > 0 
   	  begin
		select @eststats_customername  = orgentrydesc
		  from orgentry
			where orgentrykey = @estbookorg_orgentrykey

		select @estbookorg_orgentrykey  = orgentrykey
		  from estbookorgentry
			where estkey = @eststats_estkey
			and orglevelkey = 3

		select @eststats_customerdivisionname  = orgentrydesc
		  from orgentry
			where orgentrykey = @estbookorg_orgentrykey
	  end



/*  start looping through versions for each estimate  */
/* initialize cursor for estkey */
	DECLARE version_estimates INSENSITIVE CURSOR
	FOR
	select	ev.estkey ,
		ev.versionkey ,
		ev.finishedgoodqty ,
		ev.description ,
		ev.scaleorgentrykey ,
		ev.jobnumber ,
		ev.versiontypecode ,
		es.pagecount ,
		es.trimfamilycode ,
		es.film ,
		es.covertypecode ,
		es.endpapertype ,
		es.firstprinting ,
		es.bluesind 
	from estversion ev, estspecs es
	where ev.estkey=es.estkey
	and   ev.estkey=@estbook_estkey
	and   ev.versionkey=es.versionkey
	order by ev.estkey, ev.versionkey

	FOR READ ONLY
		
	OPEN version_estimates 


	FETCH NEXT FROM version_estimates 
	INTO 
		@estversion_estkey ,
		@estversion_versionkey ,
		@estversion_finishedgoodqty ,
		@estversion_description ,
		@estversion_scaleorgentrykey ,
		@estversion_jobnumber ,
		@estversion_versiontypecode ,
		@estspecs_pagecount ,
		@estspecs_trimfamilycode ,
		@estspecs_film ,
		@estspecs_covertypecode ,
		@estspecs_endpapertype ,
		@estspecs_firstprinting ,
		@estspecs_bluesind 


	select @estversion_fetch_status  = @@FETCH_STATUS
	select @eststats_versioncount = 1


	while (@estversion_fetch_status=0 )  
	begin
		select @eststats_versionkey = @estversion_versionkey
		select @eststats_finishedgoodqty = @estversion_finishedgoodqty
		select @eststats_finishedgoodqtyrange = ''
		select @eststats_versiondescr = @estversion_description
		select @eststats_scalecustomer = ''
		select @eststats_jobnumber = @estversion_jobnumber
		select @eststats_jobind = ''	
		select @eststats_versiontype = ''

		select @eststats_pagecount = @estspecs_pagecount
		select @eststats_pagecountrange = ''
		select @eststats_trimfamily = ''
		select @eststats_filmtype = ''
		select @eststats_covertype = ''
		select @eststats_endpapertype = ''
		select @eststats_printingtype = ''
		select @eststats_bluesind = 'N'

		select @eststats_printbindonlyind ='Y'
		select @eststats_bindmethod = ''
		select @eststats_printnumcolors = 0
		select @eststats_printcolordesc = ''
		select @eststats_versionunitcost = 0
		select @eststats_versionrunpermcost = 0
		select @eststats_versiontotalcost = 0


		/* @eststats_finishedgoodqtyrange varchar (20)  based on finishedgoodqty **/
		select @eststats_finishedgoodqtyrange = 
		CASE 
		  WHEN @eststats_finishedgoodqty < 1000
			THEN 'Under 1,000 copies'
		  WHEN @eststats_finishedgoodqty >= 1000 and @eststats_finishedgoodqty < 2500
			THEN '1,000 - 2,499'
		  WHEN @eststats_finishedgoodqty >= 2500 and @eststats_finishedgoodqty < 5000
			THEN '2,500 - 4,999'
		  WHEN @eststats_finishedgoodqty >= 5000 and @eststats_finishedgoodqty < 10000
			THEN '5,000 - 9,999'
		  WHEN @eststats_finishedgoodqty >= 10000 and @eststats_finishedgoodqty < 15000
			THEN '10,000 - 14,999'
		  WHEN @eststats_finishedgoodqty >= 15000 and @eststats_finishedgoodqty < 20000
			THEN '15,000 - 19,999'
		  WHEN @eststats_finishedgoodqty >= 20000 and @eststats_finishedgoodqty < 40000
			THEN '20,000 - 39,999'
		  WHEN @eststats_finishedgoodqty >= 40000 and @eststats_finishedgoodqty < 50000
			THEN '40,000 - 49,999'
		  ELSE 'Over 50,000 copies'
		END /* case */

		/* @eststats_scalecustomer varchar (50)  use scaleorgentrykey 
		   against orgentry table to get orgentrydesc **/
		if @estversion_scaleorgentrykey  is null  
		 begin
			select @estversion_scaleorgentrykey  = 0
		 end 
		if @estversion_scaleorgentrykey > 0 
   		  begin
			select @eststats_scalecustomer  = orgentrydesc
			  from orgentry
				where orgentrykey = @estversion_scaleorgentrykey
		  end



		/* @eststats_jobind varchar (10)  if jobnumber doesn't start with at least 
		   the first 4 chars numeric, 'non-Job', else 'Job' **/
		select @eval_job = SUBSTRING(@eststats_jobnumber,1,4)
		if ISNUMERIC(@eval_job) = 1
		  begin
			select @eststats_jobind = 'Job'
		  end
		else
		  begin
			select @eststats_jobind = 'non-Job'
		  end


		/* @eststats_versiontype varchar (20)  if null, 'Normal', 
		   0 = 'Common Form', 1 = 'C/F Edition' **/
		select @eststats_versiontype = 
		CASE @estversion_versiontypecode
		  WHEN 0 THEN 'Common Form'
		  WHEN 1 THEN 'C/F Edition'
		  ELSE 'Normal'
		END /* case */


		/* @eststats_pagecountrange varchar (20)  based on pagecount **/
		select @eststats_pagecountrange = 
		CASE 
		  WHEN @eststats_pagecount <= 32
			THEN '32 pages and under'
		  WHEN @eststats_pagecount > 32 and @eststats_pagecount <= 128
			THEN '36 - 128'
		  WHEN @eststats_pagecount > 128 and @eststats_pagecount <= 192
			THEN '132 - 192'
		  WHEN @eststats_pagecount > 192 and @eststats_pagecount <= 256
			THEN '196 - 256'
		  WHEN @eststats_pagecount > 256 and @eststats_pagecount <= 384
			THEN '260 - 384'
		  WHEN @eststats_pagecount > 384 and @eststats_pagecount <= 480
			THEN '388 - 480'
		  WHEN @eststats_pagecount > 480 and @eststats_pagecount <= 560
			THEN '484 - 560'
		  WHEN @eststats_pagecount > 560 and @eststats_pagecount <= 640
			THEN '564 - 640'
		  WHEN @eststats_pagecount > 640 and @eststats_pagecount <= 720
			THEN '644 - 720'
		  WHEN @eststats_pagecount > 720 and @eststats_pagecount <= 832
			THEN '724 - 832'
		  WHEN @eststats_pagecount > 832 and @eststats_pagecount <= 960
			THEN '836 - 960'
		  WHEN @eststats_pagecount > 960 and @eststats_pagecount <= 1024
			THEN '964 - 1024'
		  ELSE 'Over 1024 pages'
		END /* case */



		/* @eststats_trimfamily varchar (20)  resolve 
		   trimfamilycode against gentableid = 29  to get datadesc **/
		if @estspecs_trimfamilycode  is null  
		 begin
			select @estspecs_trimfamilycode  = 0
		 end 
		if @estspecs_trimfamilycode > 0 
   		  begin
			select @eststats_trimfamily  = datadesc
			  from gentables
				where datacode = @estspecs_trimfamilycode
				and tableid=29 
		  end


		/* @eststats_filmtype varchar (20)  resolve 
		   film (datacode) against gentableid = 50  to get datadesc **/
		if @estspecs_film  is null  
		 begin
			select @estspecs_film  = 0
		 end 
		if @estspecs_film > 0 
   		  begin
			select @eststats_filmtype  = datadesc
			  from gentables
				where datacode = @estspecs_film
				and tableid=50 
		  end


		/* @eststats_covertype varchar (20)  resolve 
		   covertypecode against gentableid = 11  to get datadesc **/
		if @estspecs_covertypecode  is null  
		 begin
			select @estspecs_covertypecode  = 0
		 end 
		if @estspecs_covertypecode > 0 
   		  begin
			select @eststats_covertype  = datadesc
			  from gentables
				where datacode = @estspecs_covertypecode
				and tableid=11 
		  end


		/* @eststats_endpapertype varchar (20)  select 
		   endpapertypedesc from endpaper where endpapertypekey=endpapertype (null='N') **/
		if @estspecs_endpapertype  is null  
		 begin
			select @estspecs_endpapertype  = 'A'
		 end 

		select @eststats_endpapertype  = endpapertypedesc
		  from endpaper
			where endpapertypekey = @estspecs_endpapertype
		if SUBSTRING(@eststats_endpapertype, 1, 13) = 'VHP to supply' or
		   SUBSTRING(@eststats_endpapertype, 1, 13) = 'VHP to print '
		  begin
			select @eststats_endpapertype  = SUBSTRING(@eststats_endpapertype, 1, 13)
		  end


		/* @eststats_printingtype varchar (20)  
		   if estspecs.firstprinting = 'Y', 'First Print', else 'Reprint' **/
		if @estspecs_firstprinting = 'Y'
		  begin
			select @eststats_printingtype = 'First Print'
		  end
		else
		  begin
			select @eststats_printingtype = 'Reprint'
		  end


		/* @eststats_bluesind char (1) IF NOT NULL, 
		   THEN FORMAT FROM ESTSPECS */
		if @estspecs_bluesind is NULL
		  begin
			select @eststats_bluesind = 'N'
		  end
		else
		  begin
			select @eststats_bluesind = @estspecs_bluesind
		  end

		/*  start looping through components for each version  */
		/* initialize cursor for estcompkey */
		DECLARE component_estimates INSENSITIVE CURSOR
		FOR
		select
			estkey ,
			versionkey , 
			compkey ,
			groupnum ,
			compqty ,
			methodcode ,
			stockcode , 
			finishcode ,
			inks 
		from estcomp
		where estkey=@estbook_estkey
		and   versionkey=@estversion_versionkey
		order by estkey, versionkey, compkey, groupnum

		FOR READ ONLY
		
		OPEN component_estimates 


		FETCH NEXT FROM component_estimates 
		INTO 
			@estcomp_estkey ,
			@estcomp_versionkey , 
			@estcomp_compkey ,
			@estcomp_groupnum ,
			@estcomp_compqty ,
			@estcomp_methodcode ,
			@estcomp_stockcode , 
			@estcomp_finishcode ,
			@estcomp_inks 


		select @estcomp_fetch_status  = @@FETCH_STATUS
		select @eststats_compcount = 1


		while (@estcomp_fetch_status=0 )  
		begin

			select @eststats_componenttype = ''
			select @eststats_compqty = @estcomp_compqty
			select @eststats_method = ''
			select @eststats_stock = ''
			select @eststats_finish = ''
			select @eststats_numcolors = ''
			select @eststats_colordesc = ''
			select @eststats_compunitcost = 0
			select @eststats_comprunpermcost = 0
			select @eststats_comptotalcost = 0


			/* @eststats_componenttype varchar (20)  select 
			   compdesc from comptype where compkey=estcomp.compkey **/

			select @eststats_componenttype = compdesc
				from comptype
				where compkey=@estcomp_compkey

			if (SUBSTRING(@eststats_componenttype, 1, 4) <> 'Prin' and
			    SUBSTRING(@eststats_componenttype, 1, 4) <> 'Bind')
			  begin
				select @eststats_printbindonlyind ='N'
			  end



			/* @eststats_method varchar (20)  if methodcode is not null, 
			   if compkey=2 resolve bindmethod (tblid=3), else resolve printmethod (tableid=20) **/
			if @estcomp_methodcode  is null  
			 begin
				select @estcomp_methodcode  = 0
			 end 
			if @estcomp_methodcode > 0 
   			  begin
				if @estcomp_compkey = 2
				  begin
					select @eststats_method  = datadesc
					  from gentables
						where datacode = @estcomp_methodcode
						and tableid=3 

					select @eststats_bindmethod = @eststats_method
				  end
				else
				  begin
					select @eststats_method  = datadesc
					  from gentables
						where datacode = @estcomp_methodcode
						and tableid=20 
				  end
			  end


			/* @eststats_stock varchar (20)  if stockcode 
			   is not null, resolve stocktype (tblid=26) **/ 
			if @estcomp_stockcode  is null  
			 begin
				select @estcomp_stockcode  = 0
			 end 
			if @estcomp_stockcode > 0 
   			  begin
				select @eststats_stock  = datadesc
				  from gentables
					where datacode = @estcomp_stockcode
					and tableid=26 
			  end




			/* @eststats_finish varchar (20)  resolve 
			   finishcode against gentableid = 15  to get datadesc **/ 
			if @estcomp_finishcode  is null  
			 begin
				select @estcomp_finishcode  = 0
			 end 
			if @estcomp_finishcode > 0 
   			  begin
				select @eststats_finish  = datadesc
				  from gentables
					where datacode = @estcomp_finishcode
					and tableid=15 
			  end




			/* @eststats_numcolors int  select numcolors
			   @eststats_colordesc varchar (20)  select inkdescshort
			   from ink where inkkey=estcomp.inks  **/
			if @estcomp_inks  is null  
			 begin
				select @estcomp_inks  = 0
			 end 
			if @estcomp_inks > 0 
   			  begin
				select @eststats_numcolors = numcolors,
					@eststats_colordesc = inkdescshort
				  from ink
					where inkkey = @estcomp_inks
				if SUBSTRING(@eststats_componenttype, 1, 4) = 'Prin'  /* print component */
				  begin
					select @eststats_printnumcolors = @eststats_numcolors
					select @eststats_printcolordesc = @eststats_colordesc
				  end
			  end






			/* @eststats_compunitcost float  
			   @eststats_comprunpermcost float  
			   @eststats_comptotalcost float  **/
			select @eststats_comptotalcost = SUM(totalcost),
				@eststats_compunitcost = SUM(unitcost),
				@eststats_comprunpermcost = SUM(runcostper1000)
				from estcost
				where estkey=@estbook_estkey
				and versionkey=@estversion_versionkey
				and compkey=@estcomp_compkey

			select @eststats_versionunitcost = @eststats_versionunitcost + @eststats_compunitcost
			select @eststats_versionrunpermcost = @eststats_versionrunpermcost + @eststats_comprunpermcost
			select @eststats_versiontotalcost = @eststats_versiontotalcost + @eststats_comptotalcost



				/* write component row here before get next row */
					insert into ESTCOMPSTATS (
						estkey ,
						versionkey ,
						componenttype ,
						compqty ,
						method ,
						stock ,
						finish ,
						numcolors ,
						colordesc ,
						compunitcost ,
						comprunpermcost ,
						comptotalcost ,
						compcount )
					values (
						@eststats_estkey ,
						@eststats_versionkey ,
						@eststats_componenttype ,
						@eststats_compqty ,
						@eststats_method ,
						@eststats_stock ,
						@eststats_finish ,
						@eststats_numcolors ,
						@eststats_colordesc ,
						@eststats_compunitcost ,
						@eststats_comprunpermcost ,
						@eststats_comptotalcost ,
						@eststats_compcount)


		FETCH NEXT FROM component_estimates 
		INTO 
			@estcomp_estkey ,
			@estcomp_versionkey , 
			@estcomp_compkey ,
			@estcomp_groupnum ,
			@estcomp_compqty ,
			@estcomp_methodcode ,
			@estcomp_stockcode , 
			@estcomp_finishcode ,
			@estcomp_inks 


		select @estcomp_fetch_status  = @@FETCH_STATUS
		end  /*estcomp loop*/ 

		close component_estimates
		deallocate component_estimates



			/* write version row here before get next row */
				insert into ESTVERSIONSTATS (
					estkey ,
					versionkey ,
					finishedgoodqty ,
					finishedgoodqtyrange ,
					versiondescr ,
					scalecustomer ,
					jobnumber ,
					jobind ,
					versiontype ,
					pagecount ,
					pagecountrange ,
					trimfamily ,
					filmtype ,
					covertype ,
					endpapertype ,
					printingtype ,
					bluesind ,
					printbindonlyind ,
					bindmethod ,
					printnumcolors ,
					printcolordesc ,
					versionunitcost ,
					versionrunpermcost ,
					versiontotalcost ,
					versioncount )
				values (
					@eststats_estkey ,
					@eststats_versionkey ,
					@eststats_finishedgoodqty ,
					@eststats_finishedgoodqtyrange ,
					@eststats_versiondescr ,
					@eststats_scalecustomer ,
					@eststats_jobnumber ,
					@eststats_jobind ,
					@eststats_versiontype ,
					@eststats_pagecount ,
					@eststats_pagecountrange ,
					@eststats_trimfamily ,
					@eststats_filmtype ,
					@eststats_covertype ,
					@eststats_endpapertype ,
					@eststats_printingtype ,
					@eststats_bluesind ,
					@eststats_printbindonlyind ,
					@eststats_bindmethod ,
					@eststats_printnumcolors ,
					@eststats_printcolordesc ,
					@eststats_versionunitcost ,
					@eststats_versionrunpermcost ,
					@eststats_versiontotalcost ,
					@eststats_versioncount )



		 
	FETCH NEXT FROM version_estimates 
	INTO	@estversion_estkey ,
		@estversion_versionkey ,
		@estversion_finishedgoodqty ,
		@estversion_description ,
		@estversion_scaleorgentrykey ,
		@estversion_jobnumber ,
		@estversion_versiontypecode ,
		@estspecs_pagecount ,
		@estspecs_trimfamilycode ,
		@estspecs_film ,
		@estspecs_covertypecode ,
		@estspecs_endpapertype ,
		@estspecs_firstprinting ,
		@estspecs_bluesind 

	select @estversion_fetch_status  = @@FETCH_STATUS

	end  /*estversion loop*/ 


	close version_estimates
	deallocate version_estimates



		/* write estimate row here before get next row */
			insert into ESTSTATS (
				estkey ,
				estimatedescr ,
				bindformat ,
				customername ,
				customerdivisionname ,
				quotenumber ,
				quoteind ,
				createdatetime ,
				estimatorname ,
				requestoriginator ,
				requeststatus ,
				estimatetype 	,
				estcount)
			values (
				@eststats_estkey ,
				@eststats_estimatedescr ,
				@eststats_bindformat ,
				@eststats_customername ,
				@eststats_customerdivisionname ,
				@eststats_quotenumber ,

				@eststats_quoteind ,
				@eststats_createdatetime ,
				@eststats_estimatorname ,
				@eststats_requestoriginator ,
				@eststats_requeststatus ,
				@eststats_estimatetype 	,
				@eststats_estcount )



FETCH NEXT FROM header_estimates 
INTO 	 @estbook_estkey ,
	 @estbook_estimatename ,
	 @estbook_mediatypesubcode ,
	 @estbook_templateind ,
	 @estbook_referencefield ,
	 @estbook_authorillustrator ,
	 @estbook_codenumber ,
	 @estbook_quotenumber ,
	 @estbook_requestdatetime ,
	 @estbook_requestedbyname,
	 @estbook_requestid ,
	 @estbook_requeststatuscode, 
	 @estbook_estimatetypecode ,
	 @estbookorg_orgentrykey

select @estbook_fetch_status  = @@FETCH_STATUS

end  /*estbook loop */ 


close header_estimates
deallocate header_estimates

commit tran
return 0



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

