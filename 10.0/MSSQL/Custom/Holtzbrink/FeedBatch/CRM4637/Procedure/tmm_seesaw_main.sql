IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'tmm_seesaw_main')
BEGIN
  DROP  Procedure  tmm_seesaw_main
END
GO
  CREATE 
    PROCEDURE dbo.tmm_seesaw_main 
        @i_xmltype integer,
        @i_location varchar(2000),
        @i_alltitles integer
    AS
      BEGIN
        /*  i_alltitles = 1 for full run / 0 for incremental */
          DECLARE 
            @v_batchkey integer,
            @v_previous_enddatetime datetime,
            @v_mainprocess_jobkey integer,
            @v_jobkey integer,
            @v_jobtypecode integer,
            @v_jobtypesubcode integer,
            @v_count integer,
            @v_bookkey integer,
            @v_printingkey integer,
            @v_retcode integer,
            @v_maintain_xml_retcode integer,
            @v_create_file_retcode integer,
            @v_error_desc varchar(2000),
            @v_messagetypecode integer,
            @v_number_of_titles integer,
            @v_msg varchar(4000),
            @v_msgshort varchar(255),
            @v_alltitles integer,
            @return_sys_err_code integer,
            @return_nodata_err_code integer,
            @return_no_err_code integer          

          SET @return_sys_err_code =  -1
          SET @return_nodata_err_code = 0
          SET @return_no_err_code = 1


            SET @v_alltitles = @i_alltitles
            IF ((@v_alltitles IS NULL) OR 
                    (@v_alltitles <> 1))
              SET @v_alltitles = 0

            SET @v_jobtypecode = 2

            /*  SeeSaw Onix Feed */
            /*  start a new job (qsijobkey and qsibatchkey will be generated and returned) */
            SET @v_jobtypesubcode = 1

            /*  Main Process */
            SET @v_messagetypecode = 1

            /*  tableid 539 - Job Started */
            EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @v_jobtypecode, @v_jobtypesubcode, 'TMM to SeeSaw Feed', 'SeeSaw Feed', 'TMMSEESAW', 0, 0, 0, @v_messagetypecode, 'TMM to SeeSaw Feed Started', 'TMM to SeeSaw Feed Started', @v_retcode OUTPUT, @v_error_desc OUTPUT 

            SET @v_mainprocess_jobkey = @v_jobkey
            SET @v_number_of_titles = 0

            IF (@v_batchkey > 0)
              BEGIN
                SET @v_jobkey = 0

                /*  Create New Job */
                SET @v_jobtypesubcode = 2

                /*  Populate Keys Process */
                SET @v_messagetypecode = 1

                /*  New Job */
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @v_jobtypecode, @v_jobtypesubcode, 'TMM to SeeSaw Feed', 'SeeSaw Feed', 'TMMSEESAW', 0, 0, 0, @v_messagetypecode, 'Populate Keys Process Started', 'Populate Keys Process Started', @v_retcode OUTPUT, @v_error_desc OUTPUT 

                /*  get endtime of populate keys process from last batch */

                SELECT @v_count = count( * )
                  FROM dbo.QSIJOB j
                  WHERE ((j.JOBTYPECODE = @v_jobtypecode) AND 
                          (j.JOBTYPESUBCODE = @v_jobtypesubcode))

                IF (@v_count > 0)
                  BEGIN
                    SELECT @v_previous_enddatetime = max(j.STOPDATETIME)
                      FROM dbo.QSIJOB j
                      WHERE ((j.JOBTYPECODE = @v_jobtypecode) AND 
                              (j.JOBTYPESUBCODE = @v_jobtypesubcode))
                    EXEC SYSDB.SSMA.db_error_exact_one_row_check @@ROWCOUNT 
                  END
                ELSE 
                  BEGIN
                    SET @v_previous_enddatetime =  NULL
                    SET @v_alltitles = 1
                  END

                /*  for now we want Bedford, Freeman, Worth (orgentrykey=1485) and Palgrave (orgentrykey=833) Titles */

                /*  that have been assigned isbns */
                IF ((@v_alltitles = 1) OR 
                        (@v_previous_enddatetime IS NULL))
                  BEGIN

                    /*  full run */
                    SELECT @v_number_of_titles = count(*)
                      FROM dbo.CORETITLEINFO c, dbo.BOOKORGENTRY o
                      WHERE c.BOOKKEY = o.BOOKKEY AND 
                            c.PRINTINGKEY = 1 AND 
                            c.PRODUCTNUMBER IS NOT NULL AND 
                            o.ORGLEVELKEY = 1 AND 
                            o.ORGENTRYKEY IN (1485, 833 )

                    IF (@v_number_of_titles > 0)
                      BEGIN

                        /*  load qsiexportkeys */
                        INSERT INTO dbo.QSIEXPORTKEYS
                          (
                            dbo.QSIEXPORTKEYS.QSIBATCHKEY, 
                            dbo.QSIEXPORTKEYS.KEY1, 
                            dbo.QSIEXPORTKEYS.KEY2, 
                            dbo.QSIEXPORTKEYS.KEY3, 
                            dbo.QSIEXPORTKEYS.LASTUSERID, 
                            dbo.QSIEXPORTKEYS.LASTMAINTDATE
                          )
                          SELECT 
                              @v_batchkey, 
                              c.BOOKKEY, 
                              c.PRINTINGKEY, 
                              0, 
                              'TMMSEESAW', 
                              getdate()
                            FROM dbo.CORETITLEINFO c, dbo.BOOKORGENTRY o
                            WHERE   c.BOOKKEY = o.BOOKKEY AND 
                                    c.PRINTINGKEY = 1 AND 
                                    c.PRODUCTNUMBER IS NOT NULL AND 
                                    o.ORGLEVELKEY = 1 AND 
                                    o.ORGENTRYKEY IN (1485, 833 )

                      END

                  END
                ELSE 
                  BEGIN

                    /*  incremental */

                    SELECT @v_number_of_titles = count( * )
                      FROM dbo.CORETITLEINFO c, dbo.BOOKORGENTRY o, dbo.TITLECHANGEDINFO t
                      WHERE   c.BOOKKEY = o.BOOKKEY AND 
                              c.BOOKKEY = t.BOOKKEY AND 
                              c.PRINTINGKEY = 1 AND 
                              c.PRODUCTNUMBER IS NOT NULL AND 
                              o.ORGLEVELKEY = 1 AND 
                              o.ORGENTRYKEY IN (1485, 833) AND 
                              t.LASTCHANGEDATE > @v_previous_enddatetime

                    IF (@v_number_of_titles > 0)
                      BEGIN

                        /*  load qsiexportkeys */
                        INSERT INTO dbo.QSIEXPORTKEYS
                          (
                            dbo.QSIEXPORTKEYS.QSIBATCHKEY, 
                            dbo.QSIEXPORTKEYS.KEY1, 
                            dbo.QSIEXPORTKEYS.KEY2, 
                            dbo.QSIEXPORTKEYS.KEY3, 
                            dbo.QSIEXPORTKEYS.LASTUSERID, 
                            dbo.QSIEXPORTKEYS.LASTMAINTDATE
                          )
                          SELECT 
                              @v_batchkey, 
                              c.BOOKKEY, 
                              c.PRINTINGKEY, 
                              0, 
                              'TMMSEESAW', 
                              getdate()
                            FROM dbo.CORETITLEINFO c, dbo.BOOKORGENTRY o, dbo.TITLECHANGEDINFO t
                            WHERE   c.BOOKKEY = o.BOOKKEY AND 
                                    c.BOOKKEY = t.BOOKKEY AND 
                                    c.PRINTINGKEY = 1 AND 
                                    c.PRODUCTNUMBER IS NOT NULL AND 
                                    o.ORGLEVELKEY = 1 AND 
                                    o.ORGENTRYKEY IN (1485, 833) AND 
                                    t.LASTCHANGEDATE > @v_previous_enddatetime

                      END

                  END

                SET @v_messagetypecode = 4

                /*  Information */
                SET @v_msg = (isnull(CAST( @v_number_of_titles AS varchar(100)), '') + ' titles to Process')
                SET @v_msgshort = (isnull(CAST( @v_number_of_titles AS varchar(100)), '') + ' titles to Process')

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @v_jobtypecode, @v_jobtypesubcode, '', '', 'TMMSEESAW', 0, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 


                SET @v_messagetypecode = 6
                /*  Job Finished */
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @v_jobtypecode, @v_jobtypesubcode, '', '', 'TMMSEESAW', 0, 0, 0, @v_messagetypecode, 'Populate Keys Process Completed', 'Populate Keys Process Completed', @v_retcode OUTPUT, @v_error_desc OUTPUT 

                /*  maintain xml */
                IF (@v_number_of_titles > 0)
                  BEGIN
                    SET @v_jobkey = 0

                    /*  Create New Job */
                    SET @v_jobtypesubcode = 3

                    /*  Maintain XML Process */
                    SET @v_messagetypecode = 1

                    /*  New Job */
                    EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @v_jobtypecode, @v_jobtypesubcode, 'TMM to SeeSaw Feed', 'SeeSaw Feed', 'TMMSEESAW', 0, 0, 0, @v_messagetypecode, 'XML Process Started', 'XML Process Started', @v_retcode OUTPUT, @v_error_desc OUTPUT 


                    EXEC dbo.TMM_SEESAW_MAINTAIN_XML_MAIN @i_xmltype, @v_batchkey, @v_jobkey, @v_jobtypecode, @v_jobtypesubcode, 'TMMSEESAW', @v_retcode OUTPUT, @v_error_desc OUTPUT 

                    SET @v_maintain_xml_retcode = @v_retcode

                    SET @v_messagetypecode = 6

                    /*  Job Finished */

                    EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @v_jobtypecode, @v_jobtypesubcode, '', '', 'TMMSEESAW', 0, 0, 0, @v_messagetypecode, 'XML Process Completed', 'XML Process Completed', @v_retcode OUTPUT, @v_error_desc OUTPUT 

                    IF (@v_maintain_xml_retcode < 0)
                      GOTO finished

                  END

                /*  create file */
                IF (@v_number_of_titles > 0)
                  BEGIN
                    SET @v_jobkey = 0

                    /*  Create New Job */
                    SET @v_jobtypesubcode = 4

                    /*  Create File Process */
                    SET @v_messagetypecode = 1

                    /*  New Job */
                    EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @v_jobtypecode, @v_jobtypesubcode, 'TMM to SeeSaw Feed', 'SeeSaw Feed', 'TMMSEESAW', 0, 0, 0, @v_messagetypecode, 'Create File Process Started', 'Create File Process Started', @v_retcode OUTPUT, @v_error_desc OUTPUT 

                    EXEC dbo.TMM_SEESAW_CREATE_FILE @i_xmltype, @v_batchkey, @v_jobkey, @v_jobtypecode, @v_jobtypesubcode, 'TMMSEESAW', @i_location, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                    SET @v_create_file_retcode = @v_retcode

                    SET @v_messagetypecode = 6

                    /*  Job Finished */

                    EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @v_jobtypecode, @v_jobtypesubcode, '', '', 'TMMSEESAW', 0, 0, 0, @v_messagetypecode, 'Create File Process Completed', 'Create File Process Completed', @v_retcode OUTPUT, @v_error_desc OUTPUT 


                    IF (@v_create_file_retcode < 0)
                      GOTO finished

                  END

              END

            finished:

            /*  job completed message */

            SET @v_jobkey = @v_mainprocess_jobkey

            /*  Job already started */

            SET @v_jobtypesubcode = 1

            /*  Main Process */

            SET @v_messagetypecode = 6

            /*  tableid 539 - job completed */

            EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @v_jobtypecode, @v_jobtypesubcode, 'TMM to SeeSaw Feed', 'SeeSaw Feed', 'TMMSEESAW', 0, 0, 0, @v_messagetypecode, 'TMM to SeeSaw Feed Completed', 'TMM to SeeSaw Feed Copmleted', @v_retcode OUTPUT, @v_error_desc OUTPUT 
 END
go
grant execute on tmm_seesaw_main  to public
go

