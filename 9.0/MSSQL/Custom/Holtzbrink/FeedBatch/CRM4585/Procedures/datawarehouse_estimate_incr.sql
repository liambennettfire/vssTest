IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'datawarehouse_estimate_incr')
BEGIN
  DROP  Procedure  datawarehouse_estimate_incr
END
GO

  CREATE 
    PROCEDURE dbo.datawarehouse_estimate_incr 
        @ware_logkey integer,
        @ware_warehousekey integer,
        @ware_system_date datetime
    AS
      BEGIN
          DECLARE 
            @cursor_row$BOOKKEY integer,
            @cursor_row$PRINTINGKEY integer,
            @cursor_row$ESTKEY integer,
            @v_incr_date datetime,
            @ware_count integer,
            @ware_company varchar(20),
            @ware_bookkey integer,
            @ware_printingkey integer          
          SET @ware_count = 0
          SET @ware_company = ''
          BEGIN

            SELECT @v_incr_date = max(dbo.ESTWHUPDATE.LASTMAINTDATE)
              FROM dbo.ESTWHUPDATE

            SELECT @ware_company = upper(dbo.ORGLEVEL.ORGLEVELDESC)
              FROM dbo.ORGLEVEL
              WHERE (dbo.ORGLEVEL.ORGLEVELKEY = 1)

            IF (@ware_company <> 'CONSUMER')
              BEGIN
                BEGIN
                  DECLARE 
                    @cursor_row$BOOKKEY$2 integer,
                    @cursor_row$PRINTINGKEY$2 integer,
                    @cursor_row$ESTKEY$2 integer                  

                  DECLARE 
                    warehouseestimate CURSOR LOCAL 
                     FOR 
                      SELECT DISTINCT eb.BOOKKEY, eb.PRINTINGKEY, we.ESTKEY
                        FROM dbo.ESTBOOK eb, dbo.ESTWHUPDATE we
                        WHERE (eb.ESTKEY = we.ESTKEY)
                  

                  OPEN warehouseestimate

                  FETCH NEXT FROM warehouseestimate
                    INTO @cursor_row$BOOKKEY$2, @cursor_row$PRINTINGKEY$2, @cursor_row$ESTKEY$2

                  WHILE  NOT(@@FETCH_STATUS = -1)
                    BEGIN

                      IF (@cursor_row$BOOKKEY$2 > 0)
                        SET @ware_bookkey = @cursor_row$BOOKKEY$2
                      ELSE 
                        SET @ware_bookkey = 0

                      IF (@cursor_row$PRINTINGKEY$2 > 0)
                        SET @ware_printingkey = @cursor_row$PRINTINGKEY$2
                      ELSE 
                        SET @ware_printingkey = 0

                      IF (@@FETCH_STATUS = -1)
                        BEGIN

                          INSERT INTO dbo.WHERRORLOG
                            (
                              dbo.WHERRORLOG.LOGKEY, 
                              dbo.WHERRORLOG.WAREHOUSEKEY, 
                              dbo.WHERRORLOG.ERRORDESC, 
                              dbo.WHERRORLOG.ERRORFUNCTION, 
                              dbo.WHERRORLOG.LASTUSERID, 
                              dbo.WHERRORLOG.LASTMAINTDATE
                            )
                            VALUES 
                              (
                                CAST( @ware_logkey AS varchar(30)), 
                                CAST( @ware_warehousekey AS varchar(30)), 
                                'No Estimate rows', 
                                'Stored procedure datawarehouse_estimate', 
                                'WARE_STORED_PROC', 
                                @ware_system_date
                              )

                          BREAK 
                        END

                      DELETE FROM dbo.WHEST
                        WHERE (dbo.WHEST.ESTKEY = @cursor_row$ESTKEY$2)

                      DELETE FROM dbo.WHESTCOST
                        WHERE (dbo.WHESTCOST.ESTKEY = @cursor_row$ESTKEY$2)

                      /* whest */
                      EXEC dbo.DATAWAREHOUSE_ESTVERSION @ware_bookkey, @ware_printingkey, @cursor_row$ESTKEY$2, @ware_company, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* incremental P and L */

                      EXEC dbo.DATAWAREHOUSE_WHEST_BASE @cursor_row$ESTKEY$2, @ware_company, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      FETCH NEXT FROM warehouseestimate
                        INTO @cursor_row$BOOKKEY$2, @cursor_row$PRINTINGKEY$2, @cursor_row$ESTKEY$2

                    END

                  CLOSE warehouseestimate

                  DEALLOCATE warehouseestimate

                END

                DELETE FROM dbo.ESTWHUPDATE
                  WHERE (dbo.ESTWHUPDATE.LASTMAINTDATE <= @v_incr_date)

              END

            IF (cursor_status(N'local', N'warehouseestimate') = 1)
              BEGIN
                CLOSE warehouseestimate
                DEALLOCATE warehouseestimate
              END

          END
      END
go
grant execute on datawarehouse_estimate_incr  to public
go
