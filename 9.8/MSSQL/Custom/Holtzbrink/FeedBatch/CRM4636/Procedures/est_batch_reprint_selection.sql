IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'est_batch_reprint_selection')
BEGIN
  DROP  Procedure  est_batch_reprint_selection
END
GO

  CREATE 
    PROCEDURE dbo.est_batch_reprint_selection 
        @v_full_process char(1)
    AS
      BEGIN
          DECLARE 
            @v_data$BOOKKEY integer,
            @v_data$ISBNX varchar(20),
            @v_max_printing_key integer,
            @v_msg varchar(200),
            @v_jobkey integer,
            @v_batchkey integer,
            @v_cnt integer,
            @v_retcode integer,
            @v_error_desc varchar(500),
            @v_estkey_cnt integer,
            @v_startdatetime datetime,
            @v_cnt_last integer,
            @v_master_version integer,
	    @newkey integer          

          BEGIN

            /* is is doing full process then get latest startdatetime */

            IF (@v_full_process <> 'Y')
              BEGIN
                SELECT @v_startdatetime = max(QSIJOB.STARTDATETIME)
                  FROM QSIJOB
                  WHERE ((QSIJOB.STATUSCODE = 3) AND 
                          (QSIJOB.JOBTYPECODE = 1) AND 
                          ((QSIJOB.JOBTYPESUBCODE = 3) OR 
                                  (QSIJOB.JOBTYPESUBCODE = 4)))

              END

            IF (@v_full_process = 'Y')
              BEGIN

                DECLARE 
                  @param_expr_6 VARCHAR(8000)                

                SET @param_expr_6 = user_name()

                EXEC WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 1, 3, 'Estimate Batch', 'Est. Batch', @param_expr_6, 0, 0, 0, 1, 'Reprint Selection Full Preprocess Started', 'Reprint Selection Full Prerocess Started', @v_retcode OUTPUT, @v_error_desc OUTPUT 

              END
            ELSE 
              BEGIN

                DECLARE 
                  @param_expr_6$2 VARCHAR(50)                

                SET @param_expr_6$2 = user_name()

                EXEC WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 1, 4, 'Estimate Batch', 'Est. Batch', @param_expr_6$2, 0, 0, 0, 1, 'Reprint Selection Incremental Preprocess Started', 'Reprint Selection Incremental Prerocess Started', @v_retcode OUTPUT, @v_error_desc OUTPUT 

              END

            BEGIN

              DECLARE 
                @v_data$BOOKKEY$2 integer,
                @v_data$ISBNX$2 varchar(20)              

              DECLARE 
                c_cursor CURSOR LOCAL 
                 FOR 
                  SELECT DISTINCT CORETITLEINFO.BOOKKEY, CORETITLEINFO.ISBNX
                    FROM CORETITLEINFO, BOOKORGENTRY
                    WHERE ((CORETITLEINFO.BISACSTATUSCODE IN (1, 4, 7 )) AND 
                            (CORETITLEINFO.BOOKKEY = BOOKORGENTRY.BOOKKEY) AND 
                            (BOOKORGENTRY.ORGENTRYKEY IN (7, 8, 498, 591, 592, 823, 885, 886, 967, 1062 )) AND 
                            (BOOKORGENTRY.ORGLEVELKEY = 2) AND 
                            (ISNULL((CORETITLEINFO.ISBNX + '.'), '.') <> '.'))
              

              OPEN c_cursor

              FETCH NEXT FROM c_cursor
                INTO @v_data$BOOKKEY$2, @v_data$ISBNX$2

              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  /*   select count(estkey) */

                  /*   into  v_estkey_cnt */

                  /*   from estbook */

                  /*   where bookkey = v_data.bookkey */

                  /*   and printingkey = v_data.printingkey; */

                  /*   if v_estkey_cnt = 0 then */

                  /*     --write message only if full process */

                  /*     if v_full_process = 'Y' then */

                  /*       v_msg := 'estbook.estkey not found for bookkey = ' || to_char(v_data.bookkey)  || ' and printing key = ' || to_char(v_data.printingkey); */

                  /*       write_qsijobmessage(v_batchkey,v_jobkey,1,3,'Estimate Batch','Est. Batch',user,0,0,0,2,v_msg,v_msg,v_retcode,v_error_desc) ; */

                  /*     end if; */

                  /*   else */

                  /*          select estkey */

                  /*          into v_estkey */

                  /*          from estbook */

                  /*          where bookkey = v_data.bookkey */

                  /*          and printingkey = v_data.printingkey; */

                  SELECT @v_cnt = count(ESTBOOK.PRINTINGKEY)
                    FROM ESTBOOK, ESTVERSION
                    WHERE ((ESTBOOK.BOOKKEY = @v_data$BOOKKEY$2) AND 
                            (ESTBOOK.ESTKEY = ESTVERSION.ESTKEY) AND 
                            (ESTBOOK.MASTERVERSIONKEY = ESTVERSION.VERSIONKEY))



                  IF (@v_cnt > 0)
                    BEGIN

                      /* find the highest printingkey for this book that has a master version */

                      SELECT @v_max_printing_key = max(ESTBOOK.PRINTINGKEY)
                        FROM ESTBOOK, ESTVERSION
                        WHERE ((ESTBOOK.BOOKKEY = @v_data$BOOKKEY$2) AND 
                                (ESTBOOK.ESTKEY = ESTVERSION.ESTKEY) AND 
                                (ESTBOOK.MASTERVERSIONKEY = ESTVERSION.VERSIONKEY))


                      /* get master version */

                      SELECT @v_master_version = ESTBOOK.MASTERVERSIONKEY
                        FROM ESTBOOK, ESTVERSION
                        WHERE ((ESTBOOK.BOOKKEY = @v_data$BOOKKEY$2) AND 
                                (ESTBOOK.ESTKEY = ESTVERSION.ESTKEY) AND 
                                (ESTBOOK.PRINTINGKEY = @v_max_printing_key) AND 
                                (ESTBOOK.MASTERVERSIONKEY = ESTVERSION.VERSIONKEY))

                      IF (@v_full_process <> 'Y')
                        BEGIN

                          /* check to see if lastmaindate falls between falls between startdatetime */

                          /* on the previous job and the current job's startdatetime */

                          SELECT @v_cnt_last = count(ESTBOOK.LASTMAINTDATE)
                            FROM ESTBOOK
                            WHERE ((ESTBOOK.LASTMAINTDATE BETWEEN @v_startdatetime AND getdate()) AND 
                                    (ESTBOOK.BOOKKEY = @v_data$BOOKKEY$2) AND 
                                    (ESTBOOK.MASTERVERSIONKEY = @v_master_version))

                          IF (@v_cnt_last = 0)
                            BEGIN
                              SELECT @v_cnt_last = count(ESTCAMERASPECS.LASTMAINTDATE)
                                FROM ESTCAMERASPECS, ESTBOOK
                                WHERE ((ESTCAMERASPECS.LASTMAINTDATE BETWEEN @v_startdatetime AND getdate()) AND 
                                        (ESTCAMERASPECS.ESTKEY = ESTBOOK.ESTKEY) AND 
                                        (ESTBOOK.BOOKKEY = @v_data$BOOKKEY$2) AND 
                                        (ESTBOOK.MASTERVERSIONKEY = @v_master_version))

                            END

                          IF (@v_cnt_last = 0)
                            BEGIN
                              SELECT @v_cnt_last = count(ESTCOMP.LASTMAINTDATE)
                                FROM ESTCOMP, ESTBOOK
                                WHERE ((ESTCOMP.LASTMAINTDATE BETWEEN @v_startdatetime AND getdate()) AND 
                                        (ESTCOMP.ESTKEY = ESTBOOK.ESTKEY) AND 
                                        (ESTBOOK.BOOKKEY = @v_data$BOOKKEY$2) AND 
                                        (ESTBOOK.MASTERVERSIONKEY = @v_master_version))

                            END

                          IF (@v_cnt_last = 0)
                            BEGIN
                              SELECT @v_cnt_last = count(ESTMATERIALSPECS.LASTMAINTDATE)
                                FROM ESTMATERIALSPECS, ESTBOOK
                                WHERE ((ESTMATERIALSPECS.LASTMAINTDATE BETWEEN @v_startdatetime AND getdate()) AND 
                                        (ESTMATERIALSPECS.ESTKEY = ESTBOOK.ESTKEY) AND 
                                        (ESTBOOK.BOOKKEY = @v_data$BOOKKEY$2) AND 
                                        (ESTBOOK.MASTERVERSIONKEY = @v_master_version))

                            END

                          IF (@v_cnt_last = 0)
                            BEGIN
                              SELECT @v_cnt_last = count(ESTMATERIALSPECSIGS.LASTMAINTDATE)
                                FROM ESTMATERIALSPECSIGS, ESTBOOK
                                WHERE ((ESTMATERIALSPECSIGS.LASTMAINTDATE BETWEEN @v_startdatetime AND getdate()) AND 
                                        (ESTMATERIALSPECSIGS.ESTKEY = ESTBOOK.ESTKEY) AND 
                                        (ESTBOOK.BOOKKEY = @v_data$BOOKKEY$2) AND 
                                        (ESTBOOK.MASTERVERSIONKEY = @v_master_version))

                            END

                          IF (@v_cnt_last = 0)
                            BEGIN
                              SELECT @v_cnt_last = count(ESTMISCSPECS.LASTMAINTDATE)
                                FROM ESTMISCSPECS, ESTBOOK
                                WHERE ((ESTMISCSPECS.LASTMAINTDATE BETWEEN @v_startdatetime AND getdate()) AND 
                                        (ESTMISCSPECS.ESTKEY = ESTBOOK.ESTKEY) AND 
                                        (ESTBOOK.BOOKKEY = @v_data$BOOKKEY$2) AND 
                                        (ESTBOOK.MASTERVERSIONKEY = @v_master_version))

                            END

                          IF (@v_cnt_last = 0)
                            BEGIN
                              SELECT @v_cnt_last = count(ESTSPECS.LASTMAINTDATE)
                                FROM ESTSPECS, ESTBOOK
                                WHERE ((ESTSPECS.LASTMAINTDATE BETWEEN @v_startdatetime AND getdate()) AND 
                                        (ESTSPECS.ESTKEY = ESTBOOK.ESTKEY) AND 
                                        (ESTBOOK.BOOKKEY = @v_data$BOOKKEY$2) AND 
                                        (ESTBOOK.MASTERVERSIONKEY = @v_master_version))

                            END

                          IF (@v_cnt_last = 0)
                            BEGIN
                              SELECT @v_cnt_last = count(ESTVERSION.LASTMAINTDATE)
                                FROM ESTVERSION, ESTBOOK
                                WHERE ((ESTVERSION.LASTMAINTDATE BETWEEN @v_startdatetime AND getdate()) AND 
                                        (ESTVERSION.ESTKEY = ESTBOOK.ESTKEY) AND 
                                        (ESTBOOK.BOOKKEY = @v_data$BOOKKEY$2) AND 
                                        (ESTBOOK.MASTERVERSIONKEY = @v_master_version))

                            END

                          IF (@v_cnt_last > 0)
			   execute get_next_key 'qsidba',@newkey
                            INSERT INTO ESTBATCHREPRINTREQUEST
                              (
                                REQUESTID, 
                                ISBN, 
                                PRINTING, 
                                LASTUSERID, 
                                LASTMAINTDATE
                              )
                              VALUES 
                                (
                                  @newkey, 
                                  @v_data$ISBNX$2, 
                                  @v_max_printing_key, 
                                  user_name(), 
                                  getdate()
                                )

                        END
                      ELSE 
			execute get_next_key 'qsidba',@newkey
                        INSERT INTO ESTBATCHREPRINTREQUEST
                          (
                            REQUESTID, 
                            ISBN, 
                            PRINTING, 
                            LASTUSERID, 
                            LASTMAINTDATE
                          )
                          VALUES 
                            (
                              @newkey, 
                              @v_data$ISBNX$2, 
                              @v_max_printing_key, 
                              user_name(), 
                              getdate()
                            )

                    END
                  ELSE 
                    IF (@v_full_process = 'Y')
                      BEGIN

                        SET @v_msg = ('No Master Version Exists for bookkey = ' + isnull(CAST( @v_data$BOOKKEY$2 AS varchar(8000)), ''))

                        DECLARE 
                          @param_expr_6$3 VARCHAR(8000)                        

                        SET @param_expr_6$3 = user_name()

                        EXEC WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 1, 3, 'Estimate Batch', 'Est. Batch', @param_expr_6$3, 0, @v_data$BOOKKEY$2, 0, 2, @v_msg, @v_msg, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                      END

                  FETCH NEXT FROM c_cursor
                    INTO @v_data$BOOKKEY$2, @v_data$ISBNX$2

                END

              CLOSE c_cursor

              DEALLOCATE c_cursor

            END

            IF (@v_full_process = 'Y')
              BEGIN

                DECLARE 
                  @param_expr_6$4 VARCHAR(8000)                

                SET @param_expr_6$4 = user_name()

                EXEC WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 1, 3, 'Estimate Batch', 'Est. Batch', @param_expr_6$4, 0, 0, 0, 6, 'Reprint Selection Full Preprocess Copmleted', 'Reprint Selection Full Prerocess Copmleted', @v_retcode OUTPUT, @v_error_desc OUTPUT 

              END
            ELSE 
              BEGIN

                DECLARE 
                  @param_expr_6$5 VARCHAR(8000)                

                SET @param_expr_6$5 = user_name()

                EXEC WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 1, 4, 'Estimate Batch', 'Est. Batch', @param_expr_6$5, 0, 0, 0, 6, 'Reprint Selection Incremental Preprocess Copmleted', 'Reprint Selection Incremental Prerocess Copmleted', @v_retcode OUTPUT, @v_error_desc OUTPUT 

              END

            IF (@@TRANCOUNT > 0)
                COMMIT WORK

          END
      END
go
grant execute on est_batch_reprint_selection  to public
go

