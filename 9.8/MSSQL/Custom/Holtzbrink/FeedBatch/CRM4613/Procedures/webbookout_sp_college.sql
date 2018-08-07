/*--*****    IMPORTANT ******
before you run this procedure make sure that script 
automation_procedures.sql and
sp_AppentToFile.sql
has been run.
That script will  enable Automation Procedures for object linking and embedding
AH - 4/6/07
*/



IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'webbookout_sp_college')
BEGIN
  DROP  Procedure  webbookout_sp_college
END
GO
  CREATE 
    PROCEDURE dbo.webbookout_sp_college 
        @i_onixlevel integer,
        @p_location varchar(3000),
        @i_websitekey integer
    AS
      BEGIN
          DECLARE 
            @cursor_row$BOOKKEY integer,
            @lv_count numeric(10, 0),
            @i_bookkey numeric(10, 0),
            @c_currentdate varchar(10),
            @d_currentdate datetime,
            @i_book_cursor_status numeric(3, 0),
            @c_websitecatalogdescription varchar(100),
            @lv_file_id_num integer,
            @lv_output_string varchar(8000),
	    @FileName varchar(255)
          SET @lv_output_string = ''
          BEGIN

            SELECT @c_websitecatalogdescription = lower(WEBSITE.WEBSITEDESCLONG)
              FROM WEBSITE
              WHERE (WEBSITE.WEBSITEKEY = @i_websitekey)

            SET @FileName = replace(@c_websitecatalogdescription, ' ', '')

            SET @FileName = (isnull(@FileName, '') + 'webbook.xml')

 	    set @FileName = @p_location + '\' + @FileName

            /*  Open Output File  */

           -- EXEC SYSDB.SSMA.UTL_FILE_FOPEN$IMPL @p_location, @c_filename, 'W', 32000, @lv_file_id_num OUTPUT 

            /*  Truncate the output table in preparation for new feed; can't truncate in oracle stored proc.  */

            DELETE FROM WEBBOOKXMLFEED

            IF (@@TRANCOUNT > 0)
                COMMIT WORK

            SELECT @lv_count = count( * )
              FROM WEBBOOKKEYS

            /*  Create Header Information for Onix Feed  */

            /*  CRM 3589 PM 02/16/06 HBPUB - Replace Question Mark with ascii character code in web feeds */

            SET @lv_output_string = ('<' + isnull(char(63), '') + 'xml version="1.0"' + ' encoding="Windows-1252"' + isnull(char(63), '') + '>')

           -- EXEC SYSDB.SSMA.UTL_FILE_PUT_LINE @lv_file_id_num, @lv_output_string 
	   execute  sp_AppendToFile @FileName, @lv_output_string 

            PRINT @lv_output_string

            SET @lv_output_string = '<CollegeProducts>'

            --EXEC SYSDB.SSMA.UTL_FILE_PUT_LINE @lv_file_id_num, @lv_output_string 
	    execute  sp_AppendToFile @FileName, @lv_output_string 

            PRINT @lv_output_string

            BEGIN

              DECLARE 
                @cursor_row$BOOKKEY$2 integer              

              DECLARE 
                book_cursor CURSOR LOCAL 
                 FOR 
                  SELECT o.BOOKKEY
                    FROM BOOKORGENTRY o, BOOKDETAIL d, BOOK b
                    WHERE ((o.BOOKKEY = d.BOOKKEY) AND 
                            (o.BOOKKEY = b.BOOKKEY) AND 
                            (b.STANDARDIND <> 'Y') AND 
                            (o.ORGLEVELKEY = 1) AND 
                            (o.ORGENTRYKEY = 1485))
              

              OPEN book_cursor

              FETCH NEXT FROM book_cursor
                INTO @cursor_row$BOOKKEY$2

              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  IF (@@ROWCOUNT = 0)
                    BEGIN

                      INSERT INTO FEEDERROR
                        (FEEDERROR.BATCHNUMBER, FEEDERROR.PROCESSDATE, FEEDERROR.ERRORDESC)
                        VALUES ('32', getdate(), 'NO ROWS on webbookkeys')

                      IF (@@TRANCOUNT > 0)
                          COMMIT WORK

                      BREAK 

                    END

                  EXEC WEBBOOKDETAIL_SP_COLLEGE @cursor_row$BOOKKEY$2, @i_onixlevel, @lv_file_id_num, @i_websitekey 

                  FETCH NEXT FROM book_cursor
                    INTO @cursor_row$BOOKKEY$2

                END

              CLOSE book_cursor

              DEALLOCATE book_cursor

            END

            SET @lv_output_string = '</CollegeProducts>'

            --EXEC SYSDB.SSMA.UTL_FILE_PUT_LINE @lv_file_id_num, @lv_output_string 
	    execute  sp_AppendToFile @FileName, @lv_output_string 

            PRINT @lv_output_string

            --EXEC SYSDB.SSMA.UTL_FILE_FCLOSE @lv_file_id_num 

            IF (cursor_status(N'local', N'book_cursor') = 1)
              BEGIN
                CLOSE book_cursor
                DEALLOCATE book_cursor
              END

          END
      END
go
grant execute on webbookout_sp_college  to public
go
