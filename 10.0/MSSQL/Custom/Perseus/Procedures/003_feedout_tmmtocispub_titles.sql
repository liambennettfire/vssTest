/****** Object:  StoredProcedure [dbo].[feedout_tmmtocispub_titles]    Script Date: 08/03/2009 06:23:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[feedout_tmmtocispub_titles]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[feedout_tmmtocispub_titles]

/****** Object:  StoredProcedure [dbo].[feedout_tmmtocispub_titles]    Script Date: 08/03/2009 06:23:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[feedout_tmmtocispub_titles]
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

DECLARE @titlestatusmessage 	VARCHAR(255)
DECLARE @statusmessage 		VARCHAR(255)
DECLARE @c_outputmessage 	VARCHAR(255)
DECLARE @c_output 		VARCHAR(255)
DECLARE @titlecount		INT
DECLARE @titlecountremainder 	INT
DECLARE @err_msg 		VARCHAR(100)
DECLARE @feed_system_date 	DATETIME
DECLARE @i_isbn 		INT
DECLARE @v_ean			VARCHAR(20)

DECLARE @feed_count 		INT
DECLARE @feedout_bookkey	INT
DECLARE @feedout_title 		VARCHAR(255)
DECLARE @feedout_shorttitle  	VARCHAR(50)
DECLARE @feedout_subtitle	VARCHAR(255)
DECLARE @feed_trimsizelength 	VARCHAR(20)
DECLARE @feed_trimsizewidth 	VARCHAR(20)
DECLARE @feed_esttrimsizewidth 	VARCHAR(20)
DECLARE @feed_esttrimsizelength VARCHAR(20)
DECLARE @feed_tentativepagecount INT
DECLARE @feed_pagecount 	INT
DECLARE @feed_pricekey		INT
DECLARE @feed_pricecode		INT
DECLARE @feed_currencycode 	INT
DECLARE @feed_pricebudget 	DECIMAL(10,2)
DECLARE @feed_pricefinal 	DECIMAL(10,2)
DECLARE @feed_priceeffdate	DATETIME
--DECLARE @feed_prodlinecode	INT		-- commented 8/06/09
DECLARE	@feed_priceonbook	INT
DECLARE	@feed_commission	INT
DECLARE	@feed_compcopy		INT
DECLARE	@feed_returnable	INT
DECLARE @feed_origqty1		INT
DECLARE @feed_origqty2		INT
DECLARE @feed_nypduedate	DATETIME
DECLARE @feed_parentkey 	INT
DECLARE @feed_childkey 		INT
DECLARE @feed_pubdate		DATETIME
DECLARE @feed_warehousedate		DATETIME
DECLARE @i_return		INT

DECLARE @v_toporg			varchar(10)
DECLARE @i_orgentrykey		int
DECLARE @i_sealavalon		int
DECLARE @i_civitas			int				-- added 9/30/09
DECLARE @feedout_isbn 		VARCHAR(10)  
DECLARE @feedout_format 	VARCHAR(40)
DECLARE @feedout_company	VARCHAR(40)		-- added 7/28/09
DECLARE @feedout_publisher	VARCHAR(40)  
DECLARE @feedout_imprint	VARCHAR(40)  
DECLARE @feedout_discount 	VARCHAR(40)  
DECLARE @feedout_territories 	VARCHAR(40)  
DECLARE @feedout_otheredit 	VARCHAR(1)  
DECLARE @feedout_othereditisbn 	VARCHAR(10)  
DECLARE @feedout_pubseries 	VARCHAR(120)  
DECLARE @feedout_volume 	VARCHAR(15)  
DECLARE @feedout_pagecount 	INT 
DECLARE @feedout_pricecirca 	VARCHAR(10)  
DECLARE @feedout_acqeditor1 	VARCHAR(20)
DECLARE @feedout_acqeditor2 	VARCHAR(20)   
DECLARE @feedout_bookseason 	VARCHAR(40)  
DECLARE @feedout_bookedition 	VARCHAR(40)  
DECLARE @feedout_trimsize 		VARCHAR(40) 
DECLARE @feedout_newprice 		VARCHAR(10)
DECLARE @feedout_effectivedate 	VARCHAR(20)
DECLARE @feedout_binding		VARCHAR (50)  
DECLARE @feedout_productline	varchar(20)
DECLARE @feedout_answerdesc		varchar(50)

DECLARE @feedout_nyprelease	DATETIME  
DECLARE @feedout_compcopy	VARCHAR(1)  
DECLARE @feedout_commission	VARCHAR(1)  
DECLARE @feedout_returnable 	VARCHAR(1)  
DECLARE @feedout_timesprinted	VARCHAR(10)  
DECLARE @feedout_writedowncode	VARCHAR(40)  
DECLARE @feedout_bisacstatus	VARCHAR(40)  
DECLARE @feedout_stockduedate	VARCHAR(10) 
DECLARE @feedout_origqty	VARCHAR(10)
DECLARE @feedout_origqtycf	VARCHAR(1)
--DECLARE @feedout_prodline	VARCHAR(40)		-- commented 8/06/09
DECLARE	@feedout_short_title	VARCHAR(120)
DECLARE @feedout_actionlvl	VARCHAR(10)
DECLARE @feedout_nypduedate	VARCHAR(10)
DECLARE @feedout_pubdate	VARCHAR(10)
DECLARE @feedout_warehousedate	VARCHAR(10)
DECLARE @v_found		VARCHAR(10)
DECLARE @v_copyright		VARCHAR(10)
DECLARE @feed_workkey   	INT

DECLARE @feedout_answer_code	varchar(40)
DECLARE @feedout_releasedate	VARCHAR(10) /*expectedshipdate*/
DECLARE @feedout_cartonqty	INT
DECLARE @feedout_spinewidth	VARCHAR(15)
DECLARE @feedout_weight		VARCHAR(10)
DECLARE @feedout_canadianprice 	VARCHAR (23)
DECLARE @feedout_returnbydate   varchar(10)
DECLARE @feedout_cdneffectivedate varchar(20)
DECLARE @feedout_editioncode    varchar(10) 
DECLARE @feedout_isnya 		int

DECLARE @c_message  		VARCHAR(255)

DECLARE @rows			INT
DECLARE @feedkey		INT
DECLARE @feed_last_processdate	DATETIME

SELECT	@statusmessage = 'BEGIN TMM FEED OUT Title AT ' + convert (char,getdate())
PRINT	@statusmessage

SELECT @titlecount=0
SELECT @titlecountremainder=0

SELECT @feed_system_date = getdate()

SELECT @feedkey = max(feedkey) 
FROM	feedout

SELECT @feed_last_processdate = dateprocessed
FROM	feedout
WHERE	feedkey = @feedkey

DELETE FROM tmmtocispub_titles
DELETE FROM feedout_otheredit

SELECT  @rows =count(distinct(ti.bookkey))
FROM 	titlehistory ti, book b
WHERE	ti.lastmaintdate > @feed_last_processdate
		AND ti.lastuserid <> 'CISPUB-2-TMM UPDATES'
		AND ti.bookkey = b.bookkey
		AND b.standardind = 'N'

DECLARE feedout_titles INSENSITIVE CURSOR FOR
SELECT	DISTINCT  i.isbn10,ti.bookkey
FROM	titlehistory ti 
LEFT OUTER JOIN isbn i ON ti.bookkey = i.bookkey 
LEFT OUTER JOIN bookverification bv ON ti.bookkey = bv.bookkey
WHERE   bv.titleverifystatuscode in (7,9)
		AND bv.verificationtypecode=1 
		AND ti.lastmaintdate > @feed_last_processdate
		AND ti.lastuserid <> 'CISPUB-2-TMM UPDATES'
UNION
SELECT	DISTINCT  i.isbn10,ti.bookkey
FROM	datehistory ti 
LEFT OUTER JOIN isbn i ON ti.bookkey = i.bookkey 
LEFT OUTER JOIN bookverification bv ON ti.bookkey = bv.bookkey
WHERE      bv.titleverifystatuscode in (7,9)
		and ti.datetypecode in (8, 32, 47, 399)			--pub date, release date, warehouse date, return by date
		AND bv.verificationtypecode=1  
		AND ti.lastmaintdate > @feed_last_processdate
		AND ti.lastuserid <> 'CISPUB-2-TMM UPDATES'
ORDER BY i.isbn10
	
FOR READ ONLY
		
OPEN feedout_titles 

FETCH NEXT FROM feedout_titles 
INTO  @feedout_isbn,@feedout_bookkey

SELECT @i_isbn  = @@FETCH_STATUS

IF @i_isbn <> 0 /*no isbn*/
	BEGIN	
		INSERT INTO feederror (isbn,batchnumber,processdate,errordesc)
		VALUES (@feedout_isbn,'1',@feed_system_date,'NO ROWS to PROCESS - Titles')
		
	END

WHILE (@i_isbn<>-1 )  /* status 1*/
	BEGIN
		IF (@i_isbn<>-2) /* status 2*/
			BEGIN
/** Increment Title Count, Print Status every 500 rows **/
				SELECT @titlecount=@titlecount + 1
				SELECT @titlecountremainder=0
				SELECT @titlecountremainder = @titlecount % 500

				IF(@titlecountremainder = 0)
					BEGIN
						SELECT @titlestatusmessage = convert (VARCHAR(50),getdate()) + '   ' + convert (VARCHAR(10),@titlecount) + '   Rows Processed'
						PRINT @titlestatusmessage
					END 

	/*set defaults here*/	
				SELECT @v_ean = ''
				SELECT @feedout_format = '' 
				SELECT @feedout_imprint = '' 
				SELECT @feedout_discount = ''
				SELECT @feedout_territories = '' 
				SELECT @feedout_pubseries = '' 
				SELECT @feedout_volume = '' 
				SELECT @feedout_pagecount = 0 
 				SELECT @feedout_acqeditor1 = '' 
 				SELECT @feedout_acqeditor2 = '' 
				SELECT @feedout_bookseason = '' 
				SELECT @feedout_bookedition = '' 
				SELECT @feedout_trimsize = ''
				SELECT @feedout_newprice = 0
   				SELECT @feedout_writedowncode	= ''
				SELECT @feedout_bisacstatus	= '' 
				/*SELECT @feedout_stockduedate = '' */
				SELECT @feedout_nypduedate = ''
    			SELECT @feedout_short_title = ''
				SELECT @feedout_returnable = ''
				
				SELECT @feedout_answer_code = ''
				SELECT @feedout_isnya  = 0
				SELECT @feedout_releasedate= ''
				SELECT @feedout_cartonqty = 0
				SELECT @feedout_spinewidth = ''
				SELECT @feedout_weight= ''
				SELECT @feedout_canadianprice = ''
				SELECT @feedout_returnbydate = ''
				
				SELECT @i_return = 0
				SELECT @feed_trimsizelength = ''
				SELECT @feed_trimsizewidth = ''
				SELECT @feed_esttrimsizewidth = ''
				SELECT @feed_esttrimsizelength = ''
				SELECT @feed_tentativepagecount = 0
				SELECT @feed_pagecount = 0
				SELECT @feed_pricebudget = 0
				SELECT @feed_pricefinal = 0
				SELECT @feedout_editioncode =''
				SELECT @feedout_binding=''
				
		/* Check for proper Organizations, based on top org */
				select @v_toporg = dbo.get_grouplevel1(@feedout_bookkey,'S')

				--need to classify Avalon & Seal travel as PBG, even though they are in PGW's structure
				set @i_sealavalon = 0

				select @i_orgentrykey = orgentrykey
				from bookorgentry
				where orglevelkey = 2
				and bookkey = @feedout_bookkey

				if @i_orgentrykey = 714 or @i_orgentrykey = 835
				begin
					set @i_sealavalon = 1
					set @v_toporg = 'PBG'
				end

				--need to promote imprint to publisher for Basic Civitas						-- added 9/30/09
				set @i_civitas = 0

				select @i_orgentrykey = orgentrykey
				from bookorgentry
				where orglevelkey = 3
				and bookkey = @feedout_bookkey

				if @i_orgentrykey = 1005
				begin
					set @i_civitas = 1
				end

				if @v_toporg = 'PBG'
					begin
						/*Check for Company/PubCd	*/

						SELECT	@feedout_company =  @v_toporg									-- added 7/28/09

--						SELECT	@feedout_publisher =  dbo.get_GroupLevel3(@feedout_bookkey,'A')
						SELECT	@feedout_publisher =											-- edited 9/30/09
						case when @i_civitas = 1 then
							dbo.get_GroupLevel3(@feedout_bookkey,'S')							-- edited 9/30/09
						else
							dbo.get_GroupLevel2(@feedout_bookkey,'S')							-- edited 9/30/09
						end

--						select @feedout_imprint = ''
						SELECT	@feedout_imprint = dbo.get_GroupLevel3(@feedout_bookkey,'S')	-- edited 9/30/09

						/*Check for Product line - for Boulder Cispub for PBG	*/
						select @feedout_productline = substring(dbo.get_product_line(@feedout_bookkey,'E'),1,20)

					end
				else if @v_toporg = 'PGW' or @v_toporg = 'CBSD'
					begin
						/*Check for Division - "P-code" for PGW	*/
						/* company in TMM - Division in CISPUB */

						SELECT	@feedout_company =  @v_toporg									-- added 7/28/09

--						SELECT	@feedout_publisher = @v_toporg
						SELECT	@feedout_publisher =  dbo.get_GroupLevel2(@feedout_bookkey,'S')	-- edited 9/30/09

						/* Publisher in TMM - Division in CISPUB */
						SELECT	@feedout_imprint = dbo.get_GroupLevel3(@feedout_bookkey,'S')	-- edited 9/30/09

						select @feedout_productline = ''
					end
				else if @v_toporg = 'PD'
					begin

						SELECT	@feedout_company =  @v_toporg									-- added 7/28/09

						/* publisher in TMM - Division in CISPUB */
						SELECT	@feedout_publisher = dbo.get_GroupLevel2(@feedout_bookkey,'S')	-- edited 9/30/09

						/* Publisher in TMM - Division in CISPUB */
						SELECT	@feedout_imprint = dbo.get_GroupLevel3(@feedout_bookkey,'S')	-- edited 9/30/09

						select @feedout_productline = ''
					end


		/* EAN, title, shorttitle, subtitle, territory */
				SELECT  @v_ean = dbo.get_ISBN(@feedout_bookkey,17)

				SELECT 	@feedout_title = dbo.get_Title(@feedout_bookkey,'T')
				SELECT 	@feedout_title = dbo.replace_xchars(@feedout_title)
				
				SELECT	@feedout_shorttitle = dbo.get_ShortTitle(@feedout_bookkey)
				SELECT	@feedout_shorttitle = dbo.replace_xchars(@feedout_shorttitle)

				SELECT	@feedout_subtitle = dbo.get_SubTitle(@feedout_bookkey)
				SELECT	@feedout_subtitle = dbo.replace_xchars(@feedout_subtitle)		

		/* Territories, discount, edition, format, series, volume, bisacstatus */
				SELECT @feedout_territories = dbo.get_Territory(@feedout_bookkey,'E')
				SELECT @feedout_discount = dbo.get_Discount(@feedout_bookkey,'E') 
				SELECT @feedout_bookedition = dbo.get_Edition(@feedout_bookkey,'S') 
				SELECT @feedout_editioncode = dbo.get_Edition(@feedout_bookkey,'C')
				SELECT @feedout_format = dbo.get_media(@feedout_bookkey,'E') 
				SELECT @feedout_pubseries = dbo.get_Series(@feedout_bookkey,'E') 

				if @v_toporg = 'PGW' or @v_toporg = 'CBSD'
				begin
					SELECT @feedout_bisacstatus = dbo.get_BisacStatusCispub(@feedout_bookkey,'1') 
				end
				else if @v_toporg = 'PBG'
				begin
					SELECT @feedout_bisacstatus = dbo.get_BisacStatusCispub(@feedout_bookkey,'2') 
				end
				else if @v_toporg = 'PD'
				begin
					SELECT @feedout_bisacstatus = dbo.get_BisacStatusCispub(@feedout_bookkey,'1') 
				end

				SELECT @feedout_answer_code = dbo.get_answer_code (@feedout_bookkey,'E')
				SELECT @feedout_answerdesc = dbo.get_answer_code (@feedout_bookkey,'D')

				SELECT @feedout_binding =dbo.get_format (@feedout_bookkey,'2') 

				SELECT	@feedout_volume = volumenumber					
				FROM bookdetail 
				WHERE bookkey = @feedout_bookkey

				IF COALESCE(@feedout_volume,0)=0
					BEGIN
						SELECT @feedout_volume = ''
					END

				SELECT @feed_count = 0

				SELECT @feed_count = optionvalue 
				FROM 	clientoptions
				WHERE 	optionid = 4  /*9-9-03 clientoptions pagecount*/

				IF @feed_count = 1
  					BEGIN
						SELECT @feed_pagecount = tmmpagecount 
						FROM 	printing
	 					WHERE 	bookkey = @feedout_bookkey
							AND  printingkey = 1 
  					END
				ELSE
					BEGIN	
						SELECT @feed_pagecount = pagecount 
						FROM 	printing
 						WHERE 	bookkey = @feedout_bookkey
							AND  printingkey = 1 
					END

				SELECT @feed_count = 0

				SELECT @feed_count = optionvalue 
				FROM 	clientoptions
				WHERE 	optionid = 7  /*9-9-03 clientoptions trim*/

				IF @feed_count = 1
					BEGIN
						SELECT @feed_trimsizelength = tmmactualtrimlength,
							@feed_trimsizewidth =tmmactualtrimwidth
						FROM	printing
 						WHERE bookkey = @feedout_bookkey
							AND  printingkey = 1 
					END
				ELSE
					BEGIN	
						SELECT @feed_trimsizelength = trimsizelength,
							@feed_trimsizewidth = trimsizewidth
						FROM 	printing
						WHERE bookkey = @feedout_bookkey
							AND  printingkey = 1 
					END

	/* pagecount,trimsize,spinesize	 */	
				SELECT @feed_tentativepagecount = tentativepagecount,
					@feed_esttrimsizewidth = esttrimsizewidth,
					@feed_esttrimsizelength = esttrimsizelength,
					@feedout_spinewidth = spinesize		
				FROM printing
				WHERE bookkey = @feedout_bookkey
					AND  printingkey = 1 

				IF datalength(rtrim(@feed_trimsizewidth)) > 0 and datalength(rtrim(@feed_trimsizelength)) > 0 
					BEGIN
						SELECT @feedout_trimsize = @feed_trimsizewidth + ' x ' + @feed_trimsizelength
					END
				ELSE
					BEGIN
						SELECT @feedout_trimsize = @feed_esttrimsizewidth + ' x ' + @feed_esttrimsizelength
					END
		
				IF rtrim(ltrim(@feedout_trimsize)) = 'x' 
					BEGIN
						SELECT @feedout_trimsize = ''
					END

				IF @feed_pagecount > 0
					BEGIN
						SELECT @feedout_pagecount =  @feed_pagecount
					END
				ELSE
					BEGIN
						SELECT @feedout_pagecount = @feed_tentativepagecount
					END

	/* QUANTITY */
				SELECT 	@feed_origqty1 = tentativeqty,
					@feed_origqty2 = firstprintingqty
				FROM printing
				WHERE bookkey = @feedout_bookkey
					AND  printingkey = 1 

				IF @feed_origqty2 > 0 and  @feed_origqty2 is not  NULL 
				/*Check Actual Qty is greater than 0*/
					BEGIN
						SELECT @feedout_origqty = CONVERT(VARCHAR,@feed_origqty2)
						SELECT @feedout_origqtycf = 'F'
					END

				IF (@feed_origqty2 is NULL OR @feed_origqty2 = 0) and @feed_origqty1 > 0	
				/*If actual is not greater than 0 use the estimated*/
					BEGIN
						SELECT @feedout_origqty = CONVERT(VARCHAR,@feed_origqty1)
						SELECT @feedout_origqtycf = 'C'
					END
					
				IF (@feed_origqty2 is NULL OR @feed_origqty2 = 0) and (@feed_origqty1 is NULL OR @feed_origqty1 = 0)
					BEGIN
						SELECT @feedout_origqty =  ''
						SELECT @feedout_origqtycf = ''
					END	

	/* prices*/
				SELECT @feed_count = 0

				SELECT @feed_count = count(*) 
				FROM	filterpricetype
				WHERE 	filterkey = 5 	/*currency and price types*/

				IF @feed_count > 0 
					BEGIN
						SELECT @feed_pricecode= pricetypecode, 
							@feed_currencycode = currencytypecode
	 					FROM	filterpricetype
						WHERE filterkey = 5 /*currency and price types*/
					END

				SELECT TOP 1 @feed_priceeffdate = max(effectivedate),
						@feed_pricekey = pricekey,
						@feed_pricefinal = finalprice,
						@feed_pricebudget =budgetprice
				FROM bookprice
				WHERE bookkey = @feedout_bookkey
						AND activeind = 1
						AND pricetypecode = @feed_pricecode
	    					AND currencytypecode = @feed_currencycode
				GROUP BY effectivedate, pricekey,finalprice,budgetprice
				ORDER BY effectivedate DESC

				select @feedout_cdneffectivedate =dbo.get_BestCdnPrice_EffDate (@feedout_bookkey,@feed_pricecode)

				IF @feed_priceeffdate IS NOT NULL
					BEGIN
						SELECT @feedout_effectivedate = CONVERT(VARCHAR,@feed_priceeffdate,101)
					END
				ELSE
					BEGIN
						SELECT @feedout_effectivedate = ''
					END

				IF @feed_pricefinal IS NOT NULL
					BEGIN
						IF @feed_pricefinal > 0
							BEGIN
								SELECT @feedout_newprice = @feed_pricefinal
								SELECT @feedout_pricecirca = 'F'
							END
						ELSE
							BEGIN
								SELECT @feedout_newprice = @feed_pricefinal
								SELECT @feedout_pricecirca = 'F'
							END
					END
				ELSE
					BEGIN
						IF @feed_pricebudget IS NOT NULL
							BEGIN
								IF @feed_pricebudget > 0
									BEGIN
										SELECT @feedout_newprice = @feed_pricebudget
										SELECT @feedout_pricecirca = 'C'
									END
								ELSE
									BEGIN
										SELECT @feedout_newprice = 0
										SELECT @feedout_pricecirca = 'C'
									END
							END
						ELSE
							BEGIN
								SELECT @feedout_newprice = 0
								SELECT @feedout_pricecirca = 'C'
							END				
					END

	/*canadian price*/
				SELECT @feedout_canadianprice = dbo.get_best_cdn_price(@feedout_bookkey,11)

	/*season*/
				SELECT @feed_count = 0
				SELECT @feed_count  = seasonkey 
				FROM	printing 
				WHERE	bookkey = @feedout_bookkey 
						AND printingkey = 1

				IF @feed_count  > 0
					BEGIN
						SELECT @feedout_bookseason = seasonshortdesc 
						FROM	season
						WHERE	seasonkey = @feed_count
					END

				ELSE
					BEGIN
						SELECT @feed_count = 0
						SELECT @feed_count  = estseasonkey 
						FROM printing 
						WHERE bookkey = @feedout_bookkey 
							AND printingkey = 1

						IF @feed_count  > 0
  							BEGIN
								SELECT @feedout_bookseason = seasonshortdesc 
								FROM	season
								WHERE	seasonkey = @feed_count
  							END
					END

	/*acq editor  1  & 2 	*/
				SELECT @feedout_acqeditor1 = dbo.get_WebRolePerson(@feedout_bookkey,1,'S')
				SELECT @feedout_acqeditor2 = dbo.get_WebRolePerson(@feedout_bookkey,2,'S')	

	/* Copy Right - stored as an integer with an edit mask of 0### - this allows the client press to enter the year (i.e. 2005)
		or the mmyy (i.e. 0605).  The mmyy is stored as a 3 digit integer, so the feed out will need to add 0 prefix if
		there is only 3 digits */

				SELECT @v_copyright = copyrightyear
				FROM bookdetail
				WHERE bookkey = @feedout_bookkey								
							
	/* Pub  Date		*/
				SELECT @feed_pubdate = bestdate
				FROM bookdates
				WHERE bookkey = @feedout_bookkey
							AND printingkey = 1
							AND datetypecode = 8

				IF datalength(@feed_pubdate)> 0
					SELECT @feedout_pubdate = convert(varchar,@feed_pubdate,101)
					
				ELSE
					SELECT @feedout_pubdate = ''

				IF @feed_pubdate IS NULL
					SELECT @feedout_pubdate = ''


	/* NYP Due Date		*/
				SELECT @feed_nypduedate = bestdate
				FROM bookdates
				WHERE bookkey = @feedout_bookkey
							AND printingkey = 1
							AND datetypecode = 32

				IF datalength(@feed_nypduedate)> 0
					SELECT @feedout_nypduedate = convert(varchar,@feed_nypduedate,101)
					
				ELSE
					SELECT @feedout_nypduedate = ''

				IF @feed_nypduedate IS NULL
					SELECT @feedout_nypduedate = ''

	/*stock due date 	*/
				/*SELECT @feedout_stockduedate = dbo.get_BestStockDueDate(@feedout_bookkey,1)*/

	/*release date*/
				SELECT @feedout_releasedate = dbo.get_BestReleaseDate (@feedout_bookkey,1)

	/* Warehouse  Date		*/
				SELECT @feedout_warehousedate = dbo.get_bestdate (@feedout_bookkey, 1, 47)

	/*cartonqty*/
				SELECt @feedout_cartonqty = dbo.get_cartonqty (@feedout_bookkey,1)

	/*bookweight*/			
				SELECT @feedout_weight = bookweight
				FROM booksimon
				WHERE bookkey = @feedout_bookkey
				
	/*returnbydate*/
				SELECT @feedout_returnbydate = dbo.get_bestdate (@feedout_bookkey,1,399)				

/*		-- Commented out 8/06/09
	/* Product Line and ABC Class	*/
				if @v_toporg = 'PGW'
					begin	
						SELECT @feed_prodlinecode = customcode01
						FROM 	bookcustom
						WHERE	bookkey = @feedout_bookkey

						IF @feed_prodlinecode > 0
	  						BEGIN
								SELECT  @feedout_prodline = dbo.get_customcode01(@feedout_bookkey,'E')
							END 

						ELSE
							BEGIN
								SELECT  @feedout_prodline = ''
							END
					end
				else
					begin
						select @feedout_prodline = ''
					end
*/
	/*  Commission, CompCopies, and Returnable*/
					
				SELECT 	@feed_commission = customind06,
					@feed_compcopy = customind07
				FROM	bookcustom
				WHERE bookkey = @feedout_bookkey

	/*	Commission	*/
				
				SET @feedout_commission = CASE @feed_commission
						WHEN 1	THEN	'Y'
						WHEN 0	THEN	'N'
						ELSE	''
					END
				
	/*	Compy Copy	*/
				
				SET @feedout_compcopy =  CASE @feed_compcopy
						WHEN 1	THEN	'Y'
						WHEN 0	THEN	'N'
						ELSE	''
					END

	/*	Action Level	*/

				SELECT @feed_count = 0
				SELECT 	@feed_count = customint03
				FROM bookcustom
				WHERE bookkey = @feedout_bookkey

				IF @feed_count > 0
					SELECT @feedout_actionlvl = @feed_count

				ELSE
					SELECT @feedout_actionlvl = ''

	/*	Write Down Code	*/

				SELECT @feed_count = 0

				SELECT 	@feed_count = customint04
				FROM bookcustom
				WHERE bookkey = @feedout_bookkey

				IF @feed_count > 0
					SELECT @feedout_writedowncode = @feed_count

				ELSE
					SELECT @feedout_writedowncode = ''

	/* 	Times Printed	*/

				SELECT @feed_count = 0
				
				SELECT 	@feed_count = customint05
				FROM bookcustom
				WHERE bookkey = @feedout_bookkey	
				
				IF @feed_count > 0
					SELECT @feedout_timesprinted = @feed_count

				ELSE
					SELECT @feedout_timesprinted = ''

		/* Returns	*/
				
				SELECT @i_return = returncode
				FROM bookdetail
				WHERE bookkey = @feedout_bookkey

				IF @i_return = 2
					BEGIN
						SELECT @feedout_returnable = 'Y'
					END
				ELSE
					BEGIN
						SELECT @feedout_returnable = 'N'
					END

		/* other edition */
				SELECT @feedout_otheredit = 'N'
				SELECT @feedout_othereditisbn = ''
				SELECT @feed_parentkey = 0
				SELECT @feed_childkey = 0

				SELECT @feed_workkey = workkey
				FROM book
				WHERE bookkey = @feedout_bookkey

				IF @feedout_bookkey <> @feed_workkey
					BEGIN
						SELECT @v_found = ''

						SELECT @feed_parentkey = bookkey
						FROM book
						WHERE bookkey = @feed_workkey

						select @v_found = i.isbn10
						FROM isbn i 
						WHERE i.bookkey = @feed_parentkey

						IF @v_found IS NOT NULL AND ltrim(rtrim(@v_found)) <> ''
							BEGIN
								SELECT @feedout_otheredit = 'Y'
								SELECT @feedout_othereditisbn = @v_found
							END
						
						ELSE
							BEGIN
								SELECT @feedout_otheredit = 'N'
								SELECT @feedout_othereditisbn = ''
							END
					END

				IF @feedout_bookkey = @feed_workkey
					BEGIN
						SELECT @v_found = ''

						SELECT TOP 1 @feed_childkey = b.bookkey
						FROM book b LEFT OUTER JOIN book b1 ON b.bookkey = b1.bookkey
						WHERE b.workkey = @feed_workkey 
							AND b.linklevelcode <> 10

						IF @feed_childkey IS NOT NULL 
							BEGIN
								SELECT @v_found = i.isbn10
								FROM	isbn i 
								WHERE	i.bookkey = @feed_childkey 
								
								IF @v_found IS NOT NULL AND ltrim(rtrim(@v_found)) <> ''
									BEGIN
										SELECT @feedout_otheredit = 'Y'
										SELECT @feedout_othereditisbn = @v_found
									END
							END
						ELSE
							BEGIN
								SELECT @feedout_otheredit = 'N'
								SELECT @feedout_othereditisbn = ''
							END
					END

/*INSERT INTO feed out table*/
				INSERT INTO tmmtocispub_titles
					(isbn,
					ean,
					type,
					company,			-- added 7/28/09
					publisher,			-- edited 7/28/09
					imprint,
--					prodline,			-- commented 8/06/09
					discount,
					territories,
					pubseries,
					volume,
					title,
					shorttitle,
					subtitle,
					pagecount,
					acqeditor1,
					acqeditor2,
					copyright,
					season,
					edition,
					trimsize,
					newprice,
					effectivedate,
					pricecirca,	
					actionlvl,
					compcopy,
					commission,
					returnable,
					writedowncode,
					pubstatus,
					nypduedate,
					/*stockduedate,*/
					origqty,
					origqtycf,
					pubdate,
					answer_code,
					expectedshipdate,
					cartonqty,
					spinewidth,
					weight,
					canadianprice,
					returnbydate,
					cdneffectivedate,
					editioncode,
					binding,
					productline,
					answer_codedesc,
					warehousedate)
					VALUES 
					(@feedout_isbn,
					@v_ean,
					@feedout_format,
					@feedout_company,		-- added 7/28/09
					@feedout_publisher,
					@feedout_imprint,
--					@feedout_prodline,		-- commented 8/06/09
					@feedout_discount,
					@feedout_territories,
					@feedout_pubseries,
					@feedout_volume,
					@feedout_title,
					@feedout_shorttitle,
					@feedout_subtitle,
					@feedout_pagecount,
					@feedout_acqeditor1,
					@feedout_acqeditor2,
					@v_copyright,
					@feedout_bookseason,
					@feedout_bookedition,
					@feedout_trimsize,
					@feedout_newprice,
					@feedout_effectivedate,
					@feedout_pricecirca,
					@feedout_actionlvl,
					@feedout_compcopy,
					@feedout_commission,
					@feedout_returnable,
					@feedout_writedowncode,
					@feedout_bisacstatus,
					@feedout_nypduedate,
					/*@feedout_stockduedate,*/
					@feedout_origqty,
					@feedout_origqtycf, 
					@feedout_pubdate,
					@feedout_answer_code, /*34*/
					@feedout_releasedate,
					@feedout_cartonqty,
					@feedout_spinewidth,
					@feedout_weight,
					@feedout_canadianprice,
					@feedout_returnbydate,
					@feedout_cdneffectivedate,
					@feedout_editioncode,
					@feedout_binding,
					@feedout_productline,
					@feedout_answerdesc,
					@feedout_warehousedate)
		
				INSERT INTO feedout_otheredit(isbn,otheredit,othereditisbn)
				VALUES (@feedout_isbn,@feedout_otheredit,@feedout_othereditisbn)      		
	
			END /*isbn status 2*/

	FETCH NEXT FROM feedout_titles 
	INTO  @feedout_isbn,@feedout_bookkey

	SELECT @i_isbn  = @@FETCH_STATUS

END /*isbn status 1*/

UPDATE pofeeddate
SET feeddate = tentativefeeddate
WHERE feeddatekey=7

INSERT INTO feederror (batchnumber,processdate,errordesc)
VALUES ('1',@feed_system_date,'Titles Out Completed')

SELECT @feedkey = max(@feedkey)+1
INSERT INTO feedout(feedkey,type,dateprocessed,numrows)
VALUES(@feedkey,7,@feed_system_date,@rows)

CLOSE feedout_titles
DEALLOCATE feedout_titles

SELECT @statusmessage = 'END TMM FEED OUT Titles AT ' + convert (char,getdate())
PRINT @statusmessage

RETURN 0







