IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'datawarehouse_whtitlecatalog')
BEGIN
  DROP  Procedure  datawarehouse_whtitlecatalog
END
GO

  CREATE 
    PROCEDURE dbo.datawarehouse_whtitlecatalog 
        @ware_bookkey integer,
        @ware_logkey integer,
        @ware_warehousekey integer,
        @ware_system_date datetime
    AS
      BEGIN
          DECLARE 

            @ware_count integer,
            @c_sql nvarchar(4000),
            @cursor_row$CATALOGKEY integer,
            @cursor_row$CATALOGTITLE varchar(50),
            @cursor_row$DESCRIPTION varchar(100),
            @cursor_row$CATALOGTYPECODE integer,
            @cursor_row$PUBMONTH datetime          
          SET @ware_count = 1
          SET @c_sql = ''
          BEGIN

            DELETE FROM dbo.WHTITLECATALOG
              WHERE (dbo.WHTITLECATALOG.BOOKKEY = @ware_bookkey)

            INSERT INTO dbo.WHTITLECATALOG
              (dbo.WHTITLECATALOG.BOOKKEY, dbo.WHTITLECATALOG.LASTUSERID, dbo.WHTITLECATALOG.LASTMAINTDATE)
              VALUES (@ware_bookkey, 'WARE_STORED_PROC', @ware_system_date)


            BEGIN

              DECLARE 
                @cursor_row$CATALOGKEY$2 integer,
                @cursor_row$CATALOGTITLE$2 varchar(50),
                @cursor_row$DESCRIPTION$2 varchar(100),
                @cursor_row$CATALOGTYPECODE$2 integer,
                @cursor_row$PUBMONTH$2 datetime              

              DECLARE 
                warehousewhtitlecatalog CURSOR LOCAL 
                 FOR 
                  SELECT DISTINCT 
                      c.CATALOGKEY, 
                      isnull(c.CATALOGTITLE, '') AS CATALOGTITLE, 
                      isnull(c.DESCRIPTION, '') AS DESCRIPTION, 
                      c.CATALOGTYPECODE, 
                      isnull(c.PUBMONTH, '') AS PUBMONTH
                    FROM dbo.BOOKCATALOG b, dbo.CATALOGSECTION cs, dbo.CATALOG c
                    WHERE ((b.BOOKKEY = @ware_bookkey) AND 
                            (b.SECTIONKEY = cs.SECTIONKEY) AND 
                            (cs.CATALOGKEY = c.CATALOGKEY))
                  ORDER BY c.CATALOGTYPECODE, pubmonth, catalogtitle
              

              OPEN warehousewhtitlecatalog

              FETCH NEXT FROM warehousewhtitlecatalog
                INTO 
                  @cursor_row$CATALOGKEY$2, 
                  @cursor_row$CATALOGTITLE$2, 
                  @cursor_row$DESCRIPTION$2, 
                  @cursor_row$CATALOGTYPECODE$2, 
                  @cursor_row$PUBMONTH$2


              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  IF (@@FETCH_STATUS = -1)
                    BREAK 

                  /*  currently only using catalogtypecode =1, retail, to add others just repeat below */

                  IF (@cursor_row$CATALOGTYPECODE$2 = 1)
                    IF (@ware_count <= 20)
                      BEGIN

                        SET @c_sql = ''
                        set @c_sql = N'update whtitlecatalog set retailcatalogtitle' + isnull(CAST( @ware_count AS varchar(100)), '') + ' = ' + char(39) + '1' + char(39) + ',' + ' retailcatalogdescription' + isnull(CAST( @ware_count AS varchar(100)), '') + ' = ' + char(39) + '2' + char(39) + ',' +  ' retailcatalogkey' + isnull(CAST( @ware_count AS varchar(100)), '') + ' = ' + char(39) + '3' + char(39) + '  where bookkey= ' + isnull(CAST( @ware_bookkey AS varchar(100)), '')
                        EXECUTE sp_executesql @c_sql


                        IF (@@ROWCOUNT = 0)
                          BEGIN
                            INSERT INTO dbo.WHERRORLOG
                              (
                                dbo.WHERRORLOG.LOGKEY, 
                                dbo.WHERRORLOG.WAREHOUSEKEY, 
                                dbo.WHERRORLOG.ERRORDESC, 
                                dbo.WHERRORLOG.ERRORSEVERITY, 
                                dbo.WHERRORLOG.ERRORFUNCTION, 
                                dbo.WHERRORLOG.LASTUSERID, 
                                dbo.WHERRORLOG.LASTMAINTDATE
                              )
                              VALUES 
                                (
                                  CAST( @ware_logkey AS varchar(100)), 
                                  CAST( @ware_warehousekey AS varchar(100)), 
                                  'Unable to insert whtitlecatalog', 
                                  ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(100)), '')), 
                                  'Stored procedure datawarehouse_whtitlecatalog', 
                                  'WARE_STORED_PROC', 
                                  @ware_system_date
                                )
                          END

                        SET @ware_count = (@ware_count + 1)

                      END

                  FETCH NEXT FROM warehousewhtitlecatalog
                    INTO 
                      @cursor_row$CATALOGKEY$2, 
                      @cursor_row$CATALOGTITLE$2, 
                      @cursor_row$DESCRIPTION$2, 
                      @cursor_row$CATALOGTYPECODE$2, 
                      @cursor_row$PUBMONTH$2

                END

              CLOSE warehousewhtitlecatalog

              DEALLOCATE warehousewhtitlecatalog

            END

            /*  FETCH LOOP  */

            IF (cursor_status(N'local', N'warehousewhtitlecatalog') = 1)
              BEGIN
                CLOSE warehousewhtitlecatalog
                DEALLOCATE warehousewhtitlecatalog
              END

          END
      END
go
grant execute on datawarehouse_whtitlecatalog  to public
go
