IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'feed_in_vista_bookmisc_calc')
BEGIN
  DROP  Procedure  feed_in_vista_bookmisc_calc
END
GO

  CREATE 
    PROCEDURE dbo.feed_in_vista_bookmisc_calc 
        @i_bookkey integer
    AS
      BEGIN
          DECLARE 
            @udpatesqlstring varchar(8000),
            @sqlstring varchar(8000),
            @i_count integer,
            @cursor_row1$MISCKEY integer,
            @cursor_row1$CALCSQL varchar(8000)          
          BEGIN
            BEGIN

              DECLARE 
                @cursor_row1$MISCKEY$2 integer,
                @cursor_row1$CALCSQL$2 varchar(8000),
		@i_ret integer              

              DECLARE 
                bookmisccalcs CURSOR LOCAL 
                 FOR 
                  SELECT c.MISCKEY, c.CALCSQL
                    FROM dbo.BOOKORGENTRY o, dbo.MISCITEMCALC c
                    WHERE ((o.ORGLEVELKEY = c.ORGLEVELKEY) AND 
                            (o.ORGENTRYKEY = c.ORGENTRYKEY) AND 
                            (o.ORGLEVELKEY IN (1, 2 )) AND 
                            (o.BOOKKEY = @i_bookkey))              

              OPEN bookmisccalcs

              FETCH NEXT FROM bookmisccalcs
                INTO @cursor_row1$MISCKEY$2, @cursor_row1$CALCSQL$2

              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  IF (@@FETCH_STATUS = -1)
                    BREAK 

                  SELECT @i_count = count( * )
                    FROM dbo.BOOKMISC
                    WHERE ((dbo.BOOKMISC.BOOKKEY = @i_bookkey) AND 
                            (dbo.BOOKMISC.MISCKEY = @cursor_row1$MISCKEY$2))

                  IF (@i_count = 0)
                    INSERT INTO dbo.BOOKMISC
                      (dbo.BOOKMISC.BOOKKEY, dbo.BOOKMISC.MISCKEY)
                      VALUES (@i_bookkey, @cursor_row1$MISCKEY$2)

                  SELECT @udpatesqlstring = @cursor_row1$CALCSQL$2

                  SET @sqlstring = N'UPDATE bookmisc t1 SET floatvalue = (' + isnull(@udpatesqlstring, '') + ' t2 where t1.bookkey = t2.bookkey) ' + ', lastuserid = ''qsibookmisccalc'', lastmaintdate = sysdate ' + ' WHERE t1.misckey = ' + isnull(CAST( @cursor_row1$MISCKEY$2 AS varchar(20)), '') + ' and t1.bookkey = ' + isnull(CAST( @i_bookkey AS varchar(20)), '')

  		  execute sp_executesql  @sqlstring

                  FETCH NEXT FROM bookmisccalcs
                    INTO @cursor_row1$MISCKEY$2, @cursor_row1$CALCSQL$2

                END

              CLOSE bookmisccalcs

              DEALLOCATE bookmisccalcs

            END
          END
      END
go
grant execute on feed_in_vista_bookmisc_calc  to public
go
