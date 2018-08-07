IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'tmm_seesaw_maintain_xml_onix21')
BEGIN
  DROP  Procedure  tmm_seesaw_maintain_xml_onix21
END
GO

  CREATE 
    PROCEDURE dbo.tmm_seesaw_maintain_xml_onix21 
        @i_bookkey integer,
        @i_printingkey integer,
        @i_xmltype integer,
        @i_batchkey integer,
        @i_jobkey integer,
        @i_jobtypecode integer,
        @i_jobtypesubcode integer,
        @i_userid varchar(100),
        @o_error_code integer OUTPUT ,
        @o_error_desc varchar(255) OUTPUT 
    AS
      BEGIN
          DECLARE 
            @v_xml varchar(max),
            @v_product_xml varchar(max),
            @v_batchkey integer,
            @v_jobkey integer,
            @v_count integer,
            @v_msg varchar(4000),
            @v_msgshort varchar(255),
            @v_messagetypecode integer,
            @v_retcode integer,
            @v_error_desc varchar(2000),
            @v_pricetypecode integer,
            @v_currencytypecode integer,
            @v_commenttypecode integer,
            @v_commenttypesubcode integer,
            @v_qsicode_gentables integer,
            @v_qsicode_subgentables integer,
            @v_firstone_only integer,
            @v_filterkey integer,
            @v_orglevelkey integer,
            @v_tableid integer,
            @v_schemeid varchar(5),
            @v_schemename varchar(25),
            @return_sys_err_code integer,
            @return_nodata_err_code integer,
            @return_no_err_code integer,
            @first_warning_code integer          

          SET @v_xml = ''
          SET @v_product_xml = ''
          SET @return_sys_err_code =  -1
          SET @return_nodata_err_code = 0
          SET @return_no_err_code = 1
          SET @first_warning_code =  -90
          SET @v_batchkey = @i_batchkey
          SET @v_jobkey = @i_jobkey

            IF ((@i_bookkey IS NULL) OR 
                    (@i_bookkey <= 0))
              BEGIN

                /*  bookkey is required */
                SET @o_error_code = 0
                SET @o_error_desc = ''
                SET @v_msg = 'Invalid Bookkey'
                SET @v_msgshort = 'Invalid Bookkey'
                SET @v_messagetypecode = 2

                /*  Error */
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, 0, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 
              END

            SET @o_error_code = @return_no_err_code
            SET @o_error_desc = ''

            /* ***************************************** */
            /*  Output the beginning Product tag for this book  */
            /* ***************************************** */

            SET @v_product_xml = '<product>'

            /* ***************************************** */
            /*  Output RecordReference - unique product number - we will use bookkey  */
            /* ***************************************** */

            SET @v_product_xml = (isnull(@v_product_xml, '') + '<a001>' + isnull(CAST( @i_bookkey AS varchar(100)), '') + '</a001>')

            /* ***************************************** */
            /*  Output NotificationType - set to '03' for confirmed book  */
            /* ***************************************** */

            SET @v_product_xml = (isnull(@v_product_xml, '') + '<a002>03</a002>')

            /* ***************************************** */
            /*  EAN (stripped)                           */
            /* ***************************************** */

            EXEC dbo.ONIX21_EAN_NODASHES @i_bookkey, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
            IF (@v_retcode < 0)
              BEGIN
                SET @v_msg = @v_error_desc
                SET @v_msgshort = @v_error_desc
                SET @v_messagetypecode = 2
                /*  Error */
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 
              END

            IF (@v_retcode = 0)
              BEGIN
                /*  no data found */
                SET @v_msg = 'EAN not found'
                SET @v_msgshort = 'EAN not found'
                SET @v_messagetypecode = 2
                /*  Error */
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 
              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  ISBN 10 (stripped)                       */
            /* ***************************************** */

            SET @v_xml = ''
            EXEC dbo.ONIX21_ISBN10 @i_bookkey, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
            IF (@v_retcode < 0)
              BEGIN
                SET @v_msg = @v_error_desc
                SET @v_msgshort = @v_error_desc
                SET @v_messagetypecode = 2
                /*  Error */
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 
              END

            IF (@v_retcode = 0)
              BEGIN
                /*  no data found */
                SET @v_msg = 'ISBN10 not found'
                SET @v_msgshort = 'ISBN10 not found'
                SET @v_messagetypecode = 2

                /*  Error */
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 
              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Title Composite                          */
            /* ***************************************** */

            SET @v_xml = ''
            EXEC dbo.ONIX21_TITLE @i_bookkey, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
            IF (@v_retcode < 0)
              BEGIN
                SET @v_msg = @v_error_desc
                SET @v_msgshort = @v_error_desc
                SET @v_messagetypecode = 2

               /*  Error */
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 
              END
            IF (@v_retcode = 0)
              BEGIN
                /*  no data found */
                SET @v_msg = 'Title not found'
                SET @v_msgshort = 'Title not found'
                SET @v_messagetypecode = 2
                /*  Error */
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 
              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Short Title Composite                    */
            /* ***************************************** */
            SET @v_xml = ''
            EXEC dbo.ONIX21_SHORT_TITLE @i_bookkey, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
            IF (@v_retcode < 0)
              BEGIN
                SET @v_msg = @v_error_desc
                SET @v_msgshort = @v_error_desc
                SET @v_messagetypecode = 2
                /*  Error */
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 
              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Product Format                           */
            /* ***************************************** */

            SET @v_xml = ''

            EXEC dbo.ONIX21_FORMAT @i_bookkey, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
            IF (@v_retcode < 0)
              BEGIN
                SET @v_msg = @v_error_desc
                SET @v_msgshort = @v_error_desc
                IF (@v_retcode <= @first_warning_code)
                  SET @v_messagetypecode = 3
                ELSE 
                  SET @v_messagetypecode = 2

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                IF (@v_messagetypecode = 2)
                  BEGIN
                    /*  error */
                    RETURN 
                  END

              END

            IF (@v_retcode = 0)
              BEGIN

                /*  no data found */
                IF @v_error_desc IS NOT NULL AND @v_error_desc <> ''
                  BEGIN
                    SET @v_msg = @v_error_desc
                    SET @v_msgshort = @v_error_desc
                  END
                ELSE 
                  BEGIN
                    SET @v_msg = 'Format not found'
                    SET @v_msgshort = 'Format not found'
                  END

                SET @v_messagetypecode = 3

                /*  Warning */
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Author                                   */
            /* ***************************************** */

            SET @v_xml = ''
            EXEC dbo.ONIX21_AUTHOR @i_bookkey, @v_batchkey, @v_jobkey, @i_userid, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
            IF (@v_retcode < 0)
              BEGIN
                SET @v_msg = @v_error_desc
                SET @v_msgshort = @v_error_desc
                SET @v_messagetypecode = 2

                /*  Error */
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Edition Desc show errors;                      */
            /* ***************************************** */
            SET @v_xml = ''
            EXEC dbo.ONIX21_EDITION_TYPE @i_bookkey, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
            IF (@v_retcode < 0)
              BEGIN
                SET @v_msg = @v_error_desc
                SET @v_msgshort = @v_error_desc
                IF (@v_retcode <= @first_warning_code)
                  SET @v_messagetypecode = 3
                ELSE 
                  SET @v_messagetypecode = 2
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                IF (@v_messagetypecode = 2)
                  BEGIN
                    /*  error */
                    RETURN 
                  END
              END

            IF ((@v_retcode >= 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Edition Number                           */
            /* ***************************************** */

            SET @v_xml = ''
            EXEC dbo.ONIX21_EDITION_NUMBER @i_bookkey, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN
                SET @v_msg = @v_error_desc
                SET @v_msgshort = @v_error_desc
                IF (@v_retcode <= @first_warning_code)
                  SET @v_messagetypecode = 3
                ELSE 
                  SET @v_messagetypecode = 2

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                IF (@v_messagetypecode = 2)
                  BEGIN
                    /*  Error */
                    RETURN 
                  END

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Copyright Year                           */
            /* ***************************************** */

            SET @v_xml = ''
            EXEC dbo.ONIX21_COPYRIGHTYEAR @i_bookkey, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN
                SET @v_msg = @v_error_desc
                SET @v_msgshort = @v_error_desc
                SET @v_messagetypecode = 2
                /*  Error */
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 
              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Series                                   */
            /* ***************************************** */
            SET @v_xml = ''
            EXEC dbo.ONIX21_SERIES @i_bookkey, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
            IF (@v_retcode < 0)
              BEGIN
                SET @v_msg = @v_error_desc
                SET @v_msgshort = @v_error_desc
                SET @v_messagetypecode = 2
                /*  Error */
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 
              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  US List Price                            */
            /* ***************************************** */
            SET @v_xml = ''
            SET @v_pricetypecode = 11

            /*  List Price */
            SET @v_currencytypecode = 6

            /*  US Dollars */
            EXEC dbo.ONIX21_PRICE @i_bookkey, @v_pricetypecode, @v_currencytypecode, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN
                SET @v_msg = @v_error_desc
                SET @v_msgshort = @v_error_desc
                IF (@v_retcode <= @first_warning_code)
                  SET @v_messagetypecode = 3
                ELSE 
                  SET @v_messagetypecode = 2
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                IF (@v_messagetypecode = 2)
                  BEGIN
                    /*  Error */
                    RETURN 
                  END
              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  US Net Price                             */
            /* ***************************************** */

            SET @v_xml = ''
            SET @v_pricetypecode = 9

            /*  Net Price */
            SET @v_currencytypecode = 6

            /*  US Dollars */
            EXEC dbo.ONIX21_PRICE @i_bookkey, @v_pricetypecode, @v_currencytypecode, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN
                SET @v_msg = @v_error_desc
                SET @v_msgshort = @v_error_desc
                IF (@v_retcode <= @first_warning_code)
                  SET @v_messagetypecode = 3
                ELSE 
                  SET @v_messagetypecode = 2

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                IF (@v_messagetypecode = 2)
                  BEGIN
                    /*  Error */
                    RETURN 
                  END
              END
            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Pub Date                                 */
            /* ***************************************** */
            SET @v_xml = ''
            EXEC dbo.ONIX21_PUBDATE @i_bookkey, @i_printingkey, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
            IF (@v_retcode < 0)
              BEGIN
                SET @v_msg = @v_error_desc
                SET @v_msgshort = @v_error_desc
                SET @v_messagetypecode = 2
                /*  Error */
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 
              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Audience                                 */
            /* ***************************************** */
            SET @v_xml = ''
            EXEC dbo.ONIX21_AUDIENCE @i_bookkey, @v_batchkey, @v_jobkey, @i_userid, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
            IF (@v_retcode < 0)
              BEGIN
                SET @v_msg = @v_error_desc
                SET @v_msgshort = @v_error_desc
                SET @v_messagetypecode = 2
                /*  Error */
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 
              END
            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  BISAC Subject Categories                 */
            /* ***************************************** */

            SET @v_xml = ''
            EXEC dbo.ONIX21_BISAC_SUBJECTS @i_bookkey, @i_printingkey, @v_batchkey, @v_jobkey, @i_userid, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
            IF (@v_retcode < 0)
              BEGIN
                SET @v_msg = @v_error_desc
                SET @v_msgshort = @v_error_desc
                SET @v_messagetypecode = 2
                /*  Error */
                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Palgrave Classification Subjects         */
            /* ***************************************** */

            SET @v_xml = ''
            SET @v_tableid = 432
            SET @v_schemeid = '24'
            SET @v_schemename = 'MM'
            EXEC dbo.ONIX21_ADDITIONAL_SUBJECTS @i_bookkey, @i_printingkey, @v_batchkey, @v_jobkey, @v_tableid, @v_schemeid, @v_schemename, @i_userid, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
            IF (@v_retcode < 0)
              BEGIN
                SET @v_msg = @v_error_desc
                SET @v_msgshort = @v_error_desc
                IF (@v_retcode <= @first_warning_code)
                  SET @v_messagetypecode = 3
                ELSE 
                  SET @v_messagetypecode = 2

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                IF (@v_messagetypecode = 2)
                  BEGIN
                    /*  Error */
                    RETURN 
                  END

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Palgrave Vista Subjects                  */
            /* ***************************************** */

            SET @v_xml = ''

            SET @v_tableid = 435

            SET @v_schemeid = '24'

            SET @v_schemename = 'PGVISTASUBJECT'

            EXEC dbo.ONIX21_ADDITIONAL_SUBJECTS @i_bookkey, @i_printingkey, @v_batchkey, @v_jobkey, @v_tableid, @v_schemeid, @v_schemename, @i_userid, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                IF (@v_retcode <= @first_warning_code)
                  SET @v_messagetypecode = 3
                ELSE 
                  SET @v_messagetypecode = 2

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                IF (@v_messagetypecode = 2)
                  BEGIN
                    /*  Error */
                    RETURN 
                  END

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Imprint                                  */
            /* ***************************************** */

            SET @v_xml = ''

            SET @v_orglevelkey = 4

            /*  Public Imprint */

            EXEC dbo.ONIX21_IMPRINT @i_bookkey, @v_orglevelkey, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Publisher                                */
            /* ***************************************** */

            SET @v_xml = ''

            SET @v_filterkey = 18

            /*  Publisher */

            EXEC dbo.ONIX21_PUBLISHER @i_bookkey, @v_filterkey, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Number of Pages                          */
            /* ***************************************** */

            SET @v_xml = ''

            EXEC dbo.ONIX21_NUM_PAGES @i_bookkey, @i_printingkey, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Trim Size                                */
            /* ***************************************** */

            SET @v_xml = ''

            EXEC dbo.ONIX21_TRIM_SIZE @i_bookkey, @i_printingkey, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Book Weight                              */
            /* ***************************************** */

            SET @v_xml = ''

            EXEC dbo.ONIX21_BOOK_WEIGHT @i_bookkey, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Illustrations Note                       */
            /* ***************************************** */

            SET @v_xml = ''

            EXEC dbo.ONIX21_ILLUS_NOTE @i_bookkey, @i_printingkey, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Awards                                   */
            /* ***************************************** */

            SET @v_xml = ''

            EXEC dbo.ONIX21_PRIZE_AWARD @i_bookkey, @v_batchkey, @v_jobkey, @i_userid, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Website Info                             */
            /* ***************************************** */

            SET @v_xml = ''

            EXEC dbo.ONIX21_WEBSITE @i_bookkey, @i_printingkey, @v_batchkey, @v_jobkey, @i_userid, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Previous Edition ISBN                    */
            /* ***************************************** */

            SET @v_xml = ''

            SET @v_qsicode_gentables = 1

            SET @v_qsicode_subgentables = 1

            /*  Replaces */

            SET @v_firstone_only = 1

            /*  if there are multiple relationships, only process the first one */

            EXEC dbo.ONIX21_ASSOCIATED_TITLES @i_bookkey, @v_qsicode_gentables, @v_qsicode_subgentables, @v_firstone_only, @v_batchkey, @v_jobkey, @i_userid, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                IF (@v_retcode <= @first_warning_code)
                  SET @v_messagetypecode = 3
                ELSE 
                  SET @v_messagetypecode = 2

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                IF (@v_messagetypecode = 2)
                  BEGIN
                    /*  Error */
                    RETURN 
                  END

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Linked Titles                            */
            /* ***************************************** */

            SET @v_xml = ''

            EXEC dbo.ONIX21_LINKED_TITLES @i_bookkey, @v_batchkey, @v_jobkey, @i_userid, @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                IF (@v_retcode <= @first_warning_code)
                  SET @v_messagetypecode = 3
                ELSE 
                  SET @v_messagetypecode = 2

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                IF (@v_messagetypecode = 2)
                  BEGIN
                    /*  Error */
                    RETURN 
                  END

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ***************************************** */
            /*  Other Text - Book Comments               */
            /* ***************************************** */

            SET @v_xml = ''

            SET @v_commenttypecode = 3

            SET @v_commenttypesubcode = 1

            /*  Cat. Body Copy */

            EXEC dbo.ONIX21_BOOKCOMMENTS @i_bookkey, @i_printingkey, @v_commenttypecode, @v_commenttypesubcode, 'LITE', @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            SET @v_xml = ''

            SET @v_commenttypecode = 3

            SET @v_commenttypesubcode = 39

            /*  WWW Brief Description */

            EXEC dbo.ONIX21_BOOKCOMMENTS @i_bookkey, @i_printingkey, @v_commenttypecode, @v_commenttypesubcode, 'LITE', @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            SET @v_xml = ''

            SET @v_commenttypecode = 3

            SET @v_commenttypesubcode = 6

            /*  WWW Description */

            EXEC dbo.ONIX21_BOOKCOMMENTS @i_bookkey, @i_printingkey, @v_commenttypecode, @v_commenttypesubcode, 'LITE', @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            SET @v_xml = ''

            SET @v_commenttypecode = 3

            SET @v_commenttypesubcode = 20

            /*  Cat. Table of Contents */

            EXEC dbo.ONIX21_BOOKCOMMENTS @i_bookkey, @i_printingkey, @v_commenttypecode, @v_commenttypesubcode, 'LITE', @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            SET @v_xml = ''

            SET @v_commenttypecode = 3

            SET @v_commenttypesubcode = 40

            /*  WWW Quotes */

            EXEC dbo.ONIX21_BOOKCOMMENTS @i_bookkey, @i_printingkey, @v_commenttypecode, @v_commenttypesubcode, 'LITE', @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            SET @v_xml = ''

            SET @v_commenttypecode = 3

            SET @v_commenttypesubcode = 29

            /*  Cat. Author Info */

            EXEC dbo.ONIX21_BOOKCOMMENTS @i_bookkey, @i_printingkey, @v_commenttypecode, @v_commenttypesubcode, 'LITE', @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            SET @v_xml = ''

            SET @v_commenttypecode = 3

            SET @v_commenttypesubcode = 19

            /*  Tip Competiton */

            EXEC dbo.ONIX21_BOOKCOMMENTS @i_bookkey, @i_printingkey, @v_commenttypecode, @v_commenttypesubcode, 'LITE', @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            SET @v_xml = ''

            SET @v_commenttypecode = 3

            SET @v_commenttypesubcode = 3

            /*  WWW Back Panel Copy */

            EXEC dbo.ONIX21_BOOKCOMMENTS @i_bookkey, @i_printingkey, @v_commenttypecode, @v_commenttypesubcode, 'LITE', @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            SET @v_xml = ''

            SET @v_commenttypecode = 3

            SET @v_commenttypesubcode = 18

            /*  Tip Key Selling Points */

            EXEC dbo.ONIX21_BOOKCOMMENTS @i_bookkey, @i_printingkey, @v_commenttypecode, @v_commenttypesubcode, 'LITE', @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            SET @v_xml = ''

            SET @v_commenttypecode = 3

            SET @v_commenttypesubcode = 82

            /*  Cat. New To This Edition */

            EXEC dbo.ONIX21_BOOKCOMMENTS @i_bookkey, @i_printingkey, @v_commenttypecode, @v_commenttypesubcode, 'LITE', @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            SET @v_xml = ''

            SET @v_commenttypecode = 3

            SET @v_commenttypesubcode = 17

            /*  Cat. Key Note */

            EXEC dbo.ONIX21_BOOKCOMMENTS @i_bookkey, @i_printingkey, @v_commenttypecode, @v_commenttypesubcode, 'LITE', @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            SET @v_xml = ''

            SET @v_commenttypecode = 3

            SET @v_commenttypesubcode = 9

            /*  Lnch Audience */

            EXEC dbo.ONIX21_BOOKCOMMENTS @i_bookkey, @i_printingkey, @v_commenttypecode, @v_commenttypesubcode, 'LITE', @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            SET @v_xml = ''

            SET @v_commenttypecode = 3

            SET @v_commenttypesubcode = 86

            /*  Cat. Positioning Statement */

            EXEC dbo.ONIX21_BOOKCOMMENTS @i_bookkey, @i_printingkey, @v_commenttypecode, @v_commenttypesubcode, 'LITE', @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            SET @v_xml = ''

            SET @v_commenttypecode = 3

            SET @v_commenttypesubcode = 77

            /*  Cat. Features */

            EXEC dbo.ONIX21_BOOKCOMMENTS @i_bookkey, @i_printingkey, @v_commenttypecode, @v_commenttypesubcode, 'LITE', @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            SET @v_xml = ''

            SET @v_commenttypecode = 3

            SET @v_commenttypesubcode = 32

            /*  WWW Table of Contents */

            EXEC dbo.ONIX21_BOOKCOMMENTS @i_bookkey, @i_printingkey, @v_commenttypecode, @v_commenttypesubcode, 'LITE', @v_xml OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

            IF (@v_retcode < 0)
              BEGIN

                SET @v_msg = @v_error_desc

                SET @v_msgshort = @v_error_desc

                SET @v_messagetypecode = 2

                /*  Error */

                EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                RETURN 

              END

            IF ((@v_retcode > 0) AND 
                    (len(@v_xml) > 0))
              SET @v_product_xml = (isnull(@v_product_xml, '') + isnull(@v_xml, ''))

            /* ************************************* */

            /* * Output Product Group Ending Line  * */

            /* ************************************* */

            SET @v_product_xml = (isnull(@v_product_xml, '') + '</product>')

            /*  Write to qsiexport table */

            IF (len(@v_product_xml) > 0)
              BEGIN

                SELECT @v_count = count( * )
                  FROM dbo.QSIEXPORTXML
                  WHERE ((dbo.QSIEXPORTXML.QSIXMLTYPE = @i_xmltype) AND 
                          (dbo.QSIEXPORTXML.KEY1 = @i_bookkey) AND 
                          (dbo.QSIEXPORTXML.KEY2 = @i_printingkey))


                IF (@v_count = 0)
                  BEGIN

                    /*  insert initial data */

                    INSERT INTO dbo.QSIEXPORTXML
                      (
                        dbo.QSIEXPORTXML.QSIXMLTYPE, 
                        dbo.QSIEXPORTXML.KEY1, 
                        dbo.QSIEXPORTXML.KEY2, 
                        dbo.QSIEXPORTXML.KEY3, 
                        dbo.QSIEXPORTXML.VALIDXML, 
                        dbo.QSIEXPORTXML.ERRORXML, 
                        dbo.QSIEXPORTXML.INVALIDIND, 
                        dbo.QSIEXPORTXML.LASTUSERID, 
                        dbo.QSIEXPORTXML.LASTMAINTDATE
                      )
                      VALUES 
                        (
                          @i_xmltype, 
                          @i_bookkey, 
                          @i_printingkey, 
                          0, 
                           NULL, 
                           NULL, 
                          0, 
                          @i_userid, 
                          getdate()
                        )

                  END
	   END
      END
go
grant execute on tmm_seesaw_maintain_xml_onix21  to public
go

