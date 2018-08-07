IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_additional_subjects')
BEGIN
  DROP  Procedure  onix21_additional_subjects
END
GO

  CREATE 
    PROCEDURE dbo.onix21_additional_subjects 
        @i_bookkey integer,
        @i_printingkey integer,
        @i_batchkey integer,
        @i_jobkey integer,
        @i_tableid integer,
        @i_subjectschemeid varchar(100),
        @i_subjectschemename varchar(100),
        @i_userid varchar(500),
        @o_xml text OUTPUT ,
        @o_error_code integer OUTPUT ,
        @o_error_desc varchar(255) OUTPUT 
    AS
      BEGIN
          DECLARE 
            @v_xml varchar(max),
            @v_count integer,
            @v_retcode integer,
            @v_error_desc varchar(2000),
            @v_subject varchar(25),
            @v_subjectdesc varchar(120),
            @v_subjectdescshort varchar(20),
            @v_msg varchar(4000),
            @v_msgshort varchar(255),
            @v_messagetypecode integer,
            @v_jobkey integer,
            @v_batchkey integer,
            @v_record_separator varchar(2),
            @return_sys_err_code integer,
            @return_nodata_err_code integer,
            @return_no_err_code integer,
            @return_onixcode_notfound integer,
            @return_missing_data integer,
            @cursor_row$CATEGORYCODE integer,
            @cursor_row$CATEGORYSUBCODE integer,
            @cursor_row$CATEGORYSUB2CODE integer,
            @cursor_row$SUBJECT_LONGDESC varchar(200),
            @cursor_row$SUBJECT_SHORTDESC varchar(200),
            @cursor_row$SUBSUBJECT_LONGDESC varchar(200),
            @cursor_row$SUBSUBJECT_SHORTDESC varchar(200)          
          SET @v_xml = ''
          SET @v_record_separator = char(13) + char(10)
          SET @return_sys_err_code =  -1
          SET @return_nodata_err_code = 0
          SET @return_no_err_code = 1
          SET @return_onixcode_notfound =  -99
          SET @return_missing_data =  -97

            SET @o_error_code = @return_no_err_code
            SET @o_error_desc = ''
            SET @o_xml = ''
            SET @v_jobkey = @i_jobkey
            SET @v_batchkey = @i_batchkey

            IF (upper(@i_subjectschemeid) = '24')
              BEGIN
                /*  subject scheme name is required for proprietary subject scheme */
                IF @i_subjectschemename  = Null
                  BEGIN
                    SET @o_error_code = @return_missing_data
                    SET @o_error_desc = 'Subject Scheme Name is required for a Proprietary Subject Scheme.'
                    RETURN 
                  END
              END

            BEGIN

              DECLARE 
                @cursor_row$CATEGORYCODE$2 integer,
                @cursor_row$CATEGORYSUBCODE$2 integer,
                @cursor_row$CATEGORYSUB2CODE$2 integer,
                @cursor_row$SUBJECT_LONGDESC$2 varchar(8000),
                @cursor_row$SUBJECT_SHORTDESC$2 varchar(8000),
                @cursor_row$SUBSUBJECT_LONGDESC$2 varchar(8000),
                @cursor_row$SUBSUBJECT_SHORTDESC$2 varchar(8000)              

              DECLARE 
                subject_cursor CURSOR LOCAL 
	
                 FOR 
                  SELECT 
                      c.CATEGORYCODE, 
                      c.CATEGORYSUBCODE, 
                      c.CATEGORYSUB2CODE, 
                      dbo.REPLACE_XCHARS(dbo.GENTABLES_LONGDESC_FUNCTION(c.CATEGORYTABLEID, c.CATEGORYCODE)) AS SUBJECT_LONGDESC, 
                      dbo.REPLACE_XCHARS(dbo.GENTABLES_SHORTDESC_FUNCTION(c.CATEGORYTABLEID, c.CATEGORYCODE)) AS SUBJECT_SHORTDESC, 
                      dbo.REPLACE_XCHARS(dbo.SUBGENT_LONGDESC_FUNCTION(c.CATEGORYTABLEID, c.CATEGORYCODE, c.CATEGORYSUBCODE)) AS SUBSUBJECT_LONGDESC, 
                      dbo.REPLACE_XCHARS(dbo.SUBGENT_SHORTDESC_FUNCTION(c.CATEGORYTABLEID, c.CATEGORYCODE, c.CATEGORYSUBCODE)) AS SUBSUBJECT_SHORTDESC
                    FROM dbo.BOOKSUBJECTCATEGORY c
                    WHERE ((c.BOOKKEY = @i_bookkey) AND 
                            (c.CATEGORYTABLEID = @i_tableid))
                  ORDER BY c.SORTORDER
              

              OPEN subject_cursor

              FETCH NEXT FROM subject_cursor
                INTO 
                  @cursor_row$CATEGORYCODE$2, 
                  @cursor_row$CATEGORYSUBCODE$2, 
                  @cursor_row$CATEGORYSUB2CODE$2, 
                  @cursor_row$SUBJECT_LONGDESC$2, 
                  @cursor_row$SUBJECT_SHORTDESC$2, 
                  @cursor_row$SUBSUBJECT_LONGDESC$2, 
                  @cursor_row$SUBSUBJECT_SHORTDESC$2


              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN
                  IF (@@FETCH_STATUS = -1)
                    BEGIN
                      /*  return 0 */
                      SET @o_error_code = @return_nodata_err_code
                      SET @o_error_desc = ''
                      RETURN 
                    END

                  IF (@cursor_row$CATEGORYSUBCODE$2 > 0)
                    BEGIN
                      SET @v_subjectdesc = @cursor_row$SUBSUBJECT_LONGDESC$2
                      SET @v_subjectdescshort = @cursor_row$SUBSUBJECT_SHORTDESC$2
                    END
                  ELSE 
                    BEGIN
                      SET @v_subjectdesc = @cursor_row$SUBJECT_LONGDESC$2
                      SET @v_subjectdescshort = @cursor_row$SUBJECT_SHORTDESC$2
                    END

                  IF ((ISNULL((@v_subjectdesc + '.'), '.') <> '.') OR 
                          (ISNULL((@v_subjectdescshort + '.'), '.') <> '.'))
                    BEGIN
                      SET @v_xml = (isnull(@v_xml, '') + '<subject>')
                      SET @v_xml = (isnull(@v_xml, '') + '<b067>' + isnull(@i_subjectschemeid, '') + '</b067>')
                      SET @v_xml = (isnull(@v_xml, '') + '<b171>' + isnull(@i_subjectschemename, '') + '</b171>')
                      IF @v_subjectdescshort = null
                        SET @v_xml = (isnull(@v_xml, '') + '<b069><![CDATA[' + isnull(@v_subjectdescshort, '') + ']]></b069>')

                      IF @v_subjectdesc = NULL
                        SET @v_xml = (isnull(@v_xml, '') + '<b070><![CDATA[' + isnull(@v_subjectdesc, '') + ']]></b070>')

                      SET @v_xml = (isnull(@v_xml, '') + '</subject>' + isnull(@v_record_separator, ''))

                      SET @o_xml = @v_xml

                    END
                  ELSE 
                    IF (@v_jobkey > 0)
                      BEGIN

                        SET @v_msg = ('Subject Description not found for tableid ' + isnull(CAST( @i_tableid AS varchar(100)), '') + ' and datacode ' + isnull(CAST( @cursor_row$CATEGORYCODE$2 AS varchar(8000)), '') + ' and datasubcode ' + isnull(CAST( isnull(@cursor_row$CATEGORYSUBCODE$2, 0) AS varchar(100)), ''))

                        SET @v_msgshort = 'Subject Description not found'

                        SET @v_messagetypecode = 3

                        /*  Warning */

                        EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 0, 0, '', '', @i_userid, @i_bookkey, @i_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                      END

                  FETCH NEXT FROM subject_cursor
                    INTO 
                      @cursor_row$CATEGORYCODE$2, 
                      @cursor_row$CATEGORYSUBCODE$2, 
                      @cursor_row$CATEGORYSUB2CODE$2, 
                      @cursor_row$SUBJECT_LONGDESC$2, 
                      @cursor_row$SUBJECT_SHORTDESC$2, 
                      @cursor_row$SUBSUBJECT_LONGDESC$2, 
                      @cursor_row$SUBSUBJECT_SHORTDESC$2

                END

              CLOSE subject_cursor

              DEALLOCATE subject_cursor

            END

      END

go
grant execute on onix21_additional_subjects  to public
go


