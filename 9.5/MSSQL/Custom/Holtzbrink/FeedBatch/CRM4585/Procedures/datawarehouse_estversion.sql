IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'datawarehouse_estversion')
BEGIN
  DROP  Procedure  datawarehouse_estversion
END
GO

  CREATE 
    PROCEDURE dbo.datawarehouse_estversion 
        @ware_bookkey integer,
        @ware_printingkey integer,
        @ware_estkey integer,
        @ware_company varchar(255),
        @ware_logkey integer,
        @ware_warehousekey integer,
        @ware_system_date datetime
    AS
      BEGIN
          DECLARE 
            @cursor_row$VERSIONKEY integer,
            @cursor_row$FINISHEDGOODQTY integer,
            @cursor_row$FINISHEDGOODVENDORCODE integer,
            @cursor_row$REQUESTDATETIME datetime,
            @cursor_row$REQUESTEDBYNAME varchar(100),
            @cursor_row$REQUESTID varchar(50),
            @cursor_row$REQUESTCOMMENT varchar(8000),
            @cursor_row$REQUESTBATCHID varchar(50),
            @cursor_row$DESCRIPTION varchar(8000),
            @cursor_row$SPECIALINSTRUCTIONS1 varchar(8000),
            @ware_count integer,
            @ware_count2 integer,
            @ware_count3 integer,
            @ware_count4 integer,
            @ware_pricecount integer,
            @ware_royalcount integer,
            @ware_vendorname varchar(80),
            @ware_vendorshort varchar(8),
            @ware_pagecount integer,
            @ware_trimfamilycode integer,
            @ware_trim_long varchar(40),
            @ware_mediacode integer,
            @ware_media_long varchar(40),
            @ware_mediasubcode integer,
            @ware_mediasub_long varchar(40),
            @ware_colorcount integer,
            @ware_endpapertype varchar(40),
            @ware_foilamt numeric(10, 2),
            @ware_covercode integer,
            @ware_cover_long varchar(40),
            @ware_film integer,
            @ware_film_long varchar(40),
            @ware_bluesind varchar(1),
            @ware_firstprinting varchar(1),
            @ware_plateavailind varchar(1),
            @ware_filmavailind varchar(1),
            @ware_endpapertypedesc varchar(40),
            @ware_listprice numeric(10, 2),
            @ware_discountpercent numeric(10, 2),
            @ware_discountpercent1 numeric(10, 2),
            @ware_returnrate numeric(10, 2),
            @ware_returnrate1 numeric(10, 2),
            @ware_royaltypercent1 integer,
            @ware_totalroyalty numeric(10, 2),
            @ware_returntostock integer,
            @ware_returntostock1 integer,
            @ware_finishedgoodqty integer,
            @ware_advertisingfgqty numeric(10, 4),
            @ware_totaladvertising numeric(10, 2),
            @ware_advertisingnetcopy numeric(10, 4),
            @ware_ratecategorycode integer,
            @ware_saleschannelcode integer,
            @ware_saleschannelcode1 integer,
            @ware_remainderprice numeric(10, 2),
            @ware_remainderprice1 numeric(10, 2),
            @ware_remainderqty integer,
            @ware_remainderqty1 integer,
            @ware_overheadpercent numeric(10, 2),
            @ware_overheadpercent1 numeric(10, 2),
            @ware_advertisingpercent numeric(10, 2),
            @ware_advertisingpercent1 numeric(10, 2),
            @ware_columnheadingcode integer,
            @ware_userentercode integer,
            @ware_columnheadingcode1 integer,
            @ware_userentercode1 integer,
            @ware_datadescshort varchar(20),
            @ware_royaltypercent numeric(10, 2),
            @ware_royaltyquantity integer,
            @c_price_received numeric(10, 2),
            @c_net_copies numeric(10, 2),
            @ware_costtype varchar(1),
            @ware_totalcost integer,
            @ware_totalplant numeric(10, 2),
            @ware_totaledition numeric(10, 2),
            @c_edition_fg numeric(10, 4),
            @c_plant_fg numeric(10, 4),
            @c_total_plant numeric(10, 2),
            @c_total_edition numeric(10, 2),
            @c_edition_netcopy numeric(10, 4),
            @c_percentof numeric(10, 2),
            @c_edition_percent numeric(10, 2),
            @c_plant_netcopy numeric(10, 4),
            @c_plant_percent numeric(10, 2),
            @c_total_prod numeric(10, 2),
            @c_prod_netcopy numeric(10, 4),
            @c_prod_percent numeric(10, 2),
            @c_total_royalty numeric(10, 2),
            @c_royalty_netcopy numeric(10, 4),
            @c_royalty_percent numeric(10, 2),
            @c_prod_fg numeric(10, 4),
            @c_gross_sales numeric(20, 4),
            @c_gross_unit numeric(10, 4),
            @c_royalty_fg numeric(10, 4),
            @c_gross_percent numeric(10, 4),
            @c_edition_unit numeric(10, 4),
            @c_inv_wo_unit numeric(10, 4),
            @c_inv_wo_percent numeric(10, 2),
            @c_prod_unit numeric(10, 4),
            @grosssalescost numeric(10, 4),
            @c_royalty_unit numeric(10, 4),
            @c_total_unit numeric(10, 4),
            @c_total_percent numeric(10, 4),
            @ware_overheadfgqty numeric(10, 4),
            @ware_overheadnetcopy numeric(10, 4),
            @ware_totaloverhead integer,
            @ware_totaladvertingfg integer,
            @ware_advertingfgqty integer,
            @ware_advertingfgnetcopy integer,
            @c_total_overhead numeric(10, 2),
            @c_overhead_fg numeric(10, 4),
            @c_overhead_netcopy numeric(10, 4),
            @c_overhead_percent numeric(10, 2),
            @c_total_advertising numeric(10, 2),
            @c_advertising_fg numeric(10, 4),
            @c_advertising_netcopy numeric(10, 4),
            @c_advertising_percent numeric(10, 2),
            @c_total_cost numeric(10, 2),
            @c_returned_qty numeric(10, 4),
            @c_sales integer,
            @c_returns integer,
            @c_net_sales integer,
            @c_remainder_sales integer,
            @c_total_revenue numeric(10, 2),
            @c_revenue_per_fgqty numeric(10, 4),
            @c_revenue_per_netcopies numeric(10, 4),
            @c_profit_loss numeric(10, 2),
            @c_profitloss_per_fgqty numeric(10, 4),
            @c_profitloss_per_netcopies numeric(10, 4),
            @c_profit_margin numeric(10, 2),
            @c_netqty numeric(10, 2),
            @c_net_unit numeric(10, 4),
            @c_inv_wo numeric(10, 2),
            @c_plant_unit numeric(10, 4),
            @c_var_gp numeric(10, 4),
            @c_var_gp_unit numeric(10, 4)          
          SET @ware_count = 1
          SET @ware_count2 = 0
          SET @ware_count3 = 0
          SET @ware_count4 = 0
          SET @ware_pricecount = 0
          SET @ware_royalcount = 0
          SET @ware_vendorname = ''
          SET @ware_vendorshort = ''
          SET @ware_pagecount = 0
          SET @ware_trimfamilycode = 0
          SET @ware_trim_long = ''
          SET @ware_mediacode = 0
          SET @ware_media_long = ''
          SET @ware_mediasubcode = 0
          SET @ware_mediasub_long = ''
          SET @ware_colorcount = 0
          SET @ware_endpapertype = ''
          SET @ware_foilamt = 0
          SET @ware_covercode = 0
          SET @ware_cover_long = ''
          SET @ware_film = 0
          SET @ware_film_long = ''
          SET @ware_bluesind = ''
          SET @ware_firstprinting = ''
          SET @ware_plateavailind = ''
          SET @ware_filmavailind = ''
          SET @ware_endpapertypedesc = ''
          SET @ware_listprice = 0
          SET @ware_discountpercent = 0
          SET @ware_discountpercent1 = 0
          SET @ware_returnrate = 0
          SET @ware_returnrate1 = 0
          SET @ware_royaltypercent1 = 0
          SET @ware_totalroyalty = 0
          SET @ware_returntostock = 0
          SET @ware_returntostock1 = 0
          SET @ware_finishedgoodqty = 0
          SET @ware_advertisingfgqty = 0
          SET @ware_totaladvertising = 0
          SET @ware_advertisingnetcopy = 0
          SET @ware_ratecategorycode = 0
          SET @ware_saleschannelcode = 0
          SET @ware_saleschannelcode1 = 0
          SET @ware_remainderprice = 0
          SET @ware_remainderprice1 = 0
          SET @ware_remainderqty = 0
          SET @ware_remainderqty1 = 0
          SET @ware_overheadpercent = 0
          SET @ware_overheadpercent1 = 0
          SET @ware_advertisingpercent = 0
          SET @ware_advertisingpercent1 = 0
          SET @ware_columnheadingcode = 0
          SET @ware_userentercode = 0
          SET @ware_columnheadingcode1 = 0
          SET @ware_userentercode1 = 0
          SET @ware_datadescshort = ''
          SET @ware_royaltypercent = 0
          SET @ware_royaltyquantity = 0
          SET @c_price_received = 0
          SET @c_net_copies = 0
          SET @ware_costtype = ''
          SET @ware_totalcost = 0
          SET @ware_totalplant = 0
          SET @ware_totaledition = 0
          SET @c_edition_fg = 0
          SET @c_plant_fg = 0
          SET @c_total_plant = 0
          SET @c_total_edition = 0
          SET @c_edition_netcopy = 0
          SET @c_percentof = 0
          SET @c_edition_percent = 0
          SET @c_plant_netcopy = 0
          SET @c_plant_percent = 0
          SET @c_total_prod = 0
          SET @c_prod_netcopy = 0
          SET @c_prod_percent = 0
          SET @c_total_royalty = 0
          SET @c_royalty_netcopy = 0
          SET @c_royalty_percent = 0
          SET @c_prod_fg = 0
          SET @c_gross_sales = 0
          SET @c_gross_unit = 0
          SET @c_royalty_fg = 0
          SET @c_gross_percent = 0
          SET @c_edition_unit = 0
          SET @c_inv_wo_unit = 0
          SET @c_inv_wo_percent = 0
          SET @c_prod_unit = 0
          SET @grosssalescost = 0
          SET @c_royalty_unit = 0
          SET @c_total_unit = 0
          SET @c_total_percent = 0
          SET @ware_overheadfgqty = 0
          SET @ware_overheadnetcopy = 0
          SET @ware_totaloverhead = 0
          SET @ware_totaladvertingfg = 0
          SET @ware_advertingfgqty = 0
          SET @ware_advertingfgnetcopy = 0
          SET @c_total_overhead = 0
          SET @c_overhead_fg = 0
          SET @c_overhead_netcopy = 0
          SET @c_overhead_percent = 0
          SET @c_total_advertising = 0
          SET @c_advertising_fg = 0
          SET @c_advertising_netcopy = 0
          SET @c_advertising_percent = 0
          SET @c_total_cost = 0
          SET @c_returned_qty = 0
          SET @c_sales = 0
          SET @c_returns = 0
          SET @c_net_sales = 0
          SET @c_remainder_sales = 0
          SET @c_total_revenue = 0
          SET @c_revenue_per_fgqty = 0
          SET @c_revenue_per_netcopies = 0
          SET @c_profit_loss = 0
          SET @c_profitloss_per_fgqty = 0
          SET @c_profitloss_per_netcopies = 0
          SET @c_profit_margin = 0
          SET @c_netqty = 0
          SET @c_net_unit = 0
          SET @c_inv_wo = 0
          SET @c_plant_unit = 0
          SET @c_var_gp = 0
          SET @c_var_gp_unit = 0
          BEGIN

            BEGIN

              DECLARE 
                @cursor_row$VERSIONKEY$2 integer,
                @cursor_row$FINISHEDGOODQTY$2 integer,
                @cursor_row$FINISHEDGOODVENDORCODE$2 integer,
                @cursor_row$REQUESTDATETIME$2 datetime,
                @cursor_row$REQUESTEDBYNAME$2 varchar(8000),
                @cursor_row$REQUESTID$2 varchar(8000),
                @cursor_row$REQUESTCOMMENT$2 varchar(8000),
                @cursor_row$REQUESTBATCHID$2 varchar(8000),
                @cursor_row$DESCRIPTION$2 varchar(8000),
                @cursor_row$SPECIALINSTRUCTIONS1$2 varchar(8000)              

              DECLARE 
                warehouseversion CURSOR LOCAL 
                 FOR 
                  SELECT 
                      dbo.ESTVERSION.VERSIONKEY, 
                      isnull(dbo.ESTVERSION.FINISHEDGOODQTY, 0) AS FINISHEDGOODQTY, 
                      isnull(dbo.ESTVERSION.FINISHEDGOODVENDORCODE, 0) AS FINISHEDGOODVENDORCODE, 
                      isnull(dbo.ESTVERSION.REQUESTDATETIME, '') AS REQUESTDATETIME, 
                      isnull(dbo.ESTVERSION.REQUESTEDBYNAME, '') AS REQUESTEDBYNAME, 
                      isnull(dbo.ESTVERSION.REQUESTID, '') AS REQUESTID, 
                      isnull(dbo.ESTVERSION.REQUESTCOMMENT, '') AS REQUESTCOMMENT, 
                      isnull(dbo.ESTVERSION.REQUESTBATCHID, '') AS REQUESTBATCHID, 
                      isnull(dbo.ESTVERSION.DESCRIPTION, '') AS DESCRIPTION, 
                      isnull(dbo.ESTVERSION.SPECIALINSTRUCTIONS1, '') AS SPECIALINSTRUCTIONS1
                    FROM dbo.ESTVERSION
                    WHERE (dbo.ESTVERSION.ESTKEY = @ware_estkey)
              

              OPEN warehouseversion

              FETCH NEXT FROM warehouseversion
                INTO 
                  @cursor_row$VERSIONKEY$2, 
                  @cursor_row$FINISHEDGOODQTY$2, 
                  @cursor_row$FINISHEDGOODVENDORCODE$2, 
                  @cursor_row$REQUESTDATETIME$2, 
                  @cursor_row$REQUESTEDBYNAME$2, 
                  @cursor_row$REQUESTID$2, 
                  @cursor_row$REQUESTCOMMENT$2, 
                  @cursor_row$REQUESTBATCHID$2, 
                  @cursor_row$DESCRIPTION$2, 
                  @cursor_row$SPECIALINSTRUCTIONS1$2

              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN
                  IF (@@FETCH_STATUS = -1)
                    BEGIN
                      /*  no estimate rows */
                      INSERT INTO dbo.WHEST
                        (
                          dbo.WHEST.ESTKEY, 
                          dbo.WHEST.BOOKKEY, 
                          dbo.WHEST.PRINTINGKEY, 
                          dbo.WHEST.ESTVERSION, 
                          dbo.WHEST.LASTUSERID, 
                          dbo.WHEST.LASTMAINTDATE
                        )
                        VALUES 
                          (
                            @ware_estkey, 
                            @ware_bookkey, 
                            @ware_printingkey, 
                            0, 
                            'WARE_STORED_PROC', 
                            @ware_system_date
                          )

                      INSERT INTO dbo.WHESTCOST
                        (
                          dbo.WHESTCOST.ESTKEY, 
                          dbo.WHESTCOST.ESTVERSION, 
                          dbo.WHESTCOST.COMPKEY, 
                          dbo.WHESTCOST.CHARGECODEKEY, 
                          dbo.WHESTCOST.LASTUSERID, 
                          dbo.WHESTCOST.LASTMAINTDATE
                        )
                        VALUES 
                          (
                            @ware_estkey, 
                            0, 
                            0, 
                            0, 
                            'WARE_STORED_PROC', 
                            @ware_system_date
                          )
                      BREAK 
                    END

                  SET @ware_count2 = 0

                  SELECT @ware_count2 = count( * )
                    FROM dbo.VENDOR
                    WHERE (dbo.VENDOR.VENDORKEY = @cursor_row$FINISHEDGOODVENDORCODE$2)

                  IF @@ROWCOUNT > 0 AND @ware_count2 > 0
                    BEGIN
                      SELECT @ware_vendorname = isnull(dbo.VENDOR.NAME, ''), 
		             @ware_vendorshort = isnull(dbo.VENDOR.SHORTDESC, '')
                        FROM dbo.VENDOR
                        WHERE (dbo.VENDOR.VENDORKEY = @cursor_row$FINISHEDGOODVENDORCODE$2)
                    END

                  INSERT INTO dbo.WHEST
                    (
                      dbo.WHEST.ESTKEY, 
                      dbo.WHEST.BOOKKEY, 
                      dbo.WHEST.PRINTINGKEY, 
                      dbo.WHEST.ESTVERSION, 
                      dbo.WHEST.REQUESTDATETIME, 
                      dbo.WHEST.REQUESTEDBYNAME, 
                      dbo.WHEST.REQUESTID, 
                      dbo.WHEST.REQUESTCOMMENT, 
                      dbo.WHEST.REQUESTBATCHID, 
                      dbo.WHEST.FINISHEDGOODQTY, 
                      dbo.WHEST.FINISHEDGOODVENDOR, 
                      dbo.WHEST.LASTUSERID, 
                      dbo.WHEST.LASTMAINTDATE, 
                      dbo.WHEST.VERSIONDESC, 
                      dbo.WHEST.SPECIALINSTRUCTIONS1
                    )
                    VALUES 
                      (
                        @ware_estkey, 
                        @ware_bookkey, 
                        @ware_printingkey, 
                        @cursor_row$VERSIONKEY$2, 
                        @cursor_row$REQUESTDATETIME$2, 
                        @cursor_row$REQUESTEDBYNAME$2, 
                        @cursor_row$REQUESTID$2, 
                        @cursor_row$REQUESTCOMMENT$2, 
                        @cursor_row$REQUESTBATCHID$2, 
                        @cursor_row$FINISHEDGOODQTY$2, 
                        @ware_vendorname, 
                        'WARE_STORED_PROC', 
                        @ware_system_date, 
                        @cursor_row$DESCRIPTION$2, 
                        @cursor_row$SPECIALINSTRUCTIONS1$2
                      )

                  IF (@@ROWCOUNT > 0)
                    BEGIN
                      /*  3-26-04 save finishedgoodqty from cursor  */
                      SET @ware_finishedgoodqty = @cursor_row$FINISHEDGOODQTY$2
                      /*
                       -- CRM 2881 PM 6-6-05 Changed equijoin to left join in the following 2 queries to accomodate issue
                       -- 		where e.endpapertype was NULL
                       --*/

                      SET @ware_count = (@ware_count + 1)
                      SET @ware_count2 = 0
                      SELECT @ware_count2 = count( * )
                        FROM dbo.ESTSPECS e LEFT
                           JOIN dbo.ENDPAPER ed  ON (e.ENDPAPERTYPE = ed.ENDPAPERTYPEKEY)
                        WHERE ((e.ESTKEY = @ware_estkey) AND 
                                (e.VERSIONKEY = @cursor_row$VERSIONKEY$2))

                      IF @@ROWCOUNT > 0 AND @ware_count2 > 0 BEGIN
                          SELECT 
                              @ware_pagecount = isnull(e.PAGECOUNT, 0), 
                              @ware_trimfamilycode = isnull(e.TRIMFAMILYCODE, 0), 
                              @ware_film = isnull(e.FILM, 0), 
                              @ware_bluesind = isnull(e.BLUESIND, ''), 
                              @ware_mediacode = isnull(e.MEDIATYPECODE, 0), 
                              @ware_mediasubcode = isnull(e.MEDIATYPESUBCODE, 0), 
                              @ware_colorcount = isnull(e.COLORCOUNT, 0), 
                              @ware_endpapertype = isnull(e.ENDPAPERTYPE, ''), 
                              @ware_foilamt = isnull(e.FOILAMT, 0), 
                              @ware_covercode = isnull(e.COVERTYPECODE, 0), 
                              @ware_firstprinting = isnull(e.FIRSTPRINTING, ''), 
                              @ware_plateavailind = isnull(e.PLATEAVAILIND, ''), 
                              @ware_filmavailind = isnull(e.FILMAVAILIND, ''), 
                              @ware_endpapertypedesc = isnull(CASE (ed.ENDPAPERTYPEDESC + '.') WHEN '.' THEN NULL ELSE ed.ENDPAPERTYPEDESC END, '')
                            FROM dbo.ESTSPECS e LEFT
                               JOIN dbo.ENDPAPER ed  ON (e.ENDPAPERTYPE = ed.ENDPAPERTYPEKEY)
                            WHERE ((e.ESTKEY = @ware_estkey) AND 
                                    (e.VERSIONKEY = @cursor_row$VERSIONKEY$2))

                          IF (@ware_trimfamilycode > 0)
                            SET @ware_trim_long = dbo.gentables_longdesc_function(29, @ware_trimfamilycode)
                          ELSE 
                            SET @ware_trim_long = ''

                          IF (@ware_mediacode > 0)
                            SET @ware_media_long = dbo.gentables_longdesc_function(258, @ware_mediacode)
                          ELSE 
                            SET @ware_media_long = ''

                          IF (@ware_mediasubcode > 0)
                            SET @ware_mediasub_long = dbo.SUBGENT_LONGDESC_FUNCTION(258, @ware_mediacode, @ware_mediasubcode)
                          ELSE 
                            SET @ware_mediasub_long = ''

                          IF (@ware_covercode > 0)
                            SET @ware_cover_long = dbo.gentables_longdesc_function(11, @ware_covercode)
                          ELSE 
                            SET @ware_cover_long = ''

                          IF (@ware_film > 0)
                            SET @ware_film_long = dbo.gentables_longdesc_function(50, @ware_film)
                          ELSE 
                            SET @ware_film_long = ''

                          UPDATE dbo.WHEST
                            SET 
                              dbo.WHEST.PAGECOUNT = @ware_pagecount, 
                              dbo.WHEST.TRIMFAMILY = @ware_trim_long, 
                              dbo.WHEST.FILM = @ware_film_long, 
                              dbo.WHEST.BLUESIND = @ware_bluesind, 
                              dbo.WHEST.MEDIATYPE = @ware_media_long, 
                              dbo.WHEST.MEDIASUBTYPE = @ware_mediasub_long, 
                              dbo.WHEST.COLORCOUNT = @ware_colorcount, 
                              dbo.WHEST.FOILAMT = @ware_foilamt, 
                              dbo.WHEST.COVERTYPE = @ware_cover_long, 
                              dbo.WHEST.FIRSTPRINTING = @ware_firstprinting, 
                              dbo.WHEST.PLATEAVAILIND = @ware_plateavailind, 
                              dbo.WHEST.FILMAVAILIND = @ware_filmavailind
                            WHERE ((dbo.WHEST.ESTKEY = @ware_estkey) AND 
                                    (dbo.WHEST.BOOKKEY = @ware_bookkey) AND 
                                    (dbo.WHEST.PRINTINGKEY = @ware_printingkey) AND 
                                    (dbo.WHEST.ESTVERSION = @cursor_row$VERSIONKEY$2))

                        END

                      /* estplspecs pricing and royalty */
                      IF (@ware_company = 'CONSUMER') BEGIN

                          SET @ware_pricecount = 0

                          SELECT @ware_pricecount = count( * )
                            FROM dbo.ESTPLSPECS e, dbo.ESTBOOK eb
                            WHERE ((e.ESTKEY = eb.ESTKEY) AND 
                                    (e.ESTKEY = @ware_estkey) AND 
                                    (e.VERSIONKEY = @cursor_row$VERSIONKEY$2))

                          /* 3-26-04 remove estversion from this select-- do not need finishedgoods already gotten in cursor */

                          IF @@ROWCOUNT > 0 AND @ware_pricecount > 0  BEGIN
                              SELECT 
                                  @ware_listprice = isnull(e.LISTPRICE, 0), 
                                  @ware_discountpercent = isnull(e.DISCOUNTPERCENT, 0), 
                                  @ware_returnrate = isnull(e.RETURNRATE, 0), 
                                  @ware_royaltypercent = isnull(e.ROYALTYPERCENT, 0), 
                                  @ware_totalroyalty = isnull(e.TOTALROYALTY, 0), 
                                  @ware_returntostock = isnull(e.RETURNTOSTOCK, 0), 
                                  @ware_ratecategorycode = isnull(eb.RATECATEGORYCODE, 1), 
                                  @ware_saleschannelcode = isnull(e.SALESCHANNELCODE, 0)
                                FROM dbo.ESTPLSPECS e, dbo.ESTBOOK eb
                                WHERE ((e.ESTKEY = eb.ESTKEY) AND 
                                        (e.ESTKEY = @ware_estkey) AND 
                                        (e.VERSIONKEY = @cursor_row$VERSIONKEY$2))

                           END
                        END
                      ELSE 
                        BEGIN
                          SET @ware_pricecount = 0
                          SELECT @ware_pricecount = count( * )
                            FROM dbo.ESTBOOK eb, dbo.ESTPLSPECS e
                               LEFT JOIN dbo.GENTABLES g  ON (e.COLUMNHEADINGCODE = g.DATACODE)
                            WHERE ((e.ESTKEY = eb.ESTKEY) AND 
                                    (e.ESTKEY = @ware_estkey) AND 
                                    (e.VERSIONKEY = @cursor_row$VERSIONKEY$2) AND 
                                    (g.TABLEID = 392))


                          IF @@ROWCOUNT > 0 AND @ware_pricecount > 0 BEGIN
                              SELECT 
                                  @ware_listprice = isnull(e.LISTPRICE, 0), 
                                  @ware_discountpercent = isnull(e.DISCOUNTPERCENT, 0), 
                                  @ware_returnrate = isnull(e.RETURNRATE, 0), 
                                  @ware_royaltypercent = isnull(e.ROYALTYPERCENT, 0), 
                                  @ware_remainderprice = isnull(e.REMAINDERPRICE, 0), 
                                  @ware_remainderqty = isnull(e.REMAINDERQTY, 0), 
                                  @ware_overheadpercent = isnull(e.OVERHEADPERCENT, 0), 
                                  @ware_advertisingpercent = isnull(e.ADVERTISINGPERCENT, 0), 
                                  @ware_totalroyalty = isnull(e.TOTALROYALTY, 0), 
                                  @ware_columnheadingcode = isnull(e.COLUMNHEADINGCODE, 0), 
                                  @ware_userentercode = isnull(e.USERENTERCODE, 0), 
                                  @ware_datadescshort = isnull(g.DATADESCSHORT, ''), 
                                  @ware_ratecategorycode = isnull(eb.RATECATEGORYCODE, 1)
                                FROM dbo.ESTBOOK eb, dbo.ESTPLSPECS e
                                   LEFT JOIN dbo.GENTABLES g  ON (e.COLUMNHEADINGCODE = g.DATACODE)
                                WHERE ((e.ESTKEY = eb.ESTKEY) AND 
                                        (e.ESTKEY = @ware_estkey) AND 
                                        (e.VERSIONKEY = @cursor_row$VERSIONKEY$2) AND 
                                        (g.TABLEID = 392))
                            END

                        END

                      IF (@ware_company <> 'CONSUMER')
                        IF (@ware_remainderqty = 0)
                          SET @ware_remainderqty = ((@ware_finishedgoodqty * @ware_discountpercent) / 100)

                      /*  estimate royalty information */
                      SET @ware_royalcount = 0
                      SELECT @ware_royalcount = count( * )
                        FROM dbo.ESTROYAL
                        WHERE ((dbo.ESTROYAL.ESTKEY = @ware_estkey) AND 
                                (dbo.ESTROYAL.VERSIONKEY = @cursor_row$VERSIONKEY$2))

                      IF (@ware_royalcount > 0) BEGIN

                          SELECT @ware_royaltypercent = isnull(max(dbo.ESTROYAL.ROYALTYPERCENT), 0), @ware_royaltyquantity = isnull(max(dbo.ESTROYAL.ROYALTYQUANTITY), 0)
                            FROM dbo.ESTROYAL
                            WHERE ((dbo.ESTROYAL.ESTKEY = @ware_estkey) AND 
                                    (dbo.ESTROYAL.VERSIONKEY = @cursor_row$VERSIONKEY$2))

                          IF ((@ware_columnheadingcode = 0) AND 
                                  (@ware_userentercode = 0) AND 
                                  (@ware_ratecategorycode = 0))
                            SET @ware_ratecategorycode = 1

                          SET @ware_count2 = 0

                          SELECT @ware_count2 = count( * )
                            FROM dbo.DEFAULTPLSPECS

                          IF @@ROWCOUNT > 0 AND  @ware_count2 > 0  BEGIN

                              SELECT 
                                  @ware_columnheadingcode1 = isnull(dbo.DEFAULTPLSPECS.COLUMNHEADINGCODE, 0), 
                                  @ware_userentercode1 = isnull(dbo.DEFAULTPLSPECS.USERENTERCODE, 0), 
                                  @ware_discountpercent1 = isnull(dbo.DEFAULTPLSPECS.DISCOUNTPERCENT, 0), 
                                  @ware_returnrate1 = isnull(dbo.DEFAULTPLSPECS.RETURNRATE, 0), 
                                  @ware_royaltypercent1 = isnull(dbo.DEFAULTPLSPECS.ROYALTYPERCENTOFCODE, 0), 
                                  @ware_returntostock1 = isnull(dbo.DEFAULTPLSPECS.RETURNTOSTOCKRATE, 0), 
                                  @ware_saleschannelcode1 = isnull(dbo.DEFAULTPLSPECS.SALESCHANNELCODE, 0), 
                                  @ware_remainderprice1 = isnull(dbo.DEFAULTPLSPECS.REMAINDERPRICE, 0), 
                                  @ware_remainderqty1 = isnull(dbo.DEFAULTPLSPECS.REMAINDERQTY, 0), 
                                  @ware_overheadpercent1 = isnull(dbo.DEFAULTPLSPECS.OVERHEADPERCENT, 0), 
                                  @ware_advertisingpercent1 = isnull(dbo.DEFAULTPLSPECS.ADVERTISINGPERCENT, 0)
                                FROM dbo.DEFAULTPLSPECS
                                WHERE (dbo.DEFAULTPLSPECS.RATECATEGORYCODE = @ware_ratecategorycode)

                              IF (@ware_company <> 'CONSUMER')
                                BEGIN

                                 /*  get columnheading desc from default */
                                  SELECT @ware_count4 = count( * )
                                    FROM dbo.GENTABLES
                                    WHERE ((dbo.GENTABLES.TABLEID = 392) AND 
                                            (dbo.GENTABLES.DATACODE = @ware_columnheadingcode1))

                                  IF (@ware_count4 = 1)
                                    BEGIN
                                      SELECT @ware_datadescshort = dbo.GENTABLES.DATADESCSHORT
                                        FROM dbo.GENTABLES
                                        WHERE ((dbo.GENTABLES.TABLEID = 392) AND 
                                                (dbo.GENTABLES.DATACODE = @ware_columnheadingcode1))


                                    END
                                  ELSE 
                                    SET @ware_datadescshort = 'undefined'
                                    SET @ware_columnheadingcode = @ware_columnheadingcode1
                                    SET @ware_userentercode = @ware_userentercode1

                                END

                              IF (@ware_pricecount = 0)
                                BEGIN

                                  SET @ware_discountpercent = @ware_discountpercent1
                                  SET @ware_returnrate = @ware_returnrate1
                                  SET @ware_royaltypercent = @ware_royaltypercent1

                                  IF (@ware_company = 'CONSUMER')
                                    BEGIN
                                      SET @ware_saleschannelcode = @ware_saleschannelcode1
                                      SET @ware_returntostock = @ware_returntostock1
                                    END
                                  ELSE 
                                    BEGIN
                                      SET @ware_remainderprice = @ware_remainderprice1
                                      SET @ware_remainderqty = @ware_remainderqty1
                                      SET @ware_overheadpercent = @ware_overheadpercent1
                                      SET @ware_advertisingpercent = @ware_advertisingpercent1
                                    END
                                END
                            END
                        END

                      /*  do not see how these values are placed back into pricing? DO NOT CALL FOR NOW */

                      /* 	if ware_royalcount = 0 then /-* royalty from above is zero do defaults */

                      /* 		if ware_company = 'CONSUMER' and ware_bookkey > 0 then  */

                      /* 			datawarehouse_estroyalty1 (ware_bookkey,ware_saleschannelcode,ware_ratecategorycode, */

                      /* 			ware_company,ware_estkey,cursor_row.versionkey,ware_logkey, */

                      /* 			ware_warehousekey); */

                      /* 		else */

                      /* 			datawarehouse_estroyalty1 (ware_bookkey,ware_saleschannelcode,ware_ratecategorycode, */

                      /* 			ware_company,ware_estkey,cursor_row.versionkey,ware_logkey, */

                      /* 			ware_warehousekey); */

                      /*
                       -- end if;
                       -- /-*	end if;
                       --*/

                      /*  estplspecs  costs  */

                      /*  05-25-05 PM CRM 2855 Reset ware_totalplant  */

                      SET @ware_totalplant = 0
                      SET @ware_count2 = 0
                      SELECT @ware_count2 = count( * )
                        FROM dbo.CDLIST c, dbo.ESTCOST e
                        WHERE ((c.INTERNALCODE = e.CHGCODECODE) AND 
                                (e.ESTKEY = @ware_estkey) AND 
                                (e.VERSIONKEY = @cursor_row$VERSIONKEY$2) AND 
                                (c.COSTTYPE = 'P'))


                      IF @@ROWCOUNT > 0 AND @ware_count2 > 0 BEGIN
                          SELECT @ware_costtype = c.COSTTYPE, @ware_totalplant = isnull(SUM(e.TOTALCOST), 0)
                            FROM dbo.CDLIST c, dbo.ESTCOST e
                            WHERE ((c.INTERNALCODE = e.CHGCODECODE) AND 
                                    (e.ESTKEY = @ware_estkey) AND 
                                    (e.VERSIONKEY = @cursor_row$VERSIONKEY$2) AND 
                                    (c.COSTTYPE = 'P'))
                            GROUP BY c.COSTTYPE
                        END

                      SET @ware_count3 = 0

                      SELECT @ware_count3 = count( * )
                        FROM dbo.CDLIST c, dbo.ESTCOST e
                        WHERE ((c.INTERNALCODE = e.CHGCODECODE) AND 
                                (e.ESTKEY = @ware_estkey) AND 
                                (e.VERSIONKEY = @cursor_row$VERSIONKEY$2) AND 
                                (c.COSTTYPE = 'E'))

                      IF @@ROWCOUNT > 0 AND @ware_count3 > 0 BEGIN
                          SELECT @ware_costtype = c.COSTTYPE, @ware_totaledition = isnull(SUM(e.TOTALCOST), 0)
                            FROM dbo.CDLIST c, dbo.ESTCOST e
                            WHERE ((c.INTERNALCODE = e.CHGCODECODE) AND 
                                    (e.ESTKEY = @ware_estkey) AND 
                                    (e.VERSIONKEY = @cursor_row$VERSIONKEY$2) AND 
                                    (c.COSTTYPE = 'E'))
                            GROUP BY c.COSTTYPE
                        END

                      /*
                       -- 2-4-03 just case too many write errors
                       -- 	if ware_count2 = 0 and ware_count3 = 0 then
                       -- 			INSERT INTO qsidba.wherrorlog (logkey, warehousekey,errordesc,
                       --      	   		 errorseverity, errorfunction,lastuserid, lastmaintdate)
                       -- 		 VALUES (to_char(ware_logkey)  ,to_char(ware_warehousekey),
                       -- 			'Error retrieving total costs',
                       -- 			('Warning/data error estkey '||to_char(ware_estkey)),
                       -- 			'Stored procedure datawarehouse_estver','WARE_STORED_PROC', ware_system_date);
                       -- 		commit;
                       -- 	end if;
                       --*/

                      SET @c_price_received = (@ware_listprice * (1 - (@ware_discountpercent / 100)))
                      SET @c_net_copies = (@ware_finishedgoodqty - (@ware_finishedgoodqty * @ware_returnrate / 100))
                      SET @c_total_edition = @ware_totaledition
                      SET @c_total_plant = @ware_totalplant
                      IF (@ware_finishedgoodqty > 0)
                        BEGIN
                          SET @c_edition_fg = (@c_total_edition / @ware_finishedgoodqty)
                          SET @c_plant_fg = (@c_total_plant / @ware_finishedgoodqty)
                        END

                      IF (@c_net_copies > 0)
                        SET @c_edition_netcopy = (@c_total_edition / @c_net_copies)

                      IF (@ware_columnheadingcode = 1)
                        SET @c_percentof = (@ware_listprice * @ware_finishedgoodqty)
                      ELSE 
                        SET @c_percentof = ((@ware_listprice * (1 - (@ware_discountpercent / 100))) * @ware_finishedgoodqty)

                      IF (@c_percentof > 0)
                        SET @c_edition_percent = ((@ware_totaledition / @c_percentof) * 100)

                      IF (@c_net_copies > 0)
                        SET @c_plant_netcopy = (@c_total_plant / @c_net_copies)

                      IF (@c_percentof > 0)
                        SET @c_plant_percent = ((@ware_totalplant / @c_percentof) * 100)

                      SET @c_total_prod = (@c_total_edition + @c_total_plant)

                      SET @c_prod_netcopy = (@c_edition_netcopy + @c_plant_netcopy)

                      IF (@c_percentof > 0)
                        SET @c_prod_percent = ((@c_total_prod / @c_percentof) * 100)

                      SET @c_total_royalty = @ware_totalroyalty

                      IF (@c_net_copies > 0)
                        SET @c_royalty_netcopy = (@ware_totalroyalty / @c_net_copies)

                      IF (@c_percentof > 0)
                        SET @c_royalty_percent = ((@c_total_royalty / @c_percentof) * 100)

                      IF ((@ware_userentercode = 2) AND 
                              (@ware_overheadfgqty > 0))
                        SET @c_total_overhead = (@ware_overheadfgqty * @ware_finishedgoodqty)
                      ELSE 
                        IF ((@ware_userentercode = 3) AND 
                                (@ware_overheadnetcopy > 0))
                          SET @c_total_overhead = (@ware_overheadnetcopy * @c_net_copies)
                        ELSE 
                          IF ((@ware_userentercode = 1) AND 
                                  (@ware_totaloverhead > 0))
                            SET @c_total_overhead = @ware_totaloverhead
                          ELSE 
                            SET @c_total_overhead = ((@ware_overheadpercent / 100) * @c_percentof)

                      SET @ware_totaloverhead = @c_total_overhead

                      IF ((@ware_userentercode = 1) AND 
                              (@ware_totaloverhead > 0))
                        SET @c_overhead_fg = (@ware_totaloverhead / @ware_finishedgoodqty)
                      ELSE 
                        IF ((@ware_userentercode = 3) AND 
                                (@ware_overheadnetcopy > 0))
                          IF (@ware_finishedgoodqty > 0)
                            SET @c_overhead_fg = ((@ware_overheadnetcopy * @c_net_copies) / @ware_finishedgoodqty)
                        ELSE 
                          IF ((@ware_userentercode = 2) AND 
                                  (@ware_overheadfgqty > 0))
                            SET @c_overhead_fg = @ware_overheadfgqty
                          ELSE 
                            IF (@ware_finishedgoodqty > 0)
                              SET @c_overhead_fg = ((@ware_overheadpercent / 100 * @c_percentof) / @ware_finishedgoodqty)

                      IF ((@ware_userentercode = 1) AND 
                              (@ware_totaloverhead > 0))
                        IF (@c_net_copies > 0)
                          SET @c_overhead_netcopy = (@ware_totaloverhead / @c_net_copies)
                      ELSE 
                        IF ((@ware_userentercode = 2) AND 
                                (@ware_overheadfgqty > 0))
                          IF (@c_net_copies > 0)
                            SET @c_overhead_netcopy = ((@ware_overheadfgqty * @ware_finishedgoodqty) / @c_net_copies)
                        ELSE 
                          IF ((@ware_userentercode = 3) AND 
                                  (@ware_overheadnetcopy > 0))
                            SET @c_overhead_netcopy = @ware_overheadnetcopy
                          ELSE 
                            IF (@c_net_copies > 0)
                              SET @c_overhead_netcopy = ((@ware_overheadpercent / 100 * @c_percentof) / @c_net_copies)

                      IF ((@ware_userentercode = 1) AND 
                              (@ware_totaloverhead > 0) AND 
                              (@c_percentof > 0))
                        SET @c_overhead_percent = ((@ware_totaloverhead / @c_percentof) * 100)
                      ELSE 
                        IF ((@ware_userentercode = 2) AND 
                                (@ware_overheadfgqty > 0) AND 
                                (@c_percentof > 0))
                          SET @c_overhead_percent = (((@ware_overheadfgqty * @ware_finishedgoodqty) / @c_percentof) * 100)
                        ELSE 
                          IF ((@ware_userentercode = 3) AND 
                                  (@ware_overheadnetcopy > 0) AND 
                                  (@c_percentof > 0))
                            SET @c_overhead_percent = (((@ware_overheadnetcopy * @c_net_copies) / @c_percentof) * 100)
                          ELSE 
                            SET @c_overhead_percent = @ware_overheadpercent

                      IF ((@ware_userentercode = 2) AND 
                              (@ware_advertisingfgqty > 0))
                        SET @c_total_advertising = (@ware_advertisingfgqty * @ware_finishedgoodqty)
                      ELSE 
                        IF ((@ware_userentercode = 3) AND 
                                (@ware_advertisingnetcopy > 0))
                          SET @c_total_advertising = (@ware_advertisingnetcopy * @c_net_copies)
                        ELSE 
                          IF ((@ware_userentercode = 1) AND 
                                  (@ware_totaladvertising > 0))
                            SET @c_total_advertising = @ware_totaladvertising
                          ELSE 
                            SET @c_total_advertising = ((@ware_advertisingpercent / 100) * @c_percentof)

                      SET @ware_totaladvertising = @c_total_advertising

                      IF ((@ware_userentercode = 1) AND 
                              (@ware_totaladvertising > 0))
                        IF (@ware_finishedgoodqty > 0)
                          SET @c_advertising_fg = (@ware_totaladvertising / @ware_finishedgoodqty)
                      ELSE 
                        IF ((@ware_userentercode = 3) AND 
                                (@ware_advertisingnetcopy > 0))
                          IF (@ware_finishedgoodqty > 0)
                            SET @c_advertising_fg = ((@ware_advertisingnetcopy * @c_net_copies) / @ware_finishedgoodqty)
                        ELSE 
                          IF ((@ware_userentercode = 2) AND 
                                  (@ware_advertisingfgqty > 0))
                            SET @c_advertising_fg = @ware_advertisingfgqty
                          ELSE 
                            IF (@ware_finishedgoodqty > 0)
                              SET @c_advertising_fg = ((@ware_advertisingpercent / 100 * @c_percentof) / @ware_finishedgoodqty)

                      IF ((@ware_userentercode = 1) AND 
                              (@ware_totaladvertising > 0))
                        IF (@c_net_copies > 0)
                          SET @c_advertising_netcopy = (@ware_totaladvertising / @c_net_copies)
                      ELSE 
                        IF ((@ware_userentercode = 2) AND 
                                (@ware_advertisingfgqty > 0))
                          IF (@c_net_copies > 0)
                            SET @c_advertising_netcopy = ((@ware_advertisingfgqty * @ware_finishedgoodqty) / @c_net_copies)
                        ELSE 
                          IF ((@ware_userentercode = 3) AND 
                                  (@ware_advertisingnetcopy > 0))
                            SET @c_advertising_netcopy = @ware_advertisingnetcopy
                          ELSE 
                            IF (@c_net_copies > 0)
                              SET @c_advertising_netcopy = ((@ware_advertisingpercent / 100 * @c_percentof) / @c_net_copies)

                      IF ((@ware_userentercode = 1) AND 
                              (@ware_totaladvertising > 0) AND 
                              (@c_percentof > 0))
                        SET @c_advertising_percent = ((@ware_totaladvertising / @c_percentof) * 100)
                      ELSE 
                        IF ((@ware_userentercode = 2) AND 
                                (@ware_advertisingfgqty > 0) AND 
                                (@c_percentof > 0))
                          SET @c_advertising_percent = (((@ware_advertisingfgqty * @ware_finishedgoodqty) / @c_percentof) * 100)
                        ELSE 
                          IF ((@ware_userentercode = 3) AND 
                                  (@ware_advertisingnetcopy > 0) AND 
                                  (@c_percentof > 0))
                            SET @c_advertising_percent = (((@ware_advertisingnetcopy * @c_net_copies) / @c_percentof) * 100)
                          ELSE 
                            SET @c_advertising_percent = @ware_advertisingpercent

                      SET @c_total_cost = CAST( (round(@ware_totaledition, 0) + @ware_totalplant + round(@ware_totalroyalty, 0) + @ware_totaloverhead + @ware_totaladvertising) AS numeric(10, 2))-- hren

                      SET @c_returned_qty = (@ware_finishedgoodqty * @ware_returnrate / 100)

                      SET @c_sales = (@ware_finishedgoodqty * @c_price_received)

                      SET @c_returns = (@c_returned_qty * @c_price_received)

                      SET @c_net_sales = (@c_sales - @c_returns)

                      SET @c_remainder_sales = (@ware_remainderprice * @ware_remainderqty)

                      SET @c_total_revenue = (@c_net_sales + @c_remainder_sales)

                      IF (@ware_finishedgoodqty > 0)
                        SET @c_revenue_per_fgqty = (@c_total_revenue / @ware_finishedgoodqty)

                      IF (@c_net_copies > 0)
                        SET @c_revenue_per_netcopies = (@c_total_revenue / @c_net_copies)

                      SET @c_profit_loss = (@c_total_revenue - @c_total_cost)

                      IF (@ware_finishedgoodqty > 0)
                        SET @c_profitloss_per_fgqty = (@c_profit_loss / @ware_finishedgoodqty)

                      IF (@c_net_copies > 0)
                        SET @c_profitloss_per_netcopies = (@c_profit_loss / @c_net_copies)

                      IF (@c_total_revenue > 0)
                        SET @c_profit_margin = ((@c_profit_loss / @c_total_revenue) * 100)

                      IF (@ware_company <> 'CONSUMER')
                        BEGIN

                          IF (@ware_finishedgoodqty > 0)
                            BEGIN
                              SET @c_total_prod = (@c_total_prod / @ware_finishedgoodqty)
                              SET @c_total_royalty = (@c_total_royalty / @ware_finishedgoodqty)
                            END

                          UPDATE dbo.WHEST
                            SET 
                              dbo.WHEST.RETAILPRICE = @ware_listprice, 
                              dbo.WHEST.AVGPRICERECD = @c_price_received, 
                              dbo.WHEST.RETURNRATE = @ware_returnrate, 
                              dbo.WHEST.REMAINDERPRICE = @ware_remainderprice, 
                              dbo.WHEST.DISCOUNTPCT = @ware_discountpercent, 
                              dbo.WHEST.NETCOPIESSOLD = @c_net_copies, 
                              dbo.WHEST.REMAINDERQTY = @ware_remainderqty, 
                              dbo.WHEST.EDITIONCOST = @c_total_edition, 
                              dbo.WHEST.EDITIONFGUNIT = @c_edition_fg, 
                              dbo.WHEST.EDITIONNETUNIT = @c_edition_netcopy, 
                              dbo.WHEST.EDITIONPCT = @c_edition_percent, 
                              dbo.WHEST.PLANTCOST = @c_total_plant, 
                              dbo.WHEST.PLANTFGUNIT = @c_plant_fg, 
                              dbo.WHEST.PLANTNETUNIT = @c_plant_netcopy, 
                              dbo.WHEST.PLANTPCT = @c_plant_percent, 
                              dbo.WHEST.PRODCOST = @c_total_prod, 
                              dbo.WHEST.PRODFGUNIT = @c_prod_unit, 
                              dbo.WHEST.PRODNETUNIT = @c_prod_netcopy, 
                              dbo.WHEST.PRODPCT = @c_prod_percent, 
                              dbo.WHEST.ROYALTYCOST = @c_total_royalty, 
                              dbo.WHEST.ROYALTYFGUNIT = @c_total_royalty, 
                              dbo.WHEST.ROYALTYNETUNIT = @c_royalty_netcopy, 
                              dbo.WHEST.ROYALTYPCT = @c_royalty_percent, 
                              dbo.WHEST.OVERHEAD = @c_total_overhead, 
                              dbo.WHEST.OVERHEADFGUNIT = @c_overhead_fg, 
                              dbo.WHEST.OVERHEADNETUNIT = @c_overhead_netcopy, 
                              dbo.WHEST.OVERHEADPCT = @c_overhead_percent, 
                              dbo.WHEST.ADVERTISING = @c_total_advertising, 
                              dbo.WHEST.ADVERTISINGFGUNIT = @c_advertising_fg, 
                              dbo.WHEST.ADVERTISINGNETUNIT = @c_advertising_netcopy, 
                              dbo.WHEST.ADVERTISINGPCT = @c_advertising_percent, 
                              dbo.WHEST.TOTALCOST = @c_total_cost, 
                              dbo.WHEST.TOTALFGUNIT = (@c_prod_fg + @c_royalty_fg + @ware_overheadfgqty + @ware_advertisingfgqty), 
                              dbo.WHEST.TOTALNETUNIT = (@c_prod_netcopy + @c_royalty_netcopy + @ware_overheadnetcopy + @ware_advertisingnetcopy), 
                              dbo.WHEST.TOTALPCT = (@c_prod_percent + @c_royalty_percent + @c_overhead_percent + @c_advertising_percent), 
                              dbo.WHEST.REVENUE = @c_total_revenue, 
                              dbo.WHEST.REVENUEFGUNIT = @c_revenue_per_fgqty, 
                              dbo.WHEST.REVENUENETUNIT = @c_revenue_per_netcopies, 
                              dbo.WHEST.PROFITLOSS = @c_profit_loss, 
                              dbo.WHEST.PROFITLOSSFGUNIT = @c_profitloss_per_fgqty, 
                              dbo.WHEST.PROFITLOSSNETUNIT = @c_profitloss_per_netcopies, 
                              dbo.WHEST.PROFITMARGIN = @c_profit_margin
                            WHERE ((dbo.WHEST.ESTKEY = @ware_estkey) AND 
                                    (dbo.WHEST.BOOKKEY = @ware_bookkey) AND 
                                    (dbo.WHEST.PRINTINGKEY = @ware_printingkey) AND 
                                    (dbo.WHEST.ESTVERSION = @cursor_row$VERSIONKEY$2))

                        END
                      ELSE 
                        BEGIN

                          SET @c_net_unit = (@ware_listprice * (1 - (@ware_discountpercent / 100)))

                          SET @c_gross_sales = (@ware_finishedgoodqty * ROUND(@c_net_unit, 3))

                          IF (@ware_finishedgoodqty > 0)
                            SET @c_gross_unit = (@c_gross_sales / @ware_finishedgoodqty)

                          SET @c_gross_percent = 100.0

                          SET @c_netqty = (@ware_finishedgoodqty * (100 - @ware_returnrate) / 100)

                          SET @c_net_sales = (@c_netqty * ROUND(@c_net_unit, 3))

                          IF (@c_netqty > 0)
                            SET @c_edition_unit = (@ware_totaledition / @c_netqty)

                          IF (@c_net_sales > 0)
                            SET @c_edition_percent = ((@ware_totaledition / @c_net_sales) * 100)

                          SET @c_inv_wo = ((@ware_finishedgoodqty - @c_netqty) * (100 - @ware_returntostock) / 100 * ROUND(@c_edition_unit, 3))

                          IF (@c_netqty > 0)
                            SET @c_inv_wo_unit = (@c_inv_wo / @c_netqty)

                          IF (@c_net_sales > 0)
                            SET @c_inv_wo_percent = ((@c_inv_wo / @c_net_sales) * 100)

                          IF (@c_netqty > 0)
                            SET @c_plant_unit = (@ware_totalplant / @c_netqty)

                          IF (@c_net_sales > 0)
                            SET @c_plant_percent = ((@ware_totalplant / @c_net_sales) * 100)

                          SET @c_total_prod = (@ware_totaledition + @c_inv_wo + @ware_totalplant)

                          SET @c_prod_unit = (@c_edition_unit + @c_inv_wo_unit + @c_plant_unit)

                          SET @c_prod_percent = (@c_edition_percent + @c_inv_wo_percent + @c_plant_percent)

                          IF (@c_netqty > 0)
                            SET @c_royalty_unit = (@ware_totalroyalty / @c_netqty)

                          IF (@c_net_sales > 0)
                            SET @c_royalty_percent = ((@ware_totalroyalty / @c_net_sales) * 100)

                          SET @c_total_cost = CAST( (@c_total_prod + Round(@ware_totalroyalty, 0)) AS numeric(10, 2))

                          SET @c_total_unit = (@c_prod_unit + @c_royalty_unit)

                          SET @c_total_percent = (@c_prod_percent + @c_royalty_percent)

                          SET @c_var_gp = (@c_net_sales - (@c_total_cost - @ware_totalplant))

                          IF (@c_netqty > 0)
                            SET @c_var_gp_unit = (@c_var_gp / @c_netqty)

                          UPDATE dbo.WHEST
                            SET 
                              dbo.WHEST.RETAILPRICE = @ware_listprice, 
                              dbo.WHEST.AVGPRICERECD = @c_price_received, 
                              dbo.WHEST.RETURNRATE = @ware_returnrate, 
                              dbo.WHEST.DISCOUNTPCT = @ware_discountpercent, 
                              dbo.WHEST.EDITIONCOST = @ware_totaledition, 
                              dbo.WHEST.EDITIONNETUNIT = @c_edition_unit, 
                              dbo.WHEST.EDITIONPCT = @c_edition_percent, 
                              dbo.WHEST.PLANTCOST = @ware_totalplant, 
                              dbo.WHEST.PLANTFGUNIT = @c_plant_unit, 
                              dbo.WHEST.PLANTPCT = @c_plant_percent, 
                              dbo.WHEST.PRODCOST = @c_total_prod, 
                              dbo.WHEST.PRODFGUNIT = @c_prod_unit, 
                              dbo.WHEST.PRODPCT = @c_prod_percent, 
                              dbo.WHEST.ROYALTYCOST = @ware_totalroyalty, 
                              dbo.WHEST.ROYALTYFGUNIT = @c_royalty_unit, 
                              dbo.WHEST.ROYALTYPCT = @c_royalty_percent, 
                              dbo.WHEST.TOTALCOST = @c_total_cost, 
                              dbo.WHEST.TOTALFGUNIT = @c_total_unit, 
                              dbo.WHEST.TOTALPCT = @c_total_percent
                            WHERE ((dbo.WHEST.ESTKEY = @ware_estkey) AND 
                                    (dbo.WHEST.BOOKKEY = @ware_bookkey) AND 
                                    (dbo.WHEST.PRINTINGKEY = @ware_printingkey) AND 
                                    (dbo.WHEST.ESTVERSION = @cursor_row$VERSIONKEY$2))

                        END

                      EXEC dbo.DATAWAREHOUSE_ESTCOMP @ware_bookkey, @ware_printingkey, @ware_estkey, @cursor_row$VERSIONKEY$2, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whest */

                      EXEC dbo.DATAWAREHOUSE_ESTCOST @ware_estkey, @cursor_row$VERSIONKEY$2, @ware_logkey, @ware_warehousekey, @ware_system_date 

                    END
                  ELSE 
                    BEGIN
                      INSERT INTO dbo.WHERRORLOG
                        (
                          dbo.WHERRORLOG.LOGKEY, 
                          dbo.WHERRORLOG.WAREHOUSEKEY, 
                          dbo.WHERRORLOG.ERRORDESC, 
                          dbo.WHERRORLOG.ERRORSEVERITY, 
                          dbo.WHERRORLOG.ERRORFUNCTION, 
                          dbo.WHERRORLOG.LASTUSERID, 
                          dbo.WHERRORLOG.LASTMAINTDATE
                        )
                        VALUES 
                          (
                            CAST( @ware_logkey AS varchar(30)), 
                            CAST( @ware_warehousekey AS varchar(30)), 
                            'Unable to insert whest table - for estversion', 
                            ('Warning/data error estkey ' + isnull(CAST( @ware_estkey AS varchar(30)), '')), 
                            'Stored procedure datawarehouse_estver', 
                            'WARE_STORED_PROC', 
                            @ware_system_date
                          )
                    END

                  FETCH NEXT FROM warehouseversion
                    INTO 
                      @cursor_row$VERSIONKEY$2, 
                      @cursor_row$FINISHEDGOODQTY$2, 
                      @cursor_row$FINISHEDGOODVENDORCODE$2, 
                      @cursor_row$REQUESTDATETIME$2, 
                      @cursor_row$REQUESTEDBYNAME$2, 
                      @cursor_row$REQUESTID$2, 
                      @cursor_row$REQUESTCOMMENT$2, 
                      @cursor_row$REQUESTBATCHID$2, 
                      @cursor_row$DESCRIPTION$2, 
                      @cursor_row$SPECIALINSTRUCTIONS1$2

                END

              CLOSE warehouseversion

              DEALLOCATE warehouseversion

            END

            IF (@ware_count = 1)
              BEGIN

                INSERT INTO dbo.WHEST
                  (
                    dbo.WHEST.ESTKEY, 
                    dbo.WHEST.BOOKKEY, 
                    dbo.WHEST.PRINTINGKEY, 
                    dbo.WHEST.ESTVERSION, 
                    dbo.WHEST.LASTUSERID, 
                    dbo.WHEST.LASTMAINTDATE
                  )
                  VALUES 
                    (
                      @ware_estkey, 
                      @ware_bookkey, 
                      @ware_printingkey, 
                      0, 
                      'WARE_STORED_PROC', 
                      @ware_system_date
                    )

                INSERT INTO dbo.WHESTCOST
                  (
                    dbo.WHESTCOST.ESTKEY, 
                    dbo.WHESTCOST.ESTVERSION, 
                    dbo.WHESTCOST.COMPKEY, 
                    dbo.WHESTCOST.CHARGECODEKEY, 
                    dbo.WHESTCOST.LASTUSERID, 
                    dbo.WHESTCOST.LASTMAINTDATE
                  )
                  VALUES 
                    (
                      @ware_estkey, 
                      0, 
                      0, 
                      0, 
                      'WARE_STORED_PROC', 
                      @ware_system_date
                    )

              END

            IF (cursor_status(N'local', N'warehouseversion') = 1)
              BEGIN
                CLOSE warehouseversion
                DEALLOCATE warehouseversion
              END

          END
      END
go
grant execute on datawarehouse_estversion  to public
go




