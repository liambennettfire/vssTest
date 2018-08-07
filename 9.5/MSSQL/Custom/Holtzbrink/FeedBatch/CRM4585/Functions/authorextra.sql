
IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.AUTHOREXTRA') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION dbo.AUTHOREXTRA
GO
  CREATE 
    FUNCTION dbo.AUTHOREXTRA 
      (
        @ware_authorkey integer,
        @ware_whichvalue integer
      ) 
      RETURNS varchar(8000)
    AS
      BEGIN

        DECLARE 
          @ware_authorstring varchar(2000)        

        BEGIN
            DECLARE 
              @cursor_row$FIRSTNAME varchar(8000),
              @cursor_row$LASTNAME varchar(8000),
              @cursor_row$AUTHORSUFFIX varchar(8000),
              @cursor_row$TITLE varchar(8000),
              @cursor_row$CORPORATECONTRIBUTORIND integer,
              @cursor_row$MIDDLENAME varchar(8000),
              @cursor_row$AUTHORDEGREE varchar(8000),
              @ware_author varchar(100)            
            SET @ware_author = ''
            BEGIN

              IF (@ware_whichvalue = 1)
                BEGIN
                  /* accredation */
                  BEGIN

                    DECLARE 
                      @cursor_row$FIRSTNAME$2 varchar(8000),
                      @cursor_row$LASTNAME$2 varchar(8000),
                      @cursor_row$AUTHORSUFFIX$2 varchar(8000),
                      @cursor_row$TITLE$2 varchar(8000),
                      @cursor_row$CORPORATECONTRIBUTORIND$2 integer,
                      @cursor_row$MIDDLENAME$2 varchar(8000),
                      @cursor_row$AUTHORDEGREE$2 varchar(8000)                    

                    DECLARE 
                      whauthorextra CURSOR LOCAL 
                       FOR 
                        SELECT 
                            isnull(AUTHOR.FIRSTNAME, ''), 
                            isnull(AUTHOR.LASTNAME , ''),
                            isnull(AUTHOR.AUTHORSUFFIX , '') ,
                            isnull(AUTHOR.TITLE , ''),
                            isnull(AUTHOR.CORPORATECONTRIBUTORIND, 0),
                            isnull(AUTHOR.MIDDLENAME , ''), 
                            isnull(AUTHOR.AUTHORDEGREE , '')
                          FROM dbo.AUTHOR
                          WHERE (dbo.AUTHOR.AUTHORKEY = @ware_authorkey)
                    

                    OPEN whauthorextra

                    FETCH NEXT FROM whauthorextra
                      INTO 
                        @cursor_row$FIRSTNAME$2, 
                        @cursor_row$LASTNAME$2, 
                        @cursor_row$AUTHORSUFFIX$2, 
                        @cursor_row$TITLE$2, 
                        @cursor_row$CORPORATECONTRIBUTORIND$2, 
                        @cursor_row$MIDDLENAME$2, 
                        @cursor_row$AUTHORDEGREE$2



                    WHILE  NOT(@@FETCH_STATUS = -1)
                      BEGIN

                        IF (@@FETCH_STATUS = -1)
                          BREAK 

                        IF len(rtrim(ltrim(@cursor_row$TITLE$2))) > 0
                          BEGIN
                            SET @ware_authorstring = (rtrim(ltrim(@cursor_row$TITLE$2)))
                            BREAK 
                          END
                        ELSE 
                          BEGIN
                            SET @ware_authorstring =  NULL
                            BREAK 
                          END

                        FETCH NEXT FROM whauthorextra
                          INTO 
                            @cursor_row$FIRSTNAME$2, 
                            @cursor_row$LASTNAME$2, 
                            @cursor_row$AUTHORSUFFIX$2, 
                            @cursor_row$TITLE$2, 
                            @cursor_row$CORPORATECONTRIBUTORIND$2, 
                            @cursor_row$MIDDLENAME$2, 
                            @cursor_row$AUTHORDEGREE$2

                      END

                    CLOSE whauthorextra

                    DEALLOCATE whauthorextra

                  END
                END

              IF (@ware_whichvalue = 2)
                BEGIN
                  /* suffix */
                  BEGIN

                    DECLARE 
                      @cursor_row$FIRSTNAME$3 varchar(8000),
                      @cursor_row$LASTNAME$3 varchar(8000),
                      @cursor_row$AUTHORSUFFIX$3 varchar(8000),
                      @cursor_row$TITLE$3 varchar(8000),
                      @cursor_row$CORPORATECONTRIBUTORIND$3 integer,
                      @cursor_row$MIDDLENAME$3 varchar(8000),
                      @cursor_row$AUTHORDEGREE$3 varchar(8000)                    

                    DECLARE 
                      whauthorextra CURSOR LOCAL 
                       FOR 
                        SELECT 
                            isnull(AUTHOR.FIRSTNAME, ''),
                            isnull(AUTHOR.LASTNAME, ''),
                            isnull(AUTHOR.AUTHORSUFFIX, ''),
                            isnull(AUTHOR.TITLE, ''),
                            isnull(AUTHOR.CORPORATECONTRIBUTORIND, 0), 
                            isnull(AUTHOR.MIDDLENAME, ''),
                            isnull(AUTHOR.AUTHORDEGREE, '')
                          FROM dbo.AUTHOR
                          WHERE (dbo.AUTHOR.AUTHORKEY = @ware_authorkey)
                    

                    OPEN whauthorextra

                    FETCH NEXT FROM whauthorextra
                      INTO 
                        @cursor_row$FIRSTNAME$3, 
                        @cursor_row$LASTNAME$3, 
                        @cursor_row$AUTHORSUFFIX$3, 
                        @cursor_row$TITLE$3, 
                        @cursor_row$CORPORATECONTRIBUTORIND$3, 
                        @cursor_row$MIDDLENAME$3, 
                        @cursor_row$AUTHORDEGREE$3


               
                    WHILE  NOT(@@FETCH_STATUS = -1)
                      BEGIN

                        IF (@@FETCH_STATUS = -1)
                          BREAK 

                        IF len(rtrim(ltrim(@cursor_row$AUTHORSUFFIX$3))) > 0
                          BEGIN
                            SET @ware_authorstring = rtrim(ltrim(@cursor_row$AUTHORSUFFIX$3))
                            BREAK 
                          END
                        ELSE 
                          BEGIN
                            SET @ware_authorstring =  NULL
                            BREAK 
                          END

                        FETCH NEXT FROM whauthorextra
                          INTO 
                            @cursor_row$FIRSTNAME$3, 
                            @cursor_row$LASTNAME$3, 
                            @cursor_row$AUTHORSUFFIX$3, 
                            @cursor_row$TITLE$3, 
                            @cursor_row$CORPORATECONTRIBUTORIND$3, 
                            @cursor_row$MIDDLENAME$3, 
                            @cursor_row$AUTHORDEGREE$3

                      END

                    CLOSE whauthorextra

                    DEALLOCATE whauthorextra

                  END
                END

              IF (@ware_whichvalue = 3)
                BEGIN
                  /* degree */
                  BEGIN

                    DECLARE 
                      @cursor_row$FIRSTNAME$4 varchar(8000),
                      @cursor_row$LASTNAME$4 varchar(8000),
                      @cursor_row$AUTHORSUFFIX$4 varchar(8000),
                      @cursor_row$TITLE$4 varchar(8000),
                      @cursor_row$CORPORATECONTRIBUTORIND$4 integer,
                      @cursor_row$MIDDLENAME$4 varchar(8000),
                      @cursor_row$AUTHORDEGREE$4 varchar(8000)                    

                    DECLARE 
                      whauthorextra CURSOR LOCAL 
                       FOR 
                        SELECT 
                            isnull(AUTHOR.FIRSTNAME, ''),
                            isnull(AUTHOR.LASTNAME, ''),
                            isnull(AUTHOR.AUTHORSUFFIX, ''),
                            isnull(AUTHOR.TITLE, ''),
                            isnull(AUTHOR.CORPORATECONTRIBUTORIND, 0),
                            isnull(AUTHOR.MIDDLENAME, ''),
                            isnull(AUTHOR.AUTHORDEGREE, '')
                          FROM dbo.AUTHOR
                          WHERE (dbo.AUTHOR.AUTHORKEY = @ware_authorkey)
                    

                    OPEN whauthorextra

                    FETCH NEXT FROM whauthorextra
                      INTO 
                        @cursor_row$FIRSTNAME$4, 
                        @cursor_row$LASTNAME$4, 
                        @cursor_row$AUTHORSUFFIX$4, 
                        @cursor_row$TITLE$4, 
                        @cursor_row$CORPORATECONTRIBUTORIND$4, 
                        @cursor_row$MIDDLENAME$4, 
                        @cursor_row$AUTHORDEGREE$4


                    WHILE  NOT(@@FETCH_STATUS = -1)
                      BEGIN

                        IF (@@FETCH_STATUS = -1)
                          BREAK 

                        IF len(rtrim(ltrim(@cursor_row$AUTHORDEGREE$4))) > 0
                          BEGIN
                            SET @ware_authorstring = rtrim(ltrim(@cursor_row$AUTHORDEGREE$4))
                            BREAK 
                          END
                        ELSE 
                          BEGIN
                            SET @ware_authorstring =  NULL
                            BREAK 
                          END

                        FETCH NEXT FROM whauthorextra
                          INTO 
                            @cursor_row$FIRSTNAME$4, 
                            @cursor_row$LASTNAME$4, 
                            @cursor_row$AUTHORSUFFIX$4, 
                            @cursor_row$TITLE$4, 
                            @cursor_row$CORPORATECONTRIBUTORIND$4, 
                            @cursor_row$MIDDLENAME$4, 
                            @cursor_row$AUTHORDEGREE$4

                      END

                    CLOSE whauthorextra

                    DEALLOCATE whauthorextra

                  END
                END

              IF (@ware_whichvalue = 4)
                BEGIN

                  /* complete name */

                  BEGIN

                    DECLARE 
                      @cursor_row$FIRSTNAME$5 varchar(8000),
                      @cursor_row$LASTNAME$5 varchar(8000),
                      @cursor_row$AUTHORSUFFIX$5 varchar(8000),
                      @cursor_row$TITLE$5 varchar(8000),
                      @cursor_row$CORPORATECONTRIBUTORIND$5 integer,
                      @cursor_row$MIDDLENAME$5 varchar(8000),
                      @cursor_row$AUTHORDEGREE$5 varchar(8000)                    

                    DECLARE 
                      whauthorextra CURSOR LOCAL 
                       FOR 
                        SELECT 
                            isnull(AUTHOR.FIRSTNAME, ''),
                            isnull(AUTHOR.LASTNAME, ''),
                            isnull(AUTHOR.AUTHORSUFFIX, ''),
                            isnull(AUTHOR.TITLE, ''),
                            isnull(AUTHOR.CORPORATECONTRIBUTORIND, 0),
                            isnull(AUTHOR.MIDDLENAME, ''),
                            isnull(AUTHOR.AUTHORDEGREE, '')
                          FROM dbo.AUTHOR
                          WHERE (dbo.AUTHOR.AUTHORKEY = @ware_authorkey)
                    

                    OPEN whauthorextra

                    FETCH NEXT FROM whauthorextra
                      INTO 
                        @cursor_row$FIRSTNAME$5, 
                        @cursor_row$LASTNAME$5, 
                        @cursor_row$AUTHORSUFFIX$5, 
                        @cursor_row$TITLE$5, 
                        @cursor_row$CORPORATECONTRIBUTORIND$5, 
                        @cursor_row$MIDDLENAME$5, 
                        @cursor_row$AUTHORDEGREE$5



                    WHILE  NOT(@@FETCH_STATUS = -1)
                      BEGIN

                        IF (@@FETCH_STATUS = -1)
                          BREAK 

                        IF (@cursor_row$CORPORATECONTRIBUTORIND$5 = 1)
                          IF len(rtrim(ltrim(@cursor_row$LASTNAME$5))) > 0
                            SET @ware_authorstring = @cursor_row$LASTNAME$5
                        ELSE 
                          BEGIN

                            IF len(rtrim(ltrim(@cursor_row$TITLE$5))) > 0
                              SET @ware_author = rtrim(ltrim(@cursor_row$TITLE$5))
                            ELSE 
                              SET @ware_author = ''

                            IF len(@ware_author) > 0
                              SET @ware_authorstring = isnull(@ware_author, '')
                            ELSE 
                              SET @ware_authorstring = ''

                            IF len(rtrim(ltrim(@cursor_row$FIRSTNAME$5))) > 0
                              IF len(@ware_authorstring) > 0
                                SET @ware_authorstring = isnull(@ware_authorstring, '') + isnull(rtrim(ltrim(@cursor_row$FIRSTNAME$5)), '')
                              ELSE 
                                SET @ware_authorstring = isnull(rtrim(ltrim(@cursor_row$FIRSTNAME$5)), '')

                            IF len(rtrim(ltrim(@cursor_row$MIDDLENAME$5))) > 0
                              IF len(@ware_authorstring) > 0
                                SET @ware_authorstring = isnull(@ware_authorstring, '') + isnull(rtrim(ltrim(@cursor_row$MIDDLENAME$5)), '')
                              ELSE 
                                SET @ware_authorstring = isnull(rtrim(ltrim(@cursor_row$MIDDLENAME$5)), '')

                            IF len(rtrim(ltrim(@cursor_row$LASTNAME$5))) > 0
                              IF len(@ware_authorstring) > 0
                                SET @ware_authorstring = isnull(@ware_authorstring, '') + isnull(rtrim(ltrim(@cursor_row$LASTNAME$5)), '')
                              ELSE 
                                SET @ware_authorstring = isnull(rtrim(ltrim(@cursor_row$LASTNAME$5)), '')

                            IF len(rtrim(ltrim(@cursor_row$AUTHORSUFFIX$5))) > 0
                              IF len(@ware_authorstring) > 0
                                SET @ware_authorstring = isnull(@ware_authorstring, '') + isnull(rtrim(ltrim(@cursor_row$AUTHORSUFFIX$5)), '')
                              ELSE 
                                SET @ware_authorstring = isnull(rtrim(ltrim(@cursor_row$AUTHORSUFFIX$5)), '')

                            IF len(rtrim(ltrim(@cursor_row$AUTHORDEGREE$5))) > 0
                              IF len(@ware_authorstring) > 0
                                SET @ware_authorstring = isnull(@ware_authorstring, '') + isnull(rtrim(ltrim(@cursor_row$AUTHORDEGREE$5)), '')                             
			      ELSE 
                                SET @ware_authorstring = rtrim(ltrim(@cursor_row$AUTHORDEGREE$5))

                          END

                        FETCH NEXT FROM whauthorextra
                          INTO 
                            @cursor_row$FIRSTNAME$5, 
                            @cursor_row$LASTNAME$5, 
                            @cursor_row$AUTHORSUFFIX$5, 
                            @cursor_row$TITLE$5, 
                            @cursor_row$CORPORATECONTRIBUTORIND$5, 
                            @cursor_row$MIDDLENAME$5, 
                            @cursor_row$AUTHORDEGREE$5

                      END

                    CLOSE whauthorextra

                    DEALLOCATE whauthorextra

                  END

                  SET @ware_authorstring = rtrim(ltrim(@ware_authorstring))

                  SET @ware_authorstring = rtrim(ltrim(@ware_authorstring))

                  SET @ware_authorstring = rtrim(ltrim(@ware_authorstring))

                  SET @ware_authorstring = rtrim(ltrim(@ware_authorstring))

                END

              RETURN @ware_authorstring

            END
        END


        RETURN null
      END

go
GRANT EXEC ON dbo.AUTHOREXTRA TO public
GO




