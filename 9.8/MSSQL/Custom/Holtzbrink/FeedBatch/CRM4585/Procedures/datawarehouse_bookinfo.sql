IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'datawarehouse_bookinfo')
BEGIN
  DROP  Procedure  datawarehouse_bookinfo
END
GO
CREATE   PROCEDURE dbo.datawarehouse_bookinfo 
        @ware_bookkey integer,
        @ware_logkey integer,
        @ware_warehousekey integer,
        @ware_system_date datetime
    AS

BEGIN
          DECLARE 
            @cursor_row$AUTHORKEY integer,
            @cursor_row$DISPLAYNAME varchar(100),
            @cursor_row$LASTNAME varchar(100),
            @cursor_row$AUTHORTYPECODE integer,
            @cursor_row$PRIMARYIND integer,
            @ware_count integer,
            @ware_company varchar(20),
            @ware_titlestatus_long varchar(40),
            @ware_titlestatus_short varchar(20),
            @ware_territory_long varchar(40),
            @ware_territory_short varchar(20),
            @ware_titletype_long varchar(40),
            @ware_titletype_short varchar(20),
            @ware_shorttitle varchar(50),
            @ware_subtitle varchar(255),
            @ware_title varchar(255),
            @ware_titlestatuscode integer,
            @ware_territoriescode integer,
            @ware_titletypecode integer,
            @ware_mediatypecode integer,
            @ware_mediatypesubcode integer,
            @ware_fullauthordisplayname varchar(255),
            @ware_titleprefix varchar(275),
            @ware_agehighupind integer,
            @ware_agelowupind integer,
            @ware_gradelowupind integer,
            @ware_gradehighupind integer,
            @ware_bisacstatuscode integer,
            @ware_editioncode integer,
            @ware_agelow integer,
            @ware_agehigh integer,
            @ware_gradelow varchar(10),
            @ware_gradehigh varchar(10),
            @ware_languagecode integer,
            @ware_origincode integer,
            @ware_platformcode integer,
            @ware_restrictioncode integer,
            @ware_returncode integer,
            @ware_seriescode integer,
            @ware_userlevelcode integer,
            @ware_volumenumber integer,
            @ware_salesdivisioncode integer,
            @ware_format varchar(120),
            @ware_formatshort varchar(20),
            @ware_media varchar(40),
            @ware_mediashort varchar(20),
            @prefix varchar(15),
            @ware_titleprefixandtitle varchar(275),
            @bisacstatus_long varchar(40),
            @bisacstatus_short varchar(20),
            @edition_long varchar(40),
            @edition_short varchar(20),
            @language_long varchar(40),
            @language_short varchar(20),
            @origin_long varchar(40),
            @origin_short varchar(20),
            @platform_long varchar(40),
            @platform_short varchar(20),
            @restrictions_long varchar(40),
            @restrictions_short varchar(20),
            @ware_returndesc varchar(40),
            @ware_returnshort varchar(20),
            @salesdivision_long varchar(40),
            @salesdivision_short varchar(20),
            @series_long varchar(255),
            @series_short varchar(20),
            @userlevel_long varchar(40),
            @userlevel_short varchar(20),
            @ware_productnumber varchar(20),
            @agelowstr varchar(10),
            @agehighstr varchar(10),
            @agerange varchar(25),
            @gradelowstr varchar(15),
            @gradehighstr varchar(15),
            @graderange varchar(25),
            @CanadianRestriction_short varchar(20),
            @CanadianRestriction_long varchar(40),
            @ware_isbn varchar(13),
            @ware_upc varchar(20),
            @ware_ean varchar(20),
            @ware_lccn varchar(14),
            @ware_isbn10 varchar(10),
            @ware_isbn13_hold varchar(20),
            @ware_isbn13_count integer,
            @ware_ean13 varchar(13),
            @ware_ean5 varchar(5),
            @ware_upc12 varchar(12),
            @ware_upc17 varchar(17),
            @ware_itemnumber varchar(20),
            @ware_announcedfirstprint integer,
            @ware_estimatedinsertillus varchar(255),
            @ware_actualinsertillus varchar(255),
            @ware_tentativepagecount integer,
            @ware_pagecount integer,
            @ware_projectedsales numeric(10, 2),
            @ware_tentativeqty integer,
            @ware_firstprintingqty integer,
            @ware_seasonkey integer,
            @ware_estseasonkey integer,
            @ware_trimsizelength varchar(25),
            @ware_trimsizewidth varchar(25),
            @ware_esttrimsizewidth varchar(25),
            @ware_esttrimsizelength varchar(25),
            @ware_issuenumber integer,
            @ware_pubmonth datetime,
            @ware_slotcode integer,
            @ware_estannouncedfirstprint integer,
            @ware_estprojectedsales numeric(10, 2),
            @ware_audionumberunits integer,
            @ware_audiototalruntime varchar(10),
            @ware_best integer,
            @ware_best2 varchar(255),
            @ware_best3 integer,
            @ware_best4 numeric(10, 2),
            @ware_best5 numeric(10, 2),
            @eststr varchar(25),
            @actstr varchar(25),
            @beststr varchar(25),
            @eststr2 varchar(40),
            @actstr2 varchar(40),
            @beststr2 varchar(40),
            @ware_seasontype integer,
            @ware_seasondesc varchar(40),
            @ware_seasonyear integer,
            @ware_slot_long varchar(40),
            @ware_slot_short varchar(20),
            @ware_discountcode integer,
            @ware_allagesind integer,
            @ware_discount_long varchar(40),
            @ware_discount_short varchar(20),
            @ware_allages varchar(1),
            @ware_totalvolume integer,
            @ware_pubmonthddyymm varchar(10),
            @ware_allauthorlast varchar(1000),
            @ware_allauthdisp varchar(2000),
            @ware_allauthcomp varchar(2000),
            @ware_allauthcomp2 varchar(2000),
            @ware_bestdisplay varchar(2000),
            @lv_titlereleasedtoeloquenceind varchar(1),
            @ware_spinesize varchar(15),
            @ware_isbn13_dash varchar(20),
            @ware_isbn13_undash varchar(20),
            @v_sendtoeloquenceind int,
            @ware_projectisbn varchar(19),
            @ware_alternateprojectisbn varchar(19),
            @ware_nextisbn varchar(19),
            @ware_nexteditionisbn varchar(19),
            @ware_previouseditionisbn varchar(19),
            @ware_copyrightyear integer,
            @ware_Canadian_Restriction_Code integer,
            @ware_cartonqty integer,
            @ware_elocustomerkey integer,
            @ware_elocustomer_long varchar(100),
            @ware_elocustomer_short varchar(30),
	    @ware_primaryeditionworkkey integer,
	    @ware_primaryeditionisbn10 varchar(10),
	    @ware_primaryeditionean13 varchar(13),
            @ware_editionnumber integer,
	    @ware_editiondescription varchar(150),
	    @ware_additionaleditinfo varchar(100)


	  SET @ware_primaryeditionworkkey = 0
	  SET @ware_primaryeditionisbn10 = ''
	  SET @ware_primaryeditionean13 = ''
          SET @ware_count = 0
          SET @ware_company = ''
          SET @ware_titlestatus_long = ''
          SET @ware_titlestatus_short = ''
          SET @ware_territory_long = ''
          SET @ware_territory_short = ''
          SET @ware_titletype_long = ''
          SET @ware_titletype_short = ''
          SET @ware_shorttitle = ''
          SET @ware_subtitle = ''
          SET @ware_title = ''
          SET @ware_titlestatuscode = 0
          SET @ware_territoriescode = 0
          SET @ware_titletypecode = 0
          SET @ware_mediatypecode = 0
          SET @ware_mediatypesubcode = 0
          SET @ware_fullauthordisplayname = ''
          SET @ware_titleprefix = ''
          SET @ware_agehighupind = 0
          SET @ware_agelowupind = 0
          SET @ware_gradelowupind = 0
          SET @ware_gradehighupind = 0
          SET @ware_bisacstatuscode = 0
          SET @ware_editioncode = 0
          SET @ware_agelow = 0
          SET @ware_agehigh = 0
          SET @ware_gradelow = ''
          SET @ware_gradehigh = ''
          SET @ware_languagecode = 0
          SET @ware_origincode = 0
          SET @ware_platformcode = 0
          SET @ware_restrictioncode = 0
          SET @ware_returncode = 0
          SET @ware_seriescode = 0
          SET @ware_userlevelcode = 0
          SET @ware_volumenumber = 0
          SET @ware_salesdivisioncode = 0
          SET @ware_format = ''
          SET @ware_formatshort = ''
          SET @ware_media = ''
          SET @ware_mediashort = ''
          SET @prefix = ''
          SET @ware_titleprefixandtitle = ''
          SET @bisacstatus_long = ''
          SET @bisacstatus_short = ''
          SET @edition_long = ''
          SET @edition_short = ''
          SET @language_long = ''
          SET @language_short = ''
          SET @origin_long = ''
          SET @origin_short = ''
          SET @platform_long = ''
          SET @platform_short = ''
          SET @restrictions_long = ''
          SET @restrictions_short = ''
          SET @ware_returndesc = ''
          SET @ware_returnshort = ''
          SET @salesdivision_long = ''
          SET @salesdivision_short = ''
          SET @series_long = ''
          SET @series_short = ''
          SET @userlevel_long = ''
          SET @userlevel_short = ''
          SET @ware_productnumber = ''
          SET @agelowstr = ''
          SET @agehighstr = ''
          SET @agerange = ''
          SET @gradelowstr = ''
          SET @gradehighstr = ''
          SET @graderange = ''
          SET @CanadianRestriction_short = ''
          SET @CanadianRestriction_long = ''
          SET @ware_isbn = ''
          SET @ware_upc = ''
          SET @ware_ean = ''
          SET @ware_lccn = ''
          SET @ware_isbn10 = ''
          SET @ware_isbn13_hold = ''
          SET @ware_ean13 = ''
          SET @ware_ean5 = ''
          SET @ware_upc12 = ''
          SET @ware_upc17 = ''
          SET @ware_itemnumber = ''
          SET @ware_announcedfirstprint = 0
          SET @ware_estimatedinsertillus = ''
          SET @ware_actualinsertillus = ''
          SET @ware_tentativepagecount = 0
          SET @ware_pagecount = 0
          SET @ware_projectedsales = 0
          SET @ware_tentativeqty = 0
          SET @ware_firstprintingqty = 0
          SET @ware_seasonkey = 0
          SET @ware_estseasonkey = 0
          SET @ware_trimsizelength = ''
          SET @ware_trimsizewidth = ''
          SET @ware_esttrimsizewidth = ''
          SET @ware_esttrimsizelength = ''
          SET @ware_issuenumber = 0
          SET @ware_slotcode = 0
          SET @ware_estannouncedfirstprint = 0
          SET @ware_estprojectedsales = 0
          SET @ware_audionumberunits = 0
          SET @ware_audiototalruntime = ''
          SET @ware_best = 0
          SET @ware_best2 = ''
          SET @ware_best3 = 0
          SET @ware_best4 = 0
          SET @ware_best5 = 0
          SET @eststr = ''
          SET @actstr = ''
          SET @beststr = ''
          SET @eststr2 = ''
          SET @actstr2 = ''
          SET @beststr2 = ''
          SET @ware_seasontype = 0
          SET @ware_seasondesc = ''
          SET @ware_seasonyear = 0
          SET @ware_slot_long = ''
          SET @ware_slot_short = ''
          SET @ware_discountcode = 0
          SET @ware_allagesind = 0
          SET @ware_discount_long = ''
          SET @ware_discount_short = ''
          SET @ware_allages = ''
          SET @ware_pubmonthddyymm = ''
          SET @ware_allauthorlast = ''
          SET @ware_allauthdisp = ''
          SET @ware_allauthcomp = ''
          SET @ware_allauthcomp2 = ''
          SET @ware_bestdisplay = ''
          SET @lv_titlereleasedtoeloquenceind = ''
          SET @ware_spinesize = ''
          SET @ware_isbn13_dash = ''
          SET @ware_isbn13_undash = ''
          SET @ware_projectisbn = ''
          SET @ware_alternateprojectisbn = ''
          SET @ware_nextisbn = ''
          SET @ware_nexteditionisbn = ''
          SET @ware_previouseditionisbn = ''
          SET @ware_copyrightyear = 0
          SET @ware_Canadian_Restriction_Code = 0
          SET @ware_cartonqty = 0

            /* book */

            SET @ware_count = 0

            SELECT @ware_count = count( * )
              FROM BOOK
              WHERE (BOOK.BOOKKEY = @ware_bookkey)

           IF @ware_count > 0  BEGIN
                SELECT @ware_shorttitle = isnull(BOOK.SHORTTITLE, '')
                  FROM BOOK
                  WHERE (BOOK.BOOKKEY = @ware_bookkey)

                SELECT @ware_subtitle = isnull(BOOK.SUBTITLE, '')
                  FROM BOOK
                  WHERE (BOOK.BOOKKEY = @ware_bookkey)

                SELECT @ware_title = isnull(substring(BOOK.TITLE, 1, 80), '')
                  FROM BOOK
                  WHERE (BOOK.BOOKKEY = @ware_bookkey)

                SELECT @ware_titlestatuscode = isnull(BOOK.TITLESTATUSCODE, 0)
                  FROM BOOK
                  WHERE (BOOK.BOOKKEY = @ware_bookkey)

                SELECT @ware_territoriescode = isnull(BOOK.TERRITORIESCODE, 0)
                  FROM BOOK
                  WHERE (BOOK.BOOKKEY = @ware_bookkey)

                SELECT @ware_titletypecode = isnull(BOOK.TITLETYPECODE, 0)
                  FROM BOOK
                  WHERE (BOOK.BOOKKEY = @ware_bookkey)

	        SELECT @ware_primaryeditionworkkey = IsNull(workkey,0)
	        FROM book
	        WHERE bookkey = @ware_bookkey      
	
	        select @ware_primaryeditionisbn10 = isbn10, @ware_primaryeditionean13 = ean13
	        from isbn 
	        where bookkey = @ware_primaryeditionworkkey

               /* 121206-bl */

                SELECT @ware_elocustomerkey = isnull(BOOK.ELOCUSTOMERKEY, 0)
                  FROM BOOK
                  WHERE (BOOK.BOOKKEY = @ware_bookkey)

                 IF (@ware_titlestatuscode > 0) BEGIN
                        execute @ware_titlestatus_long = dbo.GENTABLES_LONGDESC_FUNCTION 149, @ware_titlestatuscode
                        execute @ware_titlestatus_short = dbo.GENTABLES_SHORTDESC_FUNCTION 149, @ware_titlestatuscode
                        SET @ware_titlestatus_short = substring(@ware_titlestatus_short, 1, 8)
                 END ELSE BEGIN
                        SET @ware_titlestatus_long = ''
                        SET @ware_titlestatus_short = ''
                 END

		 IF @@ROWCOUNT > 0  BEGIN
                 
			 IF (@ware_territoriescode > 0)  BEGIN
	                        execute @ware_territory_long = dbo.GENTABLES_LONGDESC_FUNCTION 131, @ware_territoriescode
	                        execute @ware_territory_short = dbo.GENTABLES_SHORTDESC_FUNCTION 131, @ware_territoriescode
	                        SET @ware_territory_short = substring(@ware_territory_short, 1, 8)
	                 END ELSE BEGIN
		                        SET @ware_territory_long = ''
	                        SET @ware_territory_short = ''
	                 END
	
	                 IF (@ware_titletypecode > 0) BEGIN
	                        execute @ware_titletype_long = dbo.GENTABLES_LONGDESC_FUNCTION 132, @ware_titletypecode
	                        execute @ware_titletype_short = dbo.GENTABLES_SHORTDESC_FUNCTION 132, @ware_titletypecode
	                        SET @ware_titletype_short = substring(@ware_titletype_short, 1, 8)
	                 END ELSE BEGIN
	                        SET @ware_titletype_long = ''
	                        SET @ware_titletype_short = ''
	                  END
	
	                    /* 121206-bl */
	                  IF (@ware_elocustomerkey > 0) BEGIN
	                        SELECT @ware_elocustomer_long = CUSTOMER.CUSTOMERLONGNAME, @ware_elocustomer_short = CUSTOMER.CUSTOMERSHORTNAME
	                        FROM CUSTOMER
	                        WHERE (CUSTOMER.CUSTOMERKEY = @ware_elocustomerkey)
	                  END ELSE BEGIN
	                        SET @ware_elocustomer_long = ''
	                        SET @ware_elocustomer_short = ''
	                  END
                 
                END ELSE BEGIN
	                    INSERT INTO WHERRORLOG
	                      (
	                        WHERRORLOG.LOGKEY, 
	                        WHERRORLOG.WAREHOUSEKEY, 
	                        WHERRORLOG.ERRORDESC, 
	                        WHERRORLOG.ERRORSEVERITY, 
	                        WHERRORLOG.ERRORFUNCTION, 
	                        WHERRORLOG.LASTUSERID, 
	                        WHERRORLOG.LASTMAINTDATE
	                      )
	                      VALUES 
	                        (
	                          @ware_logkey, 
	                          @ware_warehousekey, 
	                          'No book rows for this title', 
	                          ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
	                          'Stored procedure datawarehouse_bisac', 
	                          'WARE_STORED_PROC', 
	                          @ware_system_date
	                        )
                  	    END
          END ELSE BEGIN
                INSERT INTO WHERRORLOG
                  (
                    WHERRORLOG.LOGKEY, 
                    WHERRORLOG.WAREHOUSEKEY, 
                    WHERRORLOG.ERRORDESC, 
                    WHERRORLOG.ERRORSEVERITY, 
                    WHERRORLOG.ERRORFUNCTION, 
                    WHERRORLOG.LASTUSERID, 
                    WHERRORLOG.LASTMAINTDATE
                  )
                  VALUES 
                    (
                      @ware_logkey, 
                      @ware_warehousekey, 
                      'No book rows for this title', 
                      ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                      'Stored procedure datawarehouse_bisac', 
                      'WARE_STORED_PROC', 
                      @ware_system_date
                    )
          END

            INSERT INTO WHTITLEINFO
              (
                WHTITLEINFO.BOOKKEY, 
                WHTITLEINFO.SHORTTITLE, 
                WHTITLEINFO.SUBTITLE, 
                WHTITLEINFO.TITLE, 
                WHTITLEINFO.LASTUSERID, 
                WHTITLEINFO.LASTMAINTDATE,
		primaryeditionworkkey, 
		primaryeditionisbn10, 
		primaryeditionean13
              )
              VALUES 
                (
                  @ware_bookkey, 
                  @ware_shorttitle, 
                  @ware_subtitle, 
                  @ware_title, 
                  'WARE_STORED_PROC', 
                  @ware_system_date,
		  @ware_primaryeditionworkkey, 
		  @ware_primaryeditionisbn10, 
		  @ware_primaryeditionean13
                )




            if @@rowcount = 0 BEGIN
                INSERT INTO WHERRORLOG
                  (
                    WHERRORLOG.LOGKEY, 
                    WHERRORLOG.WAREHOUSEKEY, 
                    WHERRORLOG.ERRORDESC, 
                    WHERRORLOG.ERRORSEVERITY, 
                    WHERRORLOG.ERRORFUNCTION, 
                    WHERRORLOG.LASTUSERID, 
                    WHERRORLOG.LASTMAINTDATE
                  )
                  VALUES 
                    (
                      @ware_logkey, 
                      @ware_warehousekey, 
                      'Unable to insert whtitleinfo table - for book', 
                      ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                      'Stored procedure datawarehouse_bookinfo', 
                      'WARE_STORED_PROC', 
                      @ware_system_date
                    )
              END

            INSERT INTO WHTITLECLASS
              (
                WHTITLECLASS.BOOKKEY, 
                WHTITLECLASS.INTERNALSTATUS, 
                WHTITLECLASS.INTERNALSTATUSSHORT, 
                WHTITLECLASS.TERRITORIES, 
                WHTITLECLASS.TERRITORIESSHORT, 
                WHTITLECLASS.TITLETYPE, 
                WHTITLECLASS.TITLETYPESHORT, 
                WHTITLECLASS.ELOCUSTOMER, 
                WHTITLECLASS.ELOCUSTOMERSHORT, 
                WHTITLECLASS.LASTUSERID, 
                WHTITLECLASS.LASTMAINTDATE
              )
              VALUES 
                (
                  @ware_bookkey, 
                  @ware_titlestatus_long, 
                  @ware_titlestatus_short, 
                  @ware_territory_long, 
                  @ware_territory_short, 
                  @ware_titletype_long, 
                  @ware_titletype_short, 
                  @ware_elocustomer_long, 
                  @ware_elocustomer_short, 
                  'WARE_STORED_PROC', 
                  @ware_system_date
                )

            IF @@ROWCOUNT = 0 BEGIN
                INSERT INTO WHERRORLOG
                  (
                    WHERRORLOG.LOGKEY, 
                    WHERRORLOG.WAREHOUSEKEY, 
                    WHERRORLOG.ERRORDESC, 
                    WHERRORLOG.ERRORSEVERITY, 
                    WHERRORLOG.ERRORFUNCTION, 
                    WHERRORLOG.LASTUSERID, 
                    WHERRORLOG.LASTMAINTDATE
                  )
             VALUES 
                    (
                      @ware_logkey, 
                      @ware_warehousekey, 
                      'Unable to insert whtitleclass table - for book', 
                      ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                      'Stored procedure datawarehouse_bookinfo', 
                      'WARE_STORED_PROC', 
                      @ware_system_date
                    )
              END

            /* bookdetail */

            SET @ware_count = 0
            SELECT @ware_count = count( * )
              FROM BOOKDETAIL
              WHERE (BOOKDETAIL.BOOKKEY = @ware_bookkey)

            IF @ware_count > 0 BEGIN
                  SELECT 
                    @ware_mediatypecode = isnull(BOOKDETAIL.MEDIATYPECODE, 0), 
                    @ware_mediatypesubcode = isnull(BOOKDETAIL.MEDIATYPESUBCODE, 0), 
                    @ware_fullauthordisplayname = isnull(BOOKDETAIL.FULLAUTHORDISPLAYNAME, ''), 
                    @ware_titleprefix = isnull(BOOKDETAIL.TITLEPREFIX , ''), 
                    @ware_agehighupind = isnull(BOOKDETAIL.AGEHIGHUPIND, 0), 
                    @ware_agelowupind = isnull(BOOKDETAIL.AGELOWUPIND, 0), 
                    @ware_gradelowupind = isnull(BOOKDETAIL.GRADELOWUPIND, 0), 
                    @ware_gradehighupind = isnull(BOOKDETAIL.GRADEHIGHUPIND, 0), 
                    @ware_bisacstatuscode = isnull(BOOKDETAIL.BISACSTATUSCODE, 0), 
                    @ware_editioncode = isnull(BOOKDETAIL.EDITIONCODE, 0), 
                    @ware_agelow = isnull(BOOKDETAIL.AGELOW, 0), 
                    @ware_agehigh = isnull(BOOKDETAIL.AGEHIGH, 0), 
                    @ware_gradelow = isnull(BOOKDETAIL.GRADELOW, ''), 
                    @ware_gradehigh = isnull(BOOKDETAIL.GRADEHIGH, ''), 
                    @ware_languagecode = isnull(BOOKDETAIL.LANGUAGECODE, 0), 
                    @ware_origincode = isnull(BOOKDETAIL.ORIGINCODE, 0), 
                    @ware_platformcode = isnull(BOOKDETAIL.PLATFORMCODE, 0), 
                    @ware_restrictioncode = isnull(BOOKDETAIL.RESTRICTIONCODE, 0), 
                    @ware_returncode = isnull(BOOKDETAIL.RETURNCODE, 0), 
                    @ware_seriescode = isnull(BOOKDETAIL.SERIESCODE, 0), 
                    @ware_userlevelcode = isnull(BOOKDETAIL.USERLEVELCODE, 0), 
                    @ware_volumenumber = BOOKDETAIL.VOLUMENUMBER, 
                    @ware_salesdivisioncode = isnull(BOOKDETAIL.SALESDIVISIONCODE, 0), 
                    @ware_discountcode = isnull(BOOKDETAIL.DISCOUNTCODE, 0), 
                    @ware_allagesind = isnull(BOOKDETAIL.ALLAGESIND, 0), 
                    @ware_projectisbn = isnull(BOOKDETAIL.VISTAPROJECTNUMBER, ''), 
                    @ware_alternateprojectisbn = isnull(BOOKDETAIL.ALTERNATEPROJECTISBN, ''), 
                    @ware_nextisbn = isnull(BOOKDETAIL.NEXTISBN, ''), 
                    @ware_nexteditionisbn = isnull(BOOKDETAIL.NEXTEDITIONISBN, ''), 
                    @ware_previouseditionisbn = isnull(BOOKDETAIL.PREVEDITIONISBN, ''), 
                    @ware_copyrightyear = isnull(BOOKDETAIL.COPYRIGHTYEAR, 0), 
                    @ware_Canadian_Restriction_Code = isnull(BOOKDETAIL.CANADIANRESTRICTIONCODE, 0),
		    @ware_editiondescription = isnull(editiondescription, ''),
		    @ware_editionnumber = isnull(editionnumber,0),
		    @ware_additionaleditinfo = isnull(additionaleditinfo, '')
                  FROM BOOKDETAIL
                  WHERE (BOOKDETAIL.BOOKKEY = @ware_bookkey)

                IF (@@ROWCOUNT > 0) BEGIN
                    IF ((@ware_mediatypecode > 0) AND (@ware_mediatypesubcode > 0))
                      BEGIN
                        exec @ware_format = SUBGENT_LONGDESC_FUNCTION 312, @ware_mediatypecode, @ware_mediatypesubcode
                        exec @ware_formatshort = SUBGENT_SHORTDESC_FUNCTION 312, @ware_mediatypecode, @ware_mediatypesubcode
                        SET @ware_formatshort = substring(@ware_formatshort, 1, 8)
                      END
                END ELSE  BEGIN
                        SET @ware_format = ''
                        SET @ware_formatshort = ''
                END

                IF (@ware_mediatypecode > 0) BEGIN
                        exec @ware_media = dbo.GENTABLES_LONGDESC_FUNCTION 312, @ware_mediatypecode
                        exec @ware_mediashort = dbo.GENTABLES_SHORTDESC_FUNCTION 312, @ware_mediatypecode 
                        SET @ware_mediashort = substring(@ware_mediashort, 1, 8)
                 END ELSE BEGIN
                        SET @ware_media = ''
                        SET @ware_mediashort = ''
                 END

                    SET @prefix = rtrim(substring(@ware_titleprefix, 1, 15))
                    SET @ware_titleprefix = @ware_title

                    /* 8-27 remove blank sapce */

                    IF (len(@prefix) > 0) BEGIN
                      SET @ware_titleprefixandtitle = (isnull(@prefix, '') + ' ' + isnull(@ware_title, ''))
                    END ELSE BEGIN
                      SET @ware_titleprefixandtitle = @ware_title
		    END

                    IF (len(@prefix) > 0)
                      SET @ware_titleprefix = (isnull(@ware_titleprefix, '') + ', ' + isnull(@prefix, ''))
                    IF (@ware_bisacstatuscode > 0) BEGIN
                        exec @bisacstatus_long = dbo.GENTABLES_LONGDESC_FUNCTION 314, @ware_bisacstatuscode
                        exec @bisacstatus_short = dbo.GENTABLES_SHORTDESC_FUNCTION 314, @ware_bisacstatuscode
                        SET @bisacstatus_short = substring(@bisacstatus_short, 1, 8)
                    END ELSE BEGIN
                        SET @bisacstatus_long = ''
                        SET @bisacstatus_short = ''
                    END

                    IF (@ware_editioncode > 0)BEGIN
                        exec @edition_long = dbo.GENTABLES_LONGDESC_FUNCTION 200, @ware_editioncode
                        exec @edition_short = dbo.GENTABLES_SHORTDESC_FUNCTION 200, @ware_editioncode
                        SET @edition_short = substring(@edition_short, 1, 8)
                    END ELSE BEGIN
                        SET @edition_long = ''
                        SET @edition_short = ''
                    END

                    IF (@ware_languagecode > 0) BEGIN
                        exec @language_long = dbo.GENTABLES_LONGDESC_FUNCTION 318, @ware_languagecode 
                        exec @language_short = dbo.GENTABLES_SHORTDESC_FUNCTION 318, @ware_languagecode
                        SET @language_short = substring(@language_short, 1, 8)
                    END ELSE BEGIN
                        SET @language_long = ''
                        SET @language_short = ''
                    END

                    IF (@ware_origincode > 0) BEGIN
                       exec @origin_long = dbo.GENTABLES_LONGDESC_FUNCTION 315, @ware_origincode
                       exec @origin_short = dbo.GENTABLES_SHORTDESC_FUNCTION 315, @ware_origincode
                       SET @origin_short = substring(@origin_short, 1, 8)
                    END ELSE BEGIN
                        SET @origin_long = ''
                        SET @origin_short = ''
                    END

                    IF (@ware_platformcode > 0) BEGIN
                        exec @platform_long = dbo.GENTABLES_LONGDESC_FUNCTION 321, @ware_platformcode
                        exec @platform_short = dbo.GENTABLES_SHORTDESC_FUNCTION 321, @ware_platformcode
                        SET @platform_short = substring(@platform_short, 1, 8)
                    END ELSE BEGIN
                        SET @platform_long = ''
                        SET @platform_short = ''
                    END

                    IF (@ware_restrictioncode > 0) BEGIN
                        exec @restrictions_long = dbo.GENTABLES_LONGDESC_FUNCTION 320, @ware_restrictioncode
                        exec @restrictions_short = dbo.GENTABLES_SHORTDESC_FUNCTION 320, @ware_restrictioncode
                        SET @restrictions_short = substring(@restrictions_short, 1, 8)
                    END ELSE BEGIN
                        SET @restrictions_long = ''
                        SET @restrictions_short = ''
                    END

                    IF (@ware_returncode > 0) BEGIN
                        exec @ware_returndesc = dbo.GENTABLES_LONGDESC_FUNCTION 319, @ware_returncode
                        exec @ware_returnshort = dbo.GENTABLES_SHORTDESC_FUNCTION 319, @ware_returncode
                        SET @ware_returnshort = substring(@ware_returnshort, 1, 8)
                    END ELSE BEGIN
                        SET @ware_returndesc = ''
                        SET @ware_returnshort = ''
                    END

                    IF (@ware_salesdivisioncode > 0) BEGIN
                        exec @salesdivision_long = dbo.GENTABLES_LONGDESC_FUNCTION 313, @ware_salesdivisioncode
                        exec @salesdivision_short = dbo.GENTABLES_SHORTDESC_FUNCTION 313, @ware_salesdivisioncode
                        SET @salesdivision_short = substring(@salesdivision_short, 1, 8)
                    END ELSE BEGIN
                        SET @salesdivision_long = ''
                        SET @salesdivision_short = ''
                     END

                    IF (@ware_seriescode > 0) BEGIN
                        exec @series_long = dbo.GENTABLES_ALTERNATEDESC1 327, @ware_seriescode
                        exec @series_short = dbo.GENTABLES_SHORTDESC_FUNCTION 327, @ware_seriescode
                        SET @series_short = substring(@series_short, 1, 8)
                        SELECT @ware_totalvolume = CAST( GENTABLES.NUMERICDESC1 AS float)
                          FROM GENTABLES
                          WHERE ((GENTABLES.TABLEID = 327) AND 
                                  (GENTABLES.DATACODE = @ware_seriescode))

                        IF (@ware_totalvolume = 0) BEGIN
                          SET @ware_totalvolume =  NULL
                        END
		     END ELSE BEGIN
                        SET @series_long = ''
                        SET @series_short = ''
                     END

                    IF (@ware_volumenumber = 0) BEGIN
                      SET @ware_volumenumber =  NULL
                    END
                    IF (@ware_userlevelcode > 0) BEGIN
                        exec @userlevel_long = dbo.GENTABLES_LONGDESC_FUNCTION 322, @ware_userlevelcode
                        exec @userlevel_short = dbo.GENTABLES_SHORTDESC_FUNCTION 322, @ware_userlevelcode
                        SET @userlevel_short = substring(@userlevel_short, 1, 8)
                    END ELSE  BEGIN
                        SET @userlevel_long = ''
                        SET @userlevel_short = ''
                    END

                    IF (@ware_discountcode > 0) BEGIN
                        exec @ware_discount_long = dbo.GENTABLES_LONGDESC_FUNCTION 459, @ware_discountcode
                        exec @ware_discount_short = dbo.GENTABLES_SHORTDESC_FUNCTION 459, @ware_discountcode
                        SET @ware_discount_short = substring(@ware_discount_short, 1, 8)
                    END ELSE BEGIN
                        SET @ware_discount_long = ''
                        SET @ware_discount_short = ''
                    END

                    IF (@ware_allagesind = 0)
                      SET @ware_allages = 'N'

                    IF (@ware_allagesind = 1)
                      SET @ware_allages = 'Y'

                    /* 6-18-04  rework  age and grade range old way overwritting high and low ind */
                    IF (@ware_agelow IS NULL)
                      SET @ware_agelow = 0

                    IF (@ware_agehigh IS NULL)
                      SET @ware_agehigh = 0

                    IF (@ware_agehighupind IS NULL)
                      SET @ware_agehighupind = 0

                    IF (@ware_agelowupind IS NULL)
                      SET @ware_agelowupind = 0

                    IF (@ware_gradelow IS NULL)
                      SET @ware_gradelow = 0

                    IF (@ware_gradehigh IS NULL)
                      SET @ware_gradehigh = 0

                    IF (@ware_gradehighupind IS NULL)
                      SET @ware_gradehighupind = 0

                    IF (@ware_gradelowupind IS NULL)
                      SET @ware_gradelowupind = 0

                    SET @agerange = ''

                    SET @agehighstr = CAST( @ware_agehigh AS varchar(30))

                    IF (@agehighstr = '0')
                      SET @agehighstr = ''

                    SET @agelowstr = CAST( @ware_agelow AS varchar(30))

                    IF (@agelowstr = '0')
                      SET @agelowstr = ''

                    IF (@ware_agelowupind > 0)
                      IF (len(@agehighstr) = 0)
                        SET @agerange = ''
                      ELSE 
                        SET @agerange = ('UP to ' + isnull(@agehighstr, ''))

                    IF (@ware_agehighupind > 0)
                      IF (len(@agelowstr) = 0)
                        SET @agerange = ''
                      ELSE 
                        SET @agerange = (isnull(@agelowstr, '') + ' and UP')

                    IF ((len(@agehighstr) = 0) AND 
                            (len(@agerange) = 0))
                      SET @agerange = @agelowstr

                    IF ((len(@agelowstr) = 0) AND 
                            (len(@agerange) = 0))
                      SET @agerange = @agehighstr

                    IF ((len(@agelowstr) > 0) AND 
                            (len(@agehighstr) > 0))
                      SET @agerange = (isnull(@agelowstr, '') + ' to ' + isnull(@agehighstr, ''))

                    IF (@agerange = '0 to 0')
                      SET @agerange = ''

                    SET @gradehighstr = ''

                    SET @gradehighstr = CAST( @ware_gradehigh AS varchar(30))

                    IF (@gradehighstr = '0')
                      SET @gradehighstr = ''

                    SET @gradelowstr = CAST( @ware_gradelow AS varchar(30))

                    IF (@gradelowstr = '0')
                      SET @gradelowstr = ''

                    IF (@ware_gradelowupind > 0)
                      IF (len(@gradehighstr) = 0)
                        SET @graderange = ''
                      ELSE 
                        SET @graderange = ('UP to ' + isnull(@gradehighstr, ''))

                    IF (@ware_gradehighupind > 0)
                      IF (len(@gradelowstr) = 0)
                        SET @graderange = ''
                      ELSE 
                        SET @graderange = (isnull(@gradelowstr, '') + ' and UP')

                    IF ((len(@gradehighstr) = 0) AND 
                            (len(@graderange) = 0))
                      SET @graderange = @gradelowstr

                    IF ((len(@gradelowstr) = 0) AND 
                            (len(@graderange) = 0))
                      SET @graderange = @gradehighstr

                    IF ((len(@gradelowstr) > 0) AND 
                            (len(@gradehighstr) > 0))
                      SET @graderange = (isnull(@gradelowstr, '') + ' to ' + isnull(@gradehighstr, ''))

                    IF (@graderange = '0 to 0')
                      SET @graderange = ''

                    UPDATE WHTITLEINFO
                      SET 
                        WHTITLEINFO.FORMAT = @ware_format, 
                        WHTITLEINFO.FORMATSHORT = @ware_formatshort, 
                        WHTITLEINFO.MEDIA = @ware_media, 
                        WHTITLEINFO.MEDIASHORT = @ware_mediashort, 
                        WHTITLEINFO.FULLAUTHORDISPLAYNAME = @ware_fullauthordisplayname, 
                        WHTITLEINFO.TITLEPREFIX = @prefix, 
                        WHTITLEINFO.TITLEANDTITLEPREFIX = rtrim(substring(@ware_titleprefix, 1, 80)), 
                        WHTITLEINFO.TITLEPREFIXANDTITLE = ltrim(rtrim(substring(@ware_titleprefixandtitle, 1, 80)))
                      WHERE (WHTITLEINFO.BOOKKEY = @ware_bookkey)

                    IF @@ROWCOUNT = 0 
                      BEGIN
                        INSERT INTO WHERRORLOG
                          (
                            WHERRORLOG.LOGKEY, 
                            WHERRORLOG.WAREHOUSEKEY, 
                            WHERRORLOG.ERRORDESC, 
                            WHERRORLOG.ERRORSEVERITY, 
                            WHERRORLOG.ERRORFUNCTION, 
                            WHERRORLOG.LASTUSERID, 
                            WHERRORLOG.LASTMAINTDATE
                          )
                          VALUES 
                            (
                              @ware_logkey, 
                              @ware_warehousekey, 
                              'Unable to update whtitleinfo table - for bookdetail', 
                              ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                              'Stored procedure datawarehouse_bookinfo', 
                              'WARE_STORED_PROC', 
                              @ware_system_date
                            )

                      END

                    UPDATE WHTITLECLASS
                      SET 
                        WHTITLECLASS.BISACSTATUS = @bisacstatus_long, 
                        WHTITLECLASS.BISACSTATUSSHORT = @bisacstatus_short, 
                        WHTITLECLASS.EDITION = @edition_long, 
                        WHTITLECLASS.EDITIONSHORT = @edition_short, 
                        WHTITLECLASS.[LANGUAGE] = @language_long, 
                        WHTITLECLASS.LANGUAGESHORT = @language_short, 
                        WHTITLECLASS.ORIGIN = @origin_long, 
                        WHTITLECLASS.ORIGINSHORT = @origin_short, 
                        WHTITLECLASS.PLATFORM = @platform_long, 
                        WHTITLECLASS.PLATFORMSHORT = @platform_short, 
                        WHTITLECLASS.RESTRICTIONS = @restrictions_long, 
                        WHTITLECLASS.RESTRICTIONSSHORT = @restrictions_short, 
                        WHTITLECLASS.RETURNDESC = @ware_returndesc, 
                        WHTITLECLASS.RETURNSHORT = @ware_returnshort, 
                        WHTITLECLASS.SALESDIVISION = @salesdivision_long, 
                        WHTITLECLASS.SALESDIVISIONSHORT = @salesdivision_short, 
                        WHTITLECLASS.SERIES = @series_long, 
                        WHTITLECLASS.SERIESSHORT = @series_short, 
                        WHTITLECLASS.USERLEVEL = @userlevel_long, 
                        WHTITLECLASS.USERLEVELSHORT = @userlevel_short, 
                        WHTITLECLASS.VOLUME = @ware_volumenumber, 
                        WHTITLECLASS.AGES = @agerange, 
                        WHTITLECLASS.GRADES = @graderange, 
                        WHTITLECLASS.DISCOUNT = @ware_discount_long, 
                        WHTITLECLASS.DISCOUNTSHORT = @ware_discount_short, 
                        WHTITLECLASS.ALLAGESIND = @ware_allages, 
                        WHTITLECLASS.TOTALVOLUME = @ware_totalvolume, 
                        WHTITLECLASS.PROJECTISBN = @ware_projectisbn, 
                        WHTITLECLASS.ALTERNATEPROJECTISBN = @ware_alternateprojectisbn, 
                        WHTITLECLASS.NEXTISBN = @ware_nextisbn, 
                        WHTITLECLASS.NEXTEDITIONISBN = @ware_nexteditionisbn, 
                        WHTITLECLASS.PREVIOUSEDITIONISBN = @ware_previouseditionisbn, 
                        WHTITLECLASS.COPYRIGHTYEAR = @ware_copyrightyear,
			WHTITLECLASS.editiondescription = @ware_editiondescription,
			WHTITLECLASS.editionnumber = @ware_editionnumber,
			WHTITLECLASS.additionaleditinfo = @ware_additionaleditinfo
                      WHERE (WHTITLECLASS.BOOKKEY = @ware_bookkey)

                    IF @@ROWCOUNT = 0 
                      BEGIN
                        INSERT INTO WHERRORLOG
                          (
                            WHERRORLOG.LOGKEY, 
                            WHERRORLOG.WAREHOUSEKEY, 
                            WHERRORLOG.ERRORDESC, 
                            WHERRORLOG.ERRORSEVERITY, 
                            WHERRORLOG.ERRORFUNCTION, 
                            WHERRORLOG.LASTUSERID, 
                            WHERRORLOG.LASTMAINTDATE
                          )
                          VALUES 
                            (
                              @ware_logkey, 
                              @ware_warehousekey, 
                              'Unable to update whtitleclass table - for bookdetail', 
                              ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                              'Stored procedure datawarehouse_bookinfo', 
                              'WARE_STORED_PROC', 
                              @ware_system_date
                            )
                      END
                ELSE
                  BEGIN
                    INSERT INTO WHERRORLOG
                      (
                        WHERRORLOG.LOGKEY, 
                        WHERRORLOG.WAREHOUSEKEY, 
                        WHERRORLOG.ERRORDESC, 
                        WHERRORLOG.ERRORSEVERITY, 
                        WHERRORLOG.ERRORFUNCTION, 
                        WHERRORLOG.LASTUSERID, 
                        WHERRORLOG.LASTMAINTDATE
                      )
                      VALUES 
                        (
                          @ware_logkey, 
                          @ware_warehousekey, 
                          'No bookdetail rows for this title', 
                          ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                          'Stored procedure datawarehouse_bookinfo', 
                          'WARE_STORED_PROC', 
                          @ware_system_date
                        )
                 END
              END
           ELSE 
              BEGIN
                INSERT INTO WHERRORLOG
                  (
                    WHERRORLOG.LOGKEY, 
                    WHERRORLOG.WAREHOUSEKEY, 
                    WHERRORLOG.ERRORDESC, 
                    WHERRORLOG.ERRORSEVERITY, 
                    WHERRORLOG.ERRORFUNCTION, 
                    WHERRORLOG.LASTUSERID, 
                    WHERRORLOG.LASTMAINTDATE
                  )
                  VALUES 
                    (
                      @ware_logkey, 
                      @ware_warehousekey, 
                      'No bookdetail rows for this title', 
                      ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                      'Stored procedure datawarehouse_bookinfo', 
                      'WARE_STORED_PROC', 
                      @ware_system_date
                    )
              END

            /* productnumber */
            SET @ware_count = 0
            SELECT @ware_count = count( * )
              FROM PRODUCTNUMBER p, PRODUCTNUMLOCATION pl
              WHERE ((p.PRODUCTNUMLOCKEY = pl.PRODUCTNUMLOCKEY) AND 
                      (p.BOOKKEY = @ware_bookkey))

            IF @ware_count > 0
              BEGIN
                SELECT @ware_productnumber = p.PRODUCTNUMBER
                  FROM PRODUCTNUMBER p, PRODUCTNUMLOCATION pl
                  WHERE ((p.PRODUCTNUMLOCKEY = pl.PRODUCTNUMLOCKEY) AND 
                          (p.BOOKKEY = @ware_bookkey))

                  UPDATE WHTITLEINFO
                  SET WHTITLEINFO.PRODUCTNUMBER = @ware_productnumber
                  WHERE (WHTITLEINFO.BOOKKEY = @ware_bookkey)

                  IF @@ROWCOUNT = 0 
                      BEGIN
                        INSERT INTO WHERRORLOG
                          (
                            WHERRORLOG.LOGKEY, 
                            WHERRORLOG.WAREHOUSEKEY, 
                            WHERRORLOG.ERRORDESC, 
                            WHERRORLOG.ERRORSEVERITY, 
                            WHERRORLOG.ERRORFUNCTION, 
                            WHERRORLOG.LASTUSERID, 
                            WHERRORLOG.LASTMAINTDATE
                          )
                          VALUES 
                            (
                              @ware_logkey, 
                              @ware_warehousekey, 
                              'Unable to update whtitleinfo table - for productnumber', 
                              ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                              'Stored procedure datawarehouse_bookinfo', 
                              'WARE_STORED_PROC', 
                              @ware_system_date
                            )
                  END
              END ELSE BEGIN
                   INSERT INTO WHERRORLOG
                      (
                        WHERRORLOG.LOGKEY, 
                        WHERRORLOG.WAREHOUSEKEY, 
                        WHERRORLOG.ERRORDESC, 
                        WHERRORLOG.ERRORSEVERITY, 
                        WHERRORLOG.ERRORFUNCTION, 
                        WHERRORLOG.LASTUSERID, 
                        WHERRORLOG.LASTMAINTDATE
                      )
                      VALUES 
                        (
                          @ware_logkey, 
                          @ware_warehousekey, 
                          'No productnumber row for this title', 
                          ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                          'Stored procedure datawarehouse_bookinfo', 
                          'WARE_STORED_PROC', 
                          @ware_system_date
                        )
                  END

            /* isbn */

            SELECT @ware_count = count( * )
              FROM ISBN
              WHERE (ISBN.BOOKKEY = @ware_bookkey)

             IF (@ware_count = 0)
                  BEGIN
                    INSERT INTO WHERRORLOG
                      (
                        WHERRORLOG.LOGKEY, 
                        WHERRORLOG.WAREHOUSEKEY, 
                        WHERRORLOG.ERRORDESC, 
                        WHERRORLOG.ERRORSEVERITY, 
                        WHERRORLOG.ERRORFUNCTION, 
                        WHERRORLOG.LASTUSERID, 
                        WHERRORLOG.LASTMAINTDATE
                      )
                      VALUES 
                        (
                          @ware_logkey, 
                          @ware_warehousekey, 
                          'No isbn table row ', 
                          ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                          'Stored procedure datawarehouse_bookinfo', 
                          'WARE_STORED_PROC', 
                          @ware_system_date
                        )
                  END

                IF (@ware_count > 1)
                  BEGIN
                    INSERT INTO WHERRORLOG
                      (
                        WHERRORLOG.LOGKEY, 
                        WHERRORLOG.WAREHOUSEKEY, 
                        WHERRORLOG.ERRORDESC, 
                        WHERRORLOG.ERRORSEVERITY, 
                        WHERRORLOG.ERRORFUNCTION, 
                        WHERRORLOG.LASTUSERID, 
                        WHERRORLOG.LASTMAINTDATE
                      )
                      VALUES 
                        (
                          @ware_logkey, 
                          @ware_warehousekey, 
                          'No more than one isbn table row ', 
                          ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                          'Stored procedure datawarehouse_bookinfo', 
                          'WARE_STORED_PROC', 
                          @ware_system_date
                        )
                  END

                IF (@ware_count = 1)
                  BEGIN

                    /*  PM 12/20.06 -- Can't seem to find where ISBN13 dash/nodash CRM 1500 is so I'm adding it here */
                    SELECT 
                        @ware_isbn = isnull(ISBN.ISBN, ''), 
                        @ware_upc = isnull(ISBN.UPC, ''), 
                        @ware_ean = isnull(ISBN.EAN, ''), 
                        @ware_lccn = isnull(ISBN.LCCN, ''), 
                        @ware_isbn10 = isnull(ISBN.ISBN10, ''), 
                        @ware_itemnumber = isnull(ISBN.ITEMNUMBER, ''), 
                        @ware_ean13 = isnull(ISBN.EAN13, ''), 
                        @ware_isbn13_dash = isnull(ISBN.EAN, ''), 
                        @ware_isbn13_undash = isnull(ISBN.EAN13, '')
                      FROM ISBN
                      WHERE (ISBN.BOOKKEY = @ware_bookkey)


                    SELECT @ware_company = upper(ORGLEVEL.ORGLEVELDESC)
                      FROM ORGLEVEL
                      WHERE (ORGLEVEL.ORGLEVELKEY = 1)

                    IF (@ware_company = 'CONSUMER')
                      BEGIN
                        SET @ware_count = 0
                        SELECT @ware_count = count( * )
                          FROM EANUPC
                          WHERE (EANUPC.BOOKKEY = @ware_bookkey)

                        IF ((@@ROWCOUNT > 0) AND 
                                (@ware_count > 0))
                          BEGIN

                            SELECT 
                                @ware_ean13 = isnull(EANUPC.EAN13, ''), 
                                @ware_ean5 = isnull(EANUPC.EAN5, ''), 
                                @ware_upc12 = isnull(EANUPC.UPC12, ''), 
                                @ware_upc17 = isnull(EANUPC.UPC17, '')
                              FROM EANUPC
                              WHERE (EANUPC.BOOKKEY = @ware_bookkey)

                            IF (len(rtrim(@ware_ean5)) > 0)
                              SET @ware_ean = (isnull(@ware_ean13, '') + isnull(@ware_ean5, ''))
                            ELSE 
                              SET @ware_ean = @ware_ean13

                            IF (len(rtrim(@ware_upc12)) > 0)
                              SET @ware_upc = @ware_upc12
                            ELSE 
                              SET @ware_upc = @ware_upc17

                          END

                      END

                    UPDATE WHTITLEINFO
                      SET 
                        WHTITLEINFO.ISBN = @ware_isbn, 
                        WHTITLEINFO.UPC = @ware_upc, 
                        WHTITLEINFO.EAN = @ware_ean, 
                        WHTITLEINFO.LCCN = @ware_lccn, 
                        WHTITLEINFO.ISBN10 = @ware_isbn10, 
                        WHTITLEINFO.ITEMNUMBER = @ware_itemnumber, 
                        WHTITLEINFO.EAN13 = @ware_ean13, 
                        WHTITLEINFO.ISBN13_DASH = @ware_isbn13_dash, 
                        WHTITLEINFO.ISBN13_UNDASH = @ware_isbn13_undash
                      WHERE (WHTITLEINFO.BOOKKEY = @ware_bookkey)

                   IF @@ROWCOUNT = 0
                      BEGIN
                        INSERT INTO WHERRORLOG
                          (
                            WHERRORLOG.LOGKEY, 
                            WHERRORLOG.WAREHOUSEKEY, 
                            WHERRORLOG.ERRORDESC, 
                            WHERRORLOG.ERRORSEVERITY, 
                            WHERRORLOG.ERRORFUNCTION, 
                            WHERRORLOG.LASTUSERID, 
                            WHERRORLOG.LASTMAINTDATE
                          )
                          VALUES 
                            (
                              @ware_logkey, 
                              @ware_warehousekey, 
                              'Unable to update whtitleinfo table - for isbn', 
                              ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                              'Stored procedure datawarehouse_bookinfo', 
                              'WARE_STORED_PROC', 
                              @ware_system_date
                            )
	                  END

              END

            /*  end isbn */

            /* audiocassettespecs */

            SET @ware_count = 0

            SELECT @ware_count = count( * )
              FROM AUDIOCASSETTESPECS a
              WHERE (a.BOOKKEY = @ware_bookkey)

            IF @ware_count > 0
              BEGIN

                SELECT @ware_audionumberunits = a.NUMCASSETTES, @ware_audiototalruntime = a.TOTALRUNTIME
                  FROM AUDIOCASSETTESPECS a
                  WHERE ((a.BOOKKEY = @ware_bookkey) AND 
                          (a.PRINTINGKEY = 1))

                IF (@@ROWCOUNT > 0)
                  BEGIN
                    UPDATE WHTITLEINFO
                      SET WHTITLEINFO.AUDIONUMBERUNITS = @ware_audionumberunits, WHTITLEINFO.AUDIOTOTALRUNTIME = @ware_audiototalruntime
                      WHERE (WHTITLEINFO.BOOKKEY = @ware_bookkey)
		  END
                    ELSE 
                      BEGIN


                        INSERT INTO WHERRORLOG
                          (
                            WHERRORLOG.LOGKEY, 
                            WHERRORLOG.WAREHOUSEKEY, 
                            WHERRORLOG.ERRORDESC, 
                            WHERRORLOG.ERRORSEVERITY, 
                            WHERRORLOG.ERRORFUNCTION, 
                            WHERRORLOG.LASTUSERID, 
                            WHERRORLOG.LASTMAINTDATE
                          )
                          VALUES 
                            (
                              @ware_logkey, 
                              @ware_warehousekey, 
                              'Unable to update whtitleinfo table - for audiocassettespecs', 
                              ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                              'Stored procedure datawarehouse_bookinfo', 
                              'WARE_STORED_PROC', 
                              @ware_system_date
                            )
                      END
                  END
                ELSE 
                  BEGIN
                    INSERT INTO WHERRORLOG
                      (
                        WHERRORLOG.LOGKEY, 
                        WHERRORLOG.WAREHOUSEKEY, 
                        WHERRORLOG.ERRORDESC, 
                        WHERRORLOG.ERRORSEVERITY, 
                        WHERRORLOG.ERRORFUNCTION, 
                        WHERRORLOG.LASTUSERID, 
                        WHERRORLOG.LASTMAINTDATE
                      )
                      VALUES 
                        (
                          @ware_logkey, 
                          @ware_warehousekey, 
                          'No audiocassettespecs row for this title', 
                          ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                          'Stored procedure datawarehouse_bookinfo', 
                          'WARE_STORED_PROC', 
                          @ware_system_date
                        )
                  END

              END

            /*  end audiocassettespecs  */

            /* printing key = 1 */

            SET @ware_count = 0

            SELECT @ware_count = count( * )
              FROM PRINTING
              WHERE ((PRINTING.BOOKKEY = @ware_bookkey) AND 
                      (PRINTING.PRINTINGKEY = 1))


            if @@ROWCOUNT > 0 BEGIN
                SELECT 
                    @ware_announcedfirstprint = isnull(PRINTING.ANNOUNCEDFIRSTPRINT, 0), 
                    @ware_estimatedinsertillus = isnull(PRINTING.ESTIMATEDINSERTILLUS, ''), 
                    @ware_actualinsertillus = isnull(PRINTING.ACTUALINSERTILLUS, ''), 
                    @ware_tentativepagecount = isnull(PRINTING.TENTATIVEPAGECOUNT, 0), 
                    @ware_pagecount = isnull(PRINTING.PAGECOUNT, 0), 
                    @ware_projectedsales = isnull(PRINTING.PROJECTEDSALES, 0), 
                    @ware_tentativeqty = isnull(PRINTING.TENTATIVEQTY, 0), 
                    @ware_firstprintingqty = isnull(PRINTING.FIRSTPRINTINGQTY, 0), 
                    @ware_seasonkey = isnull(PRINTING.SEASONKEY, 0), 
                    @ware_estseasonkey = isnull(PRINTING.ESTSEASONKEY, 0), 
                    @ware_trimsizelength = isnull(PRINTING.TRIMSIZELENGTH, ''), 
                    @ware_trimsizewidth = isnull(PRINTING.TRIMSIZEWIDTH, ''), 
                    @ware_esttrimsizewidth = isnull(PRINTING.ESTTRIMSIZEWIDTH , ''), 
                    @ware_esttrimsizelength = isnull(PRINTING.ESTTRIMSIZELENGTH, ''), 
                    @ware_issuenumber = isnull(PRINTING.ISSUENUMBER, 0), 
                    @ware_pubmonth = isnull(PRINTING.PUBMONTH, ''), 
                    @ware_slotcode = isnull(PRINTING.SLOTCODE, 0), 
                    @ware_estannouncedfirstprint = isnull(PRINTING.ESTANNOUNCEDFIRSTPRINT, 0), 
                    @ware_estprojectedsales = isnull(PRINTING.ESTPROJECTEDSALES, 0), 
                    @ware_spinesize = isnull(PRINTING.SPINESIZE, '')
                  FROM PRINTING
                  WHERE ((PRINTING.BOOKKEY = @ware_bookkey) AND 
                          (PRINTING.PRINTINGKEY = 1))

                IF (@@ROWCOUNT > 0)
                  BEGIN
                    IF (@ware_announcedfirstprint > 0)
                      SET @ware_best = @ware_announcedfirstprint
                    ELSE 
                      SET @ware_best = @ware_estannouncedfirstprint

                    IF (@ware_announcedfirstprint = 0)
                      SET @ware_announcedfirstprint =  NULL

                    IF (@ware_estannouncedfirstprint = 0)
                      SET @ware_estannouncedfirstprint =  NULL

                    IF (@ware_best = 0)
                      SET @ware_best =  NULL

                    SET @ware_actualinsertillus =  ISNULL(@ware_actualinsertillus, '')
                    SET @ware_estimatedinsertillus =  ISNULL(@ware_estimatedinsertillus, '')
                    IF (len(rtrim(@ware_actualinsertillus)) > 0)
                      SET @ware_best2 = @ware_actualinsertillus
                    ELSE 
                      SET @ware_best2 = @ware_estimatedinsertillus
                    IF (@ware_pagecount > 0)
                      SET @ware_best3 = @ware_pagecount
                    ELSE 
                     SET @ware_best3 = @ware_tentativepagecount
                    IF (@ware_pagecount = 0)
                      SET @ware_pagecount =  NULL
                    IF (@ware_tentativepagecount = 0)
                      SET @ware_tentativepagecount =  NULL
                    IF (@ware_best3 = 0)
                      SET @ware_best3 =  NULL
                    IF (@ware_projectedsales > 0)
                      SET @ware_best4 = @ware_projectedsales
                    ELSE 
                      SET @ware_best4 = @ware_estprojectedsales
                    IF (@ware_projectedsales = 0)
                      SET @ware_projectedsales =  NULL
                    IF (@ware_estprojectedsales = 0)
                      SET @ware_estprojectedsales =  NULL
                    IF (@ware_best4 = 0)
                      SET @ware_best4 =  NULL
                    IF (@ware_firstprintingqty > 0)
                      SET @ware_best5 = @ware_firstprintingqty
                    ELSE 
                      SET @ware_best5 = @ware_tentativeqty
                    IF (@ware_firstprintingqty = 0)
                      SET @ware_firstprintingqty =  NULL
                    IF (@ware_tentativeqty = 0)
                      SET @ware_tentativeqty =  NULL
                    IF (@ware_best5 = 0)
                      SET @ware_best5 =  NULL

                    SET @ware_trimsizewidth = IsNull(@ware_trimsizewidth, '')
                    SET @ware_esttrimsizelength = IsNull(@ware_esttrimsizelength, '')
                    SET @ware_esttrimsizewidth = IsNull(@ware_esttrimsizewidth, '')
                    SET @ware_trimsizelength = IsNull(@ware_trimsizelength, '')
                    /*
                     -- 1-31-02 this is not working for whatever reason  so change the logic to below
                     -- 
                     -- 		if length(rtrim(ware_trimsizewidth,' ')) = 0 and length(rtrim(ware_trimsizelength,' ')) = 0 then
                     -- 			actstr := '';
                     -- 			if length(rtrim(ware_esttrimsizewidth,' ')) = 0 and length(rtrim(ware_esttrimsizelength,' ')) = 0 then
                     -- 				eststr := '';
                     -- 				beststr := '';
                     -- 			else
                     -- 				eststr := ware_esttrimsizewidth || ' x ' || ware_esttrimsizelength;
                     -- 				beststr := ware_esttrimsizewidth || ' x ' || ware_esttrimsizelength;
                     -- 			end if;
                     -- 		else
                     -- 			actstr := ware_trimsizewidth || ' x ' || ware_trimsizelength;
                     -- 			beststr := actstr;
                     -- 			if length(rtrim(ware_esttrimsizewidth,' ')) = 0 and length(rtrim(ware_esttrimsizelength,' ')) = 0 then
                     -- 				eststr := '';
                     -- 			else
                     -- 				eststr := ware_esttrimsizewidth || ' x ' || ware_esttrimsizelength;
                     -- 			end if;
                     -- 		end if;
                     --*/

                    IF ((len(rtrim(@ware_trimsizewidth)) > 0) AND 
                            (len(rtrim(@ware_trimsizelength)) > 0))
                      BEGIN
                        SET @actstr = (isnull(@ware_trimsizewidth, '') + ' x ' + isnull(@ware_trimsizelength, ''))
                        SET @beststr = @actstr
                        SET @eststr = (isnull(@ware_esttrimsizewidth, '') + ' x ' + isnull(@ware_esttrimsizelength, ''))
                      END
                    ELSE 
                      BEGIN
                        SET @eststr = (isnull(@ware_esttrimsizewidth, '') + ' x ' + isnull(@ware_esttrimsizelength, ''))
                        SET @beststr = @eststr
                      END

                    IF (rtrim(ltrim(@eststr)) = 'x')
                      SET @eststr = ''

                    IF (rtrim(ltrim(@actstr)) = 'x')
                      SET @actstr = ''

                    IF (rtrim(ltrim(@beststr)) = 'x')
                      SET @beststr = ''

                    IF (@ware_slotcode > 0)
                      BEGIN

                        exec @ware_slot_long = dbo.GENTABLES_LONGDESC_FUNCTION 102, @ware_slotcode
                        exec @ware_slot_short = dbo.GENTABLES_SHORTDESC_FUNCTION 102, @ware_slotcode
                        SET @ware_slot_short = substring(@ware_slot_short, 1, 8)
                      END
                    ELSE 
                      BEGIN
                        SET @ware_slot_long = ''
                        SET @ware_slot_short = ''
                      END

                    IF (@ware_estseasonkey > 0)
                      BEGIN
                        SELECT @ware_seasondesc = isnull(SEASON.SEASONDESC, '')
                          FROM SEASON
                          WHERE (SEASON.SEASONKEY = @ware_estseasonkey)

                        SET @ware_seasondesc = IsNull(@ware_seasondesc, '')

                        IF (len(rtrim(@ware_seasondesc)) > 0)
                          BEGIN
                            SET @eststr2 = @ware_seasondesc
                            SET @beststr2 = @eststr2
                          END
                        ELSE 
                          SET @eststr2 = ''
                      END

                    IF (@ware_seasonkey > 0)
                      BEGIN
                        SELECT @ware_seasondesc = isnull(SEASON.SEASONDESC, '')
                          FROM SEASON
                          WHERE (SEASON.SEASONKEY = @ware_seasonkey)

                        SET @ware_seasondesc = IsNull(@ware_seasondesc, '')

                        IF (len(rtrim(@ware_seasondesc)) > 0)
                          BEGIN
                            SET @actstr2 = @ware_seasondesc
                            SET @beststr2 = @actstr2
                          END
                        ELSE 
                          SET @actstr2 = ''
                      END

                    /* new author columns 11-12-02 */

                    BEGIN
                      DECLARE 
                        @cursor_row$AUTHORKEY$2 integer,
                        @cursor_row$DISPLAYNAME$2 varchar(255),
                        @cursor_row$LASTNAME$2 varchar(100),
                        @cursor_row$AUTHORTYPECODE$2 integer,
                        @cursor_row$PRIMARYIND$2 integer                      

                      DECLARE 
                        warehouseauthor2 CURSOR LOCAL 
                         FOR 
                          SELECT 
                              a.AUTHORKEY, 
                              isnull(a.DISPLAYNAME, ''), 
                              isnull(a.LASTNAME, '') , 
                              isnull(b.AUTHORTYPECODE, 0)  , 
                              isnull(b.PRIMARYIND, 0)  
                            FROM BOOKAUTHOR b, AUTHOR a
                            WHERE ((b.AUTHORKEY = a.AUTHORKEY) AND 
                                    (b.BOOKKEY = @ware_bookkey))
                          ORDER BY b.PRIMARYIND DESC, b.SORTORDER ASC, authortypecode
                      
                      OPEN warehouseauthor2
                      FETCH NEXT FROM warehouseauthor2
                        INTO 
                          @cursor_row$AUTHORKEY$2, 
                          @cursor_row$DISPLAYNAME$2, 
                          @cursor_row$LASTNAME$2, 
                          @cursor_row$AUTHORTYPECODE$2, 
                          @cursor_row$PRIMARYIND$2


                      WHILE  NOT(@@FETCH_STATUS = -1)
                        BEGIN
                          IF (@@FETCH_STATUS = 0)
                            BEGIN

                              /* 7-1-03 do not add duplicate authors to full author columns */
                              SET @ware_count = 0
			      set @cursor_row$DISPLAYNAME$2 = rtrim(@cursor_row$DISPLAYNAME$2)
                              exec @ware_count = dbo.AUTHOR_DUP_CHECK_SP @cursor_row$DISPLAYNAME$2, @ware_allauthdisp

                              IF (@ware_count = 0)
                                BEGIN
                                  SET @ware_allauthorlast = (isnull(@ware_allauthorlast, '') + isnull(rtrim(@cursor_row$LASTNAME$2), ''))
                                  SET @ware_allauthdisp = (isnull(@ware_allauthdisp, '') + isnull(rtrim(@cursor_row$DISPLAYNAME$2), ''))
                                  exec @ware_allauthcomp2 = AUTHOREXTRA @cursor_row$AUTHORKEY$2, 4
                                  SET @ware_allauthcomp = (isnull(@ware_allauthcomp, '') + isnull(@ware_allauthcomp2, ''))
                                END

                            END
                          FETCH NEXT FROM warehouseauthor2
                            INTO 
                              @cursor_row$AUTHORKEY$2, 
                              @cursor_row$DISPLAYNAME$2, 
                              @cursor_row$LASTNAME$2, 
                              @cursor_row$AUTHORTYPECODE$2, 
                              @cursor_row$PRIMARYIND$2
                        END

                      CLOSE warehouseauthor2

                      DEALLOCATE warehouseauthor2

                    END

                    SET @ware_allauthorlast = rtrim(@ware_allauthorlast)
		    --SET @ware_allauthorlast = substring(@ware_allauthorlast, 1, len(@ware_allauthorlast) - 1)
                    SET @ware_allauthdisp = rtrim(@ware_allauthdisp)
		    --SET @ware_allauthdisp = substring(@ware_allauthdisp, 1, len(@ware_allauthdisp) - 1)
                    SET @ware_allauthcomp = rtrim(@ware_allauthcomp)
		    --SET @ware_allauthcomp = substring(@ware_allauthcomp, 1, len(@ware_allauthcomp) - 1)

                    IF (len(ltrim(rtrim(@ware_fullauthordisplayname))) > 0)
                      SET @ware_bestdisplay = @ware_fullauthordisplayname
                    ELSE 
                      SET @ware_bestdisplay = @ware_allauthcomp

                    /*  11-26-02 add titlereleasedtoeloquenceind Y or N value */

                    /* 121206 bl */

                    SET @ware_count = 0

                    /*
                     -- 5/13/05 - could be multiple partner rows - if 1 has sendtoeloquenceind = 1, then set
                     --              lv_titlereleasedtoeloquenceind = 'Y'
                     --*/

                    SELECT @ware_count = count( * )
                      FROM BOOKEDIPARTNER
                      WHERE ((BOOKEDIPARTNER.PRINTINGKEY = 1) AND 
                              (BOOKEDIPARTNER.BOOKKEY = @ware_bookkey) AND 
                              (BOOKEDIPARTNER.SENDTOELOQUENCEIND = 1))


                    IF ((@@ROWCOUNT > 0) AND 
                            (@ware_count > 0))
                      SET @lv_titlereleasedtoeloquenceind = 'Y'
                    ELSE 
                      SET @lv_titlereleasedtoeloquenceind = 'N'

                    /*
                     -- 6/13/06 - CRM 3988 - Add logic to datawarehouse proc so that X is used inTITLERELEASEDTOELOQUENCEIND
                     --              for a title marked as 'Never Release to Eloq
                     --*/

                    SET @ware_count = 0

                    SELECT @ware_count = count( * )
                      FROM BOOKEDISTATUS
                      WHERE ((BOOKEDISTATUS.PRINTINGKEY = 1) AND 
                              (BOOKEDISTATUS.BOOKKEY = @ware_bookkey) AND 
                              (BOOKEDISTATUS.EDISTATUSCODE = 8))


                    IF (@ware_count > 0)
                      SET @lv_titlereleasedtoeloquenceind = 'X'

                    /*  01-10-03	 add childformat and short desc */

                    SET @ware_mediatypecode = 0
                    SET @ware_format = ''
                    SET @ware_count = 0
                    SELECT @ware_count = count( * )
                      FROM BOOKSIMON
                      WHERE (BOOKSIMON.BOOKKEY = @ware_bookkey)

                    IF (@ware_count > 0)
                      BEGIN
                        SELECT @ware_mediatypecode = isnull(BOOKSIMON.FORMATCHILDCODE, 0)
                          FROM BOOKSIMON
                          WHERE (BOOKSIMON.BOOKKEY = @ware_bookkey)


                        IF (@ware_mediatypecode > 0)
                          BEGIN
                            exec @ware_format = dbo.GENTABLES_LONGDESC_FUNCTION 300, @ware_mediatypecode
                            exec @ware_formatshort = dbo.GENTABLES_SHORTDESC_FUNCTION 300, @ware_mediatypecode
                          END
                        ELSE 
                          BEGIN
                            SET @ware_format = ''
                            SET @ware_formatshort = ''
                          END
                      END

                    /*  06/14/06 CRM 3968 Add carton qty to whititleinfo  */
                    SET @ware_count = 0
                    SELECT @ware_count = count( * )
                      FROM BINDINGSPECS
                      WHERE ((BINDINGSPECS.PRINTINGKEY = 1) AND 
                              (BINDINGSPECS.BOOKKEY = @ware_bookkey) AND 
                              (BINDINGSPECS.CARTONQTY1 > 0))

                    IF (@ware_count > 0)
                      BEGIN
                        SELECT @ware_cartonqty = BINDINGSPECS.CARTONQTY1
                          FROM BINDINGSPECS
                          WHERE ((BINDINGSPECS.PRINTINGKEY = 1) AND 
                                  (BINDINGSPECS.BOOKKEY = @ware_bookkey))

                      END

                    /*  1/28/05 - PM - CRM# 2212  */

                    IF (@ware_Canadian_Restriction_Code > 0)
                      BEGIN
                        exec @CanadianRestriction_long = dbo.GENTABLES_LONGDESC_FUNCTION 428, @ware_Canadian_Restriction_Code
                        exec @CanadianRestriction_short = dbo.GENTABLES_SHORTDESC_FUNCTION 428, @ware_Canadian_Restriction_Code
                      END

                    UPDATE WHTITLEINFO
                      SET 
                        WHTITLEINFO.ANNOUNCEDFIRSTPRINTACT = @ware_announcedfirstprint, 
                        WHTITLEINFO.ANNOUNCEDFIRSTPRINTEST = @ware_estannouncedfirstprint, 
                        WHTITLEINFO.ANNOUNCEDFIRSTPRINTBEST = @ware_best, 
                        WHTITLEINFO.INSERTILLUSEST = @ware_estimatedinsertillus, 
                        WHTITLEINFO.INSERTILLUSACT = @ware_actualinsertillus, 
                        WHTITLEINFO.INSERTILLUSBEST = @ware_best2, 
                        WHTITLEINFO.PAGECOUNTEST = @ware_tentativepagecount, 
                        WHTITLEINFO.PAGECOUNTACT = @ware_pagecount, 
                        WHTITLEINFO.PAGECOUNTBEST = @ware_best3, 
                        WHTITLEINFO.PROJECTEDSALESEST = @ware_estprojectedsales, 
                        WHTITLEINFO.PROJECTEDSALESACT = @ware_projectedsales, 
                        WHTITLEINFO.PROJECTEDSALESBEST = @ware_best4, 
                        WHTITLEINFO.QUANTITYEST = @ware_tentativeqty, 
                        WHTITLEINFO.QUANTITYACT = @ware_firstprintingqty, 
                        WHTITLEINFO.QUANTITYBEST = @ware_best5, 
                        WHTITLEINFO.TRIMSIZEEST = @eststr, 
                        WHTITLEINFO.TRIMSIZEACT = @actstr, 
                        WHTITLEINFO.TRIMSIZEBEST = @beststr, 
                        WHTITLEINFO.SEASONYEAREST = @eststr2, 
                        WHTITLEINFO.SEASONYEARACT = @actstr2, 
                        WHTITLEINFO.SEASONYEARBEST = @beststr2, 
                        WHTITLEINFO.ALLAUTHORLASTNAME = @ware_allauthorlast, 
                        WHTITLEINFO.ALLAUTHORDISPLAYNAME = @ware_allauthdisp, 
                        WHTITLEINFO.ALLAUTHORCOMPLETENAME = @ware_allauthcomp, 
                        WHTITLEINFO.BESTAUTHORDISPLAYNAME = @ware_bestdisplay, 
                        WHTITLEINFO.TITLERELEASEDTOELOQUENCEIND = @lv_titlereleasedtoeloquenceind, 
                        WHTITLEINFO.CHILDFORMAT = @ware_format, 
                        WHTITLEINFO.CHILDFORMATSHORT = @ware_formatshort, 
                        WHTITLEINFO.SPINESIZE = @ware_spinesize, 
                        WHTITLEINFO.CANADIAN_RESTRICTION_LONG = @CanadianRestriction_long, 
                        WHTITLEINFO.CANADIAN_RESTRICTION_SHORT = @CanadianRestriction_short, 
                        WHTITLEINFO.CARTONQTY = @ware_cartonqty
                      WHERE (WHTITLEINFO.BOOKKEY = @ware_bookkey)

                    IF (@ware_pubmonth IS NULL)
                      SET @ware_pubmonth = ''

                    /* 11-5-03 add pubyear */

                    IF len(@ware_pubmonth) > 0 BEGIN
	                 UPDATE WHTITLEINFO
                        SET 
                          WHTITLEINFO.PUBMONTH = convert(varchar(30), datename(month, @ware_pubmonth)),
                          WHTITLEINFO.PUBMONTHSHORT = convert(varchar(3), datename(month, @ware_pubmonth)),
                          WHTITLEINFO.PUBMONTHMMDDYY = convert(varchar(5), datepart(month, @ware_pubmonth)) + '/' + '1' + '/' + convert(varchar(5),datepart(year, @ware_pubmonth)), 
                          WHTITLEINFO.PUBYEAR = datepart(year, @ware_pubmonth)
                          WHERE (WHTITLEINFO.BOOKKEY = @ware_bookkey)
                    END 

		    IF @@ROWCOUNT = 0 BEGIN
                        INSERT INTO WHERRORLOG
                          (
                            WHERRORLOG.LOGKEY, 
                            WHERRORLOG.WAREHOUSEKEY, 
                            WHERRORLOG.ERRORDESC, 
                            WHERRORLOG.ERRORSEVERITY, 
                            WHERRORLOG.ERRORFUNCTION, 
                            WHERRORLOG.LASTUSERID, 
                            WHERRORLOG.LASTMAINTDATE
                          )
                          VALUES 
                            (
                              @ware_logkey, 
                              @ware_warehousekey, 
                              'Unable to update whtitleinfo table - for printing key 1', 
                              ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                              'Stored procedure datawarehouse_bookinfo', 
                              'WARE_STORED_PROC', 
                              @ware_system_date
                            )
                    END

                    UPDATE WHTITLECLASS
                    SET WHTITLECLASS.SLOT = @ware_slot_long, WHTITLECLASS.SLOTSHORT = @ware_slot_short
                    WHERE (WHTITLECLASS.BOOKKEY = @ware_bookkey)

		    IF @@ROWCOUNT = 0 BEGIN BEGIN
                        INSERT INTO WHERRORLOG
                          (
                            WHERRORLOG.LOGKEY, 
                            WHERRORLOG.WAREHOUSEKEY, 
                            WHERRORLOG.ERRORDESC, 
                            WHERRORLOG.ERRORSEVERITY, 
                            WHERRORLOG.ERRORFUNCTION, 
                            WHERRORLOG.LASTUSERID, 
                            WHERRORLOG.LASTMAINTDATE
                          )
                          VALUES 
                            (
                              @ware_logkey, 
                              @ware_warehousekey, 
                              'Unable to update whtitleclass table - for slot on printing key 1', 
                              ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                              'Stored procedure datawarehouse_bookinfo', 
                              'WARE_STORED_PROC', 
                              @ware_system_date
                            )
	            END
            END  ELSE  BEGIN
                    INSERT INTO WHERRORLOG
                      (
                        WHERRORLOG.LOGKEY, 
                        WHERRORLOG.WAREHOUSEKEY, 
                        WHERRORLOG.ERRORDESC, 
                        WHERRORLOG.ERRORSEVERITY, 
                        WHERRORLOG.ERRORFUNCTION, 
                        WHERRORLOG.LASTUSERID, 
                        WHERRORLOG.LASTMAINTDATE
                      )
                      VALUES 
                        (
                          @ware_logkey, 
                          @ware_warehousekey, 
                          'No printing row for printingkey 1', 
                          ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                          'Stored procedure datawarehouse_bookinfo', 
                          'WARE_STORED_PROC', 
                          @ware_system_date
                        )
                  END
         END  ELSE  BEGIN
                INSERT INTO WHERRORLOG
                  (
                    WHERRORLOG.LOGKEY, 
                    WHERRORLOG.WAREHOUSEKEY, 
                    WHERRORLOG.ERRORDESC, 
                    WHERRORLOG.ERRORSEVERITY, 
                    WHERRORLOG.ERRORFUNCTION, 
                    WHERRORLOG.LASTUSERID, 
                    WHERRORLOG.LASTMAINTDATE
                  )
                  VALUES 
                    (
                      @ware_logkey, 
                      @ware_warehousekey, 
                      'No printing row for printingkey 1', 
                      ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                      'Stored procedure datawarehouse_bookinfo', 
                      'WARE_STORED_PROC', 
                      @ware_system_date
                    )
          END

            IF (cursor_status(N'local', N'warehouseauthor2') = 1) BEGIN
                CLOSE warehouseauthor2
                DEALLOCATE warehouseauthor2
            END

END
go
grant execute on datawarehouse_bookinfo  to public
go
