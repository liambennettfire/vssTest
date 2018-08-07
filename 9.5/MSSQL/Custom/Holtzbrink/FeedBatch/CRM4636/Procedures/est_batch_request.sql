IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'est_batch_request')
BEGIN
  DROP  Procedure  est_batch_request
END
GO

  CREATE 
    PROCEDURE dbo.est_batch_request 
    AS
      BEGIN
          DECLARE 
            @v_data$REQUESTID integer,
            @v_data$ISBN varchar(20),
            @v_data$PRINTINGNUMBER integer,
            @v_data$ESTBATCHVERSIONSTATUS integer,
            @v_data$FGQUANTITY integer,
            @v_data$OUTPUTTYPE integer,
            @v_data$VERSIONQTYTYPECODE integer,
            @v_data$VERSIONSTATUSCODE integer,
            @v_data$SOURCECODE integer,
            @v_data$REQUESTDATE datetime,
            @v_data$BOOKKEY integer,
            @v_data$PRINTINGKEY integer,
            @v_data$LASTUSERID varchar(8000),
            @v_data$LASTMAINTDATE datetime,
            @v_bookkey integer,
            @v_jobkey integer,
            @v_batchkey integer,
            @v_retcode integer,
            @v_printingkey integer,
            @v_error_desc varchar(500),
            @v_estkey integer,
            @v_count integer,
            @v_ignore bit  ,
	    @newkey integer        
          BEGIN

            DECLARE 
              @param_expr_6 VARCHAR(8000)            

            SET @param_expr_6 = user_name()

            EXEC WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 1, 1, 'Estimate Batch', 'Est. Batch', @param_expr_6, 0, 0, 0, 1, 'Estimate Request Process Started', 'Estimate Request Process Started', @v_retcode OUTPUT, @v_error_desc OUTPUT 

            BEGIN

              DECLARE 
                @v_data$REQUESTID$2 integer,
                @v_data$ISBN$2 varchar(8000),
                @v_data$PRINTINGNUMBER$2 integer,
                @v_data$ESTBATCHVERSIONSTATUS$2 integer,
                @v_data$FGQUANTITY$2 integer,
                @v_data$OUTPUTTYPE$2 integer,
                @v_data$VERSIONQTYTYPECODE$2 integer,
                @v_data$VERSIONSTATUSCODE$2 integer,
                @v_data$SOURCECODE$2 integer,
                @v_data$REQUESTDATE$2 datetime,
                @v_data$BOOKKEY$2 integer,
                @v_data$PRINTINGKEY$2 integer,
                @v_data$LASTUSERID$2 varchar(8000),
                @v_data$LASTMAINTDATE$2 datetime              

              DECLARE 
                c_cursor CURSOR LOCAL 
                 FOR 
                  SELECT 
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
                    FROM ESTIMATEREQUEST
              

              OPEN c_cursor

              FETCH NEXT FROM c_cursor
                INTO 
                  @v_data$REQUESTID$2, 
                  @v_data$ISBN$2, 
                  @v_data$PRINTINGNUMBER$2, 
                  @v_data$ESTBATCHVERSIONSTATUS$2, 
                  @v_data$FGQUANTITY$2, 
                  @v_data$OUTPUTTYPE$2, 
                  @v_data$VERSIONQTYTYPECODE$2, 
                  @v_data$VERSIONSTATUSCODE$2, 
                  @v_data$SOURCECODE$2, 
                  @v_data$REQUESTDATE$2, 
                  @v_data$BOOKKEY$2, 
                  @v_data$PRINTINGKEY$2, 
                  @v_data$LASTUSERID$2, 
                  @v_data$LASTMAINTDATE$2


              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  SET @v_ignore = /* false */ 0

                  /* if bookkey and printingkey is null then find them for this isbn and printingnumber */

                  IF ((@v_data$BOOKKEY$2 IS NULL) AND 
                          (@v_data$PRINTINGKEY$2 IS NULL))
                    BEGIN

                      SELECT @v_count = count(CORETITLEINFO.BOOKKEY)
                        FROM CORETITLEINFO
                        WHERE (CORETITLEINFO.ISBNX = @v_data$ISBN$2)

                      IF (@v_count = 0)
                        BEGIN

                          DECLARE 
                            @param_expr_6$2 VARCHAR(8000)                          

                          SET @param_expr_6$2 = user_name()

                          DECLARE 
                            @param_expr_11 VARCHAR(8000)                          

                          SET @param_expr_11 = ('ISBN ' + isnull(@v_data$ISBN$2, '') + ' not found on the system.')

                          DECLARE 
                            @param_expr_12 VARCHAR(8000)                          

                          SET @param_expr_12 = ('ISBN ' + isnull(@v_data$ISBN$2, '') + 'not found on the system.')

                          EXEC WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 1, 1, 'Estimate Batch', 'Est. Batch', @param_expr_6$2, 0, 0, 0, 2, @param_expr_11, @param_expr_12, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                          SET @v_ignore = /* true */ 1

                        END
                      ELSE 
                        BEGIN
                          SELECT @v_bookkey = CORETITLEINFO.BOOKKEY, @v_printingkey = PRINTING.PRINTINGKEY
                            FROM CORETITLEINFO, PRINTING
                            WHERE ((CORETITLEINFO.ISBNX = @v_data$ISBN$2) AND 
                                    (CORETITLEINFO.BOOKKEY = PRINTING.BOOKKEY) AND 
                                    (CORETITLEINFO.PRINTINGKEY = PRINTING.PRINTINGKEY) AND 
                                    (PRINTING.PRINTINGNUM = @v_data$PRINTINGNUMBER$2))

                        END

                    END
                  ELSE 
                    BEGIN
                      SET @v_bookkey = @v_data$BOOKKEY$2
                      SET @v_printingkey = @v_data$PRINTINGKEY$2
                    END

                  IF (@v_ignore = /* false */ 0)
                    BEGIN

                      /* update estversion for this title if versionqtytypecode is Reprint Vendor Grid */

                      IF (@v_data$VERSIONQTYTYPECODE$2 = 5)
                        UPDATE ESTVERSION
                          SET ESTVERSION.ACTIVEIND = 0, ESTVERSION.SELECTEDVERSIONIND = 0
                          WHERE ((ESTVERSION.VERSIONQTYTYPECODE = 5) AND 
                                  (ESTVERSION.ESTKEY IN
                                      ( 
                                        SELECT ESTBOOK.ESTKEY
                                          FROM ESTBOOK
                                          WHERE (ESTBOOK.BOOKKEY = @v_bookkey)
                                      )))
                      ELSE 
                        BEGIN

                          /*  Find all active versions with the same versiontypecode as the estimate request. */

                          /*  If no versions are found matching the versionqtytypecode, do nothing. */

                          /*  For each version found with the same versionqtytypecode: */

                          /*  If this version is the Master version,  set the estversion.versionqtytypecode on */

                          /*  this version (the Master Version) to Null Otherwise Set the estversion.activeind on */

                          /*  the version found to 'N'. */

                          SET @v_estkey = @v_estkey

                          SELECT @v_estkey = ESTBOOK.ESTKEY
                            FROM ESTBOOK
                            WHERE ((ESTBOOK.PRINTINGKEY = @v_printingkey) AND 
                                    (ESTBOOK.BOOKKEY = @v_bookkey))

                          SELECT @v_count = count( * )
                            FROM ESTVERSION
                            WHERE ((ESTVERSION.ACTIVEIND = 1) AND 
                                    (ESTVERSION.VERSIONQTYTYPECODE = @v_data$VERSIONQTYTYPECODE$2) AND 
                                    (ESTVERSION.ESTKEY = @v_estkey))

                          IF (@v_count > 0)
                            BEGIN
                              UPDATE ESTVERSION
                                SET ESTVERSION.ACTIVEIND = 0, ESTVERSION.SELECTEDVERSIONIND = 0
                                WHERE ((ESTVERSION.ACTIVEIND = 1) AND 
                                        (ESTVERSION.VERSIONQTYTYPECODE = @v_data$VERSIONQTYTYPECODE$2) AND 
                                        (ESTVERSION.ESTKEY = @v_estkey) AND 
                                        (ESTVERSION.VERSIONKEY NOT IN
                                            ( 
                                              SELECT ESTBOOK.MASTERVERSIONKEY
                                                FROM ESTBOOK
                                                WHERE ((ESTBOOK.PRINTINGKEY = @v_printingkey) AND 
                                                        (ESTBOOK.BOOKKEY = @v_bookkey))
                                            )))
                              UPDATE ESTVERSION
                                SET ESTVERSION.VERSIONQTYTYPECODE =  NULL
                                WHERE ((ESTVERSION.ACTIVEIND = 1) AND 
                                        (ESTVERSION.VERSIONQTYTYPECODE = @v_data$VERSIONQTYTYPECODE$2) AND 
                                        (ESTVERSION.VERSIONKEY IN
                                            ( 
                                              SELECT ESTBOOK.MASTERVERSIONKEY
                                                FROM ESTBOOK
                                                WHERE ((ESTBOOK.PRINTINGKEY = @v_printingkey) AND 
                                                        (ESTBOOK.BOOKKEY = @v_bookkey))
                                            )))
                            END

                        END

                      /* create estbatchversion record */
		      execute get_next_key 'qsidba',@newkey
                      INSERT INTO ESTBATCHVERSION
                        (
                          ESTBATCHVERSION.ESTBATCHVERSIONKEY, 
                          ESTBATCHVERSION.BOOKKEY, 
                          ESTBATCHVERSION.PRINTINGKEY, 
                          ESTBATCHVERSION.BATCHSTATUSCODE, 
                          ESTBATCHVERSION.FGQUANTITY, 
                          ESTBATCHVERSION.VERSIONQTYTYPECODE, 
                          ESTBATCHVERSION.VERSIONSTATUSCODE, 
                          ESTBATCHVERSION.REQUESTID, 
                          ESTBATCHVERSION.SOURCECODE, 
                          ESTBATCHVERSION.REQUESTDATE, 
                          ESTBATCHVERSION.LASTUSERID, 
                          ESTBATCHVERSION.LASTMAINTDATE, 
                          ESTBATCHVERSION.CREATEUSER, 
                          ESTBATCHVERSION.CREATEDATE
                        )
                        VALUES 
                          (
                            @newkey, 
                            @v_bookkey, 
                            @v_printingkey, 
                            1, 
                            @v_data$FGQUANTITY$2, 
                            @v_data$VERSIONQTYTYPECODE$2, 
                            @v_data$VERSIONSTATUSCODE$2, 
                            @v_data$REQUESTID$2, 
                            @v_data$SOURCECODE$2, 
                            @v_data$REQUESTDATE$2, 
                            @v_data$LASTUSERID$2, 
                            @v_data$LASTMAINTDATE$2, 
                            @v_data$LASTUSERID$2, 
                            @v_data$LASTMAINTDATE$2
                          )

                      DELETE FROM ESTIMATEREQUEST
                        WHERE (requestid =  @v_data$REQUESTID$2)

                    END

                  FETCH NEXT FROM c_cursor
                    INTO 
                      @v_data$REQUESTID$2, 
                      @v_data$ISBN$2, 
                      @v_data$PRINTINGNUMBER$2, 
                      @v_data$ESTBATCHVERSIONSTATUS$2, 
                      @v_data$FGQUANTITY$2, 
                      @v_data$OUTPUTTYPE$2, 
                      @v_data$VERSIONQTYTYPECODE$2, 
                      @v_data$VERSIONSTATUSCODE$2, 
                      @v_data$SOURCECODE$2, 
                      @v_data$REQUESTDATE$2, 
                      @v_data$BOOKKEY$2, 
                      @v_data$PRINTINGKEY$2, 
                      @v_data$LASTUSERID$2, 
                      @v_data$LASTMAINTDATE$2

                END

              CLOSE c_cursor

              DEALLOCATE c_cursor

            END

            DECLARE 
              @param_expr_6$3 VARCHAR(8000)            

            SET @param_expr_6$3 = user_name()

            EXEC WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 1, 1, 'Estimate Batch', 'Est. Batch', @param_expr_6$3, 0, 0, 0, 6, 'Estimate Request Process Started', 'Estimate Request Process Completed', @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@@TRANCOUNT > 0)
                COMMIT WORK

          END
      END


go
grant execute on est_batch_request  to public
go


