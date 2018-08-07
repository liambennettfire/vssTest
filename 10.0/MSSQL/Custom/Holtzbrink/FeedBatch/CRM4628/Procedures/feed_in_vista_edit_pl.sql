IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'feed_in_vista_edit_pl')
BEGIN
  DROP  Procedure  feed_in_vista_edit_pl
END
GO
CREATE  PROCEDURE dbo.feed_in_vista_edit_pl 
AS
BEGIN
DECLARE 
@err_msg char(200),
@feed_system_date datetime,
@feedin_bookkey integer,
@feedin_count integer,
@feed_isbn10 varchar(10),
@feed_isbn varchar(13),
@feed_return integer,
@cursor_row$ISBN varchar(13),
@cursor_row$INIT_UNITS integer,
@cursor_row$INIT_$ numeric(18,4),
@cursor_row$REO_UNITS integer,
@cursor_row$REO_$ numeric(18,4),
@cursor_row$RET_UNITS integer,
@cursor_row$RET_$ numeric(18,4),
@cursor_row$SAMPLE_UNITS integer,
@cursor_row$MAYJUNE_NET$ numeric(18,4),
@cursor_row$MAYJUNE_ROY$ numeric(18,4),
@cursor_row$LTD_SALES_EARNINGS numeric(18,4),
@cursor_row$LTD_SUBRIGHTS_EARNINGS numeric(18,4),
@cursor_row$LTD_OTHER_EARNINGS numeric(18,4),
@cursor_row$ADVANCES numeric(18,4),
@cursor_row$MARKETING_VALUE numeric(18,4),
@cursor_row$COOP_UNITS numeric(18,4),
@cursor_row$COOP_VALUE numeric(18,4),
@cursor_row$RECEIPT_QTY integer,
@cursor_row$RECEIPT_VALUE numeric(18,4),
@cursor_row$CLOSING_INV_UNITS integer,
@cursor_row$CLOSING_INV_VALUE numeric(18,4),
@cursor_row$PPB$ numeric(18,4),
@cursor_row$MANUFACTURING$ numeric(18,4)          

BEGIN
            SELECT @feed_system_date = getdate()

            INSERT INTO FEEDERROR
              (FEEDERROR.BATCHNUMBER, FEEDERROR.PROCESSDATE, FEEDERROR.ERRORDESC)
              VALUES ('10', @feed_system_date, ('Vista P and L Started ' + isnull(convert(varchar(30), getdate(), 100), '')))

            DECLARE 
                @cursor_row$ISBN$2 varchar(13),
                @cursor_row$INIT_UNITS$2 integer,
                @cursor_row$INIT_$$2 numeric(18,4),
                @cursor_row$REO_UNITS$2 integer,
                @cursor_row$REO_$$2 numeric(18,4),
                @cursor_row$RET_UNITS$2 integer,
                @cursor_row$RET_$$2 numeric(18,4),
                @cursor_row$SAMPLE_UNITS$2 numeric(18,4),
                @cursor_row$MAYJUNE_NET$$2 numeric(18,4),
                @cursor_row$MAYJUNE_ROY$$2 numeric(18,4),
                @cursor_row$LTD_SALES_EARNINGS$2 numeric(18,4),
                @cursor_row$LTD_SUBRIGHTS_EARNINGS$2 numeric(18,4),
                @cursor_row$LTD_OTHER_EARNINGS$2 numeric(18,4),
                @cursor_row$ADVANCES$2 numeric(18,4),
                @cursor_row$MARKETING_VALUE$2 numeric(18,4),
                @cursor_row$COOP_UNITS$2 integer,
                @cursor_row$COOP_VALUE$2 numeric(18,4),
                @cursor_row$RECEIPT_QTY$2 integer,
                @cursor_row$RECEIPT_VALUE$2 numeric(18,4),
                @cursor_row$CLOSING_INV_UNITS$2 integer,
                @cursor_row$CLOSING_INV_VALUE$2 numeric(18,4),
                @cursor_row$PPB$$2 numeric(18,4),
                @cursor_row$MANUFACTURING$$2 numeric(18,4)              

              DECLARE 
                feed_vistapls CURSOR LOCAL 
                 FOR 
                  SELECT DISTINCT 
                      t.ISBN, 
                      isnull(t.INIT_UNITS, 0) AS INIT_UNITS, 
                      isnull(t.INIT_$, 0) AS INIT_$, 
                      isnull(t.REO_UNITS, 0) AS REO_UNITS, 
                      isnull(t.REO_$, 0) AS REO_$, 
                      isnull(t.RET_UNITS, 0) AS RET_UNITS, 
                      isnull(t.RET_$, 0) AS RET_$, 
                      isnull(t.SAMPLE_UNITS, 0) AS SAMPLE_UNITS, 
                      isnull(t.MAYJUNE_NET$, 0) AS MAYJUNE_NET$, 
                      isnull(t.MAYJUNE_ROY$, 0) AS MAYJUNE_ROY$, 
                      isnull(t.LTD_SALES_EARNINGS, 0) AS LTD_SALES_EARNINGS, 
                      isnull(t.LTD_SUBRIGHTS_EARNINGS, 0) AS LTD_SUBRIGHTS_EARNINGS, 
                      isnull(t.LTD_OTHER_EARNINGS, 0) AS LTD_OTHER_EARNINGS, 
                      isnull(t.ADVANCES, 0) AS ADVANCES, 
                      isnull(t.MARKETING_VALUE, 0) AS MARKETING_VALUE, 
                      isnull(t.COOP_UNITS, 0) AS COOP_UNITS, 
                      isnull(t.COOP_VALUE, 0) AS COOP_VALUE, 
                      isnull(t.RECEIPT_QTY, 0) AS RECEIPT_QTY, 
                      isnull(t.RECEIPT_VALUE, 0) AS RECEIPT_VALUE, 
                      isnull(t.CLOSING_INV_UNITS, 0) AS CLOSING_INV_UNITS, 
                      isnull(t.CLOSING_INV_VALUE, 0) AS CLOSING_INV_VALUE, 
                      isnull(t.PPB$, 0) AS PPB$, 
                      isnull(t.MANUFACTURING$, 0) AS MANUFACTURING$
                    FROM HB_EPL_DATA t, ISBN i
                    WHERE (i.ISBN10 = t.ISBN)
                  ORDER BY t.ISBN
              

              OPEN feed_vistapls

              FETCH NEXT FROM feed_vistapls
                INTO 
                  @cursor_row$ISBN$2, 
                  @cursor_row$INIT_UNITS$2, 
                  @cursor_row$INIT_$$2, 
                  @cursor_row$REO_UNITS$2, 
                  @cursor_row$REO_$$2, 
                  @cursor_row$RET_UNITS$2, 
                  @cursor_row$RET_$$2, 
                  @cursor_row$SAMPLE_UNITS$2, 
                  @cursor_row$MAYJUNE_NET$$2, 
                  @cursor_row$MAYJUNE_ROY$$2, 
                  @cursor_row$LTD_SALES_EARNINGS$2, 
                  @cursor_row$LTD_SUBRIGHTS_EARNINGS$2, 
                  @cursor_row$LTD_OTHER_EARNINGS$2, 
                  @cursor_row$ADVANCES$2, 
                  @cursor_row$MARKETING_VALUE$2, 
                  @cursor_row$COOP_UNITS$2, 
                  @cursor_row$COOP_VALUE$2, 
                  @cursor_row$RECEIPT_QTY$2, 
                  @cursor_row$RECEIPT_VALUE$2, 
                  @cursor_row$CLOSING_INV_UNITS$2, 
                  @cursor_row$CLOSING_INV_VALUE$2, 
                  @cursor_row$PPB$$2, 
                  @cursor_row$MANUFACTURING$$2


              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  IF (@@FETCH_STATUS = -1)
                    BEGIN

                      INSERT INTO FEEDERROR
                        (
                          FEEDERROR.ISBN, 
                          FEEDERROR.BATCHNUMBER, 
                          FEEDERROR.PROCESSDATE, 
                          FEEDERROR.ERRORDESC
                        )
                        VALUES 
                          (
                            ltrim(rtrim(@cursor_row$ISBN$2)), 
                            '10', 
                            @feed_system_date, 
                            'NO ROWS to PROCESS for P and L SALES'
                          )

                      BREAK 

                    END

                  SET @feed_isbn = ltrim(rtrim(@cursor_row$ISBN$2))

                  SET @feed_isbn10 = ltrim(rtrim(@cursor_row$ISBN$2))

                  SET @feed_return = 0

                  /*  remove reissue isbn book keys */

                  /* 11-19-02  duplicate isbns are present so just get the first one entered */

                  SET @feedin_count = 0

                  SET @feedin_bookkey = 0

                  SELECT @feedin_count = count( * )
                    FROM ISBN i, BOOK b
                    WHERE ((i.BOOKKEY = b.BOOKKEY) AND 
                            ((b.REUSEISBNIND IS NULL) OR 
                                    (b.REUSEISBNIND = 0)) AND 
                            (i.ISBN10 = ltrim(rtrim(@cursor_row$ISBN$2))))

                  IF (@feedin_count > 1)
                    BEGIN

                      /* duplicate get lowest isbn */

                      SELECT @feedin_bookkey = min(b.BOOKKEY)
                        FROM ISBN i, BOOK b
                        WHERE ((i.BOOKKEY = b.BOOKKEY) AND 
                                ((b.REUSEISBNIND IS NULL) OR 
                                        (b.REUSEISBNIND = 0)) AND 
                                (i.ISBN10 = ltrim(rtrim(@cursor_row$ISBN$2))))

                      SELECT @feed_isbn = ISBN.ISBN
                        FROM ISBN
                        WHERE (ISBN.BOOKKEY = @feedin_bookkey)

                      INSERT INTO FEEDERROR
                        (FEEDERROR.BATCHNUMBER, FEEDERROR.PROCESSDATE, FEEDERROR.ERRORDESC)
                        VALUES ('10', @feed_system_date, ('Duplicate ISBN on ISBN table isbn = ' + isnull(@err_msg, '') + isnull(@feed_isbn, '')))
                    END
                  ELSE 
                    BEGIN
                      SELECT @feedin_bookkey = b.BOOKKEY, @feed_isbn = i.ISBN
                        FROM ISBN i, BOOK b
                        WHERE ((i.BOOKKEY = b.BOOKKEY) AND 
                                ((b.REUSEISBNIND IS NULL) OR 
                                        (b.REUSEISBNIND = 0)) AND 
                                (i.ISBN10 = ltrim(rtrim(@cursor_row$ISBN$2))))

                    END

                  IF (@feedin_bookkey > 0)
                    BEGIN

                      /*
                       -- get misckey based on column hardcode
                       -- 	columntoupdate; 0= floatvalue, 1= longvalue,  2=textvalue
                       --*/

                      /* ***********************go to function to update ************** */
                      execute FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 2, '1', @cursor_row$INIT_UNITS$2, 0, '', @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error inserting/updating Initial Shipment Gross Units'
                              )
                        END

                      SET @feed_return = 0
                      execute FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 3, '0', 0, @cursor_row$INIT_$$2, '', @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error inserting/updating Initial Shipment Gross $'
                              )
                        END

                      SET @feed_return = 0

                      execute FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 4, '1', @cursor_row$REO_UNITS$2, 0, '', @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error inserting/updating Reorder Gross Units'
                              )
                        END

                      SET @feed_return = 0

                      execute FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 5, '0', 0, @cursor_row$REO_$$2, '', @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error inserting/updating Reorder Gross $'
                              )
                        END

                      SET @feed_return = 0

                      execute FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 20, '1', @cursor_row$RET_UNITS$2, 0, '', @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error inserting/updating Return Units'
                              )
                        END

                      SET @feed_return = 0

                      execute FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 21, '0', 0, @cursor_row$RET_$$2, '', @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error inserting/updating Return $'
                              )
                        END

                      SET @feed_return = 0

                     execute FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 25, '1', @cursor_row$SAMPLE_UNITS$2, 0, '', @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error inserting/updating Free Copies'
                              )
                        END

                      SET @feed_return = 0

                      execute FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 33, '0', 0, @cursor_row$MAYJUNE_ROY$$2, '', @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error Royalty Earnings - May/June'
                              )

                        END

                      SET @feed_return = 0

                      execute FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 14, '0', 0, @cursor_row$LTD_SALES_EARNINGS$2, '', @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error inserting/updating Royalty Earnings'
                              )

                        END

                      SET @feed_return = 0

                      execute FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 6, '0', 0, @cursor_row$LTD_SUBRIGHTS_EARNINGS$2, '', @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error inserting/updating Sub Earnings'
                              )
                        END

                      SET @feed_return = 0

                      execute  FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 37, '0', 0, @cursor_row$LTD_OTHER_EARNINGS$2, '', @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error inserting/updating  Other Earnings'
                              )
                        END

                      SET @feed_return = 0

                      execute FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 13, '0', 0, @cursor_row$ADVANCES$2, '' , @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error inserting/updating Total Advance'
                              )

                        END

                      SET @feed_return = 0

                      execute  FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 11, '0', 0, @cursor_row$MARKETING_VALUE$2, '', @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error inserting/updating Total Marketing Cost'
                              )

                        END

                      SET @feed_return = 0

                      execute  FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 12, '0', 0, @cursor_row$COOP_VALUE$2, '', @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error inserting/updating Coop $'
                              )

                        END

                      SET @feed_return = 0

                      execute  FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 28, '1', @cursor_row$RECEIPT_QTY$2, 0, '', @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error inserting/updating Total Print Qty'
                              )
                        END

                      SET @feed_return = 0

                      execute  FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 26, '1', @cursor_row$CLOSING_INV_UNITS$2, 0, '', @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error inserting/updating Inventory Units'
                              )
                        END

                      SET @feed_return = 0

                      execute  FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 27, '0', 0, @cursor_row$CLOSING_INV_VALUE$2, '', @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error inserting/updating Inventory Value'
                              )
                        END

                      SET @feed_return = 0

                      execute  FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 8, '0', 0, @cursor_row$PPB$$2, '', @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error inserting/updating Total PP and B Cost'
                              )
                        END

                      SET @feed_return = 0

                      execute  FEED_IN_VISTA_BOOKMISC_SP @feedin_bookkey, 7, '0', 0, @cursor_row$MANUFACTURING$$2, '', @feed_return out

                      IF (@feed_return <> 0)
                        BEGIN
                          INSERT INTO FEEDERROR
                            (
                              FEEDERROR.BATCHNUMBER, 
                              FEEDERROR.ISBN, 
                              FEEDERROR.PROCESSDATE, 
                              FEEDERROR.ERRORDESC
                            )
                            VALUES 
                              (
                                '10', 
                                @feed_isbn, 
                                @feed_system_date, 
                                'Error inserting/updating Total Plant Cost'
                              )
                        END

                      /*  CRM 4270 HBPUB - Modify Vista Edit PL to automatically calculate book misc fields */

               --       EXEC FEED_IN_VISTA_BOOKMISC_CALC @feedin_bookkey 

                  END

                  FETCH NEXT FROM feed_vistapls
                    INTO 
                      @cursor_row$ISBN$2, 
                      @cursor_row$INIT_UNITS$2, 
                      @cursor_row$INIT_$$2, 
                      @cursor_row$REO_UNITS$2, 
                      @cursor_row$REO_$$2, 
                      @cursor_row$RET_UNITS$2, 
                      @cursor_row$RET_$$2, 
                      @cursor_row$SAMPLE_UNITS$2, 
                      @cursor_row$MAYJUNE_NET$$2, 
                      @cursor_row$MAYJUNE_ROY$$2, 
                      @cursor_row$LTD_SALES_EARNINGS$2, 
                      @cursor_row$LTD_SUBRIGHTS_EARNINGS$2, 
                      @cursor_row$LTD_OTHER_EARNINGS$2, 
                      @cursor_row$ADVANCES$2, 
                      @cursor_row$MARKETING_VALUE$2, 
                      @cursor_row$COOP_UNITS$2, 
                      @cursor_row$COOP_VALUE$2, 
                      @cursor_row$RECEIPT_QTY$2, 
                      @cursor_row$RECEIPT_VALUE$2, 
                      @cursor_row$CLOSING_INV_UNITS$2, 
                      @cursor_row$CLOSING_INV_VALUE$2, 
                      @cursor_row$PPB$$2, 
                      @cursor_row$MANUFACTURING$$2

                END

              CLOSE feed_vistapls

              DEALLOCATE feed_vistapls

     --       END

            INSERT INTO FEEDERROR
              (FEEDERROR.BATCHNUMBER, FEEDERROR.PROCESSDATE, FEEDERROR.ERRORDESC)
              VALUES ('10', @feed_system_date, ('Vista P and L Completed' + isnull(convert(varchar(30), getdate(), 100), '')))

 
   --         IF (cursor_status(N'local', N'feed_vistapls') = 1)
  --            BEGIN
   --             CLOSE feed_vistapls
   --             DEALLOCATE feed_vistapls
   --           END



END
END

go
grant execute on feed_in_vista_edit_pl  to public
go


