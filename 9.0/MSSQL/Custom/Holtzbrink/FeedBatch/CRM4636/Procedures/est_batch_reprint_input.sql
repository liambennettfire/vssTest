IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'est_batch_reprint_input')
BEGIN
  DROP  Procedure  est_batch_reprint_input
END
GO
  CREATE 
    PROCEDURE dbo.est_batch_reprint_input 
    AS
      BEGIN
          DECLARE 
            @v_retcode integer,
            @v_error_desc varchar(500),
            @v_jobkey integer,
            @v_batchkey integer,
            @v_cnt integer,
            @v_finishedgoodvendorcode integer,
            @v_versionkey integer,
            @v_request_date datetime,
            @v_estkey integer,
            @v_vendorcode integer,
            @v_data$ESTKEY integer,
            @v_data$BOOKKEY integer,
            @v_data$PRINTINGKEY integer,
            @v_data$REQUESTID integer,
            @v_data$ISBN10 varchar(8000),
            @v_data$PRINTINGNUM integer,
            @v_quantity$QUANTITY integer,
	    @newkey int          
          BEGIN

            DECLARE 
              @param_expr_6 VARCHAR(8000)            

            SET @param_expr_6 = user_name()

            EXEC WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 1, 5, 'Estimate Batch', 'Est. Batch', @param_expr_6, 0, 0, 0, 1, 'Reprint Input Process Started', 'Reprint Input Process Started', @v_retcode OUTPUT, @v_error_desc OUTPUT 

            SELECT @v_request_date = getdate()
            BEGIN

              DECLARE 
                @v_data$ESTKEY$2 integer,
                @v_data$BOOKKEY$2 integer,
                @v_data$PRINTINGKEY$2 integer,
                @v_data$REQUESTID$2 integer,
                @v_data$ISBN10$2 varchar(8000),
                @v_data$PRINTINGNUM$2 integer              

              DECLARE 
                c_cursor CURSOR LOCAL 
                 FOR 
                  SELECT 
                      ESTBOOK.ESTKEY, 
                      ESTBOOK.BOOKKEY, 
                      ESTBOOK.PRINTINGKEY, 
                      ESTBATCHREPRINTREQUEST.REQUESTID, 
                      ISBN.ISBN10, 
                      PRINTING.PRINTINGNUM
                    FROM ESTBATCHREPRINTREQUEST, ISBN, ESTBOOK, PRINTING
                    WHERE ((ISBN.ISBN10 = ESTBATCHREPRINTREQUEST.ISBN) AND 
                            (ISBN.BOOKKEY = ESTBOOK.BOOKKEY) AND 
                            (ESTBATCHREPRINTREQUEST.PRINTING = ESTBOOK.PRINTINGKEY) AND 
                            (PRINTING.BOOKKEY = ISBN.BOOKKEY) AND 
                            (PRINTING.PRINTINGKEY = ESTBOOK.PRINTINGKEY))
              

              OPEN c_cursor

              FETCH NEXT FROM c_cursor
                INTO 
                  @v_data$ESTKEY$2, 
                  @v_data$BOOKKEY$2, 
                  @v_data$PRINTINGKEY$2, 
                  @v_data$REQUESTID$2, 
                  @v_data$ISBN10$2, 
                  @v_data$PRINTINGNUM$2



              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  /* does the master version exist */

                  SELECT @v_cnt = count(ESTVERSION.ESTKEY)
                    FROM ESTVERSION, ESTBOOK
                    WHERE ((ESTVERSION.ESTKEY = @v_data$ESTKEY$2) AND 
                            (ESTVERSION.ESTKEY = ESTBOOK.ESTKEY) AND 
                            (ESTBOOK.MASTERVERSIONKEY = ESTVERSION.VERSIONKEY))


                  /* if master version does not exist then write to qsijobmessage else */

                  /* continue processing */

                  IF (@v_cnt = 0)
                    BEGIN

                      DECLARE 
                        @param_expr_6$2 VARCHAR(8000)                      

                      SET @param_expr_6$2 = user_name()

                      DECLARE 
                        @param_expr_11 VARCHAR(8000)                      

                      SET @param_expr_11 = ('No Master Version for estkey = ' + isnull(CAST( @v_data$ESTKEY$2 AS varchar(8000)), '') + '. Unit cost quantites undetermined.')

                      EXEC WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 1, 5, 'Estimate Batch', 'Est. Batch', @param_expr_6$2, 0, @v_data$BOOKKEY$2, 0, 2, @param_expr_11, 'No Master Version Exist', @v_retcode OUTPUT, @v_error_desc OUTPUT 

                    END
                  ELSE 
                    BEGIN

                      /* Using Bind Vendor, Jacket or Cover component create estimaterequest record */

                      /* for each quantity found on the reprintquantity table */

                      SELECT @v_finishedgoodvendorcode = ESTVERSION.FINISHEDGOODVENDORCODE, @v_versionkey = ESTVERSION.VERSIONKEY
                        FROM ESTVERSION, ESTBOOK
                        WHERE ((ESTVERSION.ESTKEY = @v_data$ESTKEY$2) AND 
                                (ESTVERSION.ESTKEY = ESTBOOK.ESTKEY) AND 
                                (ESTBOOK.MASTERVERSIONKEY = ESTVERSION.VERSIONKEY))



                      SELECT @v_cnt = count(VENDOR.PAYTOVENDORKEY)
                        FROM VENDOR
                        WHERE (VENDOR.VENDORKEY = @v_finishedgoodvendorcode)


                      IF (@v_cnt > 0)
                        BEGIN

                          SELECT @v_vendorcode = VENDOR.PAYTOVENDORKEY
                            FROM VENDOR
                            WHERE (VENDOR.VENDORKEY = @v_finishedgoodvendorcode)

                          SET @v_finishedgoodvendorcode = @v_vendorcode

                        END

                      SELECT @v_cnt = count( * )
                        FROM REPRINTQUANTITY
                        WHERE ((REPRINTQUANTITY.FGVENDORKEY = @v_finishedgoodvendorcode) AND 
                                (REPRINTQUANTITY.COMPVENDORKEY IN
                                    ( 
                                      SELECT isnull(VENDOR.PAYTOVENDORKEY, VENDOR.VENDORKEY)
                                        FROM VENDOR, ESTCOMP
                                        WHERE ((ESTCOMP.COMPVENDORCODE = VENDOR.VENDORKEY) AND 
                                                (ESTCOMP.ESTKEY = @v_data$ESTKEY$2) AND 
                                                (ESTCOMP.VERSIONKEY = @v_versionkey) AND 
                                                (ESTCOMP.COMPKEY IN (2, 4, 5 )))
                                    )))


                      IF (@v_cnt = 0)
                        BEGIN

                          DECLARE 
                            @param_expr_6$3 VARCHAR(8000)                          

                          SET @param_expr_6$3 = user_name()

                          DECLARE 
                            @param_expr_11$2 VARCHAR(8000)                          

                          SET @param_expr_11$2 = ('Vendor does not exist on reprintquantity table for estkey = ' + isnull(CAST( @v_data$ESTKEY$2 AS varchar(8000)), '') + ' and versionkey = ' + isnull(CAST( @v_versionkey AS varchar(8000)), ''))

                          EXEC WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 1, 5, 'Estimate Batch', 'Est. Batch', @param_expr_6$3, 0, @v_data$BOOKKEY$2, 0, 2, @param_expr_11$2, 'Vendor does not exist.', @v_retcode OUTPUT, @v_error_desc OUTPUT 

                        END
                      ELSE 
                        BEGIN
                          SET @v_estkey = @v_data$ESTKEY$2
                          BEGIN

                            DECLARE 
                              @v_quantity$QUANTITY$2 integer                            

                            DECLARE 
                              c_quantity CURSOR LOCAL 
                               FOR 
                                SELECT REPRINTQUANTITY.QUANTITY
                                  FROM REPRINTQUANTITY
                                  WHERE ((REPRINTQUANTITY.FGVENDORKEY = @v_finishedgoodvendorcode) AND 
                                          (REPRINTQUANTITY.COMPVENDORKEY IN
                                              ( 
                                                SELECT isnull(VENDOR.PAYTOVENDORKEY, VENDOR.VENDORKEY)
                                                  FROM VENDOR, ESTCOMP
                                                  WHERE ((ESTCOMP.COMPVENDORCODE = VENDOR.VENDORKEY) AND 
                                                          (ESTCOMP.ESTKEY = @v_estkey) AND 
                                                          (ESTCOMP.VERSIONKEY = @v_versionkey) AND 
                                                          (ESTCOMP.COMPKEY IN
                                                              ( 
                                                                SELECT max(ESTCOMP.COMPKEY)
                                                                  FROM VENDOR, ESTCOMP
                                                                  WHERE ((ESTCOMP.COMPVENDORCODE = VENDOR.VENDORKEY) AND 
                                                                          (ESTCOMP.ESTKEY = @v_estkey) AND 
                                                                          (ESTCOMP.VERSIONKEY = @v_versionkey) AND 
                                                                          (ESTCOMP.COMPKEY IN (2, 4, 5 )))
                                                              )))
                                              )))
                            

                            OPEN c_quantity

                            FETCH NEXT FROM c_quantity
                              INTO @v_quantity$QUANTITY$2

                            WHILE  NOT(@@FETCH_STATUS = -1)
                              BEGIN
			        execute get_next_key 'qsidba',@newkey
                                INSERT INTO ESTIMATEREQUEST
                                  (
                                    ESTIMATEREQUEST.REQUESTID, 
                                    ESTIMATEREQUEST.ISBN, 
                                    ESTIMATEREQUEST.PRINTINGNUMBER, 
                                    ESTIMATEREQUEST.ESTBATCHVERSIONSTATUS, 
                                    ESTIMATEREQUEST.FGQUANTITY, 
                                    ESTIMATEREQUEST.OUTPUTTYPE, 
                                    ESTIMATEREQUEST.VERSIONQTYTYPECODE, 
                                    ESTIMATEREQUEST.VERSIONSTATUSCODE, 
                                    ESTIMATEREQUEST.SOURCECODE, 
                                    ESTIMATEREQUEST.REQUESTDATE, 
                                    ESTIMATEREQUEST.BOOKKEY, 
                                    ESTIMATEREQUEST.PRINTINGKEY, 
                                    ESTIMATEREQUEST.LASTUSERID, 
                                    ESTIMATEREQUEST.LASTMAINTDATE
                                  )
                                  VALUES 
                                    (
                                      @newkey, 
                                      @v_data$ISBN10$2, 
                                      @v_data$PRINTINGNUM$2, 
                                      1, 
                                      @v_quantity$QUANTITY$2, 
                                      4, 
                                      5, 
                                      3, 
                                      1, 
                                      @v_request_date, 
                                      @v_data$BOOKKEY$2, 
                                      @v_data$PRINTINGKEY$2, 
                                      user_name(), 
                                      getdate()
                                    )
                                FETCH NEXT FROM c_quantity
                                  INTO @v_quantity$QUANTITY$2
                              END

                            CLOSE c_quantity

                            DEALLOCATE c_quantity

                          END
                        END

                    END

                  DELETE FROM ESTBATCHREPRINTREQUEST
                    WHERE (ESTBATCHREPRINTREQUEST.REQUESTID = @v_data$REQUESTID$2)

                  FETCH NEXT FROM c_cursor
                    INTO 
                      @v_data$ESTKEY$2, 
                      @v_data$BOOKKEY$2, 
                      @v_data$PRINTINGKEY$2, 
                      @v_data$REQUESTID$2, 
                      @v_data$ISBN10$2, 
                      @v_data$PRINTINGNUM$2

                END

              CLOSE c_cursor

              DEALLOCATE c_cursor

            END

            DECLARE 
              @param_expr_6$4 VARCHAR(8000)            

            SET @param_expr_6$4 = user_name()

            EXEC WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 1, 5, 'Estimate Batch', 'Est. Batch', @param_expr_6$4, 0, 0, 0, 6, 'Reprint Input Process Copmleted', 'Reprint Input Process Copmleted', @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@@TRANCOUNT > 0)
                COMMIT WORK

          END
      END
go
grant execute on est_batch_reprint_input  to public
go

