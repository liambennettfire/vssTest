IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_author')
BEGIN
  DROP  Procedure  onix21_author
END
GO

  CREATE 
    PROCEDURE dbo.onix21_author 
        @i_bookkey integer,
        @i_batchkey integer,
        @i_jobkey integer,
        @i_userid varchar(50),
        @o_xml text OUTPUT ,
        @o_error_code integer OUTPUT ,
        @o_error_desc varchar(255) OUTPUT 
    AS
      BEGIN
          DECLARE 
            @v_xml varchar(max),
            @v_xml_temp varchar(max),
            @v_count integer,
            @v_retcode integer,
            @v_error_desc varchar(2000),
            @v_authortypecode integer,
            @v_tableid_authortype integer,
            @v_tableid_title integer,
            @v_onixcode varchar(30),
            @v_onixcodedefault integer,
            @v_msg varchar(4000),
            @v_msgshort varchar(255),
            @v_messagetypecode integer,
            @v_batchkey integer,
            @v_jobkey integer,
            @v_printingkey integer,
            @v_personname_inverted varchar(4000),
            @v_fullauthordisplayname varchar(255),
            @v_record_separator varchar(2),
            @return_sys_err_code integer,
            @return_nodata_err_code integer,
            @return_no_err_code integer,
            @return_onixcode_notfound integer,
            @cursor_row$AUTHORTYPECODE integer,
            @cursor_row$SORTORDER integer,
            @cursor_row$DISPLAYNAME varchar(100),
            @cursor_row$LASTNAME varchar(100),
            @cursor_row$FIRSTNAME varchar(100),
            @cursor_row$MIDDLENAME varchar(100),
            @cursor_row$ACCREDITATION varchar(100),
            @cursor_row$AUTHORKEY integer,
            @cursor_row$SUFFIX varchar(100),
            @cursor_row$DEGREE varchar(100),
            @cursor_row$GROUPNAME varchar(100),
            @cursor_row$GLOBALCONTACTKEY integer,
            @cursor_row$INDIVIDUALIND integer          
          SET @v_xml = ''
          SET @v_xml_temp = ''
          SET @v_tableid_authortype = 134
          SET @v_tableid_title = 210
          SET @v_personname_inverted = ''
          SET @v_record_separator = char(13) + char(10)
          SET @return_sys_err_code =  -1
          SET @return_nodata_err_code = 0
          SET @return_no_err_code = 1
          SET @return_onixcode_notfound =  -99

            SET @o_error_code = @return_no_err_code
            SET @o_error_desc = ''
            SET @o_xml = ''
            SET @v_jobkey = @i_jobkey
            SET @v_batchkey = @i_batchkey
            SET @v_printingkey = 1
            SET @v_xml = ''
            BEGIN
              DECLARE 
                @cursor_row$AUTHORTYPECODE$2 integer,
                @cursor_row$SORTORDER$2 integer,
                @cursor_row$DISPLAYNAME$2 varchar(100),
                @cursor_row$LASTNAME$2 varchar(100),
                @cursor_row$FIRSTNAME$2 varchar(100),
                @cursor_row$MIDDLENAME$2 varchar(100),
                @cursor_row$ACCREDITATION$2 varchar(100),
                @cursor_row$AUTHORKEY$2 integer,
                @cursor_row$SUFFIX$2 varchar(100),
                @cursor_row$DEGREE$2 varchar(100),
                @cursor_row$GROUPNAME$2 varchar(100),
                @cursor_row$GLOBALCONTACTKEY$2 integer,
                @cursor_row$INDIVIDUALIND$2 integer              

              DECLARE 
                author_cursor CURSOR LOCAL 
                 FOR 
                  SELECT 
                      isnull(ba.AUTHORTYPECODE, 0) AS AUTHORTYPECODE, 
                      isnull(ba.SORTORDER, 1) AS SORTORDER, 
                      g.DISPLAYNAME, 
                      g.LASTNAME, 
                      isnull(g.FIRSTNAME, '') AS FIRSTNAME, 
                      isnull(g.MIDDLENAME, '') AS MIDDLENAME, 
                      dbo.GENTABLES_LONGDESC_FUNCTION(@v_tableid_title, g.ACCREDITATIONCODE) AS ACCREDITATION, 
                      ba.AUTHORKEY, 
                      g.SUFFIX, 
                      g.DEGREE, 
                      g.GROUPNAME, 
                      g.GLOBALCONTACTKEY, 
                      isnull(g.INDIVIDUALIND, 1) AS INDIVIDUALIND
                    FROM dbo.BOOKAUTHOR ba, dbo.GLOBALCONTACT g
                    WHERE ((ba.AUTHORKEY = g.GLOBALCONTACTKEY) AND 
                            (ba.BOOKKEY = @i_bookkey))
                  ORDER BY ba.SORTORDER
              

              OPEN author_cursor

              FETCH NEXT FROM author_cursor
                INTO 
                  @cursor_row$AUTHORTYPECODE$2, 
                  @cursor_row$SORTORDER$2, 
                  @cursor_row$DISPLAYNAME$2, 
                  @cursor_row$LASTNAME$2, 
                  @cursor_row$FIRSTNAME$2, 
                  @cursor_row$MIDDLENAME$2, 
                  @cursor_row$ACCREDITATION$2, 
                  @cursor_row$AUTHORKEY$2, 
                  @cursor_row$SUFFIX$2, 
                  @cursor_row$DEGREE$2, 
                  @cursor_row$GROUPNAME$2, 
                  @cursor_row$GLOBALCONTACTKEY$2, 
                  @cursor_row$INDIVIDUALIND$2

              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN
                  IF (@@FETCH_STATUS = -1)
                    BEGIN

                     /*  return 0 */
                      SET @o_error_code = @return_nodata_err_code
                      SET @o_error_desc = ''
                      RETURN 
                    END
                  SET @v_authortypecode = @cursor_row$AUTHORTYPECODE$2
                  SET @v_personname_inverted = ''
                  IF (@v_authortypecode > 0)
                    BEGIN
                      EXEC dbo.GET_ONIXCODE_GENTABLES @v_tableid_authortype, @v_authortypecode, @v_onixcode OUTPUT, @v_onixcodedefault OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                      IF (@v_retcode <= 0)
                        BEGIN
                          /*  error or not found */
                          SET @o_error_code = @v_retcode
                          SET @o_error_desc = @v_error_desc
                          RETURN 
                        END

                      IF @v_onixcode IS NOT NULL
                        BEGIN
                         SET @v_xml = (isnull(@v_xml, '') + '<contributor>')

                          /*  Contributor Sequence Number */
                          SET @v_xml = (isnull(@v_xml, '') + '<b034>' + isnull(CAST( @cursor_row$SORTORDER$2 AS varchar(100)), '') + '</b034>')

                          /*  Contributor Role */
                          SET @v_xml = (isnull(@v_xml, '') + '<b035>' + isnull(@v_onixcode, '') + '</b035>')

                          IF (@cursor_row$INDIVIDUALIND$2 = 1)
                            BEGIN
                              /*  Not a corporate contributor */
                              IF @cursor_row$LASTNAME$2 IS NOT NULL
                                BEGIN

                                  /*  Person Name Inverted */
                                  SET @v_personname_inverted = (isnull(@v_personname_inverted, '') + isnull(@cursor_row$LASTNAME$2, ''))
                                  IF @cursor_row$FIRSTNAME$2 IS NOT NULL
                                    BEGIN
                                      SET @v_personname_inverted = isnull(@v_personname_inverted, '') + ', ' + isnull(@cursor_row$FIRSTNAME$2, '')
                                      IF @cursor_row$MIDDLENAME$2 IS NOT NULL
                                        SET @v_personname_inverted = isnull(@v_personname_inverted, '') + ' ' + isnull(@cursor_row$MIDDLENAME$2, '')
                                    END

                                  IF @cursor_row$SUFFIX$2 IS NOT NULL OR @cursor_row$DEGREE$2 IS NOT NULL
                                    BEGIN
                                      SET @v_personname_inverted = (isnull(@v_personname_inverted, '') + ', ')

                                      IF @cursor_row$SUFFIX$2 IS NOT NULL
                                        SET @v_personname_inverted = (isnull(@v_personname_inverted, '') + isnull(@cursor_row$SUFFIX$2, ''))

                                      IF @cursor_row$DEGREE$2 IS NOT NULL
                                        SET @v_personname_inverted = (isnull(@v_personname_inverted, '') + isnull(@cursor_row$DEGREE$2, ''))

                                    END

                                  SET @v_xml = (isnull(@v_xml, '') + '<b037><![CDATA[' + isnull(@v_personname_inverted, '') + ']]></b037>')

                                  /*  titles before name */

                                  IF (ISNULL((@cursor_row$ACCREDITATION$2 + '.'), '.') <> '.')
                                    SET @v_xml = (isnull(@v_xml, '') + '<b038><![CDATA[' + isnull(@cursor_row$ACCREDITATION$2, '') + ']]></b038>')

                                  /*  names before key names */

                                  IF @cursor_row$FIRSTNAME$2 IS NOT NULL
                                    IF @cursor_row$MIDDLENAME$2 IS NOT NULL
                                      SET @v_xml = (isnull(@v_xml, '') + '<b039><![CDATA[' + isnull(@cursor_row$FIRSTNAME$2, '') + ' ' + isnull(@cursor_row$MIDDLENAME$2, '') + ']]></b039>')
                                    ELSE 
                                      SET @v_xml = (isnull(@v_xml, '') + '<b039><![CDATA[' + isnull(@cursor_row$FIRSTNAME$2, '') + ']]></b039>')

                                  /*  keyname */

                                  SET @v_xml = (isnull(@v_xml, '') + '<b040><![CDATA[' + isnull(@cursor_row$LASTNAME$2, '') + ']]></b040>')

                                  /*  suffix */

                                  IF @cursor_row$SUFFIX$2 IS NOT NULL
                                    SET @v_xml = (isnull(@v_xml, '') + '<b248><![CDATA[' + isnull(@cursor_row$SUFFIX$2, '') + ']]></b248>')

                                  /*  qualifications and honors */

                                  IF @cursor_row$DEGREE$2 IS NOT NULL
                                    SET @v_xml = (isnull(@v_xml, '') + '<b042><![CDATA[' + isnull(@cursor_row$DEGREE$2, '') + ']]></b042>')

                                  /*  Affiliations */

                                  SET @v_xml_temp = ''

                                  EXEC dbo.ONIX21_CONTACT_AFFILIATION @cursor_row$AUTHORKEY$2, @v_batchkey, @v_jobkey, @i_userid, @v_xml_temp OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                                  IF (@v_retcode < 0)
                                    BEGIN
                                      SET @v_msg = @v_error_desc
                                      SET @v_msgshort = @v_error_desc
                                      SET @v_messagetypecode = 2

                                      /*  Error */
                                      EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 0, 0, '', '', @i_userid, @i_bookkey, 1, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                                      RETURN 
                                    END

                                  IF ((@v_retcode > 0) AND 
                                          (len(@v_xml_temp) > 0))
                                    SET @v_xml = (isnull(@v_xml, '') + isnull(@v_xml_temp, ''))

                                END
                              ELSE 
                                IF (@v_jobkey > 0)
                                  BEGIN

                                    SET @v_msg = ('Last Name is required (globalcontactkey = ' + isnull(CAST( @cursor_row$AUTHORKEY$2 AS varchar(100)), '') + ')')
                                    SET @v_msgshort = 'Last Name is required'
                                    SET @v_messagetypecode = 3

                                   /*  Warning */
                                    EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 0, 0, '', '', @i_userid, @i_bookkey, 1, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                                  END
                            END
                          ELSE 
                            IF @cursor_row$GROUPNAME$2 IS NOT NULL
                              BEGIN
                                /*  corporate contributor name */
                                SET @v_xml = (isnull(@v_xml, '') + '<b047><![CDATA[' + isnull(@cursor_row$GROUPNAME$2, '') + ']]></b047>')
                              END
                            ELSE 
                              IF (@v_jobkey > 0)
                                BEGIN
                                  SET @v_msg = ('Group Name is required (globalcontactkey = ' + isnull(CAST( @cursor_row$AUTHORKEY$2 AS varchar(100)), '') + ')')
                                  SET @v_msgshort = 'Last Name is required'
                                  SET @v_messagetypecode = 3

                                 /*  Warning */
                                  EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 0, 0, '', '', @i_userid, @i_bookkey, 1, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                                END

                          SET @v_xml = (isnull(@v_xml, '') + '</contributor>' + isnull(@v_record_separator, ''))

                          SET @o_xml = @v_xml

                        END
                      ELSE 
                        IF (@v_jobkey > 0)
                          BEGIN

                            SET @v_msg = ('Onixcode not found for tableid ' + isnull(CAST( @v_tableid_authortype AS varchar(100)), '') + ' and datacode ' + isnull(CAST( @v_authortypecode AS varchar(100)), ''))

                            SET @v_msgshort = 'Onixcode not found'

                            SET @v_messagetypecode = 3

                            /*  Warning */

                            EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, 0, 0, '', '', @i_userid, @i_bookkey, 1, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                          END

                    END

                  FETCH NEXT FROM author_cursor
                    INTO 
                      @cursor_row$AUTHORTYPECODE$2, 
                      @cursor_row$SORTORDER$2, 
                      @cursor_row$DISPLAYNAME$2, 
                      @cursor_row$LASTNAME$2, 
                      @cursor_row$FIRSTNAME$2, 
                      @cursor_row$MIDDLENAME$2, 
                      @cursor_row$ACCREDITATION$2, 
                      @cursor_row$AUTHORKEY$2, 
                      @cursor_row$SUFFIX$2, 
                      @cursor_row$DEGREE$2, 
                      @cursor_row$GROUPNAME$2, 
                      @cursor_row$GLOBALCONTACTKEY$2, 
                      @cursor_row$INDIVIDUALIND$2

                END

              CLOSE author_cursor

              DEALLOCATE author_cursor

            END

            /*  Contributor Statement */

            SELECT @v_fullauthordisplayname = dbo.REPLACE_XCHARS(dbo.BOOKDETAIL.FULLAUTHORDISPLAYNAME)
              FROM dbo.BOOKDETAIL
              WHERE (dbo.BOOKDETAIL.BOOKKEY = @i_bookkey)

            IF @v_fullauthordisplayname IS NOT NULL
              BEGIN
                SET @v_xml = (isnull(@v_xml, '') + '<b049><![CDATA[' + isnull(@v_fullauthordisplayname, '') + ']]></b049>')
                SET @o_xml = @v_xml
              END

      END
go
grant execute on onix21_author  to public
go


