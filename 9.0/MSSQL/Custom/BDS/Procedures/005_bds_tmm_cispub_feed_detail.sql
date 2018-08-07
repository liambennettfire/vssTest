IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[bds_tmm_cispub_feed_detail]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[bds_tmm_cispub_feed_detail]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

/***********************************************************************************************************************/
/*		Author:		Kusum Basra                                                                                                                                                                                                */
/*	 	Date created : 03/31/10                                                                                                                                                                                                  */
/*         Description: populates table bds_tmm_cispub_feed - this table willl later be exported to a pipe delimited file and a job set up to ftp this file to client server     */
/*                           Procedure called from bds_tmm_cispub_feed_driver - bookkey is passed as argument                                                                                     */                                                                           
/***********************************************************************************************************************/

CREATE PROCEDURE [dbo].[bds_tmm_cispub_feed_detail] 
	@i_bookkey int = 0, 
	@o_error_code   integer output,
	@o_error_desc   varchar(2000) output

AS
BEGIN

declare    
@v_error  INT,
@v_rowcount INT,
@v_count 	INT,
@EAN13 		varchar(19),
@Title		varchar(255),
@Publisher 	varchar(255),
@v_authorkey	INT,
@ContributorLastName1 varchar(80),
@ContributorLastName2 varchar(80),
@ContributorLastName3 varchar(80),
@ContributorLastName4 varchar(80),
@ContributorLastName5 varchar(80),
@ContributorFirstName1 varchar(80),
@ContributorFirstName2 varchar(80),
@ContributorFirstName3 varchar(80),
@ContributorFirstName4 varchar(80),
@ContributorFirstName5 varchar(80),
@ContributorRole1 varchar(30),
@ContributorRole2 varchar(30),
@ContributorRole3 varchar(30),
@ContributorRole4 varchar(30),
@ContributorRole5 varchar(30),
--@ContributorBio1 varchar(max),
--@ContributorBio2 varchar(max),
--@ContributorBio3 varchar(max),
--@ContributorBio4 varchar(max),
@AuthorBios varchar(max),
@USDPrice		varchar(23),
@CADPrice		varchar(23),
@UKPrice		varchar(23),
@EuroPrice		varchar(23),
@BookWeight   varchar(23),
@CartonQty      varchar(23),
@CartonWeight  varchar(23),
@Length			varchar(23),
@Width			varchar(23),
@Spinesize			varchar(23),
@i_bookweight float,
@i_cartonqty    float,
@i_copyrightyear float,
@i_cartonweight float,
@Media 		varchar(255),
@Binding		varchar(255),
@PageCount varchar(23),
@CopyRightYear	varchar(23),
@BisacCode1  varchar(255),
@BisacCode2  varchar(255),
@BisacCode3  varchar(255),
@PubDate varchar(10),
@Description varchar(max),
@InDuedate  varchar(10),
@Edition varchar(100),
@BisacStatus varchar(255),
@Color varchar(255),
@WebPageKeyWords varchar(max),
@WebPageCategories varchar(900),
@v_subject1	VARCHAR(100),
@v_subject2	VARCHAR(100),
@v_subject3	VARCHAR(100),
@v_subject4	VARCHAR(100),
@v_subject5	VARCHAR(100),
@v_subject6	VARCHAR(100),
@v_subject7	VARCHAR(100),
@v_subject8	VARCHAR(100),
@v_subject9	VARCHAR(100),
@v_subject10	VARCHAR(100),
@Rights varchar(255),
@PrimaryEAN varchar(19),
@TitleWebSiteURL  varchar(255),
@Imprint 			varchar(40),
@SubTitle			varchar(255),
@SeriesName		varchar(50),
@AuthorResidence varchar(max),
@Audience			varchar(40),
@AgeRange			varchar(40),
@Announced1stPrinting  int,
@CountryofOrigin	varchar(40),
@InsertsIllustrations varchar(255)


SET @o_error_code = 0
SET @o_error_desc = ''  
SET @EAN13 = null
SET @Title = Null
SET @Publisher = NULL
SET @USDPrice = NULL
SET @CADPrice = NULL
SET @UKPrice = NULL
SET @EuroPrice = NULL
SET @Length = null
SET @Width = null
SET @SpineSize = null
SET @BookWeight = NULL
SET @CartonQty  = NULL
SET @CartonWeight = NULL
SET @Length = NULL
SET @Width = NULL
SET @Spinesize = NULL
SET @Media = null
SET @Binding = null
SET @PageCount = null
SET @CopyRightYear = null
SET @BisacCode1 = null
SET @BisacCode2 = null
SET @BisacCode3 = null
SET @PubDate = null
SET @Description = null
SET @Edition= NULL
SET @BisacStatus = NULL
SET @Color = NULL
SET @WebPageKeyWords = NULL
SET @Rights= NULL
SET @PrimaryEAN = NULL
SET @TitleWebSiteURL = NULL
SET @ContributorLastName1 = NULL
SET @ContributorFirstName1 = NULL
SET @ContributorRole1 = NULL
--SET @ContributorBio1 = NULL
SET @ContributorLastName2 = NULL
SET @ContributorFirstName2 = NULL
SET @ContributorRole2 = NULL
--SET @ContributorBio2 = NULL
SET @ContributorLastName3 = NULL
SET @ContributorFirstName3 = NULL
SET @ContributorRole3 = NULL
--SET @ContributorBio3 = NULL
SET @ContributorLastName4 = NULL
SET @ContributorFirstName4 = NULL
SET @ContributorRole4 = NULL
--SET @ContributorBio4= NULL
SET @ContributorLastName5 = NULL
SET @ContributorFirstName5 = NULL
SET @ContributorRole5 = NULL
SET @AuthorBios = NULL
SET @WebPageCategories = NULL
SET @v_subject1	= NULL
SET @v_subject2	= NULL
SET @v_subject3	= NULL
SET @v_subject4	= NULL
SET @v_subject5	= NULL
SET @v_subject6	= NULL
SET @v_subject7	= NULL
SET @v_subject8	= NULL
SET @v_subject9	= NULL
SET @v_subject10	= NULL
SET @Imprint = NULL
SET @SubTitle = NULL
SET @SeriesName = NULL
SET @AuthorResidence = NULL
SET @Audience = NULL
SET @AgeRange = NULL
SET @Announced1stPrinting = NULL
SET @CountryofOrigin = NULL
SET @InsertsIllustrations = NULL

select @EAN13 = substring(dbo.get_isbn (@i_bookkey, 16),1,19)
IF @EAN13 IS NOT NULL 
BEGIN
	print 'EAN13'
	print @EAN13
	select @Title = substring(dbo.get_title (@i_bookkey, 'T'),1,255)
	print 'Title'
	print @Title
	select @Publisher = substring(dbo.get_grouplevel2 (@i_bookkey,1),1,255)
	print '@Publisher'
	print @Publisher
	
	set @v_count = 0
	select @v_count = count(*)
		from bookauthor
	 where bookkey = @i_bookkey
		  and sortorder = 1
	
	IF @v_count = 1
	BEGIN
		select @v_authorkey = authorkey
		  from bookauthor
	  where bookkey = @i_bookkey
			and sortorder = 1
		select @ContributorLastName1 = substring(dbo.rpt_get_contact_name(@v_authorkey,'L'),1,80)
		select @ContributorFirstName1 = substring(dbo.rpt_get_contact_name(@v_authorkey,'F'),1,80)
		select @ContributorRole1 = substring(dbo.rpt_get_author_type(@i_bookkey,1,'E'),1,40)
		---select @ContributorBio1 = substring(dbo.get_AuthorBio(@i_bookkey,3),1,8000)
	END
	print '@ContributorLastName1'
	print @ContributorLastName1
	print '@ContributorFirstName1'
	print @ContributorFirstName1
	print '@ContributorRole1'
	print @ContributorRole1
	----print '@ContributorBio1'
	----print @ContributorBio1
	
	set @v_count = 0
	select @v_count = count(*)
		from bookauthor
	 where bookkey = @i_bookkey
		  and sortorder = 2
	
	IF @v_count = 1
	BEGIN
		select @v_authorkey = authorkey
		  from bookauthor
	  where bookkey = @i_bookkey
			and sortorder = 2
		select @ContributorLastName2 = substring(dbo.rpt_get_contact_name(@v_authorkey,'L'),1,80)
		select @ContributorFirstName2 = substring(dbo.rpt_get_contact_name(@v_authorkey,'F'),1,80)
		select @ContributorRole2 = substring(dbo.rpt_get_author_type(@i_bookkey,2,'E'),1,40)
		----select @ContributorBio2 = substring(dbo.get_AuthorBio(@i_bookkey,3),1,8000)
	END
	print '@ContributorLastName2'
	print @ContributorLastName2
	print '@ContributorFirstName2'
	print @ContributorFirstName2
	print '@ContributorRole2'
	print @ContributorRole2
	---print '@ContributorBio2'
	---print @ContributorBio2
	
	set @v_count = 0
	select @v_count = count(*)
		from bookauthor
	 where bookkey = @i_bookkey
		  and sortorder = 3
	
	IF @v_count = 1
	BEGIN
		select @v_authorkey = authorkey
		  from bookauthor
	  where bookkey = @i_bookkey
			and sortorder = 3
		select @ContributorLastName3 = substring(dbo.rpt_get_contact_name(@v_authorkey,'L'),1,80)
		select @ContributorFirstName3 = substring(dbo.rpt_get_contact_name(@v_authorkey,'F'),1,80)
		select @ContributorRole3 = substring(dbo.rpt_get_author_type(@i_bookkey,3,'E'),1,40)
		---select @ContributorBio3 = substring(dbo.get_AuthorBio(@i_bookkey,3),1,8000)
	END
	print '@ContributorLastName3'
	print @ContributorLastName3
	print '@ContributorFirstName3'
	print @ContributorFirstName3
	print '@ContributorRole3'
	print @ContributorRole3
	----print '@ContributorBio3'
	---print @ContributorBio3
	
	set @v_count = 0
	select @v_count = count(*)
		from bookauthor
	 where bookkey = @i_bookkey
		  and sortorder = 4
	
	IF @v_count = 1
	BEGIN
		select @v_authorkey = authorkey
		  from bookauthor
	  where bookkey = @i_bookkey
			and sortorder = 4
		select @ContributorLastName4 = substring(dbo.rpt_get_contact_name(@v_authorkey,'L'),1,80)
		select @ContributorFirstName4 = substring(dbo.rpt_get_contact_name(@v_authorkey,'F'),1,80)
		select @ContributorRole4 = substring(dbo.rpt_get_author_type(@i_bookkey,4,'E'),1,40)
		----select @ContributorBio4 = substring(dbo.get_AuthorBio(@i_bookkey,3),1,8000)
	END
	
	print '@ContributorLastName4'
	print @ContributorLastName4
	print '@ContributorFirstName4'
	print @ContributorFirstName4
	print '@ContributorRole4'
	print @ContributorRole4
	---print '@ContributorBio4'
	---print @ContributorBio4
	
	set @v_count = 0
	select @v_count = count(*)
		from bookauthor
	 where bookkey = @i_bookkey
		  and sortorder = 5
	
	IF @v_count = 1
	BEGIN
		select @v_authorkey = authorkey
		  from bookauthor
	  where bookkey = @i_bookkey
			and sortorder = 5
		select @ContributorLastName5 = substring(dbo.rpt_get_contact_name(@v_authorkey,'L'),1,80)
		select @ContributorFirstName5 = substring(dbo.rpt_get_contact_name(@v_authorkey,'F'),1,80)
		select @ContributorRole4 = substring(dbo.rpt_get_author_type(@i_bookkey,5,'E'),1,40)
		---select @ContributorBio5 = substring(dbo.get_AuthorBio(@i_bookkey,3),1,8000)
	END
	print '@ContributorLastName5'
	print @ContributorLastName5
	print '@ContributorFirstName5'
	print @ContributorFirstName5
	print '@ContributorRole5'
	print @ContributorRole5
	---print '@ContributorBio5'
	---print @ContributorBio5
---bookcomments.commenthtmllite where commenttypecode = 3 and commenttypesubcode = 10 and bookkey = bookcomments.bookkey
	select @AuthorBios = substring(dbo.get_AuthorBio(@i_bookkey,3),1,8000)

print '@AuthorBios'
print @AuthorBios
	
	
	select @USDPrice = substring(dbo.get_BestUSPrice(@i_bookkey,8),1,23)
	print '@USDPrice'
	print @USDPrice
	select @CADPrice = substring(dbo.get_BestCANPrice(@i_bookkey,8),1,23)
	print '@CADPrice'
	print @CADPrice
	select @UKPrice = substring(dbo.get_BestUKPrice(@i_bookkey,8),1,23)
	print '@UKPrice'
	print @UKPrice
	select @EuroPrice = substring(dbo.get_BestEuroPrice(@i_bookkey,8),1,23)
	print '@EuroPrice'
	print @EuroPrice
	
	SET @i_bookweight = 0
	SELECT @i_bookweight = bookweight
	  FROM   printing
	WHERE  bookkey = @i_bookkey
		 AND printingkey = 1
	
	SET @i_cartonqty = 0
	SELECT @i_cartonqty = cartonqty1
		FROM   bindingspecs
		WHERE  bookkey = @i_bookkey and printingkey = 1
	
	select @Bookweight = substring(dbo.get_bookweight_printing(@i_bookkey,1),1,23)
	print '@Bookweight'
	print @Bookweight
	select @CartonQty = substring(dbo.get_CartonQty(@i_bookkey,1),1,23)
	print '@CartonQty'
	print @CartonQty
	
	IF @i_bookweight > 0 AND @i_cartonqty > 0 
	BEGIN
		 SELECT @i_cartonweight = @i_cartonqty * @i_bookweight
		 IF @i_cartonweight > 0  
		 BEGIN
			  SELECT @CartonWeight = CAST(@i_cartonweight AS VARCHAR(23))
	print '@CartonWeight'
	print @CartonWeight
		  END
	END
	
	select @Length = substring(dbo.get_BestTrimDimension(@i_bookkey,1,'L'),1,23)
	print '@Length'
	print @Length
	select @Width = substring(dbo.get_BestTrimDimension(@i_bookkey,1,'W'),1,23)
	print '@Width'
	print @Width
	select @SpineSize = substring(dbo.get_BestTrimDimension(@i_bookkey,1,'S'),1,23)
	print '@SpineSize'
	print @SpineSize
	
	select @Media = substring(dbo.get_media(@i_bookkey,'B'),1,255)
	print '@Media'
	print @Media
	select @Binding = substring(dbo.get_format(@i_bookkey,'B'),1,255)
	print '@Binding'
	print @Binding
	select @PageCount = substring(dbo.get_BestPageCount(@i_bookkey,1),1,23)
	print '@PageCount'
	print @PageCount
	
	SELECT @i_copyrightyear = copyrightyear
	  FROM  bookdetail
	WHERE  bookkey = @i_bookkey
	
	IF @i_copyrightyear > 0 
	BEGIN
		 SELECT @CopyRightYear = CAST(@i_copyrightyear AS VARCHAR(23))
	print '@CopyRightYear'
	print @CopyRightYear
	END
	
	select @BisacCode1 = substring(dbo.rpt_get_bisac_subject(@i_bookkey,1,'B'),1,255)
	select @BisacCode2 = substring(dbo.rpt_get_bisac_subject(@i_bookkey,2,'B'),1,255)
	select @BisacCode3 = substring(dbo.rpt_get_bisac_subject(@i_bookkey,3,'B'),1,255)
	print '@BisacCode1'
	print @BisacCode1
	print '@BisacCode2'
	print @BisacCode2
	print '@BisacCode3'
	print @BisacCode3
	
	select @Edition = editiondescription
	  from bookdetail
	 where bookkey = @i_bookkey
	print '@Edition'
	print @Edition
	
	select @PubDate = dbo.Get_BestPubDate(@i_bookkey,1)
	print '@PubDate'
	print @PubDate
	
	select @Description = substring(dbo.get_Description(@i_bookkey,3),1,8000)
	print '@Description'
	print @Description
	
	set @InDuedate = null
	select @InDueDate = substring(dbo.rpt_get_best_wh_date(@i_bookkey,1),1,10)
	print '@InDuedate'
	print @InDuedate
	
	select @BisacStatus = substring(dbo.get_BisacStatus(@i_bookkey,'B'),1,255)
	print '@BisacStatus'
	print @BisacStatus
	
	select @Color = substring(dbo.rpt_get_misc_value(@i_bookkey,39,''),1,255)
	print '@Color '
	print @Color 
	
	select @WebPageKeyWords= substring(dbo.rpt_get_misc_value(@i_bookkey,38,''),1,255)
	print '@WebPageKeyWords'
	print @WebPageKeyWords
	
	/*Web Page Categories - gentable 433 - pass 6 as a parameter for this gentable id */
	select @v_subject1 = substring(dbo.get_Subjects(@i_bookkey,6,1,'D'),1,100)
	IF @v_subject1 <> '' 
	BEGIN
		SET @WebPageCategories = @v_subject1
	END
	select @v_subject2 = substring(dbo.get_Subjects(@i_bookkey,6,2,'D'),1,100)
	IF @v_subject2 <> '' 
	BEGIN
		SET @WebPageCategories = @WebPageCategories + ' ; ' + @v_subject2
		select @v_subject3 = substring(dbo.get_Subjects(@i_bookkey,6,3,'D'),1,100)
		IF @v_subject3 <> '' 
		BEGIN
			SET @WebPageCategories = @WebPageCategories + ' ; ' + @v_subject3
			 select @v_subject4 = substring(dbo.get_Subjects(@i_bookkey,6,4,'D'),1,100)
			IF @v_subject4 <> '' 
			BEGIN
				SET @WebPageCategories = @WebPageCategories + ' ; ' + @v_subject4
				select @v_subject5 = substring(dbo.get_Subjects(@i_bookkey,6,5,'D'),1,100)
				IF @v_subject5 <> '' 
				BEGIN
					SET @WebPageCategories = @WebPageCategories + ' ; ' + @v_subject5
					select @v_subject6 = substring(dbo.get_Subjects(@i_bookkey,6,6,'D'),1,100)
					IF @v_subject6 <> '' 
					BEGIN
						SET @WebPageCategories = @WebPageCategories + ' ; ' + @v_subject6
						select @v_subject7 = substring(dbo.get_Subjects(@i_bookkey,6,7,'D'),1,100)
						IF @v_subject7 <> '' 
						BEGIN
							SET @WebPageCategories = @WebPageCategories + ' ; ' + @v_subject7
							select @v_subject8 = substring(dbo.get_Subjects(@i_bookkey,6,8,'D'),1,100)
							IF @v_subject8 <> '' 
							BEGIN
								SET @WebPageCategories = @WebPageCategories + ' ; ' + @v_subject8
								select @v_subject9 = substring(dbo.get_Subjects(@i_bookkey,6,9,'D'),1,100)
								IF @v_subject9 <> '' 
								BEGIN
									SET @WebPageCategories = @WebPageCategories + ' ; ' + @v_subject9
									select @v_subject10 = substring(dbo.get_Subjects(@i_bookkey,6,10,'D'),1,100)
									IF @v_subject10 <> '' 
									BEGIN
										SET @WebPageCategories = @WebPageCategories + ' ; ' + @v_subject10
									END
								END
							END
						END
					END
				END
			END
		END
	END
	print '@WebPageCategories'
	print @WebPageCategories
	
	
	select @Rights = substring(dbo.get_Territory(@i_bookkey,'B'),1,255)
	print '@Rights'
	print @Rights
	
	
	SELECT @PrimaryEAN = isbn.ean  
		 FROM book, isbn  
		WHERE ( book.workkey = isbn.bookkey ) and  
				( ( book.bookkey = @i_bookkey ) )   
	print '@PrimaryEAN'
	print @PrimaryEAN  
	
	SELECT @TitleWebSiteURL = pathname
		 FROM filelocation 
		WHERE bookkey = @i_bookkey 
			  AND printingkey = 1
			  AND filetypecode = 9
	
	print '@TitleWebSiteURL'
	print @TitleWebSiteURL

     SELECT @Imprint = dbo.rpt_get_group_level_3 (@i_bookkey,1)
print '@Imprint'
print @Imprint

	SELECT @SubTitle =	dbo.rpt_get_sub_title (@i_bookkey)
print '@SubTitle'
	print @SubTitle 

	SELECT @SeriesName = dbo.rpt_get_series (@i_bookkey,1)
print '@SeriesName'
	print @SeriesName

	SELECT @AuthorResidence =  dbo.rpt_get_book_comment (@i_bookkey, 3, 31, 3)
print '@AuthorResidence'
	print @AuthorResidence
	
	SELECT @Audience = dbo.rpt_get_audience (@i_bookkey,'B',1)
print '@Audience'
	print @Audience

    SELECT @AgeRange = dbo.rpt_get_age_range (@i_bookkey)
print '@AgeRange'
	print @AgeRange

    SELECT @Announced1stPrinting =  printing.announcedfirstprint
      FROM printing 
	WHERE bookkey = @i_bookkey 
	    AND printingkey = 1
print '@Announced1stPrinting '
	print @Announced1stPrinting 

    SELECT @CountryofOrigin =  dbo.rpt_get_misc_value (@i_bookkey, 40, 'short')
print '@CountryofOrigin'
	print @CountryofOrigin


    SELECT @InsertsIllustrations = dbo.rpt_get_insert_illus (@i_bookkey,1,'B')
print '@InsertsIllustrations'
	print @InsertsIllustrations
	
	INSERT INTO bds_tmm_cispub_feed
		(EAN13,
		Title,
		Publisher	,
		ContributorLastname1,
		ContributorFirstname1,
		 ContributorRole1,
		ContributorLastname2,
		ContributorFirstname2,
		 ContributorRole2,
		ContributorLastname3,
		ContributorFirstname3,
		 ContributorRole3,
		ContributorLastname4,
		ContributorFirstname4,
		 ContributorRole4,
		ContributorLastname5,
		ContributorFirstname5,
		 ContributorRole5,
		AuthorBios,
		USDPrice	,
		 CADPrice,
		BritishPoundsPrice	,
		EuroPrice,
		BookWeight,
		Cartonweight,
		 CartonQuantity,
		Length,
		Width,
		SpineSize,
		Media,
		Binding,
		Pages,
		CopyRightYear,
		BISACCode1,
		BISACCode2	,
		BISACCode3	,
		Edition,
		PubDate,
		Description,
		AllColor,
		WebPageKeywords,
		WebPageCategories,
		Rights,
		InDueDate,
		BISACStatus	,
		PrimaryEditionEAN	,
		TitleWebSiteURL,
         Imprint,
	    SubTitle,
	    SeriesName,
        AuthorResidence,
	    Audience	,
        AgeRange,
        AnnouncedFirstPrinting,
        CountryofOrigin,
        InsertsIllustrations)
	  VALUES
		 (@EAN13,
		  @Title,
		@Publisher,
		@ContributorLastName1,
		  @ContributorFirstName1,
		@ContributorRole1,
		 @ContributorLastName2,
		  @ContributorFirstName2,
		@ContributorRole2,
		  @ContributorLastName3,
		  @ContributorFirstName3,
		@ContributorRole3,
		  @ContributorLastName4,
		  @ContributorFirstName4,
		@ContributorRole4,
		  @ContributorLastName5,
		  @ContributorFirstName5,
		@ContributorRole5,
		  @AuthorBios,
		@USDPrice,
		@CADPrice,
		@UKPrice,
		@EuroPrice,
		@BookWeight,
		@CartonQty,
		@CartonWeight,
		@Length,
		@Width,
		@Spinesize,
		@Media,
		@Binding,
		@PageCount,
		@CopyRightYear,
		@BisacCode1,
		@BisacCode2,
		@BisacCode3,
		 @Edition,
		@PubDate,
		@Description,
		  @Color,
		@WebPageKeyWords,
		@WebPageCategories,
		@Rights,
		 @InDueDate,
		@BisacStatus,
		@PrimaryEAN,
		@TitleWebSiteURL,
         @Imprint ,
         @SubTitle,
         @SeriesName,
         @AuthorResidence,
         @Audience,
         @AgeRange,
        @Announced1stPrinting,
        @CountryofOrigin,
        @InsertsIllustrations)
	
	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Unable to insert into the bds_tmm_csipub_feed table.   Error #' + cast(@v_error as varchar(20))
		RETURN
	END 
END

END