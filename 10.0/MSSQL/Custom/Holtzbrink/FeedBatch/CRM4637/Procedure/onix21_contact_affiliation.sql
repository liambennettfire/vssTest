IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_contact_affiliation')
BEGIN
  DROP  Procedure  onix21_contact_affiliation
END
GO
  CREATE 
    PROCEDURE dbo.onix21_contact_affiliation 
        @i_contactkey integer,
        @i_batchkey integer,
        @i_jobkey integer,
        @i_userid varchar(100),
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
            @v_relationshipcode integer,
            @v_tableid integer,
            @v_onixcode varchar(30),
            @v_onixcodedefault integer,
            @v_msg varchar(4000),
            @v_msgshort varchar(255),
            @v_messagetypecode integer,
            @v_batchkey integer,
            @v_jobkey integer,
            @v_printingkey integer,
            @v_record_separator varchar(2),
            @return_sys_err_code integer,
            @return_nodata_err_code integer,
            @return_no_err_code integer,
            @return_onixcode_notfound integer,
            @cursor_row$CONTACTNUMBER integer,
            @cursor_row$THISCONTACTKEY integer,
            @cursor_row$OTHERCONTACTKEY integer,
            @cursor_row$THISCONTACTRELATIONSHIPDESC varchar(100),
            @cursor_row$OTHERCONTACTRELATIONSHIPDESC varchar(100),
            @cursor_row$OTHERCONTACTDISPLAYNAME varchar(100),
            @cursor_row$GLOBALCONTACTRELATIONSHIPKEY integer,
            @cursor_row$CONTACTRELATIONSHIPADDTLDESC varchar(100),
            @cursor_row$KEYIND integer          

          SET @v_xml = ''
          SET @v_tableid = 519
          SET @v_record_separator = char(13) + char(10)
          SET @return_sys_err_code =  -1
          SET @return_nodata_err_code = 0
          SET @return_no_err_code = 1
          SET @return_onixcode_notfound =  -99


            SET @o_error_code = @return_no_err_code
            SET @o_error_desc = ''
            SET @o_xml = ''
            SET @v_tableid = 519
            SET @v_jobkey = @i_jobkey
            SET @v_batchkey = @i_batchkey
            SET @v_printingkey = 1

            BEGIN
              DECLARE 
                @cursor_row$CONTACTNUMBER$2 integer,
                @cursor_row$THISCONTACTKEY$2 integer,
                @cursor_row$OTHERCONTACTKEY$2 integer,
                @cursor_row$THISCONTACTRELATIONSHIPDESC$2 varchar(8000),
                @cursor_row$OTHERCONTACTRELATIONSHIPDESC$2 varchar(8000),
                @cursor_row$OTHERCONTACTDISPLAYNAME$2 varchar(200),
                @cursor_row$GLOBALCONTACTRELATIONSHIPKEY$2 integer,
                @cursor_row$CONTACTRELATIONSHIPADDTLDESC$2 varchar(8000),
                @cursor_row$KEYIND$2 integer              

              DECLARE 
                affiliation_cursor CURSOR LOCAL 
                 FOR 
                  SELECT 
                      1 AS CONTACTNUMBER, 
                      r.GLOBALCONTACTKEY1 AS THISCONTACTKEY, 
                      r.GLOBALCONTACTKEY2 AS OTHERCONTACTKEY, 
                      dbo.GENTABLES_LONGDESC_FUNCTION(@v_tableid, r.CONTACTRELATIONSHIPCODE1) AS THISCONTACTRELATIONSHIPDESC, 
                      dbo.GENTABLES_LONGDESC_FUNCTION(@v_tableid, r.CONTACTRELATIONSHIPCODE2) AS OTHERCONTACTRELATIONSHIPDESC, 
                      isnull(c.displayname,r.globalcontactname2) AS OTHERCONTACTDISPLAYNAME, 
                      r.GLOBALCONTACTRELATIONSHIPKEY, 
                      r.CONTACTRELATIONSHIPADDTLDESC, 
                      r.KEYIND
                    FROM dbo.GLOBALCONTACTRELATIONSHIP r
                       LEFT JOIN dbo.GLOBALCONTACT c  ON (r.GLOBALCONTACTKEY2 = c.GLOBALCONTACTKEY)
                    WHERE ((r.GLOBALCONTACTKEY1 = @i_contactkey) AND 
                            (r.CONTACTRELATIONSHIPCODE1 IN
                                ( 
                                  SELECT dbo.GENTABLES.DATACODE
                                    FROM dbo.GENTABLES
                                    WHERE (dbo.GENTABLES.QSICODE = 1)
                                )))
                  UNION
                  SELECT 
                      2 AS CONTACTNUMBER, 
                      r.GLOBALCONTACTKEY2 AS THISCONTACTKEY, 
                      r.GLOBALCONTACTKEY1 AS OTHERCONTACTKEY, 
                      dbo.GENTABLES_LONGDESC_FUNCTION(@v_tableid, r.CONTACTRELATIONSHIPCODE2) AS THISCONTACTRELATIONSHIPDESC, 
                      dbo.GENTABLES_LONGDESC_FUNCTION(@v_tableid, r.CONTACTRELATIONSHIPCODE1) AS OTHERCONTACTRELATIONSHIPDESC, 
                      c.DISPLAYNAME AS OTHERCONTACTDISPLAYNAME, 
                      r.GLOBALCONTACTRELATIONSHIPKEY, 
                      r.CONTACTRELATIONSHIPADDTLDESC, 
                      r.KEYIND
                    FROM dbo.GLOBALCONTACTRELATIONSHIP r, dbo.GLOBALCONTACT c
                    WHERE ((r.GLOBALCONTACTKEY1 = c.GLOBALCONTACTKEY) AND 
                            (r.GLOBALCONTACTKEY2 > 0) AND 
                            (r.GLOBALCONTACTKEY2 = @i_contactkey) AND 
                            (r.CONTACTRELATIONSHIPCODE2 IN
                                ( 
                                  SELECT dbo.GENTABLES.DATACODE
                                    FROM dbo.GENTABLES
                                    WHERE (dbo.GENTABLES.QSICODE = 1)
                                )))
                  ORDER BY r.KEYIND DESC, thiscontactrelationshipdesc ASC, othercontactdisplayname ASC
              

              OPEN affiliation_cursor

              FETCH NEXT FROM affiliation_cursor
                INTO 
                  @cursor_row$CONTACTNUMBER$2, 
                  @cursor_row$THISCONTACTKEY$2, 
                  @cursor_row$OTHERCONTACTKEY$2, 
                  @cursor_row$THISCONTACTRELATIONSHIPDESC$2, 
                  @cursor_row$OTHERCONTACTRELATIONSHIPDESC$2, 
                  @cursor_row$OTHERCONTACTDISPLAYNAME$2, 
                  @cursor_row$GLOBALCONTACTRELATIONSHIPKEY$2, 
                  @cursor_row$CONTACTRELATIONSHIPADDTLDESC$2, 
                  @cursor_row$KEYIND$2

              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  IF (@@FETCH_STATUS = -1)
                    BEGIN

                      /*  return 0 */
                      SET @o_error_code = @return_nodata_err_code
                      SET @o_error_desc = ''
                      RETURN 
                    END

                  IF @cursor_row$THISCONTACTRELATIONSHIPDESC$2 IS NOT NULL
                    BEGIN

                      SET @v_xml = (isnull(@v_xml, '') + '<professionalaffiliation>')

                      /*  position */
                      SET @v_xml = (isnull(@v_xml, '') + '<b045><![CDATA[')
                      SET @v_xml = (isnull(@v_xml, '') + isnull(@cursor_row$THISCONTACTRELATIONSHIPDESC$2, ''))

                      IF @cursor_row$CONTACTRELATIONSHIPADDTLDESC$2  IS NOT NULL
                        SET @v_xml = (isnull(@v_xml, '') + ':' + isnull(@cursor_row$CONTACTRELATIONSHIPADDTLDESC$2, ''))

                      SET @v_xml = (isnull(@v_xml, '') + ']]></b045>')

                      /*  affiliation */

                      IF @cursor_row$OTHERCONTACTDISPLAYNAME$2  IS NOT NULL
                        SET @v_xml = (isnull(@v_xml, '') + '<b046><![CDATA[' + isnull(@cursor_row$OTHERCONTACTDISPLAYNAME$2, '') + ']]></b046>')

                      SET @v_xml = (isnull(@v_xml, '') + '</professionalaffiliation>' + isnull(@v_record_separator, ''))

                      SET @o_xml = @v_xml

                    END

                  FETCH NEXT FROM affiliation_cursor
                    INTO 
                      @cursor_row$CONTACTNUMBER$2, 
                      @cursor_row$THISCONTACTKEY$2, 
                      @cursor_row$OTHERCONTACTKEY$2, 
                      @cursor_row$THISCONTACTRELATIONSHIPDESC$2, 
                      @cursor_row$OTHERCONTACTRELATIONSHIPDESC$2, 
                      @cursor_row$OTHERCONTACTDISPLAYNAME$2, 
                      @cursor_row$GLOBALCONTACTRELATIONSHIPKEY$2, 
                      @cursor_row$CONTACTRELATIONSHIPADDTLDESC$2, 
                      @cursor_row$KEYIND$2

                END

              CLOSE affiliation_cursor

              DEALLOCATE affiliation_cursor

            END

            IF (cursor_status(N'local', N'affiliation_cursor') = 1)
              BEGIN
                CLOSE affiliation_cursor
                DEALLOCATE affiliation_cursor
              END

      END

go
grant execute on onix21_contact_affiliation  to public
go


