IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'dw_bookmisc_full_run')
BEGIN
  DROP  Procedure  dw_bookmisc_full_run
END
GO

  CREATE 
    PROCEDURE dbo.dw_bookmisc_full_run 
    AS
      BEGIN
          DECLARE 
            @ware_system_date datetime,
            @cursor_row$BOOKKEY integer          
          BEGIN

            SELECT @ware_system_date = getdate()

            DELETE FROM dbo.WHBOOKMISC

            BEGIN

              DECLARE 
                @cursor_row$BOOKKEY$2 integer              

              DECLARE 
                dw_bookmisc_full CURSOR LOCAL 
                 FOR 
                  SELECT DISTINCT bu.BOOKKEY
                    FROM dbo.BOOKMISC b, dbo.BOOK bu
                    WHERE ((bu.BOOKKEY = b.BOOKKEY) AND 
                            (bu.STANDARDIND <> 'Y'))
              

              OPEN dw_bookmisc_full

              FETCH NEXT FROM dw_bookmisc_full
                INTO @cursor_row$BOOKKEY$2



              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN
                  EXEC dbo.DATAWAREHOUSE_BOOKMISC @cursor_row$BOOKKEY$2, 'WARE_STORED_PROC', @ware_system_date 
                  FETCH NEXT FROM dw_bookmisc_full
                    INTO @cursor_row$BOOKKEY$2
                END

              CLOSE dw_bookmisc_full

              DEALLOCATE dw_bookmisc_full

            END

            IF (cursor_status(N'local', N'dw_bookmisc_full') = 1)
              BEGIN
                CLOSE dw_bookmisc_full
                DEALLOCATE dw_bookmisc_full
              END

            /* insert all rows from whtitleinfo not already in whbookmisc */

            INSERT INTO dbo.WHBOOKMISC
              (dbo.WHBOOKMISC.BOOKKEY, dbo.WHBOOKMISC.LASTUSERID, dbo.WHBOOKMISC.LASTMAINTDATE)
              SELECT w.BOOKKEY, w.LASTUSERID, @ware_system_date
                FROM dbo.WHTITLEINFO w
                WHERE  NOT( EXISTS
                            ( 
                              SELECT b.BOOKKEY
                                FROM dbo.WHBOOKMISC b
                                WHERE (b.BOOKKEY = w.BOOKKEY)
                            ))

          END
      END
go
grant execute on dw_bookmisc_full_run  to public
go
