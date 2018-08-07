/*--*****    IMPORTANT ******
before you run this procedure make sure that script 
automation_procedures.sql and
sp_AppentToFile.sql
has been run.
That script will  enable Automation Procedures for object linking and embedding
AH - 4/6/07
*/



IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'webcatalogout_book_sp')
BEGIN
  DROP  Procedure  webcatalogout_book_sp
END
GO

  CREATE 
    PROCEDURE dbo.webcatalogout_book_sp 
        @c_filename char(100),
        @i_sectionkey integer
    AS
      BEGIN
          DECLARE 
            @c_sectiondescription varchar(100),
            @i_bookkey integer,
            @c_title varchar(80),
            @c_titleprefix varchar(80),
            @i_catalogweightcode integer,
            @c_catalogweighttag varchar(25),
            @lv_firstsection integer,
            @lv_count integer,
            @lv_fieldtagcount integer,
            @c_sectiondescription2 varchar(100),
            @lv_output_string varchar(8000),
            @book_cursor_row$BOOKKEY integer,
            @book_cursor_row$TITLEPREFIX varchar(8000),
            @book_cursor_row$TITLE varchar(8000),
            @book_cursor_row$CATALOGWEIGHTCODE integer          
          SET @lv_firstsection = 1
          SET @lv_count = 0
          SET @lv_fieldtagcount = 0
          SET @lv_output_string = ''
          BEGIN
            BEGIN

              DECLARE 
                @book_cursor_row$BOOKKEY$2 integer,
                @book_cursor_row$TITLEPREFIX$2 varchar(255),
                @book_cursor_row$TITLE$2 varchar(8000),
                @book_cursor_row$CATALOGWEIGHTCODE$2 integer              

              DECLARE 
                book_cursor CURSOR LOCAL 
                 FOR 
                  SELECT 
                      b.BOOKKEY, 
                      bd.TITLEPREFIX, 
                      b.TITLE, 
                      bc.CATALOGWEIGHTCODE
                    FROM BOOKCATALOG bc, BOOK b, BOOKDETAIL bd
                    WHERE ((bc.SECTIONKEY = @i_sectionkey) AND 
                            (b.BOOKKEY = bc.BOOKKEY) AND 
                            (bd.BOOKKEY = b.BOOKKEY))
                  ORDER BY bc.SORTORDER
              

              OPEN book_cursor

              FETCH NEXT FROM book_cursor
                INTO 
                  @book_cursor_row$BOOKKEY$2, 
                  @book_cursor_row$TITLEPREFIX$2, 
                  @book_cursor_row$TITLE$2, 
                  @book_cursor_row$CATALOGWEIGHTCODE$2

              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  SET @i_bookkey = @book_cursor_row$BOOKKEY$2

                  SET @c_titleprefix = @book_cursor_row$TITLEPREFIX$2

                  SET @c_title = replace(@book_cursor_row$TITLE$2, char(38), (isnull(char(38), '') + 'amp;'))

                  SET @c_title = replace(@c_title, '<', '<lt;')

                  /* ** Select the eloquencefieldtag which will match the weight tag * */

                  /* * in the style sheet allowing flexibility of the display of titles * */

                  SET @c_catalogweighttag =  NULL

                  /* * MODIFIED BY DSL 7/24/01 and 8/21/01 - added a * */

                  /* * select count to verify that a row would be returned * */

                  /* * prior to running the select eloquencefieldtag to * */

                  /* * prevent a NO DATA FOUND error when catalogweight * */

                  /* * was NULL * */

                  SELECT @lv_fieldtagcount = count( * )
                    FROM GENTABLES
                    WHERE ((GENTABLES.TABLEID = 290) AND 
                            (GENTABLES.DATACODE = @book_cursor_row$CATALOGWEIGHTCODE$2))


                  IF (@lv_fieldtagcount > 0)
                    BEGIN
                      SELECT @c_catalogweighttag = GENTABLES.ELOQUENCEFIELDTAG
                        FROM GENTABLES
                        WHERE ((GENTABLES.TABLEID = 290) AND 
                                (GENTABLES.DATACODE = @book_cursor_row$CATALOGWEIGHTCODE$2))
                    END

                  IF (@c_catalogweighttag =  NULL)
                    SET @c_catalogweighttag = ''

                  IF (@c_catalogweighttag = '')
                    SET @c_catalogweighttag = '10'

                  IF (@c_catalogweighttag = 'WEBWEIGHT1')
                    SET @c_catalogweighttag = '1'
                  ELSE 
                    IF (@c_catalogweighttag = 'WEBWEIGHT2')
                      SET @c_catalogweighttag = '2'
                    ELSE 
                      IF (@c_catalogweighttag = 'WEBWEIGHT3')
                        SET @c_catalogweighttag = '3'
                      ELSE 
                        IF (@c_catalogweighttag = 'WEBWEIGHT4')
                          SET @c_catalogweighttag = '4'
                        ELSE 
                          IF (@c_catalogweighttag = 'WEBWEIGHT5')
                            SET @c_catalogweighttag = '5'
                          ELSE 
                            IF (@c_catalogweighttag = 'WEBWEIGHT6')
                              SET @c_catalogweighttag = '6'
                            ELSE 
                              IF (@c_catalogweighttag = 'WEBWEIGHT7')
                                SET @c_catalogweighttag = '7'
                              ELSE 
                                IF (@c_catalogweighttag = 'WEBWEIGHT8')
                                  SET @c_catalogweighttag = '8'
                                ELSE 
                                  IF (@c_catalogweighttag = 'WEBWEIGHT9')
                                    SET @c_catalogweighttag = '9'
                                  ELSE 
                                    IF (@c_catalogweighttag = 'WEBWEIGHT10')
                                      SET @c_catalogweighttag = '10'
                                    ELSE 
                                      SET @c_catalogweighttag = '10'

                  SET @lv_output_string = ('<Book Weight="' + isnull(@c_catalogweighttag, '') + '">')

                  execute  sp_AppendToFile @c_filename, @lv_output_string

                  PRINT @lv_output_string

                  SET @lv_output_string = ('<BookKey>' + isnull(CAST( @i_bookkey AS varchar(20)), '') + '</BookKey>')

                  execute  sp_AppendToFile @c_filename, @lv_output_string

                  PRINT @lv_output_string

                  SET @lv_output_string = ('<Title>' + isnull(@c_title, '') + '</Title>')

                  execute  sp_AppendToFile @c_filename, @lv_output_string

                  PRINT @lv_output_string

                  SET @lv_output_string = '</Book>'

                  execute  sp_AppendToFile @c_filename, @lv_output_string

                  PRINT @lv_output_string

                  FETCH NEXT FROM book_cursor
                    INTO 
                      @book_cursor_row$BOOKKEY$2, 
                      @book_cursor_row$TITLEPREFIX$2, 
                      @book_cursor_row$TITLE$2, 
                      @book_cursor_row$CATALOGWEIGHTCODE$2

                END

              CLOSE book_cursor

              DEALLOCATE book_cursor

            END
            IF (cursor_status(N'local', N'book_cursor') = 1)
              BEGIN
                CLOSE book_cursor
                DEALLOCATE book_cursor
              END
          END
      END
go
grant execute on webcatalogout_book_sp  to public
go

