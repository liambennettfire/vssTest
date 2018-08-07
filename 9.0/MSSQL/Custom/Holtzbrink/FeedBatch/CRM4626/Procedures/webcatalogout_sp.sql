/*--*****    IMPORTANT ******
before you run this procedure make sure that script 
automation_procedures.sql and
sp_AppentToFile.sql
has been run.
That script will  enable Automation Procedures for object linking and embedding
AH - 4/6/07
*/

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'webcatalogout_sp')
BEGIN
  DROP  Procedure  webcatalogout_sp
END
GO

  CREATE 
    PROCEDURE dbo.webcatalogout_sp 
        @i_websitekey integer,
        @p_location varchar(200)
    AS
      BEGIN
          DECLARE 
            @i_websitecatalogkey numeric(10, 0),
            @c_websitecatalogdescription varchar(100),
            @i_sectionkey numeric(10, 0),
            @c_sectiondescription varchar(100),
            @i_bookkey numeric(10, 0),
            @c_title varchar(80),
            @c_titleprefix varchar(80),
            @i_catalogweightcode numeric(10, 0),
            @c_catalogweighttag varchar(25),
            @lv_firstsection integer,
            @lv_count integer,
            @lv_childcount integer,
            @c_sectiondescription2 varchar(100),
            @c_websitedesc varchar(100),
            @c_filename varchar(100),

            /*****
            *  WARNING ORA2MS-4016 line: 28 col: 16: Type UTL_FILE.FILE_TYPE of variable lv_file_id_num  was changed to char(100)
            *****/
            @lv_file_id_num char(100),
            @lv_output_string varchar(8000),
            @section_cursor_row$SECTIONKEY integer,
            @section_cursor_row$DESCRIPTION varchar(255),
            @section2_cursor_row$SECTIONKEY integer,
            @section2_cursor_row$DESCRIPTION varchar(255)          
          SET @lv_firstsection = 1
          SET @lv_count = 0
          SET @lv_childcount = 0
          SET @lv_output_string = ''
          BEGIN

            DELETE FROM WEBCATALOGXMLFEED


            SELECT @c_websitedesc = lower(WEBSITE.WEBSITEDESCLONG)
              FROM WEBSITE
              WHERE (WEBSITE.WEBSITEKEY = @i_websitekey)

            SET @c_filename = replace(@c_websitedesc, ' ', '')

            SET @c_filename = (isnull(@c_filename, '') + 'webcatalog.xml')

            /*  Open Output File  */
            set @c_filename = @p_location + '\' + @c_filename

            /* * Output Header Info * */

            /*  CRM 3589 PM 02/16/06 HBPUB - Replace Question Mark with ascii character code in web feeds */

            SET @lv_output_string = ('<' + isnull(char(63), '') + 'xml version="1.0"' + ' encoding="Windows-1252"' + isnull(char(63), '') + '>')
		
  	    execute  sp_AppendToFile @c_filename, @lv_output_string

            PRINT @lv_output_string

            SET @lv_output_string = '<!DOCTYPE Catalog SYSTEM "Catalog.dtd">'
	    
 	    execute  sp_AppendToFile @c_filename, @lv_output_string

            PRINT @lv_output_string

            SET @lv_output_string = '<Catalog>'
	 
            execute  sp_AppendToFile @c_filename, @lv_output_string

            PRINT @lv_output_string

            SELECT @i_websitecatalogkey = WEBSITE.WEBSITECATALOGKEY
              FROM WEBSITE
              WHERE (WEBSITE.WEBSITEKEY = 2)



            /* i_websitekey  3-30-01 need to change later when live */

            SELECT @c_websitecatalogdescription = [CATALOG].DESCRIPTION
              FROM [CATALOG]
              WHERE ([CATALOG].CATALOGKEY = @i_websitecatalogkey)


            SET @lv_output_string = ('<Description>' + isnull(@c_websitecatalogdescription, '') + '</Description>')

	    execute  sp_AppendToFile @c_filename, @lv_output_string

            PRINT @lv_output_string

            BEGIN

              DECLARE 
                @section_cursor_row$SECTIONKEY$2 integer,
                @section_cursor_row$DESCRIPTION$2 varchar(255)              

              DECLARE 
                section_cursor CURSOR LOCAL 
                 FOR 
                  SELECT CATALOGSECTION.SECTIONKEY, CATALOGSECTION.DESCRIPTION
                    FROM CATALOGSECTION
                    WHERE ((CATALOGSECTION.CATALOGKEY = @i_websitecatalogkey) AND 
                            ((CATALOGSECTION.PARENTSECTIONKEY IS NULL) OR 
                                    (CATALOGSECTION.PARENTSECTIONKEY = 0)))
                  ORDER BY CATALOGSECTION.STARTINGPAGENUMBER
              

              OPEN section_cursor

              FETCH NEXT FROM section_cursor
                INTO @section_cursor_row$SECTIONKEY$2, @section_cursor_row$DESCRIPTION$2

              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  SET @c_sectiondescription = ''

                  IF (@@ROWCOUNT = 0)
                    BEGIN

                      INSERT INTO FEEDERROR
                        (FEEDERROR.BATCHNUMBER, FEEDERROR.PROCESSDATE, FEEDERROR.ERRORDESC)
                        VALUES ('33', getdate(), ('NO ROWS on catalogsection for catalogkey ' + isnull(CAST( @i_websitecatalogkey AS varchar(50)), '')))

                      BREAK 

                    END

                  SET @i_sectionkey = @section_cursor_row$SECTIONKEY$2

                  SET @c_sectiondescription = replace(@section_cursor_row$DESCRIPTION$2, char(38), (isnull(char(38), '') + 'amp;'))

                  SET @c_sectiondescription = replace(@c_sectiondescription, '<', '<lt;')

                  SET @lv_count = 0

                  SET @lv_childcount = 0

                  SELECT @lv_count = count( * )
                    FROM BOOKCATALOG bc, BOOK b, BOOKDETAIL bd
                    WHERE ((bc.SECTIONKEY = @i_sectionkey) AND 
                            (b.BOOKKEY = bc.BOOKKEY) AND 
                            (bd.BOOKKEY = b.BOOKKEY))

                  /* * Added by DSL 6/11/01 to output parent sections * */

                  /* * if books exist for child sections. Modified if condition * */

                  /* * with 'or' to check lv_childcount              * */

                  SELECT @lv_childcount = count( * )
                    FROM BOOKCATALOG bc, CATALOGSECTION cs
                    WHERE ((cs.PARENTSECTIONKEY = @i_sectionkey) AND 
                            (bc.SECTIONKEY = cs.SECTIONKEY))

                  IF ((@lv_count > 0) OR 
                          (@lv_childcount > 0))
                    BEGIN

                      IF (@lv_firstsection = 1)
                        BEGIN

                          SET @lv_output_string = '<Section Selected="No" Display="Yes" FeaturedSection="Yes">'
		          
			  execute  sp_AppendToFile @c_filename, @lv_output_string

                          PRINT @lv_output_string

                          SET @lv_firstsection = 0

                        END
                      ELSE 
                        BEGIN

                          SET @lv_output_string = '<Section Selected="No" Display="Yes" FeaturedSection="No">'

			  execute  sp_AppendToFile @c_filename, @lv_output_string

                          PRINT @lv_output_string

                        END

                      SET @lv_output_string = ('<SectionKey>' + isnull(CAST( @i_sectionkey AS varchar(50)), '') + '</SectionKey>')

		      execute  sp_AppendToFile @c_filename, @lv_output_string

                      PRINT @lv_output_string

                      SET @lv_output_string = ('<Name>' + isnull(@c_sectiondescription, '') + '</Name>')

		      execute  sp_AppendToFile @c_filename, @lv_output_string

                      PRINT @lv_output_string

                      EXEC webcatalogout_book_sp @c_filename, @i_sectionkey 

                      BEGIN

                        DECLARE 
                          @section2_cursor_row$SECTIONKEY$2 integer,
                          @section2_cursor_row$DESCRIPTION$2 varchar(255)                        

                        DECLARE 
                          section2_cursor CURSOR LOCAL 
                           FOR 
                            SELECT CATALOGSECTION.SECTIONKEY, CATALOGSECTION.DESCRIPTION
                              FROM CATALOGSECTION
                              WHERE (CATALOGSECTION.PARENTSECTIONKEY = @i_sectionkey)
                            ORDER BY CATALOGSECTION.SORTORDER
                        

                        OPEN section2_cursor

                        FETCH NEXT FROM section2_cursor
                          INTO @section2_cursor_row$SECTIONKEY$2, @section2_cursor_row$DESCRIPTION$2

                        WHILE  NOT(@@FETCH_STATUS = -1)
                          BEGIN

                            SET @c_sectiondescription2 = ''

                            IF (@@ROWCOUNT = 0)
                              BREAK 

                            SET @i_sectionkey = @section2_cursor_row$SECTIONKEY$2

                            SET @c_sectiondescription2 = replace(@section2_cursor_row$DESCRIPTION$2, char(38), (isnull(char(38), '') + 'amp;'))

                            SET @c_sectiondescription2 = replace(@c_sectiondescription2, '<', '<lt;')

                            SET @lv_output_string = '<Section Selected="No" Display="Yes" FeaturedSection="No">'

			    execute  sp_AppendToFile @c_filename, @lv_output_string

                            PRINT @lv_output_string

                            SET @lv_output_string = ('<SectionKey>' + isnull(CAST( @i_sectionkey AS varchar(50)), '') + '</SectionKey>')

			    execute  sp_AppendToFile @c_filename, @lv_output_string

                            PRINT @lv_output_string

                            SET @lv_output_string = ('<Name>' + isnull(@c_sectiondescription2, '') + '</Name>')

			    execute  sp_AppendToFile @c_filename, @lv_output_string

                            PRINT @lv_output_string

                            SET @lv_count = 0

                            SELECT @lv_count = count( * )
                              FROM BOOKCATALOG bc, BOOK b, BOOKDETAIL bd
                              WHERE ((bc.SECTIONKEY = @i_sectionkey) AND 
                                      (b.BOOKKEY = bc.BOOKKEY) AND 
                                      (bd.BOOKKEY = b.BOOKKEY))


                            IF (@lv_count > 0)
                              EXEC webcatalogout_book_sp @c_filename, @i_sectionkey 

                            SET @lv_output_string = '</Section>'

                            execute  sp_AppendToFile @c_filename, @lv_output_string

                            PRINT @lv_output_string

                            FETCH NEXT FROM section2_cursor
                              INTO @section2_cursor_row$SECTIONKEY$2, @section2_cursor_row$DESCRIPTION$2

                          END

                        CLOSE section2_cursor

                        DEALLOCATE section2_cursor

                      END

                      SET @lv_output_string = '</Section>'

                      execute  sp_AppendToFile @c_filename, @lv_output_string

                      PRINT @lv_output_string

                    END

                  FETCH NEXT FROM section_cursor
                    INTO @section_cursor_row$SECTIONKEY$2, @section_cursor_row$DESCRIPTION$2

                END

              CLOSE section_cursor

              DEALLOCATE section_cursor

            END

            SET @lv_output_string = '</Catalog>'

            execute  sp_AppendToFile @c_filename, @lv_output_string

            PRINT @lv_output_string

            --EXEC SYSDB.SSMA.UTL_FILE_FCLOSE @lv_file_id_num 

            IF (cursor_status(N'local', N'section_cursor') = 1)
              BEGIN
                CLOSE section_cursor
                DEALLOCATE section_cursor
              END

            IF (cursor_status(N'local', N'section2_cursor') = 1)
              BEGIN
                CLOSE section2_cursor
                DEALLOCATE section2_cursor
              END

          END
      END
go
grant execute on webcatalogout_sp  to public
go

