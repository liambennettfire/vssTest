IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'update_prices')
BEGIN
  DROP  Procedure  update_prices
END
GO

  CREATE 
    PROCEDURE update_prices 
    AS
      BEGIN
          DECLARE 

            @i_count integer,
            @i_bookpricecount integer,
            @i_price numeric(9, 2),
            @i_newpricekey integer,
            @i_sortorder integer,
            @cursor_row$BOOKKEY integer,
            @cursor_row$PRICE integer,
            @cursor_row$PRICETYPECODE integer,
            @cursor_row$CURRENCYTYPECODE integer          
          BEGIN

            /* 8 = List Price */

            /* 9 = Net Item Price */

            BEGIN

              DECLARE 
                @cursor_row$BOOKKEY$ integer,
                @cursor_row$PRICE$ integer,
                @cursor_row$PRICETYPECODE$ integer,
                @cursor_row$CURRENCYTYPECODE$ integer              

              DECLARE 
                cur_books CURSOR LOCAL 
                 FOR 
                  SELECT 
                      i.BOOKKEY, 
                      h.PRICE, 
                      h.PRICETYPECODE, 
                      h.CURRENCYTYPECODE
                    FROM HBPUB_FLAT_PRICE_UPDATE h, ISBN i
                    WHERE (h.ISBN = i.ISBN10)
              

              OPEN cur_books

              FETCH NEXT FROM cur_books
                INTO 
                  @cursor_row$BOOKKEY$, 
                  @cursor_row$PRICE$, 
                  @cursor_row$PRICETYPECODE$, 
                  @cursor_row$CURRENCYTYPECODE$


              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  SET @i_count = 0

                  SET @i_bookpricecount = 0

                  SET @i_sortorder = 0

                  SELECT @i_count = count( * )
                    FROM BOOKPRICE
                    WHERE ((BOOKPRICE.BOOKKEY = @cursor_row$BOOKKEY$) AND 
                            (BOOKPRICE.PRICETYPECODE = @cursor_row$PRICETYPECODE$) AND 
                            (BOOKPRICE.CURRENCYTYPECODE = @cursor_row$CURRENCYTYPECODE$))

                  IF (@i_count > 0)
                    BEGIN
                      SELECT @i_price = BOOKPRICE.FINALPRICE
                        FROM BOOKPRICE
                        WHERE ((BOOKPRICE.BOOKKEY = @cursor_row$BOOKKEY$) AND 
                                (BOOKPRICE.PRICETYPECODE = @cursor_row$PRICETYPECODE$) AND 
                                (BOOKPRICE.CURRENCYTYPECODE = @cursor_row$CURRENCYTYPECODE$))
                    END

                  IF ((@i_count > 0) AND 
                          (@i_price <> @cursor_row$PRICE$) AND 
                          (@i_price IS NOT NULL) AND 
                          (@i_price <> ''))
                    BEGIN

                      SELECT @i_sortorder = BOOKPRICE.SORTORDER
                        FROM BOOKPRICE
                        WHERE ((BOOKPRICE.PRICETYPECODE = @cursor_row$PRICETYPECODE$) AND 
                                (BOOKPRICE.CURRENCYTYPECODE = @cursor_row$CURRENCYTYPECODE$) AND 
                                (BOOKPRICE.BOOKKEY = @cursor_row$BOOKKEY$))

                      UPDATE BOOKPRICE
                        SET BOOKPRICE.FINALPRICE = @cursor_row$PRICE$, BOOKPRICE.LASTUSERID = 'qsiautoupd', BOOKPRICE.LASTMAINTDATE = getdate()
                        WHERE ((BOOKPRICE.PRICETYPECODE = @cursor_row$PRICETYPECODE$) AND 
                                (BOOKPRICE.CURRENCYTYPECODE = @cursor_row$CURRENCYTYPECODE$) AND 
                                (BOOKPRICE.BOOKKEY = @cursor_row$BOOKKEY$))

                      /*  Actual Price */
                      INSERT INTO TITLEHISTORY
                        (
                          TITLEHISTORY.BOOKKEY, 
                          TITLEHISTORY.PRINTINGKEY, 
                          TITLEHISTORY.COLUMNKEY, 
                          TITLEHISTORY.LASTMAINTDATE, 
                          TITLEHISTORY.STRINGVALUE, 
                          TITLEHISTORY.LASTUSERID, 
                          TITLEHISTORY.CURRENTSTRINGVALUE, 
                          TITLEHISTORY.FIELDDESC
                        )
                        VALUES 
                          (
                            @cursor_row$BOOKKEY$, 
                            1, 
                            9, 
                            getdate(), 
                            (isnull(CAST( @i_price AS varchar(8000)), '') + ' ' + isnull(dbo.gentables_shortdesc_function(122, @cursor_row$CURRENCYTYPECODE$), '')), 
                            'qsipriceupd', 
                            (isnull(CAST( @cursor_row$PRICE$ AS varchar(8000)), '') + ' ' + isnull(dbo.GENTABLES_SHORTDESC_FUNCTION(122, @cursor_row$CURRENCYTYPECODE$), '')), 
                            ('Price ' + isnull(CAST( @i_sortorder AS varchar(8000)), '') + ' - ' + isnull(dbo.GENTABLES_SHORTDESC_FUNCTION(306, @cursor_row$PRICETYPECODE$), ''))
                          )

                      INSERT INTO BOOKWHUPDATE
                        (BOOKWHUPDATE.BOOKKEY, BOOKWHUPDATE.LASTUSERID, BOOKWHUPDATE.LASTMAINTDATE)
                        SELECT BOOK.BOOKKEY, 'qsipriceupd', getdate()
                          FROM BOOK
                          WHERE ((BOOK.BOOKKEY = @cursor_row$BOOKKEY$) AND 
                                  (BOOK.BOOKKEY NOT IN
                                      ( 
                                        SELECT BOOKWHUPDATE.BOOKKEY
                                          FROM BOOKWHUPDATE
                                      )))

                    END

                  SELECT @i_bookpricecount = count( * )
                    FROM BOOKPRICE
                    WHERE (BOOKPRICE.BOOKKEY = @cursor_row$BOOKKEY$)

                  SET @i_sortorder = 0

                  IF (@i_bookpricecount > 0)
                    BEGIN
                      SELECT @i_sortorder = (max(BOOKPRICE.SORTORDER) + 1)
                        FROM BOOKPRICE
                        WHERE (BOOKPRICE.BOOKKEY = @cursor_row$BOOKKEY$)

                    END
                  ELSE 
                    SET @i_sortorder = 1

                  IF (@i_count = 0)
                    BEGIN

                      /*  NO Row on bookprice table */

                      EXEC GET_NEXT_KEY @i_newpricekey OUTPUT 

                      INSERT INTO BOOKPRICE
                        (
                          BOOKPRICE.PRICEKEY, 
                          BOOKPRICE.BOOKKEY, 
                          BOOKPRICE.PRICETYPECODE, 
                          BOOKPRICE.CURRENCYTYPECODE, 
                          BOOKPRICE.ACTIVEIND, 
                          BOOKPRICE.FINALPRICE, 
                          BOOKPRICE.LASTUSERID, 
                          BOOKPRICE.LASTMAINTDATE, 
                          BOOKPRICE.SORTORDER
                        )
                        VALUES 
                          (
                            @i_newpricekey, 
                            @cursor_row$BOOKKEY$, 
                            @cursor_row$PRICETYPECODE$, 
                            @cursor_row$CURRENCYTYPECODE$, 
                            1, 
                            @cursor_row$PRICE$, 
                            'qsipriceupd', 
                            getdate(), 
                            @i_sortorder
                          )

                      /*  Price Active */

                      INSERT INTO TITLEHISTORY
                        (
                          TITLEHISTORY.BOOKKEY, 
                          TITLEHISTORY.PRINTINGKEY, 
                          TITLEHISTORY.COLUMNKEY, 
                          TITLEHISTORY.LASTMAINTDATE, 
                          TITLEHISTORY.STRINGVALUE, 
                          TITLEHISTORY.LASTUSERID, 
                          TITLEHISTORY.CURRENTSTRINGVALUE, 
                          TITLEHISTORY.FIELDDESC
                        )
                        VALUES 
                          (
                            @cursor_row$BOOKKEY$, 
                            1, 
                            215, 
                            getdate(), 
                            '(Not Present)', 
                            'qsipriceupd', 
                            'Y', 
                            ('Price ' + isnull(CAST( @i_sortorder AS varchar(8000)), ''))
                          )

                      /*  Actual Price */

                      INSERT INTO TITLEHISTORY
                        (
                          TITLEHISTORY.BOOKKEY, 
                          TITLEHISTORY.PRINTINGKEY, 
                          TITLEHISTORY.COLUMNKEY, 
                          TITLEHISTORY.LASTMAINTDATE, 
                          TITLEHISTORY.STRINGVALUE, 
                          TITLEHISTORY.LASTUSERID, 
                          TITLEHISTORY.CURRENTSTRINGVALUE, 
                          TITLEHISTORY.FIELDDESC
                        )
                        VALUES 
                          (
                            @cursor_row$BOOKKEY$, 
                            1, 
                            9, 
                            getdate(), 
                            '(Not Present)', 
                            'qsipriceupd', 
                            (isnull(CAST( @cursor_row$PRICE$ AS varchar(8000)), '') + ' ' + isnull(dbo.GENTABLES_SHORTDESC_FUNCTION(122, @cursor_row$CURRENCYTYPECODE$), '')), 
                            ('Price ' + isnull(CAST( @i_sortorder AS varchar(8000)), '') + ' - ' + isnull(dbo.GENTABLES_SHORTDESC_FUNCTION(306, @cursor_row$PRICETYPECODE$), ''))
                          )

                      /*  Currency */

                      INSERT INTO TITLEHISTORY
                        (
                          TITLEHISTORY.BOOKKEY, 
                          TITLEHISTORY.PRINTINGKEY, 
                          TITLEHISTORY.COLUMNKEY, 
                          TITLEHISTORY.LASTMAINTDATE, 
                          TITLEHISTORY.STRINGVALUE, 
                          TITLEHISTORY.LASTUSERID, 
                          TITLEHISTORY.CURRENTSTRINGVALUE, 
                          TITLEHISTORY.FIELDDESC
                        )
                        VALUES 
                          (
                            @cursor_row$BOOKKEY$, 
                            1, 
                            31, 
                            getdate(), 
                            '(Not Present)', 
                            'qsipriceupd', 
                            dbo.GENTABLES_LONGDESC_FUNCTION(122, @cursor_row$CURRENCYTYPECODE$), 
                            ('Price ' + isnull(CAST( @i_sortorder AS varchar(8000)), '') + ' - ' + isnull(dbo.GENTABLES_SHORTDESC_FUNCTION(306, @cursor_row$PRICETYPECODE$), ''))
                          )

                      /*  Price Type */

                      INSERT INTO TITLEHISTORY
                        (
                          TITLEHISTORY.BOOKKEY, 
                          TITLEHISTORY.PRINTINGKEY, 
                          TITLEHISTORY.COLUMNKEY, 
                          TITLEHISTORY.LASTMAINTDATE, 
                          TITLEHISTORY.STRINGVALUE, 
                          TITLEHISTORY.LASTUSERID, 
                          TITLEHISTORY.CURRENTSTRINGVALUE, 
                          TITLEHISTORY.FIELDDESC
                        )
                        VALUES 
                          (
                            @cursor_row$BOOKKEY$, 
                            1, 
                            7, 
                            getdate(), 
                            '(Not Present)', 
                            'qsipriceupd', 
                            dbo.GENTABLES_LONGDESC_FUNCTION(306, @cursor_row$PRICETYPECODE$), 
                            ('Price ' + isnull(CAST( @i_sortorder AS varchar(8000)), ''))
                          )

                      INSERT INTO BOOKWHUPDATE
                        (BOOKWHUPDATE.BOOKKEY, BOOKWHUPDATE.LASTUSERID, BOOKWHUPDATE.LASTMAINTDATE)
                        SELECT BOOK.BOOKKEY, 'qsipriceupd', getdate()
                          FROM BOOK
                          WHERE ((BOOK.BOOKKEY = @cursor_row$BOOKKEY$) AND 
                                  (BOOK.BOOKKEY NOT IN
                                      ( 
                                        SELECT BOOKWHUPDATE.BOOKKEY
                                          FROM BOOKWHUPDATE
                                      )))

                    END

                  FETCH NEXT FROM cur_books
                    INTO 
                      @cursor_row$BOOKKEY$, 
                      @cursor_row$PRICE$, 
                      @cursor_row$PRICETYPECODE$, 
                      @cursor_row$CURRENCYTYPECODE$

                END

              CLOSE cur_books

              DEALLOCATE cur_books

            END

            IF (cursor_status(N'local', N'cur_books') = 1)
              BEGIN
                CLOSE cur_books
                DEALLOCATE cur_books
              END

          END
      END
go

grant execute on update_prices  to public
go

