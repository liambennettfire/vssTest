IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'est_batch_first_print_result')
BEGIN
  DROP  Procedure  est_batch_first_print_result
END
GO
  CREATE 
    PROCEDURE dbo.est_batch_first_print_result 
    AS
      BEGIN
          DECLARE 
            @v_data$VERSIONQTYTYPECODE integer,
            @v_data$ISBN10 varchar(8000),
            @v_data$FINISHEDGOODQTY integer,
            @v_data$VERSIONKEY integer,
            @v_data$ESTKEY integer,
            @v_jobkey integer,
            @v_batchkey integer,
            @v_cnt integer,
            @v_retcode integer,
            @v_error_desc varchar(500),
            @v_quantityt_type varchar(20),
            @v_edition_unitcost integer,
            @v_total_unitcost integer,
            @v_total_royalty integer,
            @v_royalty_per_copy integer,
            @v_net_copies integer,
            @v_return_rate integer,
            @v_edition_total_cost integer,
            @v_plant_total_cost integer,
            @v_plant_unit_cost integer,
	    @v_errorseverity integer,
	    @newkey integer
          BEGIN

            DECLARE 
              @param_expr_6 VARCHAR(8000)            

            SET @param_expr_6 = user_name()

            EXEC WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 1, 6, 'Estimate Batch', 'Est. Batch', @param_expr_6, 0, 0, 0, 1, 'First Print Result Process Started', 'First Print Result Process Started', @v_retcode OUTPUT, @v_error_desc OUTPUT 

            DELETE FROM ESTBATCHFIRSTPRINTRESULT

            BEGIN

              DECLARE 
                @v_data$VERSIONQTYTYPECODE$2 integer,
                @v_data$ISBN10$2 varchar(8000),
                @v_data$FINISHEDGOODQTY$2 integer,
                @v_data$VERSIONKEY$2 integer,
                @v_data$ESTKEY$2 integer              

              DECLARE 
                c_cursor CURSOR LOCAL 
                 FOR 
                  SELECT 
                      ESTVERSION.VERSIONQTYTYPECODE, 
                      ISBN.ISBN10, 
                      ESTVERSION.FINISHEDGOODQTY, 
                      ESTVERSION.VERSIONKEY, 
                      ESTBOOK.ESTKEY
                    FROM BOOKORGENTRY, ESTBOOK, ESTVERSION, ISBN
                    WHERE ((BOOKORGENTRY.ORGENTRYKEY IN (7, 8, 498, 591, 592, 823, 885, 886, 967, 1062 )) AND 
                            (BOOKORGENTRY.ORGLEVELKEY = 2) AND 
                            (BOOKORGENTRY.BOOKKEY = ESTBOOK.BOOKKEY) AND 
                            (ESTBOOK.PRINTINGKEY = 1) AND 
                            (ESTBOOK.ESTKEY = ESTVERSION.ESTKEY) AND 
                            (ESTBOOK.BOOKKEY = ISBN.BOOKKEY) AND 
                            ((ESTVERSION.ACTIVEIND = 1) OR 
                                    (ESTVERSION.ACTIVEIND IS NULL)))
              

              OPEN c_cursor

              FETCH NEXT FROM c_cursor
                INTO 
                  @v_data$VERSIONQTYTYPECODE$2, 
                  @v_data$ISBN10$2, 
                  @v_data$FINISHEDGOODQTY$2, 
                  @v_data$VERSIONKEY$2, 
                  @v_data$ESTKEY$2

              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN
                  /* if versionqtytypecode SUggested, High, Low or Reprint then create estbatchfirstprintresult record */
                  IF (@v_data$VERSIONQTYTYPECODE$2 IN (1, 2, 3, 4 ))
                    BEGIN
                      IF (@v_data$VERSIONQTYTYPECODE$2 = 1)
                        SET @v_quantityt_type = 'Suggested'
                      ELSE 
                        IF (@v_data$VERSIONQTYTYPECODE$2 = 2)
                          SET @v_quantityt_type = 'High'
                        ELSE 
                          IF (@v_data$VERSIONQTYTYPECODE$2 = 3)
                            SET @v_quantityt_type = 'Low'
                          ELSE 
                            IF (@v_data$VERSIONQTYTYPECODE$2 = 4)
                              SET @v_quantityt_type = 'Reprint'

                      /* calculare royalty per copy */

                      SELECT @v_cnt = count(ESTPLSPECS.TOTALROYALTY)
                        FROM ESTPLSPECS
                        WHERE ((ESTPLSPECS.ESTKEY = @v_data$ESTKEY$2) AND 
                                (ESTPLSPECS.VERSIONKEY = @v_data$VERSIONKEY$2))

                      IF (@v_cnt > 0)
                        BEGIN

                          SELECT @v_total_royalty = ESTPLSPECS.TOTALROYALTY, @v_return_rate = ESTPLSPECS.RETURNRATE
                            FROM ESTPLSPECS
                            WHERE ((ESTPLSPECS.ESTKEY = @v_data$ESTKEY$2) AND 
                                    (ESTPLSPECS.VERSIONKEY = @v_data$VERSIONKEY$2))

                          SET @v_net_copies = (@v_data$FINISHEDGOODQTY$2 - (@v_data$FINISHEDGOODQTY$2 * @v_return_rate / 100))
                          SET @v_royalty_per_copy = (@v_total_royalty / @v_net_copies)
                        END

                      /* get edtion cost */
                      SELECT @v_edition_total_cost = isnull(SUM(ESTCOST.TOTALCOST), 0)
                        FROM CDLIST, ESTCOST
                        WHERE ((CDLIST.INTERNALCODE = ESTCOST.CHGCODECODE) AND 
                                (ESTCOST.ESTKEY = @v_data$ESTKEY$2) AND 
                                (upper(CDLIST.COSTTYPE) = 'E') AND 
                                (ESTCOST.VERSIONKEY = @v_data$VERSIONKEY$2))

                      SET @v_edition_unitcost = (@v_edition_total_cost / @v_data$FINISHEDGOODQTY$2)

                      /* get plant cost */

                      SELECT @v_plant_total_cost = isnull(SUM(ESTCOST.TOTALCOST), 0), @v_plant_unit_cost = isnull(SUM(ESTCOST.UNITCOST), 0)
                        FROM CDLIST, ESTCOST
                        WHERE ((CDLIST.INTERNALCODE = ESTCOST.CHGCODECODE) AND 
                                (ESTCOST.ESTKEY = @v_data$ESTKEY$2) AND 
                                (upper(CDLIST.COSTTYPE) = 'P') AND 
                                (ESTCOST.VERSIONKEY = @v_data$VERSIONKEY$2))

                      /* get total unit cost */

                      SET @v_total_unitcost = (@v_edition_unitcost + @v_plant_unit_cost)
		      execute @v_errorseverity = GET_ESTMESSAGE_ERRORSEVERITY @v_data$ESTKEY$2, @v_data$VERSIONKEY$2

		      execute get_next_key 'qsidba',@newkey	
                      INSERT INTO ESTBATCHFIRSTPRINTRESULT
                        (
                          ESTBATCHFIRSTPRINTRESULT.FIRSTPRINTRESULTID, 
                          ESTBATCHFIRSTPRINTRESULT.ISBN, 
                          ESTBATCHFIRSTPRINTRESULT.QUANTITY, 
                          ESTBATCHFIRSTPRINTRESULT.QUANTITYTYPE, 
                          ESTBATCHFIRSTPRINTRESULT.EDITIONUNITCOST, 
                          ESTBATCHFIRSTPRINTRESULT.MARKUP, 
                          ESTBATCHFIRSTPRINTRESULT.PLANTCOST, 
                          ESTBATCHFIRSTPRINTRESULT.TOTLAUNITCOST, 
                          ESTBATCHFIRSTPRINTRESULT.ROYALTYPERCOPY, 
                          ESTBATCHFIRSTPRINTRESULT.LASTUSERID, 
                          ESTBATCHFIRSTPRINTRESULT.LASTMAINTDATE, 
                          ESTBATCHFIRSTPRINTRESULT.ERRORSEVERITYCODE
                        )
                        VALUES 
                          (
                            @newkey, 
                            @v_data$ISBN10$2, 
                            @v_data$FINISHEDGOODQTY$2, 
                            @v_quantityt_type, 
                            @v_edition_unitcost, 
                            0, 
                            @v_plant_total_cost, 
                            @v_total_unitcost, 
                            @v_royalty_per_copy, 
                            user_name(), 
                            getdate(), 
                            @v_errorseverity
                          )

                    END

                  FETCH NEXT FROM c_cursor
                    INTO 
                      @v_data$VERSIONQTYTYPECODE$2, 
                      @v_data$ISBN10$2, 
                      @v_data$FINISHEDGOODQTY$2, 
                      @v_data$VERSIONKEY$2, 
                      @v_data$ESTKEY$2

                END

              CLOSE c_cursor

              DEALLOCATE c_cursor

            END

            DECLARE 
              @param_expr_6$2 VARCHAR(8000)            

            SET @param_expr_6$2 = user_name()

            EXEC WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 1, 6, 'Estimate Batch', 'Est. Batch', @param_expr_6$2, 0, 0, 0, 6, 'First Print Result Process Copmleted', 'First Print Result Process Process Copmleted', @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@@TRANCOUNT > 0)
                COMMIT WORK

          END
      END
go
grant execute on est_batch_first_print_result  to public
go
