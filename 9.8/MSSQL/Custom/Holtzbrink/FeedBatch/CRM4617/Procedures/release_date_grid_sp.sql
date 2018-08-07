IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'release_date_grid_sp')

BEGIN

  DROP  Procedure  release_date_grid_sp

END

GO

 CREATE PROCEDURE release_date_grid_sp
    AS
     BEGIN
          DECLARE 
            @i_count INT,
            @i_count2 INT,
            @d_currentdate datetime,
            @d_releasedate datetime,
            @d_releasedate_new datetime,
            @d_pubmonth datetime,
            @d_currentpubmonth datetime,
            @d_currentwarehousedate datetime,
            @d_currentonsaledate datetime,
            @d_currentpubdate datetime,
            @d_warehouse_date datetime,
            @d_pub_date datetime,
            @d_on_sale_date datetime,
            @i_senttoeloqflag varchar(1),
			@cursor_row_bookkey  INT,
            @cursor_row_printingkey INT,
            @cursor_row_bestdate datetime  
            
          SET @i_count = 0
          SET @i_count2 = 0

          BEGIN

            SELECT @d_currentdate = getdate()
            BEGIN
                          

              DECLARE 
                releasedate_grid_cursor CURSOR LOCAL 
                 FOR 
                  SELECT DISTINCT g.bookkey, p.printingkey, d.bestdate
                    FROM hbpub_release_grid_bookkeys g, bookdates d, printing p
                    WHERE ((d.datetypecode = 32) AND (g.bookkey = d.bookkey) AND 
                            (g.bookkey = p.bookkey) AND (p.printingkey = 1))
              

              OPEN releasedate_grid_cursor

              FETCH NEXT FROM releasedate_grid_cursor
                INTO @cursor_row_bookkey, @cursor_row_printingkey, @cursor_row_bestdate
              
              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  /*  PM 7/12/06 CRM 4063 */
                  SET @i_senttoeloqflag = 0

                  SELECT @i_count = count( * )
                    FROM hbpub_release_schedule
                    WHERE (release_date = @cursor_row_bestdate)

                  /*  If there is a match on release date do insert/update, otherwise just delete the bookkey  */
                  IF (@i_count > 0)
                    BEGIN

                      SELECT 
                          @d_pubmonth = pub_month,@d_warehouse_date = warehouse_date, 
                          @d_pub_date = pub_date, @d_on_sale_date = on_sale_date
                        FROM hbpub_release_schedule
                        WHERE (@cursor_row_bestdate = release_date)
          
		            /* ************************** UPDATE PUB MONTH ************* */
                      SET @i_count2 = 0

                      SELECT @i_count2 = count( * )
                        FROM printing
                        WHERE ((printing.pubmonth IS NULL) AND 
                                (printing.bookkey = @cursor_row_bookkey) AND 
                                (printing.printingkey = @cursor_row_printingkey))
                 
                      IF (@i_count2 > 0)
                        BEGIN
                          /*  If pub month is null then update it, otherwise leave it alone */

                          UPDATE printing
                            SET 
                              printing.pubmonth = @d_pubmonth, 
                              printing.pubmonthcode = CAST( SYSDB.SSMA.TO_CHAR_DATE(@d_pubmonth, 'mm') AS float), 
                              printing.lastmaintdate = @d_currentdate, 
                              printing.lastuserid = 'RELGRID_UPD'
                            WHERE ((printing.bookkey = @cursor_row_bookkey) AND 
                                    (printing.printingkey = @cursor_row_printingkey))

                          SET @d_currentpubmonth = ''

                          SELECT @d_currentpubmonth = printing.pubmonth
                            FROM printing
                            WHERE ((printing.bookkey = @cursor_row_bookkey) AND 
                                    (printing.printingkey = @cursor_row_printingkey))
                        
                          INSERT INTO titlehistory
                            (titlehistory.bookkey,titlehistory.printingkey,titlehistory.columnkey,titlehistory.lastmaintdate, 
                              titlehistory.stringvalue,titlehistory.lastuserid,titlehistory.currentstringvalue,activedatetitlehistory.fielddesc)
                            VALUES 
                              (@cursor_row_bookkey,@cursor_row_printingkey,76,getdate(), 
                                SYSDB.SSMA.INITCAP_VARCHAR(SYSDB.SSMA.TO_CHAR_DATE(@d_pubmonth, 'MONTH')),'RELGRID_UPD', 
                                SYSDB.SSMA.INITCAP_VARCHAR(SYSDB.SSMA.TO_CHAR_DATE(@d_currentpubmonth, 'MONTH')),'Pub Month')
                          /*  PM 7/12/06 CRM 4063   */
                          SET @i_senttoeloqflag = 1
                        END

                      /* ************ UPDATE OR INSERT WAREHOUSE DATE ************* */
                      SET @i_count = 0

                      SELECT @i_count = count( * )
                        FROM bookdates
                        WHERE ((bookdates.datetypecode = 47) AND 
                                (bookdates.bookkey = @cursor_row_bookkey) AND 
                                (bookdates.printingkey = @cursor_row_printingkey))


                     IF (@i_count = 0)
                        BEGIN

                          INSERT INTO bookdates(bookkey,printingkey, datetypecode,lastuserid,lastmaintdate,estdate)
                            VALUES( @cursor_row_bookkey,@cursor_row_printingkey, 47, 'RELGRID_UPD', @d_currentdate,@d_warehouse_date)

                          INSERT INTO datehistory
                            (bookkey,datetypecode,datekey, 
                             printingkey,datechanged,datestagecode,dateprior, 
                              lastuserid,lastmaintdate)
                            VALUES 
                              (@cursor_row_bookkey,47,SYSDB.SSMA.db_get_next_sequence_value(N'QSIDBA', N'QSIKEYS_SEQ'), 
                                @cursor_row_printingkey,@d_warehouse_date, 2,NULL, 
                                'RELGRID_UPD',getdate())

                          /*  PM 7/12/06 CRM 4063      */

                          SET @i_senttoeloqflag = 1

                        END
                      ELSE 
                        BEGIN

                          SET @i_count2 = 0

                          SELECT @i_count2 = count( * )
                            FROM bookdates
                            WHERE ((estdate = @d_warehouse_date) AND 
                                    (bookkey = @cursor_row_bookkey) AND 
                                    (printingkey = @cursor_row_printingkey) AND 
                                    (datetypecode = 47))
                          
                          IF (@i_count2 = 0)
                            BEGIN

                              /*  If the date is already what it should be, don't update it */

                              UPDATE bookdates
                                SET estdate = @d_warehouse_date, lastmaintdate = @d_currentdate, lastuserid = 'RELGRID_UPD'
                                WHERE ((bookkey = @cursor_row_bookkey) AND 
                                        (printingkey = @cursor_row_printingkey) AND 
                                        (datetypecode = 47))

                              SET @d_currentwarehousedate = ''

                              SELECT @d_currentwarehousedate = bookdates.estdate
                                FROM bookdates
                                WHERE ((datetypecode = 47) AND 
                                        (estdate IS NOT NULL) AND 
                                        (bookkey = @cursor_row_bookkey) AND 
                                        (printingkey = @cursor_row_printingkey))
                             


                              INSERT INTO datehistory
                                ( bookkey,datetypecode,datekey,
											 printingkey,datechanged, 
                                  datestagecode,dateprior,lastuserid,lastmaintdate)
                                VALUES 
                                  ( @cursor_row_bookkey,47,SYSDB.SSMA.db_get_next_sequence_value(N'QSIDBA', N'QSIKEYS_SEQ'), 
                                    @cursor_row_printingkey,@d_warehouse_date, 
                                    2,@d_currentwarehousedate,'RELGRID_UPD',getdate())

                              /*  PM 7/12/06 CRM 4063 */
                              SET @i_senttoeloqflag = 1
                            END
                        END

                      /* ************ UPDATE OR INSERT PUB DATE ************* */
                      SET @i_count = 0

                      SELECT @i_count = count( * )
                        FROM bookdates
                        WHERE ((datetypecode = 8) AND 
                                (bookdates.bookkey = @cursor_row_bookkey) AND 
                                (printingkey = @cursor_row_printingkey))


                      IF (@i_count = 0)
                        BEGIN

                          INSERT INTO bookdates
                            (bookkey, printingkey,datetypecode, 
                              activedate,lastuserid,lastmaintdate)
                            VALUES 
                              (@cursor_row_bookkey,@cursor_row_printingkey,8, 
                                @d_pub_date,'RELGRID_UPD', @d_currentdate )

                          INSERT INTO datehistory
                            (bookkey, datetypecode, datekey, 
                             printingkey,datechanged,datestagecode,dateprior, 
                              lastuserid,lastmaintdate)
                            VALUES 
                              ( @cursor_row_bookkey,8,SYSDB.SSMA.db_get_next_sequence_value(N'QSIDBA', N'QSIKEYS_SEQ'), 
                                @cursor_row_printingkey,@d_pub_date,2,NULL, 
                                'RELGRID_UPD',getdate())

                          /*  PM 7/12/06 CRM 4063      */
                          SET @i_senttoeloqflag = 1

                        END
                      ELSE 
                        BEGIN

                          SET @i_count2 = 0

                          SELECT @i_count2 = count( * )
                            FROM bookdates
                            WHERE ((activedate = @d_pub_date) AND 
                                    (bookkey = @cursor_row_bookkey) AND 
                                    (printingkey = @cursor_row_printingkey) AND 
                                    (datetypecode = 8))
                     


                          IF (@i_count2 = 0)
                            BEGIN

                              /*  If the date is already what it should be, don't update it */

                              UPDATE bookdates
                                SET activedate = @d_pub_date, lastmaintdate = @d_currentdate, lastuserid = 'RELGRID_UPD'
                                WHERE ((bookkey = @cursor_row_bookkey) AND 
                                        (printingkey = @cursor_row_printingkey) AND 
                                        (datetypecode = 8))

                              SET @d_currentpubdate = ''

                              SELECT @d_currentpubdate = activedate
                                FROM bookdates
                                WHERE ((datetypecode = 8) AND 
                                        (activedate IS NOT NULL) AND 
                                        (bookkey = @cursor_row_bookkey) AND 
                                        (printingkey = @cursor_row_printingkey))
                            


                              INSERT INTO datehistory
											 (bookkey,datetypecode,datekey, 
											  printingkey,datechanged,datestagecode,dateprior, 
												lastuserid,lastmaintdate)
                                VALUES 
                                  (@cursor_row_bookkey,8,SYSDB.SSMA.db_get_next_sequence_value(N'QSIDBA', N'QSIKEYS_SEQ'), 
                                    @cursor_row_printingkey,@d_pub_date,2, @d_currentpubdate, 
                                    'RELGRID_UPD',getdate())

                              /*  PM 7/12/06 CRM 4063 */

                              SET @i_senttoeloqflag = 1

                            END

                        END

                      /* ************ UPDATE OR INSERT ON SALE DATE ************* */

                      SET @i_count = 0

                      SELECT @i_count = count( * )
                        FROM bookdates
                        WHERE ((datetypecode = 466) AND 
                                (bookkey = @cursor_row_bookkey) AND 
                                (printingkey = @cursor_row_printingkey))


                     IF (@i_count = 0)
                        BEGIN

                          INSERT INTO bookdates(bookkey,printingkey, datetypecode,lastuserid,lastmaintdate,estdate)
                            VALUES(
                                @cursor_row_bookkey,@cursor_row_printingkey,466,'RELGRID_UPD',@d_currentdate,@d_on_sale_date)

                         INSERT INTO datehistory
                            (bookkey, datetypecode, datekey, 
                             printingkey,datechanged,datestagecode,dateprior, 
                              lastuserid,lastmaintdate)
                            VALUES( @cursor_row_bookkey,466,SYSDB.SSMA.db_get_next_sequence_value(N'QSIDBA', N'QSIKEYS_SEQ'), 
                                @cursor_row_printingkey,@d_on_sale_date,2,NULL, 
                                'RELGRID_UPD',getdate())

                          /*  PM 7/12/06 CRM 4063 */

                          SET @i_senttoeloqflag = 1

                        END
                      ELSE 
                        BEGIN

                          SET @i_count2 = 0

                          SELECT @i_count2 = count( * )
                            FROM bookdates
                            WHERE ((estdate = @d_on_sale_date) AND 
                                    (bookkey = @cursor_row_bookkey) AND 
                                    (printingkey = @cursor_row_printingkey) AND 
                                    (datetypecode = 466))
                       


                          IF (@i_count2 = 0)
                            BEGIN

                              /*  If the date is already what it should be, don't update it */

                              UPDATE bookdates
                                SET estdate = @d_on_sale_date, lastmaintdate = @d_currentdate, lastuserid = 'RELGRID_UPD'
                                WHERE ((bookkey = @cursor_row_bookkey) AND 
                                        (printingkey = @cursor_row_printingkey) AND 
                                        (datetypecode = 466))

                              SET @d_currentonsaledate = ''

                              SELECT @d_currentonsaledate = estdate
                                FROM bookdates
                                WHERE ((datetypecode = 466) AND 
                                        (estdate IS NOT NULL) AND 
                                        (bookkey = @cursor_row_bookkey) AND 
                                        (printingkey = @cursor_row_printingkey))
                            


                              INSERT INTO datehistory
										 (bookkey, datetypecode, datekey, 
										  printingkey,datechanged,datestagecode,dateprior, 
											lastuserid,lastmaintdate)
                                VALUES(@cursor_row_bookkey,466,SYSDB.SSMA.db_get_next_sequence_value(N'QSIDBA', N'QSIKEYS_SEQ'), 
                                    @cursor_row_printingkey,@d_on_sale_date,2, @d_currentonsaledate, 
                                    'RELGRID_UPD',getdate())

                              /*  PM 7/12/06 CRM 4063 */

                              SET @i_senttoeloqflag = 1

                            END

                        END

                      /*
                       -- PM 7/12/06 CRM 4063 If an update or an insert has occurred at any point in this procedure, run through this procedure which
                       --   will send to outbox and warehouse
                       --*/

                      IF (@i_senttoeloqflag = 1)
                        EXEC UPDATE_BOOKEDI_BOOKWH_SP @cursor_row_bookkey, 'RELGRID_UPD' 

                    END
                  ELSE 
                    BEGIN
                      /*
                       -- If there is no match on the release grid table, delete from bookkeys and let on_sale_upd procedure 
                       --           handle the dates
                       --*/
                      DELETE FROM hbpub_release_grid_bookkeys
                        WHERE (bookkey = @cursor_row_bookkey)
                    END

                  FETCH NEXT FROM releasedate_grid_cursor
                    INTO @cursor_row_bookkey, @cursor_row_printingkey, @cursor_row_bestdate

                END

              CLOSE releasedate_grid_cursor

              DEALLOCATE releasedate_grid_cursor

            END

          END
      END


grant execute on release_date_grid_sp to public

go

